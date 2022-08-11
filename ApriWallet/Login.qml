import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.0
import Admin_


Window {
    width: 800
    height: 600
    maximumWidth: 800
    minimumWidth: 800
    maximumHeight: 600
    minimumHeight: 600
    flags: Qt.FramelessWindowHint
    signal signalAuthentication
    signal signalBalance
    signal signalExit
    property string address
    property string privKey
    visible: true
    title: qsTr("ApriWallet")
    id:loginWindow
    Rectangle
    {
        id: area
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        gradient: Gradient {
                GradientStop { position: 0.93151; color: "#49A57B" }
                GradientStop { position: 0.21005; color: "#FCC58E" }

                GradientStop {
                    position: 0
                    color: "#fcc58e"
                }

                GradientStop {
                    position: 0.52283
                    color: "#49a57b"
                }
        }
        Image {
            id: logo
            x: 300
            y: 170
            width: 200
            height: 100
            source: "qrc:/src/logo.png"
            fillMode: Image.PreserveAspectCrop
        }
        TextInput {
        id: addressInput
        x: 170
        y: 269
        width: 570
        height: 26
        opacity: 1
        text: qsTr("")
        font.pixelSize: 16
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.kerning: false
        font.preferShaping: true
        autoScroll: false
        font.family: "Helvetica"
        }
        Rectangle {
            id: addressLine
            x: 170
            y: 297
            width: 570
            height: 1
            color: "#000000"
        }

        Label {
            id: addressLabel
            x: 53
            y: 275
            text: qsTr("Address:")
            font.pointSize: 15
            font.family: "Helvetica"
        }

        Label {
            id: keyLabel
            x: 53
            y: 337
            text: qsTr("Private key:")
            font.pointSize: 15
            font.family: "Helvetica"
        }

        TextInput {
            id: keyInput
            x: 170
            y: 334
            width: 570
            height: 30
            opacity: 1
            text: qsTr("")
            font.pixelSize: 16
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            autoScroll: false
            font.family: "Helvetica"
        }
        Rectangle {
            id: keyLine
            x: 170
            y: 363
            width: 570
            height: 1
            color: "#000000"
        }
        Button {
            id: logInButton
            x: 363
            y: 417
            width: 75
            height: 40
            font.family: "Helvetica"
            font.pointSize: 11
            background: Rectangle {
                implicitWidth: 90
                implicitHeight: 30
                opacity: enabled ? 1 : 0.3
                color: logInButton.down?"#FDD8B3":"#FCC58E"
                border.width: 1
                radius: 4

            }
            text: qsTr("Log in")
            hoverEnabled: false
            focusPolicy: Qt.StrongFocus
            onClicked: {
                if(admin.validateAdress(addressInput.text))
                {
                    privKey = keyInput.text
                    address = addressInput.text
                    loginWindow.signalAuthentication()
                    loginWindow.signalBalance()
                    addressInput.text=""
                    keyInput.text=""
                }
                else
                {
                    addressInput.text = "Is not a address"
                }
            }
        }

        Button {
            id: exitButton
            x: 363
            y: 463
            width: 75
            height: 40
            text: qsTr("Exit")
            focusPolicy: Qt.StrongFocus
            hoverEnabled: false
            background: Rectangle {
                opacity: enabled ? 1 : 0.3
                color: exitButton.down?"#FDD8B3":"#FCC58E"
                radius: 4
                border.width: 1
                implicitWidth: 90
                implicitHeight: 30
            }
            font.pointSize: 11
            font.family: "Helvetica"
            onClicked: signalExit()
        }

    }
}
