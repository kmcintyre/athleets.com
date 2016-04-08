import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.XmlListModel 2.0
import Qt.labs.settings 1.0

import QtQuick.LocalStorage 2.0

import "site.js" as Site
import "tweet.js" as Tweet
import "request.js" as Request
import "database.js" as Database


ApplicationWindow {
    id: window

    width: 414
    height: 736

    visible: true

    Settings {
        id: settings
        property date arrive: new Date()
        property bool autoconnect: true
        property string curator_site: Site.domain()
        property bool debug: false
        property bool streaming: false
        property string version: "0"
        property string websocket_key
        property int visit
    }
    property var db: LocalStorage.openDatabaseSync(settings.curator_site, "1.0", settings.curator_site + " LocalDB", 1000000);
    onDbChanged: {
        Database.db = db;
        Database.settings = settings;
        Database.init();
        console.log('storage done:', settings.curator_site, settings.visit)
    }

    toolBar: Loader {
        source: "toolbar.qml"
    }
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: Qt.resolvedUrl("sites.qml")
    }
    statusBar: Loader {
        source: "statusbar.qml"
    }
    Loader {
        source: "websocket.qml";
    }
}
