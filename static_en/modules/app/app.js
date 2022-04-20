/* 
 *  This is the default license template.
 *  
 *  File: app.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
/**
 * @module App
 * @summary First module loaded
 */

/*globals window, angular, document */

angular.module('app', [
    'ngResource',
    'ngTable',
    'ui.router',
    'ui.bootstrap',
    'timer',
    'table.services',
    'rest.url.rebase',
    'rest.url.helper',
    'data.services',
    'network',
    'validators',
    'transformers',
    'rules',
    'diagnose'

])

	.filter('Status', function() {
		return function(input) {
			
			switch (input) {
			case "VALID": return "Validated Snapshot";
			case "HARVESTING_FINISHED_ERROR": return "Harvesting failed";
			case "HARVESTING_FINISHED_VALID": return "Harvesting finished";
			case "HARVESTING": return "Harvesting ...";
			case "PROCESSING": return "Processing ...";
			case "HARVESTING_STOPPED": return "Harvesting canceled";
			case "RETRYING": return "Retrying ...";
			case "INDEXING": return "Indexing ...";

			default:
				return "No snapshots available";
			}
			
		};
	})

	.filter('ShortenStatus', function() {
		return function(input) {
			
			switch (input) {
			case "VALID": return "V";
			case "HARVESTING_FINISHED_ERROR": return "E";
			case "HARVESTING_FINISHED_VALID": return "F";
			case "HARVESTING": return "R";
			case "PROCESSING": return "R";
			case "HARVESTING_STOPPED": return "S";
			case "RETRYING": return "R";
			case "INDEXING": return "I";

			default:
				return "?";
			}
			
		};
	})

	.filter('IndexStatus', function() {
		return function(input) {
			
			switch (input) {
			case "FAILED": return "E";
			case "INDEXED": return "I";
			case "UNKNOWN": return "?";

			default:
				return "?";
			}
			
		};
	})
	
	.filter('SiNo', function() {
    	return function(input) {
    		return input ? 'Si' : 'No';
    	};
    })
    
    .filter('ObjectID', function() {
    	return function(input) {
    		
    		var splitted_url = input._links.self.href.split("/");
    		return splitted_url[ splitted_url.length - 1 ];
    	};
    })
    
    .directive('ngConfirmClick', [
        function() {
            return {
                link: function (scope, element, attr) {
                    var msg = attr.ngConfirmClick || "Are you sure?";
                    var clickAction = attr.confirmedClick;
                    element.bind('click', function (event) {
                        if (window.confirm(msg)) {
                            scope.$eval(clickAction)
                        }
                    });
                }
            };
    }])
   
	
    .config(['$stateProvider', function ($stateProvider) {
        'use strict';

        $stateProvider
            .state('start', {
                url: '',
                views: {
                    'main': {
                        templateUrl: 'modules/app/app.html'
                    }
                }
            });
    }])

    .controller('app', ['$rootScope', '$scope', '$state', '$uibModal', 'TableSrv', 'RestURLHelper', 'DataSrv', function ($rootScope, $scope, $state, $uibModal, TableSrv, RestURLHelper, DataSrv) {
		'use strict';
		

		$scope.statusFilterData = [
							{id: "", title: ""}, 
							{id:"VALID", title:"Validated"}, 
							{id:"HARVESTING_FINISHED_ERROR", title:"Harvesting Error" }, 
							{id:"HARVESTING",  title:"Harvesting"},
                        	{id:"PROCESSING",  title:"Processing"},
							{id:"HARVESTING_FINISHED_VALID", title:"Harvesting Finished" },
							{id:"HARVESTING_STOPPED",  title:"Stopped"},
							{id:"RETRYING",  title:"Retriyng"}
		];

		$scope.indexStatusFilterData = [
			{id: "", title: ""}, 
			{id:"FAILED", title:"Indexing Failed"}, 
			{id:"INDEXED", title:"Indexed" }, 
		];
							
        $scope.loggedIn = true;
        $scope.navbarCollapsed = true;
        
        
        /*** Timer ******/
    	var MAX_SECS = 5;	
    	
        /* Indica acción ejecutada, se usa para mostrar alert */
        $scope.actionExecuted = false;
    	
    	$scope.restartTimerRemaining = function() {
          	$scope.timerRemainingSeconds = MAX_SECS;
        };	
    	
    	$scope.timerRunning = true;
    	$scope.timerRemainingSeconds = MAX_SECS;

        $scope.timerType = '';

        $scope.startTimer = function (){
        	$scope.restartTimerRemaining();
            $scope.$broadcast('timer-start');
            $scope.timerRunning = true;
        };

        $scope.stopTimer = function (){
            $scope.$broadcast('timer-stop');
            $scope.timerRunning = false;
        };

        $scope.$on('timer-tick', function (event, args) {
       	 
	       	 if ( $scope.timerRemainingSeconds == 0) {
	       		 //$scope.updateRunningStatus();
	       		 $scope.networksTableRefreshCallback();
	       		 $scope.restartTimerRemaining();	       		 
	       		 $scope.actionExecuted = false;
	       	 }
	       	 else {
	       		 $scope.timerRemainingSeconds--;
	       	 }
        });   
        /*** FIN DE RUTINAS TIMER ****/
        
        $scope.networksTable = TableSrv.createNgTableFromWsURL(RestURLHelper.listNetworks(), 
        		function(data) { 
					return { 
							 data:   data.networks,
							 total: data.totalElements    							 
					};
				}, 1, 25  
        );
        
     	// carga de las acciones disponibles y definicion de la tabla de redes
		DataSrv.callRestWS( RestURLHelper.listNetworkActions(), function(response) {
			$scope.networkActions = response.data;
		});
            
        $scope.networksTableRefreshCallback = function() { $scope.networksTable.reload(); };
        
        // Estado de las redes
        $scope.networks = { areAllSelected: false, selected: {} };
        
        // watch para el check all de redes
        $scope.$watch('networks.areAllSelected', function(value) {
            angular.forEach($scope.networksTable.data, function(network) {
                if (angular.isDefined(network.networkID)) {
                    $scope.networks.selected[network.networkID] = value;
                }
            });
        });
        
        /**
         * Ejecuta una acción de red sobre una o más ids de red
         * @param Action
         * @param networkID or networkList
         */	
         $scope.executeNetworkAction = function (action, incremental, networkIDs, success_callback, must_confim) {
         	 
        	 if (networkIDs != null && networkIDs != "" ) {
        		 DataSrv.callRestWS( RestURLHelper.networkActionURL(action, incremental,networkIDs), 
	        		function(response) {
		   			 		success_callback();
		   			 		$scope.restartTimerRemaining(); 
		   			 		$scope.actionExecuted = true;
		   			 		$scope.actionIdentifier =  action + ": " + response.data.msg;
	      		 	},	 
	      		 	function() { 
	      		 		alert("Error en la llamada a networkAction. Recargue la aplicación.");
	      		 	}
	      		 );
        	 }
         };
         
         
         /**
          * Ejecuta una acción de red sobre una o más ids de red
          * @param Action
          * @param networkID or networkList
          */	
          $scope.executeNetworkActions = function (networkIDs, success_callback, must_confim) {
          	 
         	 if (networkIDs != null && networkIDs != "" ) {
         		 DataSrv.callRestWS( RestURLHelper.networkActionsURL(networkIDs), 
         			function(response) {
	   			 		success_callback();
	   			 		$scope.restartTimerRemaining(); 
	   			 		$scope.actionExecuted = true;
	   			 		$scope.actionIdentifier = "EJECUTANDO TAREAS HABILITADAS: " + response.data.msg;
         		 	},	 
         		 	function() { 
         		 		alert("Error en la llamada a networkActions. Recargue la aplicación.");
         		 	}
         		 );
         	 }
          };
          
          /**
           * Mata todos las tareas asociadas con una o varias redes
           * @param Action
           * @param networkID or networkList
           */	
           $scope.killNetworkTasks = function (networkIDs, success_callback, must_confim) {
           	 
          	 if (networkIDs != null && networkIDs != "" ) {
          		 DataSrv.callRestWS( RestURLHelper.networkKillTasksURL(networkIDs), 
          			function(response) {
      			 		success_callback();
      			 		$scope.restartTimerRemaining(); 
      			 		$scope.actionExecuted = true;
      			 		$scope.actionIdentifier = "ELIMINANDO TAREAS ACTIVAS" + response.data.msg;
          		 	},	 
     		 	 	function() { 
     		 			alert("Error en la llamada a killTasks. Recargue la aplicación.");
     		 		}
          		);
          	 }
           };
           
           /**
            * Reagenda todos las tareas asociadas con una o varias redes
            * @param Action
            * @param networkID or networkList
            */	
            $scope.rescheduleNetworkTasks = function (networkIDs, success_callback, must_confim) {
            	 
           	 if (networkIDs != null && networkIDs != "" ) {
           		 DataSrv.callRestWS( RestURLHelper.networkRescheduleTasksURL(networkIDs), 
           			function(response) {
   			 			success_callback();
   			 			$scope.restartTimerRemaining(); 
   			 			$scope.actionExecuted = true;
   			 			$scope.actionIdentifier = "REAGENDANDO TAREAS" + response.data.msg;
       		 		},	 
       		 		function() { 
       		 			alert("Error en la llamada a rescheduleTasks. Recargue la aplicación.");
       		 		}
           		);
           	  }
            };
         
         /**
          * Retorna una lista de los ids de reds seleccionados separados por comas en formato string
          */
         $scope.currentSelectedNetworkList = function() {
        	 
        	 var selected = []; 
        	 
        	 angular.forEach($scope.networks.selected, function(value, key) {
        		 if (value) 
        			 selected.push(key);
        	 });
        	 
        	 return  selected.join(',');
        	 
         };
         
   	  
         /** 
     	 * openHistory 
     	 *     
     	 **/	
     	 $scope.openHistory = function (networkID) {
     	
     		    var modalInstance = $uibModal.open({
     		      animation: true,
     		      templateUrl: 'modules/app/history-tpl.html',
     		      controller: 'HistoryCtrl',
     		      size: 'lg',
     		      resolve: {
     		  	      networkID: function() { return networkID; }
     		      }
   
     	    });
     	
     	    modalInstance.result.then( function () {}, function () {});
     	   
     	}; /* fin openRecordDiagnose */ 
     	
       
     	/**
         * Obtiene el Running Status
         */	
         $scope.updateRunningStatus = function () {
         	 
    		 DataSrv.callRestWS( RestURLHelper.getRunningStatus(), function(response) { 
    			 $scope.runningStatus = response.data;
    		 });
     
         };
        
     
         
    }])

    /* History Controller*/
	.controller('HistoryCtrl', ['$scope', '$uibModal', '$uibModalInstance', 'RestURLHelper', 'DataSrv', 'TableSrv','networkID', function ($scope, $uibModal, $uibModalInstance,RestURLHelper, DataSrv, TableSrv, networkID) {
	
	
		 /** 
      	 * loadSnapshots 
      	 **/
     	$scope.loadSnapshots = function(networkID) {
	     	DataSrv.callRestWS( RestURLHelper.networkSnapshotsURLByID(networkID), function(response) {		
				$scope.snapshotsTable = TableSrv.createNgTableFromArray(response.data._embedded.snapshot);
			});
		};
		
		$scope.loadSnapshots(networkID);
		
		// Accciones de los botones del modal
		$scope.ok = function () { $uibModalInstance.close(null); };
		$scope.cancel = function () { $uibModalInstance.dismiss('cancel');};
		
		 /** 
     	 * openLog
     	 **/	
     	 $scope.openLog = function (snapshot) {
     	
     		    var modalInstance = $uibModal.open({
     		      animation: true,
     		      templateUrl: 'modules/app/log-tpl.html',
     		      controller: 'LogCtrl',
     		      size: 'lg',
     		      resolve: {
     		  	      snapshotID: function() { return RestURLHelper.OIDfromEntity(snapshot); }
     		      }
   
     	    });
     	
     	    modalInstance.result.then( function () {}, function () {});
     	   
     	}; /* fin openRecordDiagnose */ 
     	
     	 /** 
     	 * stopHarvesting  
     	 **/	
     	 $scope.stopHarvesting = function (snapshot) {
     	
     		  RestURLHelper.OIDfromEntity(snapshot); 
     		  
     		  DataSrv.callRestWS( RestURLHelper.networkActionURL('STOP_HARVESTING',RestURLHelper.OIDfromEntity(snapshot)), function(response) {
     				$scope.loadSnapshots(networkID); 
     		  });
	
     	 };
     	 
     	
		
     	 

}])
	/* Log Controller*/
	.controller('LogCtrl', ['$scope', '$uibModalInstance', 'RestURLHelper', 'DataSrv', 'TableSrv','snapshotID', function ($scope, $uibModalInstance,RestURLHelper, DataSrv, TableSrv, snapshotID) {
	
	
		DataSrv.callRestWS( RestURLHelper.snapshotLogURLByID(snapshotID), function(response) {		
			$scope.logTable = TableSrv.createNgTableFromArray(response.data._embedded.log);
		});
		
		
		// Accciones de los botones del modal
		$scope.ok = function () { $uibModalInstance.close(null); };
		$scope.cancel = function () { $uibModalInstance.dismiss('cancel');};
		
	
}]);  
