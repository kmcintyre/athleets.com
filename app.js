function capitalize(l) {
	return l.charAt(0).toUpperCase() + l.slice(1);
}

angular.module('app', ['ngMaterial', 'LocalStorageModule', 'ui.router']).run(function($rootScope){ 

	$rootScope.Utils = {
		keys : function (obj) {
			console.log('keys!')
			return Object.keys(obj)
		}		
	};	
	$rootScope.url_prefix = function () {
		return '';
	};
	
}).config(function(localStorageServiceProvider, $stateProvider, $urlRouterProvider, $locationProvider) {
    
	
	$locationProvider.hashPrefix('');
	$urlRouterProvider.otherwise('/');
	
	$stateProvider.state('site', {
        abstract: true,
        templateUrl: 'index_site.html'
    }).state('site.index', {
    	url: '/',
    	views: {
    		'toolbar': {
    			templateUrl: 'index_toolbar.html'
    		},
    		'content': {
    			templateUrl: 'index_leagues.html'    			
    		}
    	}		
    }).state('site.league', {
    	url: '/:league',
    	views: {
    		'toolbar': {
    			templateUrl: 'league_toolbar.html',
    			controller: 'teamsCtrl'
    		},
    		'content': {
    			templateUrl: 'league_teams.html',
    			controller: 'teamsCtrl'
    		}
    	}    	    
    }).state('site.team', {
    	url: '/:league/:team',    	
    	views: {
    		'toolbar': {
    			templateUrl: 'team_toolbar.html',
    			controller: 'playersCtrl'
    		},
    		'content': {
    			templateUrl: 'team_players.html',
    			controller: 'playersCtrl'
    		}
    	}    	    
    });
    
}).factory('site', function($http, localStorageService) {	

	function get(url) { 
		return $http.get(url, {
		    cache: true
		}).then(function(res) { 
			return res.data.map(function(entity) {
        		//if ( localStorageService.get(entity.profile) ) {
        			//localStorageService.set(entity.profile)
        			//localStorageService.get(entity.profile)
        		//}
        		return angular.merge({}, entity, { on: true });
            });    						
        });    			
	}
	
	return {
		load: function(groupname, url, $scope) {
			var pn = groupname + 'Preference';
        	var pln = groupname + 'PreferenceList';
        	var pnc = groupname + 'PreferenceChange';
        	var fn = groupname + 'Filter';
        	
    		return get(url).then(function(entities) {
    			console.log(entities)
    			var l = { value: groupname }
    			l.label = [capitalize(l.value), entities.length].join(' ');
    			$scope[pn] = l.value;
    			
    			console.log('loaded:', groupname, entities.length)
    			$scope[pln] = [l];     			    			    			
    			
    			$scope[pnc] = function (preference) {
    				console.log('preference change:', preference)
    				$scope[pn] = preference.value
    			}
    			
            	$scope[fn] = function(entity) {            		
            		if ( $scope[pn] == groupname ) {
            			return true;
            		} else if ( Object.keys(entity).indexOf($scope[pn]) > -1 ) {
            			return entity[$scope[pn]];
            		} else {
            			var filtered = false;
            			$scope[pln].forEach(function(preference) {
            				if ( preference.inverse && Object.keys(entity).indexOf(preference.inverse) > -1 ) {
            					var inverse_value = entity[preference.inverse];
            					if ( !inverse_value ) {
            						filtered = true;            						
            					}
            				}
            			})     
            			return filtered;
            		} 
            		            		
            	}
            	
    			$scope.$watch(groupname, function(entities) {
                	console.log('entities:', entities.length, groupname)
                	var filtered = entities.filter(function(entity) {
                		return entity.on != true
                	})
                	
                	console.log('filtered length:', filtered.length, $scope[pln].length)                	
                	if ( filtered.length == 0 ) {                		
            			$scope[pln] = $scope[pln].filter(function (f) {
                			return f.value == groupname;
                		})
                	}
                	
                	if ( $scope[pln].length == 1 ) {                		
                		//on.label = [entities.length - filtered.length, capitalize(on.value)].join(' ')
                		
                		var on = { value:'on' }
                		on.label = [entities.length - filtered.length, capitalize(on.value)].join(' ')
                		var off = { value: 'off', inverse: on.value }
                		off.label = [filtered.length, capitalize(off.value)].join(' ')
                		
                		$scope[pln].unshift(on, off);
                		
                	} else if ( $scope[pln].length > 1 ) {
                		console.log('set on/off:', $scope[pln].length, filtered.length);
                		scope_on = $scope[pln].filter(function (preference) { return preference.value == 'on'})[0];
                		scope_on.label = [entities.length - filtered.length, capitalize(scope_on.value)].join(' ')
                		
                		scope_off = $scope[pln].filter(function (preference) { return preference.value == 'off'})[0];
                		scope_off.label = [filtered.length, capitalize(scope_off.value)].join(' ')
                		
                	}               	              
                }, true);    			
    			return entities;
        	}, function (error) {
        		console.log('site error:', error)
        	});	    		    			
		}
	};    	    	  
}).controller('ctrl', function ($scope, site) { 
	$scope.title = 'Chill with pros';
	//['leagues', 'operators', 'curators']
	Promise.all(['operators', 'leagues'].map(function (groupname) {
		site.load(groupname, $scope.url_prefix() + '/site/' + groupname, $scope).then(function (entities) {
			$scope[groupname] = entities
		})		
	})).then(function (entities) {
		$scope.operator_by_role = function (role) {
			if ( $scope.operators ) {
				return $scope.operators.filter(function (operator) { return operator.role == role; })[0]
			}			
		}
	});
	
}).controller('teamsCtrl', function ($scope, $stateParams, site) {
	console.log('teamsCtrl:', $stateParams.league);	
	site.load('teams', $scope.url_prefix() + '/site/' + $stateParams.league + '/teams', $scope).then(function (teams) {
		teams.forEach(function (team) {
			team.team = team.profile.split(':')[1];
		});
		$scope.teams = teams;
	})
	$scope.$watch('leagues', function (leagues) {
		if (leagues) {
			$scope.league = leagues.filter(function (league) { return league.league == $stateParams.league })[0]
		}		
	})	
}).controller('playersCtrl', function ($scope, $stateParams, site) { 
	console.log('team:', $stateParams.team);
	site.load('teams', $scope.url_prefix() + '/site/' + $stateParams.league + '/teams', $scope).then(function (teams) {
		teams.forEach(function (team) {
			team.team = team.profile.split(':')[1];
			if ( team.team == $stateParams.team ) {
				site.load('players', $scope.url_prefix() + '/site/' + $stateParams.league + '/' + $stateParams.team, $scope).then(function (players) {
					$scope.players = players;
					$scope.team = team;
				})
			} 
		})
	})	
}).directive('errSrc', function() {
    return {
        link: function(scope, element, attrs) {
            element.bind('error', function() {
                if (attrs.src != attrs.errSrc) {
                    attrs.$set('src', attrs.errSrc);
                }
            });
        }
    }
}).directive('targetBlank', function() {
    return {
        compile: function(element) {
            var elems = (element.prop("tagName") === 'A') ? element : element.find('a');
            elems.attr("target", "_blank");
        }
    };
});

