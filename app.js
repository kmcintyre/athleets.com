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
    
	$urlRouterProvider.otherwise('/');
	$locationProvider.hashPrefix('');
	$stateProvider.state('site', { 
		url: '/',
        templateUrl: 'index_site.html'	
    }).state('league', { 
		url: '/:league',
        templateUrl: 'index_league.html',
        controller: 'leagueCtrl'
    }).state('team', { 
		url: '/:league/:team',
        templateUrl: 'index_team.html',
        controller: 'teamCtrl'
    })
    
}).factory('site', function($http, localStorageService) {	

	function get(url) { 
		return $http.get(url, {
		    cache: true
		}).then(function(res) { 
			return res.data.map(function(entity) {
        		if ( !localStorageService.get(entity.profile) ) {
        			localStorageService.set(entity.profile, { 'on': true })        			
        		}
        		return angular.merge({}, entity, localStorageService.get(entity.profile));
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
            	
            	$scope[groupname] = entities;
    			
    			$scope.$watch(groupname, function(entities) {
                	console.log('entities:', entities.length, groupname)
                	var filtered = entities.map(function (entity) {
                		console.log(entity.on)
                		localStorageService.set(entity.profile, entity)
                		return entity;
                	}).filter(function(entity) {
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
                		
                		var on = {value:'on'}
                		on.label = [entities.length - filtered.length, capitalize(on.value)].join(' ')
                		var off = {value: 'off', inverse: on.value }
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
        	});	    		    			
		}
	};    	    	  
}).controller('ctrl', function ($scope, site) { 
	$scope.title = 'Chill with pros';
	['leagues'].forEach(function (groupname) {
    	site.load(groupname, $scope.url_prefix() + '/site/' + groupname, $scope);
    });		

}).controller('leagueCtrl', function ($scope, $stateParams, site) { 
	console.log('league:', $stateParams.league);
	$scope.league = $scope.leagues.filter(function (league) { return league.league == $stateParams.league })[0]
	return site.load('teams', $scope.url_prefix() + '/site/' + $stateParams.league + '/teams', $scope).then(function (teams) {
		teams.forEach(function (team) {
			team.team = team.profile.split(':')[1];
		})
	})	
}).controller('teamCtrl', function ($scope, $stateParams, site) { 
	console.log('team:', $stateParams.team, 'teams:', $scope.teams);
	$scope.league = $scope.leagues.filter(function (league) { return league.league == $stateParams.league })[0]
	return site.load('teams', $scope.url_prefix() + '/site/' + $stateParams.league + '/teams', $scope).then(function (teams) {
		teams.forEach(function (team) {
			team.team = team.profile.split(':')[1];
			if ( team.team == $stateParams.team ) {
				$scope.team = team;
				site.load('players', $scope.url_prefix() + '/site/' + $stateParams.league + '/' + $stateParams.team, $scope)
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
}).directive('backImg', function() {
    return {
    	link: function(scope, element, attrs) {
    		console.log(attrs.backImg)
    		var entity = JSON.parse(attrs.backImg);
    		if ( entity.twitter ) {
    			var url = 'http://' + entity.site + '/' + entity.league + '/bgimage_large/' + entity.twitter + '.png'
				element.css({
	    			'background-image': 'url(' + url +')',
	    			'background-size' : 'cover'
	    		});
    			element.addClass("md-tall")
    		} else {
    			console.log('no')
    		}
    	}
    };
});

