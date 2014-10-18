define(["card"], function(card) {
	
	function deck(shuf) {
		this.cards = new Array();
		for (var i = 0; i < 52;i++ ) {
   			this.cards[i] = new card(i);
  		}
		if ( shuf ) {
			this.shuffle();
		}
	};
	
	deck.prototype.shuffle = function() {
		console.log('shuffle')
		var shuffledcards = new Array();
		while ( this.cards.length > 0 ) {
			var rand_no = Math.floor(Math.random() * this.cards.length);
			shuffledcards[shuffledcards.length] = this.cards[rand_no];
			this.cards = this.cards.slice(0,rand_no).concat( this.cards.slice(1+rand_no) );
		}
		this.cards = shuffledcards; 
	}

	deck.prototype.toString = function() {
		return this.cards.toString();
	}
	
	deck.prototype.facedown = function() {
		var fd = new card();
		fd.card = 'Blue_';
		fd.suite = 'Back';
		return fd; 
	}
	
	deck.prototype.cut = function(c) {
		if ( c > 0 && c < this.cards.length ) {
			//console.log('got here:' + this.cards.splice(0, c));
			this.cards = this.cards.concat(this.cards.splice(0, c)); 
			
			//return cutcards; 
			//this.cards = cards.slice(0,rand_no).concat( cards.slice(1+rand_no) );
		}
	}
	
	return deck;
});