import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls
import Admin_

 Window{
     width: 800
     height: 600
     maximumWidth: 800
     minimumWidth: 800
     maximumHeight: 600
     minimumHeight: 600
     id:historyWindow
     flags: Qt.FramelessWindowHint
     property string address
     property string currentTokenBalance
     property string currentEtherBalance
     property string currentExchangeRate
     readonly property string adminAddress: "0x3d2Fd6032C933d316E21da7FAE54f32A92e1CD5A"
     readonly property string contractAddress: "0xb5B074a3DCaAbe5635BA4876D3C62E450F90e15C"
     signal signalExit
     signal signalLoad
     signal signalLogOut
     onSignalLoad:
     {
         currentEtherBalance = admin.getEtherBalance(address.text)
         currentTokenBalance = admin.getTokenBalance(address.text)
         currentExchangeRate = admin.getExchangeRate()
         if(ethAmount.text != currentEtherBalance ||
             aprAmount.text != currentTokenBalance ||
             rateLabel.text != "1 APR = " + currentExchangeRate + " ETH")
                 {
                     ethAmount.text = currentEtherBalance
                     aprAmount.text = currentTokenBalance
                     rateLabel.text = "1 APR = "+ currentExchangeRate + " ETH"
                     admin.updateUserDatabase(address.text)
                 }
     }
     Rectangle {
         id: leftArea
         x: 0
         y: 0
         width: 235
         height: 600
         color: "#6CAD90"


     Image {
         id: logo
         x: 16
         y: 31
         width: 200
         height: 100
         source: "qrc:/src/logo.png"
         fillMode: Image.PreserveAspectCrop
     }

     Button {
         id: logOutButton
         x: 79
         y: 137
         width: 75
         height: 40
         font.family: "Helvetica"
         font.pointSize: 11
         background: Rectangle {
             implicitWidth: 90
             implicitHeight: 30
             opacity: enabled ? 1 : 0.3
             color: logOutButton.down?"#FDD8B3":"#FCC58E"
             border.width: 1
             radius: 4
         }
         text: qsTr("Log out")
         hoverEnabled: false
         focusPolicy: Qt.StrongFocus
         onClicked: historyWindow.signalLogOut()

     }

     Rectangle {
         id: loginRectangle
         x: 16
         y: 275
         width: 200
         height: 140
         color: "#FCC58E"
         radius: 10

         Label {
             id: loginLabel
             x: 68
             y: 57
             width: 77
             height: 18
             text: qsTr("my address")
             font.pointSize: 11
             font.family: "Helvetica"
         }

         Rectangle {

             x: 25
             y: 84
             width: 150
             height: 19
             radius: 5
             color: "#FDD8B3"
             Label {
                 id: address
                 anchors.fill: parent
                 text: historyWindow.address
                 elide: Text.ElideRight
                 font.pointSize: 9
             }
         }
         Button{
             id: copyImage
             x: 174
             y: 82
             background: {color:"#FCC58E"}
             width: 22
             height: 22
             icon.source: "qrc:/src/copy.png"
             TextEdit{
                     id: textEdit
                     visible: false
                 }
             Shortcut {
                    sequence: StandardKey.Copy
                }
             onClicked: {
                 textEdit.text = address.text
                 textEdit.selectAll()
                 textEdit.copy()
         }
         }

         Image {
             id: userImage
             x: 32
             y: 52
             width: 32
             height: 23
             source: "qrc:/src/sidebar-user-icon.png"
             fillMode: Image.PreserveAspectFit
         }
     }
     }
     Rectangle {
         id: rightArea
         x: 233
         y: 0
         width: 567
         height: 600
         color: "#D6D6D6"

         Image {
             id: ethImage
             x: 54
             y: 21
             width: 40
             height: 40
             source: "qrc:/src/eth-logo.png"
             fillMode: Image.PreserveAspectFit
         }
         Label
         {
             id: ethAmount
             x: 100
             y: 33
             text: qsTr("0.00")
             font.pointSize: 14
             font.family: "Helvetica"
         }

         Image {
             id: aprImage
             x: 182
             y: 21
             width: 40
             height: 40
             source: "qrc:/src/apritoken-logo.png"
             fillMode: Image.PreserveAspectFit
         }

         Label {
             id: aprAmount
             x: 228
             y: 33
             text: qsTr("0.00")
             font.family: "Helvetica"
             font.pointSize: 14
         }
         Label {
             id: rateLabel
             x: 329
             y: 36
             text: qsTr("1 APR = 0.05 ETH")
             font.pointSize: 13
             font.family: "Helvetica"
         }
         Label {
             id: label
             x: 151
             y: 85
             text: qsTr("Transaction history")
             font.pointSize: 20
         }
         Button {
             id: backButton
             x: 195
             y: 550
             width: 135
             height: 50
             text: qsTr("back")
             transformOrigin: Item.Center
             font.family: "Helvetica"
             font.pointSize: 11
             background: Rectangle {
                 implicitWidth: 90
                 implicitHeight: 30
                 opacity: enabled ? 1 : 0.3
                 color: backButton.down?"#73D8A9":"#6CAD8F"
                 border.width: 1
                 radius: 4
             }
             hoverEnabled: false
             onClicked: historyWindow.signalExit()
         }

         ListView {
             id: listView
             x: 8
             y: 127
             width: 548
             height: 417
             spacing: 5
             clip: true
             delegate: Item {
                 property bool isAdmin: address.text == adminAddress ? true : false
                 property bool isTransfer: (model.from != contractAddress && model.to != contractAddress ) ? true : false
                 property bool isGetting: model.from == contractAddress ? true : false
                 x: 5
                 width: listView.width
                 height: 50

                 Rectangle {
                     color: "#C6D3CD"
                     radius: 15
                     anchors.fill: parent
                    Row{
                         anchors.fill: parent
                         spacing: isAdmin ? 4 : 8
                     Text {
                         text:model.date+" "
                         anchors.verticalCenter: parent.verticalCenter
                         font.bold: true
                         font.pointSize: isAdmin ? 5 : 7
                     }
                     Text {
                         text: admin.informationAboutTransaction(model.from,model.to,isAdmin,isTransfer,isGetting);
                         font.pointSize: isAdmin ? 6 : 9
                         anchors.verticalCenter: parent.verticalCenter
                     }
                     Image {
                         height: parent.height/2
                         width: height
                         anchors.verticalCenter: parent.verticalCenter

                         source: "qrc:/src/apritoken-logo.png"
                     }
                     Text {
                         text:  isTransfer?( isGetting ? "+" + model.tokenValue : "-" + model.tokenValue) : model.tokenValue
                         anchors.verticalCenter: parent.verticalCenter
                     }
                     Image {
                         height: parent.height/2
                         anchors.verticalCenter: parent.verticalCenter
                         visible: isTransfer ? false : true
                         width: height
                         source: "qrc:/src/eth-logo.png"
                     }
                     Text {
                         visible: isTransfer ? false : true
                         text: model.etherValue
                         anchors.verticalCenter: parent.verticalCenter
                     }

                    }



                 }
             }
             model: _myModel
         }
}
     Item {
         Timer {
             interval: 10000; running: true; repeat: true
             onTriggered:{
             if(historyWindow.visible == true && admin.balanceChanged(address.text))
             {
                 historyWindow.signalLoad()
             }
         }
 }}
}
