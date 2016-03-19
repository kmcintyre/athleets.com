import QtQuick 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

import "tweet.js" as Tweet

Rectangle {
    id: intro
    width: window.width
    height: window.height

    Behavior on opacity {
        NumberAnimation {
            duration: 2000
            onRunningChanged: {
                if(!running){
                    this.destroy()
                    window.activated("intro1")
                }
            }
        }
    }

    Image {
        id: logo
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        source: "http://" + window.curator_site + "/logo/site.png"
    }

    ListModel {
        id: leagueModel
        onCountChanged: {
            console.log('columns count changed:', count)
        }
    }

    Rectangle {
        id: leagues
        anchors { horizontalCenter: parent.horizontalCenter; top: logo.bottom; topMargin: 10 }
        Component.onCompleted: {
            Tweet.addListener(this)
        }
        function received(msg) {
            for (var x = 0; x < gridView.count; x++) {
                if ( leagueModel.get(x).league == msg.league) {
                    console.log('found one:', msg.league, gridView.currentIndex, x);
                    gridView.currentIndex = x;
                    //gridView.currentItem.children[0].visible = false
                } else {
                    //gridView.itemAt(x).children[0].visible = true;
                }
            }
            //gridView.currentIndex = -1;
        }
        GridView {
            id: gridView
            model: leagueModel
            height: window.height - logo.implicitHeight
            cellWidth: 80; cellHeight: 80
            delegate: MouseArea {
                width:80
                height:80
                Image {
                    property string league_name: leagueItem.league
                    fillMode: Image.PreserveAspectFit
                    source: "http://" + window.curator_site + "/" + leagueItem.league + "/medium/" + leagueItem.twitter + ".png"
                }
                Glow {
                    samples: 10
                    color: "blue"
                    transparentBorder: true
                    source: {
                        if ( gridView.currentIndex > -1 ) {
                            return gridView.currentItem
                        }
                    }
                }
                onClicked: {
                    console.log('yo:', leagueItem.league, this.children[0])
                }
            }
            highlight: Glow {
                samples: 10
                color: "blue"
                transparentBorder: true
                source: {
                    if ( gridView.currentIndex > -1 ) {
                        return gridView.currentItem
                    }
                }
            }
            header: MouseArea {
                width: parent.width
                height: gridviewHeader.height
                onClicked: {
                    console.log('yo2');
                }
                Text {
                    id: gridviewHeader
                    width: parent.width
                    height: implicitHeight * 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.DemiBold
                    text: {
                        return leagueModel.count > 0 ? + leagueModel.count + " Leagues" : "Loading"
                    }
                }
            }

            footer: MouseArea {
                width: parent.width
                height: gridviewFooter.height
                onClicked: {
                    console.log('yo');
                    intro.state = "unload";
                }
                Text {
                    id: gridviewFooter
                    width: parent.width
                    height: implicitHeight * 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.DemiBold
                    text: {
                        return "->"
                    }
                }
            }
        }        
    }    
    states: [
        State {
            name: "unload"
            PropertyChanges {
                target: intro
                opacity: 0
            }
        }
    ]

    Component.onCompleted: {
        window.request("/site", function (leagues_json) {
            leagues_json.sort(function(a, b) {
                try {
                    return b.tweeter_home_mutual.length - a.tweeter_home_mutual.length;
                } catch (err) {
                    console.log('error sort league:', a.profile, b.profile)
                }
            });
            for (var i = 0; i < leagues_json.length; i++) { // fill the array, this loop takes a long time
                leagueModel.append({'leagueItem': leagues_json[i]})
            }
        })
    }

}
