import QtQuick 2.3
import QtQuick.Layouts 1.2

import QtQuick.Controls 1.4

Item {

    ColumnLayout {

        spacing: 2
        Layout.fillHeight: false
        width: parent.width

        RowLayout {

            CheckBox {

                onClicked: {
                    messageBox.visible = !messageBox.visible
                }

                text: qsTr("Debug")
                checked: true

            }

            Button {
                id: connect
                anchors.right: window.right
                text: {
                    if ( !socket.active ) {
                        return "Connect"
                    } else {
                        return "Disconnect"
                    }
                }
                onClicked: {
                    if ( !socket.active ) {
                        socket.active = true;
                        connect.text = "Connecting..."
                    } else if (connect.text === "Disconnect") {
                        //spring.start()
                        connect.text = "Closing";
                        socket.active = false;
                    } else {
                        connect.text = "Hold On";
                    }
                }
            }

            Label {
                horizontalAlignment: "AlignRight"
                verticalAlignment: Text.AlignVCenter
                text: "Audio"
            }

            ComboBox {
                id: audio
                //currentIndex: 0
                model: ["On", "Notify", "Off"]

            }

        }

        TextArea {
            id: messageBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: previousItem(this).bottom
        }
    }

}
