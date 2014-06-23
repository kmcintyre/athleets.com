define(["jquery", "util", "fifa_ws", "jquery.cookie", "typeahead.jquery"], function($, util, fifa_ws, jquery_cookie, typeahead_jquery) {
	
	user_prefs = { 
		width : function() {
			return Math.min(document.documentElement.clientWidth,590)
		},
		filter : { 'type' : 'none '},
		do_filter : function() {
			$('#tweets').children().show();
		}
	}	
	
	var substringMatcher = function(league) {
		return function findMatches(q, cb) {
		var matches, substringRegex;
		matches = [];
		substrRegex = new RegExp(q, 'i');
		$.each(['AFC','NFC'], function(i, c) {
			if (substrRegex.test(c)) {
				matches.push({ value: c, type: 'conference'});
			}						
		});		
		$.each(Object.keys(league.AFC.divisions).concat(Object.keys(league.NFC.divisions)), function(i, d) {
			if (substrRegex.test(d)) {
				matches.push({ value: d, type: 'division'});
			}			
		});		
		$.each(league.teams, function(i, t) {
			if (substrRegex.test(t['team'])) {
				matches.push({ value: t['team'], type: 'team', twitter: t['twitter'] });
			}
		});
		//$.each(football.formations, function(i, f) {
		//	if (substrRegex.test(f)) {
		//		matches.push({ value: f, type: 'formation'});
		//	}
		//});		
		$.each(Object.keys(football.positions), function(i, p) {
			if (substrRegex.test(football.positions[p])) {
				matches.push({ value: football.positions[p] , type: 'position', key: p});
			}
		});
		//$.each(league.players, function(i, p) {
		//	if (substrRegex.test(p['name'])) {
		//		matches.push({ value: p['name'], type: 'player', twitter: (p['twitter']?p['twitter']:'mia')});
		//	}
		//});		 
		cb(matches);
		};
	};	
	
	$(document).ready(function() {		
		function sizer() {
			$(document.body).css('width', user_prefs.width())
			$(document.body).children('div').css('width', user_prefs.width() );
			$("#tweets img").css('width', user_prefs.width() );
		}		
		$( window ).resize(function() {
			sizer();
		});
		sizer();		
		$.getJSON('wc.json').done(function (data) {
			console.log(data.teams);
			var asof = new Date(data['asof'] * 1000);			
			$('#time').html( util.shortenTs(asof) );
			
			$('#finder').on('blur', function(e) {
				if ( e.target.value.length == 0 ) {
					$('#tweets').children().show();
					user_prefs.filter = { type : 'none' };
					user_prefs.do_filter();
				}								
			});
			
			$('#finder').typeahead(
					{ hint: true, highlight: true, minLength: 2}, 
					{ name: 'favs', displayKey: 'value', source: substringMatcher(data) }
			).on('typeahead:selected', function(obj, datum, name) {
				console.log(obj);
				console.log(datum);
				console.log(name);				
				user_prefs.filter = datum;
				user_prefs.do_filter();
				$('#finder').blur();
			});
			
			user_prefs.do_filter = function() {
				console.log('yo')
				var datum = user_prefs.filter;
				if ( datum.type == 'position' ) {
					$('#tweets').children().each(function () {
						if ( $(this).data('tweet').position != datum.key ) {
							$(this).hide();
						} else {
							$(this).show();
						}
					});
				} else if ( datum.type == 'team' ) {
					$('#tweets').children().each(function () {
						if ( $(this).data('tweet').team != datum.value ) {
							$(this).hide();
						} else {
							$(this).show();
						}
					});
				} else if ( datum.type == 'conference' ) {
					var ct = data[datum.value].divisions[Object.keys(data[datum.value].divisions)[0]].teams.
					concat(data[datum.value].divisions[Object.keys(data[datum.value].divisions)[1]].teams).
					concat(data[datum.value].divisions[Object.keys(data[datum.value].divisions)[2]].teams).
					concat(data[datum.value].divisions[Object.keys(data[datum.value].divisions)[3]].teams);						
					$('#tweets').children().each(function () {
						if ( ct.indexOf( $(this).data('tweet').team ) == -1 ) {
							$(this).hide();
						} else {
							$(this).show();
						}
					});					
				} else if ( datum.type == 'division' ) {
					$('#tweets').children().each(function () {					
						if ( data[datum.value.substring(0,3)].divisions[datum.value].teams.indexOf( $(this).data('tweet').team ) == -1 ) {
							$(this).hide();
						} else {
							$(this).show();
						}
					});
				} else {
					$('#tweets').children().show();
				}				
			}
		});		
		$('#splash').css('width', user_prefs.width() );
		
		if ( $.cookie('favs') ) { 
			$('#favson').attr('checked', 'true');			
		} else {
			$('#favsoff').attr('checked', 'true');
		}		
		
		if ( $.cookie('splash') ) { 
			$('#splash').toggle();			
		} else {
			$('#skip').attr('checked', 'true');
		}
		
		$('#favs, #splash button').click(function (e) {
			$('#splash').toggle();			
		});
		$('#skip').click(function (e) {
			if ( e.target.checked )  {
				$.removeCookie('splash');
			} else {
				$.cookie('splash', { expires: 365 });				
			}
		});
		$('input[name="favorites"]').click(function (e) {
			if ( e.target.id == 'favson' )  {
				$('#favs').css('color','yellow');
			} else {
				$('#favs').css('color','black');				
			}
		});				
	});
});	
