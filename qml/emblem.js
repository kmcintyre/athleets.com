.pragma library

var label = null;

function receivedTweet(msg, label) {
    var json = JSON.parse(msg)
    console.log('RECEIVED Tweet:', json.tweet_txt, this)
    label.text = json.tweet_txt
}
