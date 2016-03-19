import QtQuick 2.3
import QtQuick.Window 2.2

import QtWebSockets 1.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.XmlListModel 2.0
import QtQml.Models 2.1
import QtMultimedia 5.0

import "schedule.js" as Schedule
import "tweet.js" as Tweet
import "emblem.js" as Emblem

Item {

    width: parent.width
    height: parent.height

    SplitView {

        anchors.top: window.top
        width: parent.width

        Label {
            width: 200
            Component.onCompleted: {
                Tweet.addListener(this)
            }
            function received(msg) {
                console.log('twitter:', msg.twitter)
                this.visible = true
                this.text = '<br><a href="https://twitter.com/' + msg.twitter + '">' + msg.twitter +'</a><br><br>' + msg.tweeter_home_name
            }
        }

        ColumnLayout {


            anchors.top: parent.top

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
                    league.source = 'http://' + msg.curator_site + '/' + msg.league + '/logo_standard/' + msg.league + '.svg';
                    if (!msg.team) {
                        console.log('no team!')
                        team.source = ''
                    } else {
                        try {
                            var tid = msg.team.toLowerCase().replace(/  /gi,' ').replace(/ /gi,'_').replace(/[^a-z0-9_]/gi,'');
                            console.log('team id:', tid)
                            team.source = 'http://' + msg.curator_site + '/' + msg.league + '/logo_standard/' + tid + '.svg';
                        } catch (err) {
                            console.log('MISSING TEAM:' + tid)
                        }
                    }
                }
            }

            Label {
                width: window.width/2
                color: 'steelblue'
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
        anchors.centerIn: parent
        width: window.width - 20
        Text {
            wrapMode: Text.Wrap
            width: parent.width
            Component.onCompleted: {
                Tweet.addListener(this)
            }
            function received(msg) {
                var twitpic = /pic.twitter.com/;
                var instagram = /instagram.com/;
                console.log('media player:', mediaPlayer.source, mediaPlayer.availability, mediaPlayer.playbackState)
                this.text = msg.tweet_txt;
                if ( mediaPlayer.availability == 0 && mediaPlayer.playbackState  == 0) {
                    if ( twitpic.test(this.text) ) {
                        console.log("   PIC:")
                        if ( mediaPlayer.source != "qrc:/sound1.wav") {
                            mediaPlayer.source = "sound1.wav";
                        }
                        mediaPlayer.play();
                    } else if ( instagram.test(this.text) ) {
                        console.log("   INSTAGRAM:")
                        if ( mediaPlayer.source != "qrc:/sound2.wav") {
                            mediaPlayer.source = "sound2.wav";
                        }
                        mediaPlayer.play();
                    }
                }
            }
        }
    }

    Canvas {
        anchors.bottom: slider.top
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

    Slider {
        id: slider
        anchors {
            bottom: parent.bottom
        }
        value: 8
        minimumValue: 1
        maximumValue: 20
    }

    Column {
        id: avi
        property string source: ''
        property string rgba: 'rgba(0,0,0,0.7)'

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

}
