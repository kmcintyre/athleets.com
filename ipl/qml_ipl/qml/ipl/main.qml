/****************************************************************************
**
** Copyright (C) 2014 Kurt Pattyn <pattyn.kurt@gmail.com>.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtWebSockets module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL21$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** As a special exception, The Qt Company gives you certain additional
** rights. These rights are described in The Qt Company LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.0
import QtWebSockets 1.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import "schedule.js" as Schedule
import "tweet.js" as Tweet
import "emblem.js" as Emblem

ColumnLayout {

    id: layout
    spacing: 2
    width:414
    height:736

    onVisibleChanged: {
        console.log('visbility changed')
    }
    onActiveFocusChanged: {
        console.log('active focus changed')
    }

    Rectangle {
        border.color: "black"
        border.width: 5
        radius: 10
        Layout.preferredWidth: parent.width
        Label {
            anchors.fill: parent
            id: status
            text: 'status'
        }
    }

    TextArea {
        id: messageBox
        Layout.preferredWidth: parent.width
    }

    Label {
        id: tweetTxt
        wrapMode: "Wrap"
        Component.onCompleted: {
            Tweet.addListener(tweetTxt)
        }
        function received(msg) {
            tweetTxt.text = msg.tweet_txt
        }
    }

    Label {
        id: label_team
        Component.onCompleted: {
            Tweet.addListener(label_team)
        }
        function received(msg) {
            try {
                label_team.text = msg.team
            } catch (err) {
                console.log('no team')
                label_team.text = '';
            }
        }
    }

    Label {
        id: label_twitter
        Component.onCompleted: {
            Tweet.addListener(label_twitter)
        }
        function received(msg) {
            label_twitter.text = msg.twitter
        }
    }

    Label {
        id: label_league
        Component.onCompleted: {
            Tweet.addListener(label_league)
        }
        function received(msg) {
            label_league.text = msg.league
        }
    }

    Button {
        id: button
        x: 40
        y: 10
        text: qsTr("Connect")
        onClicked: {
            if ( !socket.active ) {
                socket.active = true;
                button.text = "Connecting..."
            } else if (button.text === "Connected") {
                spring.start()
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
            var outgoing = JSON.stringify(JSON.parse('{ "data": "data", "role": "data"}'))
            socket.sendTextMessage(outgoing);
            console.log('sent:', outgoing);
        } else if (socket.status == WebSocket.Closed) {
            console.log('Closed!', socket.status)
            button.text = "Connect"
            messageBox.text += "\nSocket closed"
        }
    }
}
