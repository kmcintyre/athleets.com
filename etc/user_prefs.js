define(function() {
	return { 
		state : {},
		loaded : true.

		site : 'www.athleets.com',
		connection : ['ws://localhost:8080'],		
		color : {
			connectionOff:'#660066',
			connectionMaybe:'orange',
			connectionOn:'#006666',
			connectionDrop:'white',
			connectionMsg:'#006662'
		},
		
		firstTimeTxt: ['First Time'],
		notFirstTimeTxt: ['Welcome Back'],		
		initTxt: ['Programs! Peanuts!', 'Welcome to AWS Stadium', 'Tickets Please'],
		reconnectTxt: ['Retained Possession','Lucky Bounce!'],
		connectTxt: ['Enjoy the Game'],
		dropTxt: ['Fumble!', 'Ball\`s on the Turf', 'Reconnect in 30'],
		
		width : function() {
			return Math.min(document.documentElement.clientWidth,590)
		},		
		
		get_connection_for : function(ws_url) {
			console.log('get connection for:' + ws_url + ' index:' + this.connection.indexOf(ws_url));
			tried_which = this.connection.indexOf(ws_url);
			if ( tried_which >= 0 && tried_which < this.connection.length - 1 ) {
				console.log('try next?:');
				return this.connection[this.connection.indexOf(ws_url)+1]
			} else {
				console.log('default too:',this.connection[0]);
				return this.connection[0];
			}
		},
	}	
})