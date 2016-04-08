import QtQuick 2.2
import QtWebSockets 1.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.XmlListModel 2.0
import QtQml.Models 2.1
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0

import "schedule.js" as Schedule
import "tweet.js" as Tweet
import "emblem.js" as Emblem

ColumnLayout {

    id: layout
    spacing: 2
    width:  414
    height: 736

    onVisibleChanged: {
        console.log('visbility changed')
    }
    onActiveFocusChanged: {
        console.log('active focus changed')
    }

    ColumnLayout {

        spacing: 2
        Layout.fillHeight: false
        anchors.top: parent.top
        Layout.preferredWidth: parent.width

        CheckBox {
            text: qsTr("Debug")
            checked: true
        }
        TextArea {
            id: messageBox
            Layout.preferredWidth: parent.width
        }

    }

    SplitView {

        anchors.top: previousItem(this).bottom
        Layout.preferredWidth: parent.width

        Label {
            width: 280
            Component.onCompleted: {
                Tweet.addListener(this)
            }
            function received(msg) {
                this.text = msg.league
            }
        }

        ColumnLayout {

            anchors.top: parent.bottom
            anchors.right: parent.right

            Label {
                height: 64
                Component.onCompleted: {
                    Tweet.addListener(this)
                }
                function received(msg) {
                    try {
                        this.text = msg.team
                        this.visible = true
                    } catch (err) {
                        console.log('no team')
                        this.visible = false
                    }
                }
            }

            Label {
                Component.onCompleted: {
                    Tweet.addListener(this)
                }
                function received(msg) {
                    this.text = msg.twitter
                }
            }
        }

    }

    Flickable {
        width: parent.width
        anchors.top: previousItem(this).bottom
        Text {
            wrapMode: Text.Wrap
            width: parent.width
            Component.onCompleted: {
                Tweet.addListener(this)
            }
            function received(msg) {
                this.text = msg.tweet_txt
            }
        }
    }

    Rectangle {
        id: mask
        anchors.bottom: button.top
        width: parent.width / 2
        height: parent.width / 2
        radius: 20
        color: "transparent"
        Image {
            id: image

            Component.onCompleted: {
                Tweet.addListener(this)
            }            
            function received(msg) {
                console.log('image!', 'http://' + msg.curator_site + '/' + msg.league + '/large/' + msg.twitter + '.png')
                this.source = 'http://' + msg.curator_site + '/' + msg.league + '/large/' + msg.twitter + '.png'
            }
        }

        OpacityMask {
            anchors.fill: mask
            source: image
            maskSource: mask
        }
    }

    Button {
        id: button
        anchors.bottom: button.parent.bottom
        x: 40
        y: 10
        text: qsTr("Connect")
        onClicked: {
            if ( !socket.active ) {
                socket.active = true;
                button.text = "Connecting..."
            } else if (button.text === "Connected") {
                //spring.start()
                button.text = "Closing";
                socket.active = false;
            } else {
                button.text = "Hold On";
            }
        }
    }

    WebSocket {
        id: socket

        url: 'ws://service.athleets.com:8080'
        //url: 'ws://localhost:8080'
        onTextMessageReceived: {
            console.log('received message')
            messageBox.text = message
            try {
                var json = JSON.parse(message)
                if ( json.tweet_txt ) {
                    Tweet.receivedJson(json)
                } else {
                    console.log('msg:', Object.keys(json))
                }
            } catch (err) {
                console.log('error casting json:', err)
            }
        }
        onStatusChanged: if (socket.status == WebSocket.Error) {
            console.log('Error:', socket.errorString)
        } else if (socket.status == WebSocket.Open) {
            console.log('Open!', socket.status)
            button.text = "Connected"
            var outgoing = JSON.stringify(JSON.parse('{ "data": "data", "webrole": "data"}'))
            console.log('attempt send:', outgoing)
            socket.sendTextMessage(outgoing);
            console.log('sent:', outgoing);
        } else if (socket.status == WebSocket.Closed) {
            console.log('Closed!', socket.status)
            button.text = "Connect"
            messageBox.text += "\nSocket closed"
        }
    }

    //if item is not parented, -1 is returned
    function itemIndex(item) {
        if (item.parent == null)
            return -1
        var siblings = item.parent.children
        for (var i = 0; i < siblings.length; i++)
            if (siblings[i] == item)
                return i
        return -1 //will never happen
    }
    //returns null, if the item is not parented, or is the first one
    function previousItem(item) {
        if (item.parent == null)
            return null
        var index = itemIndex(item)
        return (index > 0)? item.parent.children[itemIndex(item) - 1]: null
    }
    //returns null, if item is not parented, or is the last one
    function nextItem(item) {
        if (item.parent == null)
            return null

        var index = itemIndex(item)
        var siblings = item.parent.children

        return (index < siblings.length - 1)? siblings[index + 1]: null
    }
}
