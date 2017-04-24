angular.module('app', ['ngMaterial', 'LocalStorageModule', 'ui.router'])
    .config(function($stateProvider, $urlRouterProvider, $locationProvider) {
        
    	$urlRouterProvider.otherwise('/');
        
        $stateProvider.state('leagues', {
            url: '/',
            templateUrl: 'leagues.html',
            controller: 'leagueCtrl'
        }).state('teams', {
        	url: '/:league',
            templateUrl: 'teams.html',
            controller: 'teamCtrl'
        }).state('players', {
        	url: '/:league/:team',
            templateUrl: 'players.html',
            controller: 'playerCtrl'
        }).state('social', {
        	url: '/social',
            templateUrl: 'social.html',
            controller: 'socialCtrl'
        });
        
        $locationProvider.hashPrefix('');
        
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
    }).controller('leagueCtrl', function($scope) {
        function load_leagues(response) {
        	$scope.leagues = response.data.map(function(league) {
        		league['on'] = true;
        		console.log('league:', league);
                return league;
            });                        	
        }    	    	
    	$scope.load(load_leagues, '/site/leagues', 'http://athleets.com/site/leagues')
    }).controller('teamCtrl', function($scope, $stateParams) {
    	function load_teams(response) {
        	$scope.teams = response.data.map(function(team) {
        		team.team = team.profile.split(':')[1]
        		team['on'] = true;
                return team;
            });     		
    	}    	
    	$scope.load(load_teams, '/site/' + $stateParams['league'] + '/teams', 'http://athleets.com/site/' + $stateParams['league'] + '/teams')
    }).controller('playerCtrl', function($scope, $stateParams) {
    	$scope.team = $stateParams['team']
    	function load_players(response) {
        	$scope.players = response.data.map(function(player) {        		
        		player['on'] = true;
                return player;
            });     		
    	}
    	$scope.load(load_players, '/site/' + $stateParams['league'] + '/' + $stateParams['team'], 'http://athleets.com/site/' + $stateParams['league'] + '/' + $stateParams['team'])
    }).controller('socialCtrl', function($scope) {
    	console.log('hey')
    }).controller('ctrl', function ($scope, $http) {     	
        $scope.title = 'Chill with pros';
    	$scope.load = function (func, url, backup_url) {
    		$http.get(url).then(
        		function(res) { 
        			func(res)                        	
                },
                function(err) {
                	if ( backup_url ) {
                		$scope.load(func, backup_url)
                	}
                }
           );    		
    	}
	});