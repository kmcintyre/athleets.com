define(["jquery", "util"], function($, util) {	
	
	var titleshuffle = null;
	var title = new Array();
	function pushTitleMsg(msg,delay) {
		title.push({'msg':msg,'delay':(parseInt(delay)?parseInt(delay):250)})
		if (!titleshuffle) {
			function shiftTitleMsg() {
				var to = title.shift();
				document.title = to.msg;
				return setTimeout( 
					function() { 
						if (title.length > 0) { 
							titleshuffle = shiftTitleMsg() 
						} else { 
							titleshuffle = null;
						}   
					}, 
					to.delay 
				);
			}
			titleshuffle = shiftTitleMsg();
		}
	}
	
	function getNFLSocket() {
		
		var websocket = new WebSocket("ws://localhost:8081");
		websocket.waitingMessage = document.documentElement.clientWidth;
		websocket.key = null;
		websocket.league = null;
		
		websocket.onopen = function(evt) { 
			console.log(evt);
			console.log(websocket.waitingMessage);
			if ( websocket.waitingMessage ) {
				websocket.send(JSON.stringify(websocket.waitingMessage));
			}
		};
		
		websocket.onclose = function(evt) { 
			console.log('onclose:' + evt.code);
			$("#connection").css('color','red');
			setTimeout(function() { console.log('attempt reconnect'); reconnect(); }, 15 * 1000);
			console.log(evt); 
		};
		
		websocket.onerror = function(evt) {
			console.log('onerror:' + evt.code);
			console.log(evt); 
		};
		
		websocket.onmessage = function(evt) { 				
			try {
				$("#connection").css('color','black')
				setTimeout( function() { $("#connection").css('color','green') }, 500 );			
				if ( evt.data instanceof Blob ) {
					var jsonreader = new window.FileReader();
					jsonreader.readAsText(evt.data.slice(0,1024));
					jsonreader.onloadend = function() {
						var tweet = JSON.parse(jsonreader.result);
						console.log(tweet.tweet);
						pushTitleMsg( (tweet.name?util.nameFlip(tweet.name):tweet.team)  );
						if ( $('#tweet_' + tweet.tweet).length == 0 ) { 
							var imgreader = new window.FileReader();
							imgreader.readAsDataURL(evt.data.slice(1024));										
							imgreader.onloadend = function() {
								var image = document.createElement('img');
								base64data = imgreader.result;
								image.src = base64data;
								image.id = 'tweet_' + tweet.tweet;
								image.className = 'tweet';
								util.tweet(tweet, image);								
							}
						} else {
							console.log('repeat');
						}
					}					
				} else { 
					var json = JSON.parse(evt.data);
					//console.log(json);
					if ( json.incoming ) {
						pushTitleMsg(json.incoming,1500);						
					}
					
				}
			} catch (err) {
				console.log('error?:' + err);
				console.log('assuming swkey:' + evt.data);
				document.cookie = "swkey=" + escape(evt.data);
				console.log('did the cookie get set');
			}
		};
		
		return websocket; 
	}
	
	var websocket = getNFLSocket();
	
	function reconnect() {
		websocket = getNFLSocket();
	}
		
	return {
		send : function(msg) {
			console.log("what fucking called this");
			if (websocket.readyState == 1) {
				websocket.send(JSON.stringify(msg));				
			}
		},
		
		set_league : function(l,ready) {
			console.log('set league');
			websocket.league = l;
			if (ready) {
				this.send(ready);
			} else {
				this.send({loaded: true})
			}
			
		}
	};	
});