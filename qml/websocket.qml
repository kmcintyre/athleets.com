import QtWebSockets 1.0
import QtQuick 2.5

import "tweet.js" as Tweet
import "site.js" as Site

WebSocket {
    id: socket
    property var website: [Site.domain()]
    url: 'ws://service.' + website[0] + ':8080'
    active: {
        console.log('active check:', settings.autoconnect)
        settings.autoconnect
    }
    onTextMessageReceived: {
        try {
            var json = JSON.parse(message)
            if (json.league) {
                Tweet.receivedJson(json)
            } else {
                Tweet.getListener('debug').received(json)
            }
        } catch (err) {
            console.log('error message:', err)
        }
    }
    Component.onCompleted: {
        Tweet.window = window
    }
    onActiveChanged: {
        console.log('active change:', active)
    }
    onStatusChanged: if (socket.status == WebSocket.Error) {
        console.log('socket error:', socket.errorString, socket.url)
    } else if (socket.status == WebSocket.Open) {
        console.log('socket open');
        var outgoing = JSON.stringify({"website":website})
        socket.sendTextMessage(outgoing);
        console.log('socket sent:', outgoing);
    } else if (socket.status == WebSocket.Closed) {
        console.log('socket closed')
    }
}
