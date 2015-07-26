.pragma library

var role_sent = null;
var disconnect_button = null;

function sendRole(socket) {
    if (!role_sent) {
        role_sent = socket;
        socket.sendTextMessage(JSON.stringify(JSON.parse('{ "data": "instagram", "role": "data"}')));
        disconnect_button.text = "Connected";
    }
}
function onClick(socket, button) {
    if ( !socket.active ) {
        socket.active = true;
        disconnect_button = button;
        button.text = "Connecting..."
    }
}

