import QtQuick 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

Rectangle {
    id: intro1
    width: window.width
    height: window.height

    states: [
        State {
            name: "unload"
            PropertyChanges {
                target: intro1
                opacity: 0
            }
        }
    ]

    Behavior on opacity {
        NumberAnimation {
            duration: 2000
            onRunningChanged: {
                if(!running){
                    this.destroy()
                    window.activated("stream")
                }
            }
        }
    }

    ListModel {
        id: teamModel
        onCountChanged: {
            console.log('columns count changed:', count)
        }
    }

    Rectangle {
        id: teams
        anchors.top: intro1.top
        width: parent.width
        GridView {
            id: gridView
            model: teamModel
            width: parent.width
            height: window.height
            cellWidth: 48; cellHeight: 48
            delegate: Rectangle {
                MouseArea {
                    width:48
                    height:48
                    Image {
                        width:48
                        height:48
                        property string team_name: team
                        fillMode: Image.PreserveAspectFit
                        source: "http://" + window.curator_site + "/" + league + "/small/" + twitter + ".png"
                    }
                    onClicked: {
                        console.log('yo:', team, this.children[0])
                        this.children[0].source = "http://" + window.curator_site + "/" + league + "/card/" + twitter + ".png"
                    }
                }
            }
            header: Text {
                id: gridviewHeader
                width: parent.width
                height: implicitHeight * 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.DemiBold
                text: {
                    return teamModel.count + " Teams"
                }
            }
            footer: MouseArea {
                width: parent.width
                anchors.fill: parent
                onClicked: {
                    intro1.state = "unload";
                }
                Label {
                    width: parent.width
                    color: "steelblue"
                    height: implicitHeight * 2
                    verticalAlignment: Text.AlignVCenter
                    text: "Next"
               }
            }
        }
    }

    Component.onCompleted: {
        window.request("/site/teams", function (teams_json) {
            teams_json.sort(function(a, b) {
                try {
                    return b.tweeter_home_mutual.length - a.tweeter_home_mutual.length;
                } catch (err) {
                    console.log('error sort league:', a.profile, b.profile)
                }
            });
            for (var i = 0; i < teams_json.length; i++) { // fill the array, this loop takes a long time
                teamModel.append({"league": teams_json[i].league, "twitter": teams_json[i].twitter, "team": teams_json[i].profile.substring(5)})
            }
        })
    }

}
