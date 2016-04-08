import QtQuick 2.5
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

import "tweet.js" as Tweet
import "request.js" as Request
import "database.js" as Database

GridView {
    id: gridView
    property string site
    currentIndex: -1
    model: ListModel {}
    anchors {
        fill: parent
        horizontalCenter: parent.horizontalCenter
    }    
    function received(msg) {
        for (var x = 0; x < gridView.count; x++) {
            if ( gridView.model.get(x).leagueItem.league == msg.league) {
                //console.log('found one:', msg.league, gridView.currentIndex, x);
                gridView.currentIndex = x;
                if (msg.team) {
                    gridView.footerItem.setTeam(msg)
                }
                return
            }
        }
    }
    delegate: Image {
        transform: Translate { x:  gridView.model.count * cellWidth < window.width - cellWidth ? (window.width - (gridView.model.count * cellWidth))/ 2 : window.width % cellWidth }
        property string league_name: leagueItem.league
        fillMode: Image.PreserveAspectFit
        source: {
            return "http://" + leagueItem.curator_site + "/" + leagueItem.league + "/medium/" + leagueItem.twitter + ".png"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log('league:', leagueItem.league)
                stackView.push({item:Qt.resolvedUrl("league.qml"), properties:{league:leagueItem.league}})
            }
        }
    }
    highlight: Glow {
        transform: Translate { x:  gridView.model.count * cellWidth < window.width - cellWidth ? (window.width - (gridView.model.count * cellWidth))/ 2 : window.width % cellWidth }
        samples: 10
        color: "blue"
        transparentBorder: true
        source: gridView.currentItem
    }
    header: Image {
        height: window.height / 5
        width: window.width;
        fillMode: Image.PreserveAspectFit
        scale: .88
        MouseArea {
            anchors.fill: parent
            onClicked: {
                sites.gotosite(sites.nextsite())
            }
        }
        source: 'http://' + site + '/logo/site.svg'
    }
    footer: Flickable {
        property string league

        width: window.width
        height: window.height
        function setTeam(msg) {
            console.log('set team:', msg.team)
            console.log('current index:', gridView.currentIndex)
            var url = 'http://' + gridView.model.get(gridView.currentIndex).leagueItem.curator_site + '/site/' + gridView.model.get(gridView.currentIndex).leagueItem.league;
            Database.cache(url, function(teams_json) {
                console.log('teams length:', teams_json.length, gridView.model.get(gridView.currentIndex).leagueItem.league)
                for (var x = 0; x < teams_json.length; x++) {
                    //console.log('add:', teams_json[x].profile.substring(5))
                    //model.append({'teamItem': teams_json[x], "league": teams_json[x].league, "team": teams_json[x].profile.substring(5)})
                }
            }, true);
            console.log(url);
        }
        Component.onCompleted: {
            console.log('I need to inflate')
        }
    }
    Component.onCompleted: {
        Tweet.addListener(this)
        console.log('leagues complete:', site)
        Database.cache("http://" + site + "/site", function (leagues_json) {
            leagues_json.sort(function(a, b) {
                try {
                    var hc = (b.tweeter_home_mutual ? b.tweeter_home_mutual.length : 0) - (a.tweeter_home_mutual ? a.tweeter_home_mutual.length : 0)
                    return hc;
                } catch (err) {
                    console.log('error sort league:', err, a.tweeter_home_mutual, b.tweeter_home_mutual)
                }
            });
            for (var i = 0; i < leagues_json.length; i++) { // fill the array, this loop takes a long time
                gridView.model.append({'leagueItem': leagues_json[i]})
            }
        });
    }
}
