/* 
 *  This is the default license template.
 *  
 *  File: data-services.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
var BackendDataServiceModule = angular.module('data.services', ['spring-data-rest', 'rest.url.helper']);

BackendDataServiceModule.service('DataSrv',  ["$http", "SpringDataRestAdapter", "RestURLHelper", 
     
    function($http, SpringDataRestAdapter, RestURLHelper) {
	
	 var linksToProcess = ['prevalidator', 'validator', 'transformer', 'secondaryTransformer','rules']; 
	

	 var add_methods = function(processedResponse) {
		 	 
		 
		 /* Reload */
		  processedResponse.reload = function(success_callback) {
			  
			  var httpPromise = $http.get( RestURLHelper.urlFromEntity(processedResponse) );  
			  
			  SpringDataRestAdapter.process(httpPromise, linksToProcess, true).then( function (item) {
				   
				  processedResponse = add_methods(item);
				  
			      /* devuelve el item creado al callback */
				  success_callback(processedResponse);
			             
			  });
			
		  };
		 
		 
		 /*  una funcion para asociar objetos al item */
		  processedResponse.associate = function(member_name, uri_list, success_callback, fail_callback) { 
			  
			  	// al asociar un objeto debe recargarse el objeto desde el ww
			  	var intercept_success_callback = function(data) {
			  		processedResponse.reload(success_callback);
			  	};
			  	
				var resource = processedResponse._resources(member_name,{}, {associate: { method: 'PUT', headers : {'Content-Type' : 'text/uri-list'}}} );
				resource.associate(uri_list, intercept_success_callback, fail_callback); 
		  };
		  
		  

		 /*  una funcion para desasociar objetos al item */
		  processedResponse.unassociate = function(member_name, success_callback, fail_callback) { 
			  
			  	// al asociar un objeto debe recargarse el objeto desde el ww
			  	var intercept_success_callback = function(data) {
			  		processedResponse.reload(success_callback);
			  	};
			  	
				var resource = processedResponse._resources(member_name,{}, {unassociate: { method: 'DELETE'}} );
				resource.unassociate(intercept_success_callback, fail_callback); 
		  };
		 
		  	  
		  /*  una funcion para agregar objetos a una colección miembro */
		  processedResponse.addToCollection = function(collection_name, uri_list, success_callback, fail_callback) { 
			    // al agregar a una colección debe recargarse el objeto desde el ww
			  	var intercept_success_callback = function(data) {
			  		processedResponse.reload(success_callback);
			  	};
			  
				var resource = processedResponse._resources(collection_name,{}, {addToCollection: { method: 'POST', headers : {'Content-Type' : 'text/uri-list'}}} );
				resource.addToCollection(uri_list, intercept_success_callback, fail_callback); 
		  };
		  
		
		  
		  /*  una funcion para desvincular todos los elementos de una coleccion */
		  processedResponse.unbindCollection = function(collection_name, success_callback, fail_callback) { 
			    // al agregar a una colección debe recargarse el objeto desde el ww
			  	var intercept_success_callback = function(data) {
			  		processedResponse.reload(success_callback);
			  	};
			  
				var resource = processedResponse._resources(collection_name,{}, {unbindCollection: { method: 'PUT', headers : {'Content-Type' : 'text/uri-list'}}} );
				resource.unbindCollection('', intercept_success_callback, fail_callback); 
		  };
		  
		  
		  /*  una funcion para borrar un item de una  coleccion */
		  processedResponse.deleteItemFromCollection = function(collection_name, item, success_callback, fail_callback) { 
			    // al modificar una colección debe recargarse el objeto desde el ww
			  	var intercept_success_callback = function(data) {
			  		// ademas luego de removerlo y liberarlo de la collection debe borrar el item con un remove propio
			  		item.remove(  function() { processedResponse.reload(success_callback); }, fail_callback ) ;
			  	};
			  	
			  	var item_id = item.getObjectID();
			  
				var resource = processedResponse._resources(collection_name + "/" + item_id,{}, {deleteItemFromCollection: { method: 'DELETE'} });
				resource.deleteItemFromCollection('', intercept_success_callback, fail_callback); 
		  };
		  
		  
		  /* una funcion para hacer un update del item  */
		  processedResponse.update = function(update_callback, fail_callback) {  
			  var resource = processedResponse._resources('self',{}, {update: { method: 'PATCH'}} );
			  resource.update(processedResponse, update_callback, fail_callback); 
		  };
		  
		  /* una funcion para hacer un update del item  */
		  processedResponse.updateItem = function(item, update_callback, fail_callback) {  
			  var resource = item._resources('self',{}, {update: { method: 'PATCH'}} );
			  resource.update(item, update_callback, fail_callback); 
		  };
		  
		  /* una funcion para hacer un delete item  */
		  processedResponse.remove = function(delete_callback, fail_callback) {  	  
			  var resource = processedResponse._resources('self',{}, {remove: { method: 'DELETE'}} );
			  resource.remove(delete_callback, delete_callback); 
		  };
		  
	
		  
		  
		  /**
		   * Obtención de los items 
		   */
		  processedResponse.getItems = function() {
			  if ( processedResponse._embeddedItems != null )
				  return processedResponse._embeddedItems;
			  else
				  return [];
		  };
		  
		  /**
		   * Obtención de los items de un link, esta función depende del procesamiento realizado recursivamente sobre processedResponse con add_methods
		   */
		  processedResponse.getLinkItems = function(association_link_name) {
			  
			  if (processedResponse['_' + association_link_name ] != null ) {
				  if ( processedResponse['_' + association_link_name ]._embeddedItems != null )
					  return processedResponse['_' + association_link_name ]._embeddedItems;
				  else
					  return processedResponse['_' + association_link_name ];
			  }
			  else
				  return null;
		  };
		  
		  
		  /***
		   * Obtención del id del objeto dentro de la base de datos
		   */
		  processedResponse.getObjectID = function() {
			  var parsed_self_url = processedResponse._links.self.href.split('/');
			  return parsed_self_url[parsed_self_url.length-1];
		  };
		  
		  
		  
		  /* Si el objeto posee items */
		  if ( processedResponse._embeddedItems != null ) {
			  
			  /* Agrega a cada item la posibilidad de obtener su id */ 
			  angular.forEach(processedResponse._embeddedItems, function(item, i) {
				  
				  item.getObjectID = function() {
					  var parsed_self_url = this._links.self.href.split('/');
					  return parsed_self_url[parsed_self_url.length-1];
				  };
				  
				  item.remove = function(delete_callback, fail_callback) {  	  
					  var resource = this._resources('self',{}, {remove: { method: 'DELETE'}} );
					  resource.remove(delete_callback, delete_callback); 
				  };
				  
				  
			  }); 
		  }
		  
		  
		  // para cada link para procesar
		  angular.forEach(linksToProcess, function(link, i) {
			  
			  if ( processedResponse[link] != null ) {
				  
				  if ( processedResponse[link]._embeddedItems != null  ) {
					  
					  angular.forEach(processedResponse[link]._embeddedItems, function(item, j) {
						  processedResponse[link]._embeddedItems[j] = add_methods(item);  
					  });  
					  
				  } else if ( processedResponse[link]._resources != null ) {
					  processedResponse[link] =  add_methods(processedResponse[link]);
				  }
				  
				  processedResponse['_' + link ] = processedResponse[link];
				  delete processedResponse[link];  
			  }
	
		  });
		  
	
		  return processedResponse;
		 
	 };	
	  	
		  
	  /**
	   * Get
	   * @param url
	   * @param success_callback
	   * @param error_callback
	   */
	  this.get = function(url, success_callback, error_callback ) {
		  
		  var httpPromise = $http.get(url);  
		  
		  SpringDataRestAdapter.process(httpPromise, linksToProcess, true).then( function (processedResponse) {
			   
			  var item = add_methods(processedResponse);
			  
		      /* devuelve el item creado al callback */
			  success_callback(item);
		             
		  }).catch(error_callback); // esto da error en el parse de eclipse pero no es error
	  }; 
	  
	  /**
	   * List
	   * @param url
	   * @param success_callback
	   * @param error_callback
	   */
	  this.list = function(url, success_callback, error_callback ) {
		  
		  var httpPromise = $http.get(url);  
		  
		  SpringDataRestAdapter.process(httpPromise, [], false).then( function (processedResponse) {
			   
			  var item = add_methods(processedResponse);
			  
		      /* devuelve el item creado al callback */
			  success_callback(item);
		             
		  }).catch(error_callback); // esto da error en el parse de eclipse pero no es error
	  }; 
	  
	  /**
	   * GetObject
	   * @param url
	   * @param success_callback
	   * @param error_callback
	   */
	  this.get_object = function(url, success_callback, error_callback ) {
		  
		  var httpPromise = $http.get(url);  
		  
		  SpringDataRestAdapter.process(httpPromise, [], false).then( function (processedResponse) {
			   
			  var item = add_methods(processedResponse);
			  
		      /* devuelve el item creado al callback */
			  success_callback(item);
		             
		  }).catch(error_callback); // esto da error en el parse de eclipse pero no es error
	  };
	  
	  
	  /**
	   * Add
	   * @param url
	   * @param obj
	   * @param success_callback
	   * @param error_callback
	   */
	  this.add = function(url, obj, success_callback, error_callback) {
		  
		  var httpPromise = $http.post(url, obj); 
		  
		  SpringDataRestAdapter.process(httpPromise, linksToProcess, true).then( function (processedResponse) {
			    
			  var item = add_methods(processedResponse);
			
		      /* devuelve el item creado al callback */
			  success_callback(item);
		             
		  }).catch(error_callback); // esto da error en el parse de eclipse pero no es error
	 
	  };
	  
	  /**
	   * Llamada a una función remota
	   */
	  this.callRestWS = function(url, success_callback, error_callback) {
		  $http.get(url).then(success_callback, error_callback);
	  };
	  
	  /**
	   * Llamada a una función remota XML
	   */
	  this.callRestXMLWS = function(url, success_callback, error_callback) {
		  
		  var req = {
				  method: 'GET',
				  url: url,
				  headers: { 'Content-Type': 'application/xml; charset=utf-8', 'Accept' : 'application/xml'}
		  };

		  
		  $http(req).then(success_callback, error_callback);
	  };
		  
	
	
	
	  
}]);

