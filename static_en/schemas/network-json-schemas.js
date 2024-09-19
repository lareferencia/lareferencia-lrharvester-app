/* 
 *  This is the default license template.
 *  
 *  File: network-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */

angular.module('network.json.schemas', []).service('JSONNetworkSchemas',  function() {
    
    /** Network Form Data **/
    this.network_schema = {
        type: "object",
        properties: {
          acronym : { type: "string", minLength: 2, maxLength: 10, title: "Repository Acronym", description: "Repository identifying acronym (must be unique)", required: true },
          name: { type: "string", minLength: 2, title: "Repository Name", description: "Repository name", required: true },
          institutionAcronym: { type: "string", minLength: 2, title: "Institution Acronym", description: "Institution acronym", required: true},
          institutionName: { type: "string", minLength: 2, title: "Institution", description: "Institution name", required: true},
          published :{ type: "boolean", title: "Public visible?", description: "The network is visible to the public" },
          scheduleCronExpression : { type: "string", title: "Schedule tasks expression", description: "Cron expression to schedule harvesting", "default": "* 0 0 29 2 *" }, 
          
          originURL: { type: "string", title: "OAI-PMH URL", description: "Harvesting URL", required: false},
          
          metadataPrefix: {
                "title": "Metadata Prefix",
                "type": "string",
                "enum": ["mtd-br","imf","mets","oai_dc","xoai","mtd2-br","oai_openaire","oai_openaire_jats"],
                "default": "oai_dc"
          },
                
          sets: {
              "type": "array",
              "title": "Sets",
              "items": {
                "type": "string",
                "title": "SetSpec"
              }
          },
         
          metadataStoreSchema: {
                "title": "Metadata Store Format",
                "type": "string",
                "enum": ["xoai","xoai_openaire"],
                "default": "xoai"
          },
          	      
        }
     };
    
    this.network_form = [ 
      { "type": "help",
        "helpvalue": "<div class=\"alert alert-info\">Main data and harvesting URL</div>"
      },
      { type: "submit", title: "Save changes" },
      {
        "type": "section",
        "htmlClass": "row",
        "items": [
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "acronym"
            ]
          },
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "name"
            ]
          }
        ]
      },
      {
        "type": "section",
        "htmlClass": "row",
        "items": [
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "institutionAcronym"
            ]
          },
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "institutionName"
            ]
          }
        ]
       },
       {
            "type": "section",
            "htmlClass": "row",
            "items": [
              {
                "type": "section",
                "htmlClass": "col-xs-4",
                "items": [
                  "scheduleCronExpression"
                ]
              },
              {
                "type": "section",
                "htmlClass": "col-xs-4",
                "items": [
                  "metadataStoreSchema"
                ]
              },
              {
                "type": "section",
                "htmlClass": "col-xs-4",
                "items": [
                  "published"
                ]
              },
            ]
       },
       {
            "type": "section",
            "htmlClass": "row",
            "items": [
              {
                "type": "section",
                "htmlClass": "col-xs-8",
                "items": [
                  "originURL"
                ]
              },
              {
                "type": "section",
                "htmlClass": "col-xs-4",
                "items": [
                  "metadataPrefix"
                ]
              },
            ]
       },
       {
            "type": "section",
            "htmlClass": "row",
            "items": [
              {
                "type": "section",
                "htmlClass": "col-xs-8",
                "items": [
                  "sets"
                ]
              },
              {
                "type": "section",
                "htmlClass": "col-xs-4",
                "items": [
                  
                ]
              },
            ]
       },
       
       
          
      { type: "submit", title: "Save changes" }
    ];
    
    this.network_validation_schema = {
         type: "object",
            properties: {
              prevalidator: { type: "string", title: "Pre Validator", description: "This validator excludes from snapshot at harvesting time." },
              validator: { type: "string", title: "Validator", description: "" },
              transformer: { type: "string", title: "Primary Transformer", description: "" },
              secondaryTransformer: { type: "string", title: "Secondary Transformer", description: "" },
            }	
    };
    
    this.network_validation_form =  function(validatorsArray, transformersArray) {

        validatorTitleMap = {'':'None'};
        transformerTitleMap = {'':'None'};
        
        for (var i=0;i<validatorsArray.length;i++) {
            var validator = validatorsArray[i];
            validatorTitleMap[ validator._links.self.href ] = validator.name;
        }
        
        for (var i=0;i<transformersArray.length;i++) {
            var transformer = transformersArray[i];
            transformerTitleMap[ transformer._links.self.href ] = transformer.name;
        }
        
        
        return [ { "type": "help", "helpvalue": "<div class=\"alert alert-info\">Please configure transformers and validators.</div>"},	
            
                 { key: "prevalidator", type: "select", "titleMap": validatorTitleMap },
                 { key: "validator", type: "select", "titleMap": validatorTitleMap },
                 { key: "transformer", type: "select", "titleMap": transformerTitleMap },
                 { key: "secondaryTransformer", type: "select", "titleMap": transformerTitleMap },
                 { type: "submit", title: "Save changes" }
               ];
        
    };
    
    this.buildTitleMap =  function(keyName, objArray) {

        objTitleMap = {};
        
        for (var i=0;i<objArray.length;i++) {
            var obj = objArray[i];
            objTitleMap[ obj._links.self.href ] = obj.name;
        }
    
        return  { "key": keyName, type: "select", "titleMap": objTitleMap };
               
    };
          	                       
                             	    
    
    
    /** Network Properties Form Data **/
    
    this.generate_network_actions_schema = function(propertiesArray) {
        
        var schema = { type: "object", properties: {} };
        
        for (var i=0;i<propertiesArray.length;i++) {
            var property = propertiesArray[i];
            schema.properties[property.name] = { type: "boolean", title: property.description + " (" + property.name + ") "};
        }
        
        return schema;
    };
    
    this.generate_network_actions_model = function(propertiesArray) {
        
        var model = {};
        
        for (var i=0;i<propertiesArray.length;i++) {
            var property = propertiesArray[i];
            model[property.name] = property.value;
        }
        
        return model;
    };
        
    
    this.network_properties_form = [
    { "type": "help", "helpvalue": "<div class=\"alert alert-info\">Please mark the tasks that will be executed at schedule run.</div>"},	
    { type: "submit", title: "Save changes" }, 
    {"type": "section", "htmlClass": "row", "items": [ 
        { "type": "section", "htmlClass": "col-xs-12", "items": [ 
            "*"
        ] } 
    ] }, 
    { "type": "submit", title: "Save changes" } ];
    

});