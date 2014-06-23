define(["football"], function(football) {
	
	return {
		nameFlip : function(name) {
			try {
				return name.substring(name.indexOf(',') + 1) + ' ' + name.substring(0, name.indexOf(','));
			} catch (err) {
				console.log('weird name:' + name);
				return name;
			}
		},		
		playerRow : function(p,sortedby,rank) {
			return '<tr id="' + this.simplePlayerId(p) +  '">' +
					'<td class="pos">' + p.position + '</td>' +
					//'<td class="jersey">' + ( p['jersey'] ?  p['jersey'] : '') + '</td>' +			
					'<td class="rank">' + rank + '</td>' +
					'<td class="' + sortedby + '">' + (p[sortedby]?p[sortedby]:'') + '</td>'	+
					'<td class="' + this.simpleId(p.team) + '"></td>' +
					'<td class="' + (p['twitter']?'twitter':'mia') + '" link="' + (p['twitter']?p['twitter']:'mia') + '"' + (p.media_bgcolor?' bgcolor="' + p.media_bgcolor + '"':'') + '></td>' +
					'<td class="status" value="' + p['status'] + '"></td>' +			
					'<td class="profile" link="' + p.profile + '">' + p['name'] + '</a></td>' +						
					'</tr>';
		},
		
		tweet : function(j,i) {
			//console.log(j);
			$(i).click(function() { 
				window.open('https://twitter.com/@' + j.twitter ); 
			}).css('width', user_prefs.width() );
			pd = $('<div>').append(i);
			pd.data('tweet', j);
			//if ( j.profile ) {								
			//	pd.append('<img style="position:absolute;margin-left:-15px" width="60px" src="/team_logos/' + this.simpleId(j.team) + '.svg">');
			//	pd.append( 
			//		'<span style="white-space:nowrap;font-size:.8em;font-family:Special Elite">' + (football.positions[j.position]?football.positions[j.position].name:j.position)  + '</span>'			
			//	);
			//} 
			$('#tweets').prepend(pd);
			$('#tweets div').first().children('span').css({"margin-left": -16-$('#tweets div').first().children('span').width(), 'position':'absolute'} );
			user_prefs.do_filter();
		},
		
		calloutId : function(id) {
			return '#callout-' + id; 
		},
		
		filters : ['teams_and_players', 'teams', 'players'],
		
		filterLabel : function(f,span) {
			if ( span ) {
				return '<span class="filteredby">' + this.filterLabel(f) + '</span>';
			}
			if ( f == this.filters[0] ) { return 'Teams+Players'; }
			if ( f == this.filters[1] ) { return 'Teams'; }
			if ( f == this.filters[2] ) { return 'Players'; }
			return 'Unknown';
		},
		
		sorts : ['stat_followers', 'stat_tweets', 'stat_following'],
		
		sortLabel: function(s,span) {
			if ( span ) {
				return '<span class="sortedby">' + this.sortLabel(s) + '</span>';
			}
			if ( s == this.sorts[0] ) { return 'Followers'; }
			if ( s == this.sorts[1] ) { return 'Tweets'; }
			if ( s == this.sorts[2] ) { return 'Following'; }
			return 'Unknown';
		},
		
		bestColor: function(colors, other) {
			if ( colors.length == 4) {
				colors = colors.filter(function(c) { return c != '#000000' && c != '#FFFFFF'});
			} else if ( colors.length == 3) {
				colors = colors.filter(function(c) { return c != '#000000' });
			}		
			if ( other ) {
				var temp_c = this.bestColor(colors);
				var potential_c = colors.filter(function(c) { return c != '#000000' && c != '#FFFFFF' && temp_c  });	
				if (potential_c.length){
					return potential_c[0];
				}
				return  '#000000'; 
			}
			return colors.filter(function(c) { return c != '#000000' && c != '#FFFFFF'})[0];
		},		

		notSortedBy : function(sb) {
			var sorts = this.sorts.slice(0);
			if ( sorts.indexOf(sb) > 0 ) {
				var sub = sorts.splice(0, sorts.indexOf(sb));		
				sorts = sorts.concat(sub);
			}
			sorts.splice(sorts.indexOf(sb), 1);
			return sorts;
		},	
		
		notFilteredBy : function(fb) {
			var filters = this.filters.slice(0);
			if ( filters.indexOf(fb) > 0 ) {
				var filt = filters.splice(0, filters.indexOf(fb));		
				filters = filters.concat(filt);
			}
			filters.splice(filters.indexOf(fb), 1);
			return filters;
		},		
		
		numTwitter : function(tn) {
			if ( tn == 0 ) {
				return '0';
			} else if ( tn / 1000000 >= 1 ) {
				return '' + parseInt(tn / 1000000) + '.' + parseInt((tn % 1000000)/10000) + 'M';
			} else if ( tn / 1000 >= 100 ) {
				return '' + parseInt(tn / 1000) + '.' + parseInt((tn % 1000)/100) + 'K';		
			} else if ( tn / 1000 >= 1 ) {
				return '' + parseInt(tn / 1000) + ',' + tn % 1000;		
			} else {
				return '' + tn;
			}
		},
		
		shortenTs : function(ts) {
			var dort = ts.toLocaleDateString();
			if ( new Date().toLocaleDateString() == ts.toLocaleDateString() ) {
				var jt = ts.toLocaleTimeString();
				dort = jt.substring(0,jt.lastIndexOf(":")) + jt.substring(jt.lastIndexOf(":") + 3)
				//return dort.replace(/M/g,'&#8344;').replace(/A/g,'&#8336;').replace(/P/g,'&#8346;');
				return dort;
			} else {
				dort = dort.substring(0, dort.lastIndexOf("/") );
			}
			//console.log(dort);
			if ( dort.indexOf('0') == 0 ) { dort = dort.substring(1); }
			return dort;
		},
		
		
		
		simpleId : function(id) { 
			return id.toLowerCase().replace(/ /g,"-").replace(/\./g,"") 
		},
		
		simplePlayerId : function(p) {
			return this.simpleId(p.team) + '-' + (p.jersey?p.jersey:'mia')
		},
		
		twitterNum: function(tn) {
			if ( tn == null || tn == 'null' || tn == '' ) {
				return 0;
			} else if ( tn.indexOf(',') > -1 ) {
				return this.twitterNum( tn.replace(',','') );		
			} else if ( tn.substring(tn.length - 1) == "M" ) {
				return parseInt(this.twitterNum(tn.substring(0,tn.length - 1)) * 1000000);
			} else if ( tn.substring(tn.length - 1) == "K" ) {
				return parseInt(this.twitterNum(tn.substring(0,tn.length - 1)) * 1000);
			} else if ( parseFloat(tn) ) {
				return parseFloat(tn);
			} else if ( parseInt(tn) ) {
				return parseInt(tn);
			} else {
				return 0;
			}
		},
	
		twitterSum: function(l,k,raw) {
			var total = 0;
			for (x = 0; x < l.length; x++) {
				total += this.twitterNum(l[x][k]);
			}
			if (raw) return total;
			return this.numTwitter(total);
		}
		
	}
});