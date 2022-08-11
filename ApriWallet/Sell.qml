import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls
import QtQuick.Dialogs
import Admin_
Window
{
    width: 800
    height: 600
    maximumWidth: 800
    minimumWidth: 800
    maximumHeight: 600
    minimumHeight: 600
    id:sellWindow
    flags: Qt.FramelessWindowHint
    property string address
    property string privKey
    property string rate
    property string currentTokenBalance
    property string currentEtherBalance
    signal signalExit
    signal signalLoad
    signal signalLogOut
    Admin_{
            id:admin
            onSignalError:
            {
                messageDialog.text = error
                messageDialog.visible = true
            }
        }
    MessageDialog {
            id: messageDialog
            title: "Transaction Error"
        }
    onSignalLoad:
    {
        currentEtherBalance = admin.getEtherBalance(address.text)
        currentTokenBalance = admin.getTokenBalance(address.text)
        rate = admin.getExchangeRate()
        if(ethAmount.text != currentEtherBalance ||
            aprAmount.text != currentTokenBalance ||
            rateLabel.text != "1 APR = " + rate + " ETH")
                {
                    ethAmount.text = currentEtherBalance
                    aprAmount.text = currentTokenBalance
                    rateLabel.text = "1 APR = " + rate + " ETH"
                    admin.updateUserDatabase(address.text)
                }
    }
    color: "#6cad90"
    title: qsTr("ApriWallet")
    Rectangle {
        id: leftArea
        x: 0
        y: 0
        width: 275
        height: 600
        color: "#6CAD90"


    Image {
        id: logo
        x: 38
        y: 30
        width: 200
        height: 100
        source: "qrc:/src/logo.png"
        fillMode: Image.PreserveAspectCrop
    }

    Button {
        id: logOutButton
        x: 95
        y: 145
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
        onClicked: sellWindow.signalLogOut()

    }

    Rectangle {
        id: loginRectangle
        x: 38
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
                elide: Text.ElideRight
                text: sellWindow.address
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
        x: 275
        y: 0
        width: 525
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
            id:ethAmount
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
            x: 171
            y: 195
            text: qsTr("Sell Apri::Token")
            font.pointSize: 20
        }

        Rectangle {
            id: amountRectangle
            x: 31
            y: 264
            width: 218
            height: 124
            color: "#6cad90"
            radius: 15

            Label {
                id: sellLabel
                x: 27
                y: 27
                text: qsTr("Amount to sell")
                font.family: "Helvetica"
                font.pointSize: 13
            }
                TextInput {
                id: sellInput
                x: 40
                y: 56
                width: 76
                height: 30
                opacity: 1
                text: qsTr("")
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                autoScroll: false
                font.family: "Helvetica"
                }
                Rectangle {
                    id: line
                    x: 27
                    y: 83
                    width: 110
                    height: 1
                    color: "#000000"
                }

        }

        Rectangle {
            id: priceRectangle
            x: 278
            y: 264
            width: 218
            height: 124
            color: "#6cad90"
            radius: 15

            Label {
                id: priceLabel
                x: 74
                y: 27
                text: qsTr("You`ll get")
                font.family: "Helvetica"
                font.pointSize: 13
            }

            Image {
                id: priceImage
                x: 69
                y: 54
                width: 40
                height: 40
                source: "qrc:/src/eth-logo.png"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: priceAmount
                x: 117
                y: 63
                text: qsTr("0.00")
                font.family: "Helvetica"
                font.pointSize: 14
            }
        }

        Image {
            id: amountImage
            x: 182
            y: 318
            width: 40
            height: 40
            source: "qrc:/src/apritoken-logo.png"
            fillMode: Image.PreserveAspectFit
        }

        Button {
            id: sellButton
            x: 195
            y: 422
            width: 135
            height: 50
            text: qsTr("sell")
            transformOrigin: Item.Center
            font.family: "Helvetica"
            font.pointSize: 11
            background: Rectangle {
                implicitWidth: 90
                implicitHeight: 30
                opacity: enabled ? 1 : 0.3
                color: sellButton.down?"#73D8A9":"#6CAD8F"
                border.width: 1
                radius: 4
            }
            onClicked: admin.sellTokens(address.text,privKey,sellInput.text,admin.getCurentAmountEtherum(sellInput.text,rate))
            hoverEnabled: false
        }

        Button {
            id: backButton
            x: 195
            y: 478
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
            onClicked:
            {
                sellWindow.signalExit()
                sellInput.text = ""
            }
        }
        Item {
            Timer
            {
                interval: 500; running: true; repeat: true
                            onTriggered:{
                               if(sellInput.text!="")
                               {
                                  priceAmount.text = admin.getCurentAmountEtherum(sellInput.text,rate);
                               }
                       }
            }
        }
        Item {
            Timer {
                interval: 10000; running: true; repeat: true
                onTriggered:{
                if(sellWindow.visible == true && admin.balanceChanged(address.text))
                {
                    sellWindow.signalLoad()
                }
            }
    }}
    }
}
