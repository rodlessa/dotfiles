import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: 1920
    height: 1080

    Image {
        id: background
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

            TextField {
            id: passwordField
            anchors.centerIn: parent
            width: 400
            echoMode: TextInput.Password
            placeholderText: "Password"
            font.pixelSize: 18
            focus: true
            onAccepted: {
                console.log("Login triggered, password:", passwordField.text)
                // Replace console.log with real login call if possible
              }

          background: Rectangle{
            color: "#66000000"
            radius: 10
            border.color: "#ffffff"
            border.width: 1
          }
        }
}

