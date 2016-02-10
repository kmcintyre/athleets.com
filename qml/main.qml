import QtQuick 2.3
import QtQuick.Window 2.2

import QtWebSockets 1.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.XmlListModel 2.0
import QtQml.Models 2.1
import QtGraphicalEffects 1.0

import "schedule.js" as Schedule
import "tweet.js" as Tweet
import "emblem.js" as Emblem

Window {
    id: window
    visible: true
    width: 414
    height: 736

    ColumnLayout {

        spacing: 2
        Layout.fillHeight: false
        anchors.top: parent.top
        width: parent.width
        CheckBox {

            onClicked: {
                messageBox.visible = !messageBox.visible
            }

            text: qsTr("Debug")
            checked: true

        }

        TextArea {
            id: messageBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: previousItem(this).bottom
        }

    }

    SplitView {

        anchors.top: previousItem(this).bottom
        width: parent.width

        Label {
            anchors.top: previousItem(this).bottom
            color: "red"
            width: 200
            Component.onCompleted: {
                Tweet.addListener(this)
            }
            function received(msg) {
                console.log('twitter:', msg.twitter)
                this.visible = true
                this.text = msg.twitter
            }
        }

        ColumnLayout {


            anchors.top: parent.top
            anchors.left: previousItem(this).right

            SplitView {
                width: window.width/2
                Image {
                    width: window.width/4
                    height: window.width/(4*1.4)
                    id: team
                }
                Image {
                    width: window.width/4
                    height: window.width/(4*1.4)
                    id: league
                }
            }

            Label {

                Component.onCompleted: {
                    Tweet.addListener(this)
                }

                function received(msg) {
                    league.source = 'http://dev.' + msg.curator_site + '/' + msg.league + '/logo_standard/' + msg.league + '.svg';
                    if (!msg.team) {
                        console.log('no team!')
                        team.source = ''
                    } else {
                        try {
                            var tid = msg.team.toLowerCase().replace(/  /gi,' ').replace(/ /gi,'_').replace(/[^a-z0-9_]/gi,'');
                            console.log('team id:', tid)
                            team.source = 'http://dev.' + msg.curator_site + '/' + msg.league + '/logo_standard/' + tid + '.svg';
                        } catch (err) {
                            console.log('MISSING TEAM:' + tid)
                        }



                    }
                }
            }

            Label {
                width: window.width/2
                color: 'green'
                Component.onCompleted: {
                    Tweet.addListener(this)
                }
                function received(msg) {
                    this.text = msg.league
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

    Canvas {
        anchors.bottom: avi.top
        width: parent.width / 2
        height: parent.width / 2
        id: canvas
        antialiasing: true
        property int corner: 10
        onImageLoaded : requestPaint();
        onPaint: drawWithCorners();
        function drawWithCorners() {

            var ctx = canvas.getContext("2d");
            console.log('          DID !', avi.source)
            try {
                ctx.drawImage(avi.source, 0, 0, canvas.width, canvas.height)
            } catch (err) {
                console.log('error:', err)
            }

            ctx.beginPath()
            ctx.lineWidth = canvas.corner;
            ctx.strokeStyle = 'white'
            ctx.moveTo(0, 0)
            ctx.lineTo(canvas.width, 0)
            ctx.lineTo(canvas.width, canvas.height)
            ctx.lineTo(0, canvas.height)
            ctx.lineTo(0, 0)
            ctx.lineJoin = 'round'
            ctx.stroke()
            ctx.restore()

            ctx.beginPath()
            ctx.lineWidth = canvas.corner;
            ctx.strokeStyle = avi.rgba
            ctx.moveTo(corner, corner)
            ctx.lineTo(canvas.width-corner, corner)
            ctx.lineTo(canvas.width-corner, canvas.height-corner)
            ctx.lineTo(corner, canvas.height-corner)
            ctx.lineTo(corner, corner)
            ctx.lineJoin = 'round'
            ctx.stroke()
            ctx.restore()
         }
    }

    Column {
        id: avi
        anchors.bottom: button.top
        anchors.bottomMargin: 12
        property string source: ''
        property string rgba: 'rgba(0,0,0,0.7)'
        Slider {
            id: nCtrl
            value: canvas.corner
            minimumValue: 1
            maximumValue: 20
        }
        Component.onCompleted: {
            Tweet.addListener(this)
        }
        function received(msg) {
            var source = 'http://' + msg.curator_site + '/' + msg.league + '/large/' + msg.twitter + '.png'
            if ( this.source != source ) {
                this.source = source;
                canvas.loadImage(this.source)
            }
            if ( msg.tweeter_following_bgcolor ) {
                this.rgba = msg.tweeter_following_bgcolor
            }
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
