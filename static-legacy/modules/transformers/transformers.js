/* 
 *  This is the default license template.
 *  
 *  File: transformers.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
/**
 * @module Items
 * @summary Items module
 */

/*globals window, angular, document */

angular.module('transformers', [
    'ngResource',
    'ui.bootstrap',
    'ui.router',
    'schemaForm',
    'table.services',
    'rest.url.helper',
    'data.services',
    'rules'
])

    .config(['$stateProvider', function ($stateProvider) {
        'use strict';

        $stateProvider
            .state('transformers', {
                url: '/transformers',
                views: {
                    'main@': {
                        templateUrl: 'modules/transformers/transformers.html'
                    }
                }
            });
            
        
   
    }])

    .controller('transformers', ['$scope', '$stateParams', '$filter', 'TableSrv', 'RestURLHelper', 'DataSrv', function ($scope, $stateParams, $filter, TableSrv, RestURLHelper, DataSrv) {
       
    	'use strict';

    	$scope.loadTransformers = function() { 	
			DataSrv.list( RestURLHelper.transformerURL()+ '?size=1000', function(transformers) {
				
				$scope.transformers = transformers;
				$scope.transformersTable = TableSrv.createNgTableFromGetData( 
						function(params) { 
							return $scope.transformers.getItems(); 
						}
				);
			});
		};
		
		$scope.loadTransformers();
    	
    	/*$scope.transformersTable = TableSrv.createNgTableFromWsURL(RestURLHelper.transformerURL(), 
        		function(data) { 
					return { 
						data:   data._embedded.transformer,
						total: data.page.totalElements,
						totalElements: data.page.totalElements,
						totalPages: data.page.totalPages,
						pageNumber: data.page.number
					
					};
				}, 0, 25  
		);*/
    	
    	/**
    	 * Refresh de tabla
    	 */
    	$scope.transformersTableRefreshCallback = function() {  
			$scope.loadTransformers();
			//$scope.transformers.reload( function (obj) { 
			//	$scope.transformersTable.reload();  
				//$scope.loadTransformers();
			//} );
    	};
    	
    	
    	 /** 
    	 * deleteValidator: Borrado de un transformador
    	 ***/
    	  $scope.deleteTransformer = function(transformer) {
    		      		  
    		   // llamada al borrado
    		  transformer.remove( function() {	
    			  		$scope.transformersTableRefreshCallback(); 
    		  }
    		   ///// ATENCION: FALTA LA LLAMADA AL CALLBACK DE ERROR
    		  );   	   
		  }; 
		  
		   /**
		   * cloneTransformer: Clona el validador 
		   ***/
		  $scope.cloneTransformer = function(id) {
			DataSrv.callRestWS( RestURLHelper.cloneTransformerURLByID(id) , function(response) {
				$scope.transformersTableRefreshCallback(); 
			});
		  };
        
    
			
    	
    }]);