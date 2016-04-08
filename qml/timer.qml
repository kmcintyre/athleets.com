import QtQuick 2.5

Timer {
    repeat: false
    running: false
    triggeredOnStart: false
    property var callback: function() {
        console.log('callback')
    }
    onTriggered: {
        console.log('time trigger')
        callback();
    }
    function setTimeout(cb, delay) {
        console.log()
        this.interval = delay;
        callback = cb;
        start();
    }
}
