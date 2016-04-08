.pragma library

var window = null;
var listeners = [];

function getListener(name) {
    for (var x = 0; x < listeners.length; x++) {
        if (listeners[x].objectName == name) {
            console.log('return listener:', name)
            return listeners[x];
        }
    }
}

function addListener(listener) {
    console.log('add listner', listener, listeners.length);
    listeners.push(listener)
}

function receivedJson2(json) {
    console.log('received json:', listeners.length);
    if (window) {
        window.setTimeout(function () {
            listeners.forEach(function (listener) {
                listener.received(json)
            });
        },
        0
        );
    }
}

function receivedJson(json) {
    //console.log('received tweet:', listeners.length);
    listeners.forEach(function (listener) {
        listener.received(json)
    });
}
