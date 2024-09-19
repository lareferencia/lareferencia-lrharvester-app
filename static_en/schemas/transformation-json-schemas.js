angular.module('transformation.json.schemas', []).service('JSONTransformationSchemas',  function() {
    
    
    this.form = [   
      { "type": "section",
         "htmlClass": "row",
        "items": [
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "name"
            ]
          },
          {
            "type": "section",
            "htmlClass": "col-xs-6",
            "items": [
              "description"
            ]
          },
     
        ]
      },
      
      { type: "submit", title: "Save" }
    
   ];




    this.schema = {
        type: "object",
        properties: {
            name : { type: "string", title: "Name", description: "" }, 
            description : { type: "string", title: "Description", description: "" },
        }
    };
    
    
    this.rule_data_form = [ "name", "description", "runorder"];
    
    this.rule_data_schema = {
            type: "object",
            properties: {
              name :{ type: "string", title: "Rule Name", description: "" }, 
              description :{ type: "string", title: "Description", description: "" },
              runorder :{ type: "integer", title: "Order", description: "Evaluation order" }, 

            }
    };
    
    
    
    var _RULES = [  
    
    { 		
            name : "Field value translation/mapping",
            className: "org.lareferencia.backend.validation.transformer.FieldContentTranslateRule",
            form: [ 
                    { type: "submit", title: "Save changes" }, "testFieldName", "writeFieldName", "replaceOccurrence", "testValueAsPrefix", "translationArray", { type: "submit", title: "Save changes" }],
            schema: {
                type: "object",
                    properties: {
                    translationArray: { type: "array", title: "Mapping list", description: "List of search/replace values", 
                    	items: {
                            "type": "object",
                            "title": "Translation",
                            "properties": {
                              "search": { "type": "string", "title": "Search" },
                              "replace": { "type": "string", "title": "Replace" },	
                            }
                    	}
                    },
                    testFieldName:{ type: "string", title: "Search field expression", description: "Expression for the search field.  Ex: dc.type.*" },
                    writeFieldName:{ type: "string", title: "Write field expression", description: "The name of the oai_dc field that will be created with the occurrence of Replace. Ex: dc.type " },
                    replaceOccurrence:{ type: "boolean", title: "Replace the occurrence with the new value", description: "Indicates if the occurrence in the Search field expression will be deleted" },
                    testValueAsPrefix:{ type: "boolean", title: "Evaluate as prefix?", description: "Indicates if the search value will be evaluated as a prefix of the content of the Search field expression." }, 
                    	
                    
                    }
                } /* end schema */
    },
    
    { 		
        name : "Field value translation/mapping (with priority)",
        className: "org.lareferencia.backend.validation.transformer.FieldContentPriorityTranslateRule",
        form: [ 
                { type: "submit", title: "Save changes" }, "testFieldName", "writeFieldName", "replaceOccurrence", "testValueAsPrefix", "replaceAllMatchingOccurrences", "translationArray", { type: "submit", title: "Save changes" }],
        schema: {
            type: "object",
                properties: {
                translationArray: { type: "array", title: "Mapping list", description: "List of search/replace values", 
                	items: {
                        "type": "object",
                        "title": "Translation",
                        "properties": {
                          "search": { "type": "string", "title": "Search" },
                          "replace": { "type": "string", "title": "Replace" },	
                        }
                	}
                },
                testFieldName:{ type: "string", title: "Search field expression", description: "Expression for the search field.  Ex: dc.type.*" },
                writeFieldName:{ type: "string", title: "Write field expression", description: "Expression for the write field.  Ex: dc.type.none" },
                replaceOccurrence:{ type: "boolean", title: "Replace the occurrence with the new value?", description: "" },
                testValueAsPrefix:{ type: "boolean", title: "Evaluate as prefix?", description: "" }, 
                replaceAllMatchingOccurrences:{ type: "boolean", title: "Replace all occurrences?", description: "" },  	
                
                }
            } /* end schema */
    },
    
    { 		
        name : "Field name mapping",
        className: "org.lareferencia.backend.validation.transformer.FieldNameTranslateRule",
        form: [ 
                { type: "submit", title: "Save changes" }, "sourceFieldName", "targetFieldName", { type: "submit", title: "Save changes" }],
        schema: {
            type: "object",
                properties: {
                	sourceFieldName:{ type: "string", title: "Source field name", description: "Ex: dc.type.calif " },
                	targetFieldName:{ type: "string", title: "Destination field name", description: "Ex: dc.type.none " },
                }
        } /* end schema */
    },
    
    { 		
        name : "Field name mapping (multiple)",
        className: "org.lareferencia.backend.validation.transformer.FieldNameBulkTranslateRule",
        form: [ 
                { type: "submit", title: "Save changes" }, "translationArray", { type: "submit", title: "Save changes" }],
        schema: {
            type: "object",
            properties: {
            translationArray: { type: "array", title: "Replacing list", description: "", 
            	items: {
                    "type": "object",
                    "title": "Replaces",
                    "properties": {
                      "search": { "type": "string", "title": "Search" },
                      "replace": { "type": "string", "title": "Replace" },	
                    }
            	}
            }
          }
        } /* end schema */
    },
    
    { 		
        name : "Regular expression field content replace",
        className: "org.lareferencia.backend.validation.transformer.RegexTranslateRule",
        form: [ 
                { type: "submit", title: "Save changes" }, "sourceFieldName", "targetFieldName", "removeMatchingOccurrences", "regexSearch", "regexReplace", { type: "submit", title: "Save changes" }],
        schema: {
            type: "object",
                properties: {
                	sourceFieldName:{ type: "string", title: "Source field name", description: "The name of the Source field name. Ex: dc.subject.cnpq " },
                	targetFieldName:{ type: "string", title: "Destination field name", description: "The name of the Replace field. Ex: dc.subject.por " },
                	regexSearch:{ type: "string", title: "Search regexp", description: "Regular expression with groups to reference in replace expression. Ex: CNPQ::(.+)" },
                	regexReplace:{ type: "string", title: "Replace regexp", description: "Replace regular expression (can contain group references). Ex: $1 " },
                	removeMatchingOccurrences:{ type: "boolean", title: "Delete found occurrences?", description: "Found occurrences must be deleted" },
                }
        } /* end schema */
    },
    
    { 		
        name : "Add Repository and Institution metadata",
        className: "org.lareferencia.backend.validation.transformer.AddRepoNameRule",
        form: [ "doRepoNameAppend","doRepoNameReplace","repoNameField","repoNamePrefix",
                "doInstNameAppend","doInstNameReplace","instNameField","instNamePrefix", "instAcronField","instAcronPrefix",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	doRepoNameAppend:{ type: "boolean", title: "Add repository name", description: "" },
                	doRepoNameReplace:{ type: "boolean", title: "Replace existing occurrences?", description: "" },
                	repoNameField:{ type: "string", title: "Repository field name", description: "Ex: dc.source.none" },
                	repoNamePrefix:{ type: "string", title: "Repository prefix", description: "Ex: reponame:" },
                	doInstNameAppend:{ type: "boolean", title: "Add institution metadata", description: "" },
                	doInstNameReplace:{ type: "boolean", title: "Replace existing occurrences?", description: "" },
                	instNameField:{ type: "string", title: "Institution name field name", description: "Ex: dc.source.none" },
                	instNamePrefix:{ type: "string", title: "Institution name prefix", description: "Ex: instname:" },
                	instAcronField:{ type: "string", title: "Institution acronym field name", description: "Ex: dc.source.none" },
                	instAcronPrefix:{ type: "string", title: "Institution acronym prefix", description: "Ex: instacron:" },
                	
                	
                }
        } /* end schema */
    },
    
    { 		
        name : "Conditional addition of field occurrences",
        className: "org.lareferencia.backend.validation.transformer.FieldContentConditionalAddOccrRule",
        form: [ { "key": "conditionalExpression", "type": "textarea" },"fieldName","valueToAdd","removeDuplicatedOccurrences",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	conditionalExpression:{ type: "string", title: "Expression to evaluate", description: "It is important to leave spaces between parentheses. \n Ex: ( dc.type=='info:eu-repo/semantics/article' AND dc.rights=%'info.+' ) OR ( dc.type=='info:eu-repo/semantics/bachelorThesis' )" },
                	fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.type.*" },
                	valueToAdd:{ type: "string", title: "Value to add if the condition is met", description: "Ex: info:eu-repo/semantics/article" },
                	removeDuplicatedOccurrences:{ type: "boolean", title: "Remove duplicate occurrences?", description: "" },
                }
        } /* end schema */
    },
    
    { 		
        name : "Remove duplicate occurrences in a field",
        className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateOccrsRule",
        form: ["fieldName",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.type.*" },
                }
        } /* end schema */
    },


        {
                name : "Add provenance metadata",
                className: "org.lareferencia.backend.validation.transformer.AddProvenanceMetadataRule",
                form: [
                        { type: "submit", title: "Save changes" }
                ],
                schema: {
                        type: "object",
                        properties: {
                        fieldName:{  },
                        }
                } /* end schema */
        },


    
    { 		
        name : "Remove all occurrences except the first",
        className: "org.lareferencia.backend.validation.transformer.RemoveAllButFirstOccrRule",
        form: ["fieldName",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.data.issued.*" },
                }
        } /* end schema */
    },
    
    { 		
        name : "Remove occurrences with repeated prefix",
        className: "org.lareferencia.backend.validation.transformer.RemoveDuplicatePrefixedOccrs",
        form: ["fieldName", "prefix",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.type.*" },
                	prefix:{ type: "string", title: "Prefix of the occurrences to evaluate", description: "Ex: instaname:" },

                }
        } /* end schema */
    },

    { 		
        name : "Remove redundant occurrences from a vocabulary",
        className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateVocabularyOccrsRule",
        form: ["fieldName",
                     "vocabulary",
              { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                        fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.type.*" },
                        vocabulary : { "type": "array", "title": "Vocabulary", 
                          items: { "type": "string", "title":"Value" }
                    }
                }
        } /* end schema */
    },
    
    { 		
        name : "Remove occurrences by blacklist",
        className: "org.lareferencia.backend.validation.transformer.RemoveBlacklistOccrsRule",
        form: ["fieldName",
                     "blacklist",
              { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                        fieldName:{ type: "string", title: "Name of the field to modify", description: "Ex: dc.type.*" },
                        blacklist : { "type": "array", "title": "Vocabulary", 
                          items: { "type": "string", "title":"Value" }
                    }
                }
        } /* end schema */
    },

    {
      name: "Add a value to a field",
      className: "org.lareferencia.backend.validation.transformer.FieldAddRule",
      form: [
        {type: "submit", title: "Save changes"}, "targetFieldName", "value", {
          type: "submit",
          title: "Save changes"
        }],
      schema: {
        type: "object",
        properties: {
          targetFieldName: {
            type: "string",
            title: "Destination field name",
            description: "The name of the oai_dc field of Replace. Ex: dc.type.none "
          },
          value: {type: "string", title: "Value", description: "Value to place in the record"},
        }
      } /* end schema */
    },
    
    { 		
        name : "Remove specific fields from heavy records",
        className: "org.lareferencia.backend.validation.transformer.ReduceHeavyRecords",
        form: ["maxRecordSize","fieldsToRemove",
              { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                		maxRecordSize:{ type: "integer", title: "Maximum record size in bytes.", description: "Fields will be removed only in records that exceed the size" },
                        fieldsToRemove : { "type": "array", "title": "Fields to remove", 
                          items: { "type": "string", "title":"Field expression" }
                    }
                }
        } /* end schema */
    },

    { 		
        name : "Transform oai identifier of the record",
        className: "org.lareferencia.backend.validation.transformer.IdentifierRegexRule",
        form: ["regexSearch", "regexReplace",
            { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                    regexSearch:  { type: "string", title: "Search regular expression", description: "The search regular expression, groups can be used to reference in the replacement expression. Ex: CNPQ::(.+)" },
                	regexReplace: { type: "string", title: "Replace regular expression", description: "The replacement expression, can contain references to the groups. Ex: $1 " },
                }
        } /* end schema */
    },

    { 		
        name : "Transforming a field removing all whitespaces occurrences",
        className: "org.lareferencia.backend.validation.transformer.FieldContentRemoveWhiteSpacesTranslateRule",
        form: [ "fieldName",
                { type: "submit", title: "Save changes" }
        ],
        schema: {
            type: "object",
                properties: {
                	fieldName:{ type: "string", title: "Field name to change", description: "Ex: dc.type.*" },
                }
        } /* end schema */
    },	
    
    { 		
        name : "Renaming node field names (Conditional)",
        className: "org.lareferencia.backend.validation.transformer.FieldNameConditionalTranslateRule",
        form: [ 
                { type: "submit", title: "Save changes" }, "sourceXPathExpression", "targetFieldName", { type: "submit", title: "Save changes" }],
        schema: {
            type: "object",
                properties: {
                	sourceXPathExpression:{ type: "string", title: "Node source selector (XPATH expression)", description: "XPath expression for selecting nodes to apply the renaming. Example: //*[local-name()='element' and @name='rights']/*[local-name()='field' and @name='value' and contains(text(), 'https://creativecommons.org')] " },
                	targetFieldName:{ type: "string", title: "Target field", description: "Target field name Example: oaire.licenseCondition " },
                }
        } /* end schema */
    },
    
]; //***** end of _RULES ******/// 
    


    /** mapping of rule definitions to an object **/
    var rules_defs_by_class  =  {}
    $.map( _RULES, function(rule, i ) { rules_defs_by_class[rule.className] = rule; });
    
    /** export the object with rule definitions **/
    this.ruleDefinitionByClassName = rules_defs_by_class;

});