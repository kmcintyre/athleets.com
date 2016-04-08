function setTimeout(callback, delay) {
    console.log('window setTimeout:', delay)
    var component = Qt.createComponent("timer.qml");
    var timer = component.createObject(window);
    timer.setTimeout(callback, delay)
    return timer;
}
