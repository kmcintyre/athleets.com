import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

StatusBar {
    RowLayout {
        width: window.width
        Label {
            color: "blue"
            text: {
                settings.autoconnect ? "Connecting" : "Connect"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log('Bottom Left')
                }
            }
        }
        Label {
            text: settings.streaming ? "Sites" : "Stream"
            anchors.right: parent.right
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    settings.streaming = !settings.streaming
                    var stream = stackView.find(function (item, index) { return item.objectName == 'stream'; });
                    if ( !stream ) {
                        stackView.push({item:Qt.resolvedUrl("stream.qml")});
                    } else {
                        console.log(stream)
                        stackView.pop();
                    }

                }
            }
        }
    }
}
