.pragma library

var listeners = [];

function addListener(listener) {
    console.log('add listner', listener, listeners.length);
    listeners.push(listener)
}

function receivedJson(json) {
    console.log('received json:', listeners.length, Object.keys(json))
    listeners.forEach(function (listener) {
        console.log('listener:', listener)
        listener.received(json)
    })
    console.log('   ');
}
