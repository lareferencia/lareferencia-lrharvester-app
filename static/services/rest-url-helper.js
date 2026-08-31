/* 
 *  This is the default license template.
 *  
 *  File: rest-url-helper.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
angular.module('rest.url.helper', ['rest.url.rebase']).service('RestURLHelper',  [ 'ReBaseURLHelper',
     
    function(ReBaseURLHelper) {
	
    	
      this.listNetworks = function () {
  		  return ReBaseURLHelper.rebaseURL('private/networks');	
  	  };	
  	  
  	  this.listMetadataFormats = function () {
		  return ReBaseURLHelper.rebaseURL('public/listMetadataFormats');	
	  };	
	  
  	 this.listNetworkActions = function () {
 		  return ReBaseURLHelper.rebaseURL('private/listNetworkActions');	
 	  };
 	  
 	 this.getRunningStatus = function () {
		  return ReBaseURLHelper.rebaseURL('public/getRunningStatus');	
	  }; 
 	  
 	 this.listNetworkProperties = function () {
		  return ReBaseURLHelper.rebaseURL('private/listNetworkProperties');	
	  };
    	
	  this.networkURLByID = function (networkID) {
		  return ReBaseURLHelper.rebaseURL('rest/network/' + networkID);	
	  };
	  
	  this.networkSnapshotsURLByID = function (networkID) {
		  return ReBaseURLHelper.rebaseURL('rest/snapshot/search/findByNetworkIdOrdered?network_id=' + networkID );	
	  };
	  
	  this.snapshotLogURLByID = function (snapshotID) {
		  return ReBaseURLHelper.rebaseURL('rest/log/search/findBySnapshotId?snapshot_id=' + snapshotID + '&size=1000');
	  };
	  
	  this.validatorURLByID = function (id) {
		  return ReBaseURLHelper.rebaseURL('rest/validator/' + id);	
	  };

	  this.cloneValidatorURLByID = function (id) {
		return ReBaseURLHelper.rebaseURL('private/cloneValidator/' + id);	
	  };
	  
	  this.transformerURLByID = function (id) {
		  return ReBaseURLHelper.rebaseURL('rest/transformer/' + id);	
	  };

	  this.cloneTransformerURLByID = function (id) {
		return ReBaseURLHelper.rebaseURL('private/cloneTransformer/' + id);	
	  };
	  
	  this.rulesURLByTypeAndID = function (type, id) {
		  if (type == 'transformer')
			  return ReBaseURLHelper.rebaseURL('rest/transformer/' + id);	
		  else if (type == 'validator')
		  	return ReBaseURLHelper.rebaseURL('rest/validator/' + id);	
	  };
	  
	  this.transformerRulesURLByID = function (id) {
		  return ReBaseURLHelper.rebaseURL('rest/transformer/' + id + '/rules');	
	  };
	  
	  this.propertyURLByID = function (propertyID) {
		  return ReBaseURLHelper.rebaseURL('rest/property/' + propertyID);	
	  };
	  
	  this.originURLByID = function (originID) {
		  return ReBaseURLHelper.rebaseURL('rest/origin/' + originID);	
	  };
	  	  
	  this.network_propertyURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/network_property');	
	  };
	  
	  this.propertyURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/property');	
	  }; 
	  
	  this.setURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/set');	
	  }; 
	  
	  this.networkURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/network');	
	  }; 
	  
	  this.validatorURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/validator');	
	  }; 
	  
	  this.transformerURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/transformer');	
	  }; 
	  
	  this.rulesURLByType = function (type) {
		  if (type == 'transformer')		  
			  return ReBaseURLHelper.rebaseURL('rest/transformer');	
		  else if (type == 'validator')
		  	  return ReBaseURLHelper.rebaseURL('rest/validator');	
	  }; 
	  
	  this.originURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/origin');	
	  }; 
	  
	  this.validatorRuleURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/validatorRule');	
	  };
	  
	  this.transformerRuleURL = function () {
		  return ReBaseURLHelper.rebaseURL('rest/transformerRule');	
	  };
	  
	  this.ruleURLByType = function (type) {
		  if (type == 'transformer')		  
			  return ReBaseURLHelper.rebaseURL('rest/transformerRule');	
		  else if (type == 'validator')
			  return ReBaseURLHelper.rebaseURL('rest/validatorRule');	
	  };
	  
	  
	  this.urlFromEntity = function (entity) {
		  return entity._links.self.href;
	  }; 
	  
	  
	  this.OIDfromEntity = function (entity) {
		  var splitted_url = entity._links.self.href.split("/");
  		  return splitted_url[ splitted_url.length - 1 ];
	  }; 
	  
	  this.networkActionURL = function (action, incremental, networkIDs) { 
		  var idsString = networkIDs;
		  return ReBaseURLHelper.rebaseURL('private/networkAction/' + action + '/' +  incremental + '/' + idsString);  
	  };
	  
	  this.networkKillTasksURL = function (networkIDs) { 
		  var idsString = networkIDs;
		  return ReBaseURLHelper.rebaseURL('private/killNetworkTasks/' + idsString);  
	  };
	  
	  this.networkRescheduleTasksURL = function (networkIDs) { 
		  var idsString = networkIDs;
		  return ReBaseURLHelper.rebaseURL('private/rescheduleNetworkTasks/' + idsString);  
	  };
	  
	  this.networkActionsURL = function (networkIDs) { 
		  var idsString = networkIDs;
		  return ReBaseURLHelper.rebaseURL('private/networkActions/' + idsString);  
	  };
	  
	  this.diagnoseURLByID = function (snapshotID, fqList) {
		  
		  if (fqList.length == 0)
			  return ReBaseURLHelper.rebaseURL('public/diagnose/' + snapshotID );	

		  
		  var fqEncodedList = [];
		  
		  for(var i=0;i<fqList.length;i++) {
			  fqEncodedList.push( encodeURI(fqList[i]) );
		  }
		  
		  return ReBaseURLHelper.rebaseURL('public/diagnose/' + snapshotID + '/' + fqEncodedList.join(',') + '');	
	  };
	  
	 
	  
	  this.diagnoseRuleOccrURLByID = function (snapshotID, ruleID, fqList) {  
		  
		  if (fqList.length == 0)
			  return ReBaseURLHelper.rebaseURL('public/diagnoseValidationOcurrences/' + snapshotID + '/' + ruleID );	

		  
		  var fqEncodedList = [];
		  
		  for(var i=0;i<fqList.length;i++) {
			  fqEncodedList.push( encodeURI(fqList[i]) );
		  }
		  
		  
		  return ReBaseURLHelper.rebaseURL('public/diagnoseValidationOcurrences/' + snapshotID + '/' + ruleID + '/' + fqEncodedList.join(',') + '');	
	  };
	  
	  
	  this.diagnoseRecordListURLByID = function (snapshotID, fqList) {
		  
		  if (fqList.length == 0)
			  return ReBaseURLHelper.rebaseURL('public/diagnoseListRecordValidationResults/' + snapshotID + '/fq');	

		  
		  var fqEncodedList = [];
		  
		  for(var i=0;i<fqList.length;i++) {
			  fqEncodedList.push( encodeURI(fqList[i]) );
		  }
		  
		  return ReBaseURLHelper.rebaseURL('public/diagnoseListRecordValidationResults/' + snapshotID + '/' + fqEncodedList.join(',') + '');	
	  };
	  
	  
	  this.recordMetadataURLByID = function (recordID) {		  
		  return ReBaseURLHelper.rebaseURL('public/getRecordMetadataByID/' + recordID);	
	  };
}]);