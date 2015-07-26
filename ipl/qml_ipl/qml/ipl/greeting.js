.pragma library

var role_sent = null;

function sendRole(socket) {
    if (!role_sent) {
        role_sent = socket;
        socket.sendTextMessage(JSON.stringify(JSON.parse('{ "data": "instagram", "role": "data"}')));
    }
}
function onClick(socket) {
    if ( !socket.active ) {
        socket.active = true;
    }
}

