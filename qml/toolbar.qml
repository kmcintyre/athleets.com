import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import QtMultimedia 5.0

import "tweet.js" as Tweet

GridLayout {
    width: window.width
    columns: 3
    Label {
        text: qsTr('Visit:' + settings.visit)
        font.pointSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var schedule = stackView.find(function (item, index) { return item.objectName == 'schedule'; });
                if ( !schedule ) {
                    stackView.push({item:Qt.resolvedUrl("schedule.qml")});
                } else {
                    console.log(schedule)
                    stackView.pop();
                }
            }
        }
    }
    Label {
        horizontalAlignment: Text.AlignHCenter
        CheckBox {
            onClicked: {
                settings.debug = !settings.debug
            }
            checked: settings.debug
            transform: Translate { x: -25 }
        }
        Text {
            text:qsTr("Debug")
        }
    }
    Label {
        color: "green"
        horizontalAlignment: Text.AlignRight
        text: "Top Right"
        anchors.right: parent.right
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log('Top Right')
            }
        }
    }
    TextArea {
        objectName: "debug"
        Layout.columnSpan: 3
        visible: settings.debug
        anchors.left: parent.left
        anchors.right: parent.right
        Component.onCompleted: {
            Tweet.addListener(this);
        }
        function received(msg) {
            text = JSON.stringify(msg);
        }
    }
    MediaPlayer {
        id: mediaPlayer
        volume: 0.2
        onPlaybackStateChanged: {
            console.log('   RESET:', this.playbackState)
        }
        onError: {
            console.log('Error:', errorString)
        }
    }

}
