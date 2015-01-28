define(['playbook'], function(playbook) {
	playbook.site_set({key:'init',value:['AWS Stadium', 'tweets from pros', 'world Around']})
	playbook.site_set({key:'onclose',value:['Fumble!', 'Ball\`s on the Turf', 'Pile up near mid-field']})
	playbook.site_set({key:'onopen',value:['Enjoy sport']})
	playbook.site_set({key:'hashes',value:['nfl','nba','mls','nhl','bpl','laliga','ligue1','tennis','golf','bundesliga','mlb','ipl','seriea']})
	
	playbook.site_set({key:'color',value:{ 'onmessage' : '#0052A5', 'onopen' : '#f7a70c', 'onclose' : '#960018'}})
	
	playbook.site_set({key:'connection',value:['ws://localhost:8080']})
	return {		
		loaded:true
	}	
})
