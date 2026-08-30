/* 
 *  This is the default license template.
 *  
 *  File: network.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
/**
 * @module Items
 * @summary Items module
 */

/* globals window, angular, document */

angular.module('network', [
    'ngResource',
    'ui.bootstrap',
    'ui.router',
    'schemaForm',
    'table.services',
    'rest.url.helper',
    'data.services',
    'network.json.schemas',
    'attributes.json.schemas'
])

    .config(['$stateProvider', function ($stateProvider) {
        'use strict';

        $stateProvider
            .state('network', {
            	abstract: true,
                url: '/network',
                views: {
                    'main@': {
                        templateUrl: 'modules/network/network.html'
                    }
                }
            })
            .state('network.new', {
                url: '/new'
            })
            .state('network.edit', {
                url: '/:id',
            });
        
       
        
    }])

    .controller('network', ['$scope', '$state', '$stateParams', '$filter', 'TableSrv', 'RestURLHelper', 'DataSrv', 'JSONNetworkSchemas', 'JSONAttributesSchemas', function ($scope, $state, $stateParams, $filter, TableSrv, RestURLHelper, DataSrv, JSONNetworkSchemas, JSONAttributesSchemas) {
       
    	'use strict';
    	
    	
    	/** Tabs * */
    	$scope.tab = 1;

	    $scope.setTab = function(newTab){
	      $scope.tab = newTab;
	    };

	    $scope.isSet = function(tabNum){
	      return $scope.tab === tabNum;
	    };
		/** En tabs */
		
		// carga de las acciones disponibles y definicion de la tabla de redes
		DataSrv.callRestWS( RestURLHelper.listNetworkActions(), function(response) {
			$scope.networkActions = response.data;
		});
    	
    	$scope.is_new = true;
    	
    	if ($stateParams.id != null) {	
            $scope.network_id = Number($stateParams.id);
            $scope.is_new = false;
    	}
        
        // Indica si el formulario es válido, en principio se da por válido
    	// TODO: Creo que esto hay que manejarlo con más elegancia
    	$scope.is_form_valid = true;
      
    	// schema & form - network
    	$scope.network_schema = JSONNetworkSchemas.network_schema;
    	$scope.network_form = JSONNetworkSchemas.network_form;
	//$scope.network_schema.properties.acronym.readonly =  !$scope.is_new;

    	
    	
    	// schema & form - attributes // ATENCION !!!! POR DEFAULT SE ELIJE EL
		// PRIMER PROFILE INDEX 0 (PRIMERA LINEA ABAJO)
    	$scope.network_attr_profiles = JSONAttributesSchemas.profileDefinitionList;
    	
    	$scope.attr_profile = JSONAttributesSchemas.profileDefinitionList[0];
    	$scope.attr_schema = $scope.attr_profile.schema;
    	$scope.attr_form = $scope.attr_profile.form;
    	$scope.attr_model = { "@class" : $scope.attr_profile.className }

    	
    	// estructura del formulario de propiedades de redes
    	$scope.np_form = JSONNetworkSchemas.network_properties_form;
    	$scope.network_validation_schema = JSONNetworkSchemas.network_validation_schema;
    		
    	$scope.network_validation_model = {};
    	
    	// llamadas a los servicios para carga de los validadores y
		// transformadores disponibles
    	DataSrv.get( RestURLHelper.validatorURL()+ '?size=1000', function(validators) { 
    		
    		DataSrv.get( RestURLHelper.transformerURL()+ '?size=1000', function(transformers) { 
    			
    			$scope.network_validation_form = JSONNetworkSchemas.network_validation_form(validators.getItems(),transformers.getItems());

    			if ($scope.is_new) {
    				
    				$scope.network_validation_model['transformer'] = '';
    				$scope.network_validation_model['secondaryTransformer'] = '';
    				$scope.network_validation_model['validator'] = '';
    				$scope.network_validation_model['prevalidator'] = '';

    			}
    						
    		});		
    	});
    	

    	// datos formulario de propiedades de red
    	$scope.np_model = {};
		$scope.network_model = {};
		$scope.network_model.attributes = $scope.attr_model;
		$scope.network_model.sets = [""];
		$scope.network_model.properties = {};

    	
    	// schema del formulario de propiedades
		DataSrv.callRestWS( RestURLHelper.listNetworkProperties(), function(response) {
			$scope.np_schema = JSONNetworkSchemas.generate_network_actions_schema( response.data );
		},
		function(error) {var a = error;} ); // ATENCION!!!!!!!!
    	
    	if (! $scope.is_new) { // Si no es una red nueva
    		// obtención de datos, utilizando el id obtiene la url y luego el
			// servico de datos entrega una network, eso va al form model
    		DataSrv.get( RestURLHelper.networkURLByID($scope.network_id), 
    				function(network) {
    			    			
    						// el objeto de red obtenido es ahora el modelo del
							// formulario
    						$scope.network_model = network;	
    						
    						
    						// si no existe attributes, o no tiene atributo de
							// classes o si es de una clase que no existe en
							// este profile
    						if ( $scope.network_model.attributes == null || !( '@class' in $scope.network_model.attributes ) || JSONAttributesSchemas.profileDefinitionByClassName[ $scope.network_model.attributes['@class'] ]== null )
    							$scope.network_model.attributes = $scope.attr_model;	
    					
    						// se usa el objteto attr para obtener la class
							// correcta y cargar el schema de attr
    						var profile = JSONAttributesSchemas.profileDefinitionByClassName[ $scope.network_model.attributes['@class'] ];	
    						
    						if ( profile != null ) { // si el profile existe
														// se carga
    							$scope.changeProfile(profile);	
    						} else { // pero si es null, no existe en los
										// schemas un profile con class
										// compatible, entocnes se hace reset a
										// un profile existente (default)
    							$scope.network_model.attributes['@class'] = $scope.attr_profile.className; 
    							// se establece la class de acuerdo al profile default cargado al inicio
																									
    						}
    						
    						
    						
    						
    						/*
							 * $scope.attr_profile =
							 * JSONAttributesSchemas.profileDefinitionByClassName[
							 * $scope.network_model.attributes['@class'] ];
							 * $scope.attr_schema = $scope.attr_profile.schema;
							 * $scope.attr_form = $scope.attr_profile.form;
							 */
    						
    						
    						// se cargan los valores de transformadores y
							// validadores de la red
    						$scope.network_validation_model = {};
    						
    						if (network.getLinkItems("prevalidator") != null)
    							$scope.network_validation_model['prevalidator'] = RestURLHelper.urlFromEntity(network.getLinkItems("prevalidator"));
    						else 
    							$scope.network_validation_model['prevalidator'] = '';	
    						
    						if (network.getLinkItems("validator") != null)
    							$scope.network_validation_model['validator'] = RestURLHelper.urlFromEntity(network.getLinkItems("validator"));
    						else 
    							$scope.network_validation_model['validator'] = '';
    					
    						if ( network.getLinkItems("transformer") != null )
    							$scope.network_validation_model['transformer'] =  RestURLHelper.urlFromEntity(network.getLinkItems("transformer"));
    						else
    							$scope.network_validation_model['transformer'] = '';
    						
    						if ( network.getLinkItems("secondaryTransformer") != null )
    							$scope.network_validation_model['secondaryTransformer'] =  RestURLHelper.urlFromEntity(network.getLinkItems("secondaryTransformer"));
    						else
    							$scope.network_validation_model['secondaryTransformer'] = '';
    						
    						if ( network.originURL == null )
    							$scope.network_model.originURL = '';
    					
    						if ( $scope.network_model.sets == null )
    							$scope.network_model.sets = [];
    						
    						if ( $scope.network_model.properties == null )
    							$scope.network_model.properties = {};
    					
    						// map the loaded network properties into properties form model
    						Object.keys( $scope.network_model.properties ).forEach( function(key,index) {
    							$scope.np_model[key] = $scope.network_model.properties[key];
    						});

    						   					
    						if ( network.scheduleCronExpression ==  null )
    							$scope.network_model.scheduleCronExpression = '';
    						
    				}							
    		);
    	}
    	
    	
    	
	/**
	 * Handler de errores de almacenamiento en la bd
	 */
	function onSaveError(error) { // error callback
	 	$scope.saved = false;
	    $scope.save_error = true;
	    $scope.save_error_message = error.status + ": " + error.statusText;
	};
	
	
	function asocciateElement(name, callback){
		
		if ( $scope.network_validation_model[name] != '')
	 		$scope.network_model.associate(name, $scope.network_validation_model[name], callback, onSaveError );
	 	else
	 		$scope.network_model.unassociate(name, callback, onSaveError );
	}
	
	/**
	 * No hubo problemas de almacenamiento en la bd
	 */
	function onSaveSuccess() { 
	 	$scope.saved = true;
	    $scope.save_error = false;
	};
    	
	
	
		/***********************************************************************
		 * 
		 * Cambio de profile
		 * 
		 **********************************************************************/
		$scope.changeProfile = function(profile) {
			
			$scope.attr_profile = profile;
			$scope.attr_schema = profile.schema;
	    	$scope.attr_form = profile.form;
	    	$scope.attr_model["@class"] = profile.className;
		}

		$scope.networkActionCallback = function(obj) {};
    	
    	/***********************************************************************
		 * Handler del submit del formulario
		 **********************************************************************/
    	// cuando se presion grabar
    	$scope.onSubmit = function(networkEditForm, networkAttrForm, networkValidationEditForm, networkPropertiesEditForm) {
    	  
    	  	// Se valida el formulario
    	    $scope.$broadcast('schemaFormValidate');
    	    
    	    $scope.saved = false;
    	    $scope.save_error = false;
    	    $scope.is_form_valid = true;
    	    
    	    // clean empty sets 
	    	$scope.network_model.sets = $scope.network_model.sets.filter(function(e){return e}); 

    	    // Si resulta válido
    	    if (networkEditForm.$valid && networkAttrForm.$valid && networkValidationEditForm.$valid &&  networkPropertiesEditForm.$valid ) {
    	    		
				// Si es una red nueva y no fue grabada todavía
				if ( $scope.is_new ) { 
					
					// Se llama al servicio de add con url de network y el
					// modelo json del form
					DataSrv.add( RestURLHelper.networkURL(), $scope.network_model,
							
						function(network) { // callback de creación exitosa de
											// red
						
							onSaveSuccess();
							$scope.is_new = false; // ya no es una red nueva
							$scope.network_model = network; // se actualiza el
															// modelo del form
															// con el objeto
															// actualizable
							
							updateNetworkModel(); // se agregan los datos de
													// validadores/transformadores
													// y acciones
							    	    				
						}, // fin callback de add Network
						onSaveError
					); // fin de add Network
				
				} // fin de nueva red
				else { // Ya existe red, solo se actualizan los datos
					updateNetworkModel()
				}
					
    	    } else { // si no es valido se avisa a la interfaz
    	    	$scope.is_form_valid = false;
    	    }
    	}; /* fin de OnSubmit */ 
    	
    	
    	function updateNetworkModel() { // / Esta funcion actualiza los datos de
										// la red
    		
    		 $scope.network_model.attributesJSONSerialization = JSON.stringify($scope.network_model.attributes);
    		 //$scope.network_model.setsJSONSerialization = JSON.stringify($scope.network_model.sets);
    		 
 	    	 $scope.network_model.properties = $scope.np_model;
 	    	 //$scope.network_model.propertiesJSONSerialization = JSON.stringify($scope.network_model.properties);

    		
    		 // Se actualiza el modelo
		      $scope.network_model.updateItem( 
		    		  
		        $scope.network_model,	  
		        
		    	function() { // success callback
		    		
				 	onSaveSuccess();

				 	asocciateElement('prevalidator', function() {
				 		asocciateElement('validator', function() {
				 			asocciateElement('transformer', function() {
				 				asocciateElement('secondaryTransformer', function() {
				 				});
				 			});
				 		});
				 	});	    		
		    	},
		    	onSaveError
		      ); // fin de network_model.update
    	}
    	
    	

    }]);
