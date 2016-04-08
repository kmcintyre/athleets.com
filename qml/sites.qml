import QtQuick 2.5

import "site.js" as Site
import "tweet.js" as Tweet
import "request.js" as Request
import "database.js" as Database

Item {
    id: sites
    anchors.centerIn: parent
    function addsite(site) {
        Qt.createComponent("site_leagues.qml").createObject(sites, {site: site});
    }
    function gotosite(site) {
        for (var x = 0; x < visibleChildren.length; x++) {
            visibleChildren[x].visible = false;
        }
        if ( !getsite(site) ) {
            addsite(site)
        } else {
            getsite(site).visible = true;
            console.log('have site!:', site, sites.children.length);
        }
    }
    function getsite(site) {
        for (var x = 0; x < sites.children.length; x++) {
            if (sites.children[x].site == site) {
                return sites.children[x]
            }
        }
    }
    function nextsite() {
        for (var x = 0; x < curatorModel.count; x++) {
            if ( curatorModel.get(x).siteItem.role == sites.visibleChildren[0].site ) {
               try {
                   if ( curatorModel.get(x).siteItem.role.localeCompare(Site.domain()) == curatorModel.get(x+1).siteItem.role.localeCompare(Site.domain()) ) {
                       return curatorModel.get(x+1).siteItem.role
                   } else {
                       return Site.domain()
                   }
               } catch (err) {
                    return curatorModel.get(0).siteItem.role
               }
            }
        }
        for (var x = 0; x < curatorModel.count; x++) {
            if ( curatorModel.get(x).siteItem.role.localeCompare(sites.visibleChildren[0].site) > 0 ) {
                return curatorModel.get(x).siteItem.role
            }
        }
        return curatorModel.get(0).siteItem.role
    }
    function received(msg) {
        gotosite(msg.curator_site)
    }
    ListModel {
        id: curatorModel
    }
    Component.onCompleted: {
        addsite(Site.domain())
        Tweet.addListener(this);
        Database.cache("http://" + Site.domain() + "/site/curator", function (site_json) {
            site_json.sites.sort(function(a, b) {
                try {
                    return a['role'].localeCompare(b['role'])
                } catch (err) {
                    console.log('error sort league:', err, a.tweeter_home_mutual, b.tweeter_home_mutual)
                }
            });
            for (var i = 0; i < site_json.sites.length; i++) {
                curatorModel.append({'siteItem':site_json.sites[i]})
            }
        });
    }
}
