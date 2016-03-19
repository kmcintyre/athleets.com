import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.XmlListModel 2.0
import Qt.labs.settings 1.0

import QtWebSockets 1.0

import QtMultimedia 5.0

import "site.js" as Site
import "tweet.js" as Tweet

ApplicationWindow {

    id: window
    visible: true
    width: 414
    height: 736
    property string curator_site: "athleets.com"

    Timer {
        id: timer
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

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    onActivated: {
        var component = Qt.createComponent(component_name + ".qml");
        console.log('hey:', component)
        var placed = component.createObject(window);
        console.log('stream:', placed)
    }

    signal activated(string component_name)
    Component.onCompleted: {
        activated("intro")
    }

    Settings {
        id: settings
        property bool autoconnect: true
        property string curator_site: Site.domain()
        property string version: "0"
    }    

    function request(path, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(data) {
            return function() {
                if ( data.readyState == 4 ) {
                    var js = eval('new Object(' + data.responseText + ')')
                    callback(js)
                }
            }
        })(xhr);
        var url = "http://dev." + window.curator_site + path;
        console.log('open to:', url)
        xhr.open('GET', url, true);
        xhr.setRequestHeader('accept','application/json')
        xhr.send('');
    }



    WebSocket {
        id: socket
        url: 'ws://service.' + Site.domain() + ':8080'
        //url: 'ws://localhost:8080'
        active: settings.autoconnect
        onTextMessageReceived: {
            try {
                var json = JSON.parse(message)
                if ( json.league ) {
                    console.log('msg!', json.league)
                    Tweet.receivedJson(json)
                } else {
                    console.log('no league:', message)
                }
            } catch (err) {
                console.log('error message:', err)
            }
        }
        onStatusChanged: if (socket.status == WebSocket.Error) {
            console.log('Error:', socket.errorString, socket.url)
        } else if (socket.status == WebSocket.Open) {
            console.log('Open!', socket.status)
            var outgoing = JSON.stringify(JSON.parse('{ "data": "data", "webrole": "data"}'))
            console.log('attempt send:', outgoing)
            socket.sendTextMessage(outgoing);
            console.log('sent:', outgoing);
        } else if (socket.status == WebSocket.Closed) {
            console.log('Closed!', socket.status)
        }
    }
}
