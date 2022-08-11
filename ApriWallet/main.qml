import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.0
import QtQuick.Dialogs
import Admin_
import "qrc:/crypto-js/encrypt.js" as CryptoJSLib

Window {
    width: 800
    height: 600
    maximumWidth: 800
    minimumWidth: 800
    maximumHeight: 600
    minimumHeight: 600
    visible: !loginWindow.visible
    property string privKey
    signal signalUpdate
    property string currentTokenBalance
    property string currentEtherBalance
    property string currentExchangeRate
    readonly property string adminAddress: "0x3d2Fd6032C933d316E21da7FAE54f32A92e1CD5A"
    readonly property string key: "TvbP5KVdHjnFKk71"
    title: qsTr("ApriWallet")
    id:mainWindow
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
        onClicked: loginWindow.show()

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
                text: qsTr("")
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

    Rectangle {
        id: adminRectangle
        x: 38
        y: 433
        width: 200
        height: 138
        color: "#fcc58e"
        visible: address.text == adminAddress ? true : false
        radius: 10
        Label {
            id: adminLabel
            x: 25
            y: 37
            width: 150
            height: 18
            text: qsTr("Set Exchange Rate")
            horizontalAlignment: Text.AlignHCenter
            font.family: "Helvetica"
            font.pointSize: 11
        }

        Rectangle {
            x: 25
            y: 63
            width: 150
            height: 19
            color: "#fdd8b3"
            radius: 5
            TextInput {
                id: exchangeRate
                text: qsTr("")
                horizontalAlignment: TextInput.AlignHCenter
                anchors.fill: parent
                font.pointSize: 9
            }
        }
        Button
        {
            id: setRateButton
            x: 67
            y: 92
            width: 67
            height: 30
            font.family: "Helvetica"
            font.pointSize: 9
            background: Rectangle {
                implicitWidth: 90
                implicitHeight: 30
                opacity: enabled ? 1 : 0.3
                color: setRateButton.down?"#73D8A9":"#6CAD8F"
                radius: 4
            }
            text: qsTr("Set")
            hoverEnabled: false
            focusPolicy: Qt.StrongFocus
            onClicked: {
                admin.setExchangeRate(exchangeRate.text)
                exchangeRate.text = ""
            }
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

        Label {
            x: 51
            y: 52
            text: qsTr("My account balance")
            font.family: "Helvetica"
            font.pointSize: 11
        }

        Label {
            id: rateLabel
            x: 340
            y: 52
            text: qsTr("1 APR = 0.05 ETH")
            font.pointSize: 11
            font.family: "Helvetica"
        }
        Rectangle {
                    id: coinRectangle
                    x: 270
                    y: 80
                    width: 236
                    height: 200
                    color: "#49a57b"
                    gradient: Gradient {
                            GradientStop { position: 0.0; color: "#49A57B" }
                            GradientStop { position: 1.0; color: "#FCC58E" }
                            orientation: Gradient.Horizontal
                        }
                    radius: 10

                    Image {
                        id: aprLogo
                        x: 89
                        y: 22
                        width: 60
                        height: 56
                        source: "qrc:/src/apritoken-logo.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Label {
                        id: amountApr
                        x: 58
                        y: 105
                        text: qsTr("0.000 APR")
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 20
                    }}
                    Rectangle {
                        id: etherumRectangle
                        x: 26
                        y: 80
                        width: 236
                        height: 200
                        gradient: Gradient {
                                GradientStop { position: 1.0; color: "#A064BC" }
                                GradientStop { position: 0.0; color: "#838383" }
                                orientation: Gradient.Horizontal
                            }
                        radius: 10

                    Image {
                        id: ethLogo
                        x: 88
                        y: 23
                        width: 60
                        height: 56
                        source: "qrc:/src/eth-logo.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    Label{
                        id: amountEth
                        x: 64
                        y: 105
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("0.000 ETH")
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 20
                    }

                    }

            Button {
                id: buyButton
                x: 195
                y: 327
                width: 135
                height: 50
                text: qsTr("buy")
                transformOrigin: Item.Center
                font.family: "Helvetica"
                font.pointSize: 11
                background: Rectangle {
                    implicitWidth: 90
                    implicitHeight: 30
                    opacity: enabled ? 1 : 0.3
                    color: address.text == adminAddress ? "#D6D6D6":(buyButton.down?"#73D8A9":"#6CAD8F")
                    border.width: 1
                    radius: 4
                }
                hoverEnabled: false
                onClicked: {
                    if(address.text != adminAddress)
                    {
                        buyWindow.address = address.text
                        buyWindow.privKey = CryptoJSLib.encryptAES(mainWindow.privKey,key)
                        buyWindow.show()
                        mainWindow.hide()
                        buyWindow.signalLoad()
                    }
                }
            }

            Button {
                id: sellButton
                x: 195
                y: 383
                width: 135
                height: 50
                text: qsTr("sell")
                font.family: "Helvetica"
                font.pointSize: 11
                background: Rectangle {
                    implicitWidth: 90
                    implicitHeight: 30
                    opacity: enabled ? 1 : 0.3
                    color: address.text == adminAddress ? "#D6D6D6":(sellButton.down?"#73D8A9":"#6CAD8F")
                    border.width: 1
                    radius: 4
                }
                hoverEnabled: false
                onClicked: {
                    if(address.text != adminAddress)
                    {
                        sellWindow.address = address.text
                        sellWindow.privKey = CryptoJSLib.encryptAES(mainWindow.privKey,key)
                        sellWindow.show()
                        mainWindow.hide()
                        sellWindow.signalLoad()
                    }
                }
            }

            Button {
                id: sendButton
                x: 195
                y: 439
                width: 135
                height: 50
                text: qsTr("send")
                font.family: "Helvetica"
                font.pointSize: 11
                background: Rectangle {
                    implicitWidth: 90
                    implicitHeight: 30
                    opacity: enabled ? 1 : 0.3
                    color: sendButton.down?"#73D8A9":"#6CAD8F"
                    border.width: 1
                    radius: 4
                }
                hoverEnabled: false
                onClicked: {
                    sendWindow.privKey = CryptoJSLib.encryptAES(mainWindow.privKey,key)
                    sendWindow.address = address.text
                    sendWindow.show()
                    mainWindow.hide()
                    sendWindow.signalLoad()
                }
            }

            Button {
                id: historyButton
                x: 195
                y: 495
                width: 135
                height: 50
                text: qsTr("history")
                font.family: "Helvetica"
                font.pointSize: 11
                background: Rectangle {
                    implicitWidth: 90
                    implicitHeight: 30
                    opacity: enabled ? 1 : 0.3
                    color: historyButton.down?"#73D8A9":"#6CAD8F"
                    border.width: 1
                    radius: 4
                }
                hoverEnabled: false
                onClicked: {
                    historyWindow.address = address.text
                    historyWindow.show()
                    mainWindow.hide()
                    _myModel.initialize(address.text)
                    historyWindow.signalLoad() 
                }
            }

            Image {
                id: buyImage
                x: 210
                y: 346
                width: 15
                height: 15
                source: "qrc:/src/plus.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: sellImage
                x: 213
                y: 402
                width: 15
                height: 15
                source: "qrc:/src/minus.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: sendImage
                x: 210
                y: 458
                width: 15
                height: 15
                source: "qrc:/src/send.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: historyImage
                x: 209
                y: 513
                width: 15
                height: 15
                source: "qrc:/src/history.png"
                fillMode: Image.PreserveAspectFit
            }

    }

    onSignalUpdate:
    {
        currentEtherBalance = admin.getEtherBalance(address.text)
        currentTokenBalance = admin.getTokenBalance(address.text)
        currentExchangeRate = admin.getExchangeRate()
        if(amountApr.text != currentTokenBalance + " APR" ||
           amountEth.text != currentEtherBalance + " ETH" ||
           rateLabel.text != "1 APR = "+ currentExchangeRate +" ETH")
        {
           amountApr.text = currentTokenBalance + " APR"
           amountEth.text = currentEtherBalance + " ETH"
           rateLabel.text = "1 APR = "+ currentExchangeRate +" ETH"
           admin.updateUserDatabase(address.text)
        }
    }
    Buy{
        x: mainWindow.x
        y: mainWindow.y
        id:buyWindow
        onSignalExit: {

                    buyWindow.close()
                    mainWindow.show()
                    mainWindow.signalUpdate()
                }
        onSignalLogOut:
        {
            buyWindow.close()
            loginWindow.show()
        }
    }
    Sell{
        x: mainWindow.x
        y: mainWindow.y
        id:sellWindow
        onSignalExit: {
                    sellWindow.close()
                    mainWindow.show()
                    mainWindow.signalUpdate()
                }
        onSignalLogOut:
        {
            sellWindow.close()
            loginWindow.show()
        }
    }
    Send{
        x: mainWindow.x
        y: mainWindow.y
        id:sendWindow
        onSignalExit: {
                    sendWindow.close()
                    mainWindow.show()
                    mainWindow.signalUpdate()
                }
        onSignalLogOut:
        {
            sendWindow.close()
            loginWindow.show()
        }
    }
    History{
        x: mainWindow.x
        y: mainWindow.y
        id:historyWindow

        onSignalExit: {
                    historyWindow.close()
                    mainWindow.show()
                    mainWindow.signalUpdate()
                }
        onSignalLogOut:
        {
            historyWindow.close()
            loginWindow.show()
        }
    }
    Login{
        x: mainWindow.x
        y: mainWindow.y
        id:loginWindow
        onSignalAuthentication:
        {
            loginWindow.close()
            mainWindow.show()
            address.text = loginWindow.address
            mainWindow.privKey = loginWindow.privKey
        }
        onSignalBalance:
        {
            mainWindow.signalUpdate()
        }
        onSignalExit:
        {
            Qt.callLater(Qt.quit)
        }
    }
    Item {
        Timer {
            interval: 10000; running: true; repeat: true
            onTriggered:{

            if(mainWindow.visible == true && admin.balanceChanged(address.text))
            {
                mainWindow.signalUpdate()
            }
        }
}}
}


