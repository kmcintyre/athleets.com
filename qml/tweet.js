.pragma library

var listeners = [];

function addListener(listener) {
    console.log('add listner', listener, listeners.length);
    listeners.push(listener)
}

function receivedJson(json) {
    console.log('received json:', listeners.length)
    listeners.forEach(function (listener) {
        listener.received(json)
    })
}
