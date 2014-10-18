define(function() {

	var cardorder = new Array("A","2","3","4","5","6","7","8","9","10","J","Q","K");
	var suitorder = new Array("S","H","C","D");
	
	var bjValues = {"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,"10":10,"J":10,"Q":10,"K":10,"A":1};
		
	function card(c) {
	    this.card = cardorder[ Math.floor( c % 13 ) ];
	    this.suite = suitorder[ Math.floor( c / 13 ) ];    	
    }
    
    card.prototype.toString = function() {
    	try {
    		return this.card.toString() + this.suite.toString();
    	} catch (err) {
    		throw "Unknown Card";
    	}
    }
    
	card.prototype.bjValue = function() {
		return bjValues[this.card];
	}
	
	card.prototype.fromBox = function() {
		return cardorder.indexOf(this.card) + suitorder.indexOf(this.suite) * 13;
	}
	
	card.prototype.fromSrc = function(src) {
		src = src.substring(src.lastIndexOf("/") + 1);
		src = src.substring(0,src.length -  4);
		this.card =  src.substring(0, src.length - 1);
		this.suite = src.substring(src.length - 1);
	}
    
	card.prototype.underscore = function() {
		return '_' + this.card + this.suite;
	}
	
	card.prototype.toSrc = function() {
		return '/deck/' + this.card + this.suite + '.svg';
	}
	
    card.prototype.toImg = function() {
    	var i = new Image();
    	i.src = this.toSrc();
    	i.className = 'card';
    	return i;
    }
    
    return card;
    
});
