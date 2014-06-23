define(function() {

	statuses = {
			'ACT' : 'Active',
			'RES' : 'Injured Reserve',
			'NON' : 'Non Football Related Injured Reserve',
			'SUS' : 'Suspended',
			'PUP' : 'Physically Unable to Perform',
			'UDF' : 'Unsigned Draft Pick',
			'EXE' : 'Exempt'
	};

	formations = { 
			'O' : 'Offense',
			'D' : 'Defense',
			'ST' : 'Special Teams'
	};

	positions = {
			'FS' : 'Free Safety', 
			'ILB' : 'Inside Linebacker', 
			'DE' : 'Defensive End', 
			'DB' : 'Defensive Back', 
			'FB' : 'Fullback', 
			'WR' : 'Wide Receiver', 
			'DT' : 'Defensive Tackle', 
			'OLB' : 'Outside Linebacker', 
			'LB' : 'Linebacker', 
			'SAF' : 'Safety', 
			'LS' : 'Long Snapper', 
			'RB' : 'Running Back', 
			'TE' : 'Tight End', 
			'NT' : 'Nose Tackle', 
			'MLB' : 'Middle Linebacker', 
			'C' : 'Center', 
			'G' : 'Guard', 
			'CB' : 'Cornerback', 
			'K' : 'Kicker', 
			'P' : 'Punter', 
			'T' : 'Tackle', 
			'OL' : 'Offensive Line', 
			'SS' : 'Strong Safety', 
			'OG' : 'Offensive Guard', 
			'QB' : 'Quarterback', 
			'OT' : 'Offensive Tackle'
	};
	
	return {
		'statuses' : statuses,
		'positions' : positions,
		'formations' : formations
	}
});