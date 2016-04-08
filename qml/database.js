.pragma library

.import "request.js" as Request

var db = null;
var settings = null;

function init() {
	console.log('call init database!')
	db.transaction(
        function(tx) {
            //tx.executeSql('DROP TABLE IF EXISTS cache');
            tx.executeSql('CREATE TABLE IF NOT EXISTS cache(url, data)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS tweet(site, league, tweet_id)');
            //tx.executeSql('DROP TABLE IF EXISTS visit');
            tx.executeSql('CREATE TABLE IF NOT EXISTS visit(arrive datetime, depart datetime)');
            tx.executeSql("insert into visit values(?, ?)", [settings.arrive, null]);
            console.log('tables done')
        }
    );
	
	db.transaction(function(tx) {
    	settings.visit = tx.executeSql('SELECT count(*) as count FROM visit').rows.item(0).count + 1
    });
}


function cache(url, callback) {
    console.log('cache url:', url)
    try {
        db.transaction(function(tx) {
            var data = tx.executeSql("select data from cache where url = ?", [url]).rows.item(0).data;
            callback(JSON.parse(data))
            console.log('found in cache:', url, data.length)
        });
    } catch (err) {
        console.log(db, err)
        db.transaction(function(tx) {
            Request.request(url, function(json) {
                console.log('insert into cache:', url, db, JSON.stringify(json).length)
                tx.executeSql("insert into cache values (?, ?)", [url, JSON.stringify(json)]);
                callback(json)
            });
        });
    }
}

function record_tweet(tweet) {
    db.transaction(function(tx) {
        tx.executeSql("insert into tweet values(?, ?, ?)", [null, null, null]);
    });
}
function close() {
    db.transaction(
        function(tx) {
            tx.executeSql("update visit set depart = ? where arrive = ?", [new Date(), storage.arrive]);
            var rs = tx.executeSql('SELECT * FROM visit')
            for (var x = 0; x < rs.rows.length; x++) {
                console.log(rs.rows.item(x).arrive, rs.rows.item(x).depart);
            }
        }
    );
}




