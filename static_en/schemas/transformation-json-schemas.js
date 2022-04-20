/* 
 *  This is the default license template.
 *  
 *  File: transformation-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */

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
				            "title": "Traducción",
				            "properties": {
				              "search": { "type": "string", "title": "Search" },
				              "replace": { "type": "string", "title": "Replace" },	
				            }
				    	}
				    },
				    testFieldName:{ type: "string", title: "Search field expresion", description: "Expresion for the search field.  Ej: dc.type.*" },
				    writeFieldName:{ type: "string", title: "Write field expresion", description: "El Name del campo oai_dc que se creará con la ocurrencia de Replace Ej: dc.type " },
				    replaceOccurrence:{ type: "boolean", title: "Replace the ocurrence with the new value", description: "Indica si se eliminará la ocurrencia en el Search field expresion" },
				    testValueAsPrefix:{ type: "boolean", title: "Evaluate as prefix?", description: "Indica si el valor de búsqueda se evaluará como prefijo del contenido del Search field expresion." }, 
				    	
					
				    }
				} /* fin schema */
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
			            "title": "Traducción",
			            "properties": {
			              "search": { "type": "string", "title": "Search" },
			              "replace": { "type": "string", "title": "Replace" },	
			            }
			    	}
			    },
			    testFieldName:{ type: "string", title: "Search field expresion", description: "Expresion for the search field.  Ej: dc.type.*" },
			    writeFieldName:{ type: "string", title: "Write field expresion", description: "Expresion for the write field.  Ej: dc.type.none" },
			    replaceOccurrence:{ type: "boolean", title: "Replace the ocurrence with the new value?", description: "" },
			    testValueAsPrefix:{ type: "boolean", title: "Evaluate as prefix?", description: "" }, 
			    replaceAllMatchingOccurrences:{ type: "boolean", title: "Replace all ocurrences?", description: "" },  	
				
			    }
			} /* fin schema */
	},
	
	{ 		
		name : "Field name mapping",
		className: "org.lareferencia.backend.validation.transformer.FieldNameTranslateRule",
		form: [ 
		        { type: "submit", title: "Save changes" }, "sourceFieldName", "targetFieldName", { type: "submit", title: "Save changes" }],
		schema: {
			type: "object",
			    properties: {
			    	sourceFieldName:{ type: "string", title: "Source field name", description: "Ej: dc.type.calif " },
			    	targetFieldName:{ type: "string", title: "Destination field name", description: "Ej: dc.type.none " },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Field name mapping (múltiple)",
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
		} /* fin schema */
	},
	
	{ 		
		name : "Regular expresion field content replace",
		className: "org.lareferencia.backend.validation.transformer.RegexTranslateRule",
		form: [ 
		        { type: "submit", title: "Save changes" }, "sourceFieldName", "targetFieldName", "removeMatchingOccurrences", "regexSearch", "regexReplace", { type: "submit", title: "Save changes" }],
		schema: {
			type: "object",
			    properties: {
			    	sourceFieldName:{ type: "string", title: "Source field name", description: "El Name del Source field name. Ej: dc.subject.cnpq " },
			    	targetFieldName:{ type: "string", title: "Destination field name", description: "El Name del campo de Replace Ej: dc.subject.por " },
			    	regexSearch:{ type: "string", title: "Search regexp", description: "Regular expresion with groups to refence in replace expresion. Ej: CNPQ::(.+)" },
			    	regexReplace:{ type: "string", title: "Replace regexp", description: "Replace regular expresion (can contain gropus references). Ej: $1 " },
			    	removeMatchingOccurrences:{ type: "boolean", title: "Delete found ocurrences?", description: "Found ocurrences must be deleted" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Add Repository and Institution metatata ",
		className: "org.lareferencia.backend.validation.transformer.AddRepoNameRule",
		form: [ "doRepoNameAppend","doRepoNameReplace","repoNameField","repoNamePrefix",
		        "doInstNameAppend","doInstNameReplace","instNameField","instNamePrefix", "instAcronField","instAcronPrefix",
		        { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    	doRepoNameAppend:{ type: "boolean", title: "Add repository name", description: "" },
			    	doRepoNameReplace:{ type: "boolean", title: "Replace existing ocurrences?", description: "" },
			    	repoNameField:{ type: "string", title: "Repository field name", description: "Ej: dc.source.none" },
			    	repoNamePrefix:{ type: "string", title: "Repository prefix", description: "Ej: reponame:" },
			    	doInstNameAppend:{ type: "boolean", title: "Add institution metadata", description: "" },
			    	doInstNameReplace:{ type: "boolean", title: "Replace existing ocurrences?", description: "" },
			    	instNameField:{ type: "string", title: "Instituion name field name", description: "Ej: dc.source.none" },
			    	instNamePrefix:{ type: "string", title: "Institution name prefix", description: "Ej: instname:" },
			    	instAcronField:{ type: "string", title: "Institution acronym field name", description: "Ej: dc.source.none" },
			    	instAcronPrefix:{ type: "string", title: "Institution acronym prefix", description: "Ej: instacron:" },
			    	
			    	
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Agregado condicional de ocurrencias de campo",
		className: "org.lareferencia.backend.validation.transformer.FieldContentConditionalAddOccrRule",
		form: [ { "key": "conditionalExpression", "type": "textarea" },"fieldName","valueToAdd","removeDuplicatedOccurrences",
		        { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    	conditionalExpression:{ type: "string", title: "Expresion a evaluar", description: "Es importante dejar espacios entre los paréntesis. \n Ej: ( dc.type=='info:eu-repo/semantics/article' AND dc.rights=%'info.+' ) OR ( dc.type=='info:eu-repo/semantics/bachelorThesis' )" },
			    	fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.type.*" },
			    	valueToAdd:{ type: "string", title: "Valor a agregar en caso de que se cumpla el condicional", description: "Ej: info:eu-repo/semantics/article" },
			    	removeDuplicatedOccurrences:{ type: "boolean", title: "¿Remover ocurrencias duplicadas?", description: "" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Remover ocurrencias duplicadas en un campo",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateOccrsRule",
		form: ["fieldName",
		        { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.type.*" },
			    }
		} /* fin schema */
	},


        {
                name : "Agregado de metadatos provenance",
                className: "org.lareferencia.backend.validation.transformer.AddProvenanceMetadataRule",
                form: [
                        { type: "submit", title: "Save changes" }
                ],
                schema: {
                        type: "object",
                        properties: {
                        fieldName:{  },
                        }
                } /* fin schema */
        },


	
	{ 		
		name : "Remover todas las ocurrencias excepto la primera",
		className: "org.lareferencia.backend.validation.transformer.RemoveAllButFirstOccrRule",
		form: ["fieldName",
		        { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.data.issued.*" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Remover ocurrencias con prefijo repetido",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicatePrefixedOccrs",
		form: ["fieldName", "prefix",
		        { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.type.*" },
			    	prefix:{ type: "string", title: "Prefijo de las occurrencias a evaluar", description: "Ej: instaname:" },

			    }
		} /* fin schema */
	},

	{ 		
		name : "Remover ocurrencias redundantes de un vocabulario",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateVocabularyOccrsRule",
		form: ["fieldName",
					 "vocabulary",
		      { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
						fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.type.*" },
						vocabulary : { "type": "array", "title": "Vocabulario", 
				          items: { "type": "string", "title":"valor" }
				    }
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Remover ocurrencias por blacklist",
		className: "org.lareferencia.backend.validation.transformer.RemoveBlacklistOccrsRule",
		form: ["fieldName",
					 "blacklist",
		      { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
						fieldName:{ type: "string", title: "Name del campo a modificar", description: "Ej: dc.type.*" },
						blacklist : { "type": "array", "title": "Vocabulario", 
				          items: { "type": "string", "title":"valor" }
				    }
			    }
		} /* fin schema */
	},

    {
      name: "Adicionar um valor a um campo",
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
            description: "El Name del campo oai_dc de Replace Ej: dc.type.none "
          },
          value: {type: "string", title: "Valor", description: "Valor a colocar no registo"},
        }
      } /* fin schema */
    },
    
    { 		
		name : "Remover campos específicos de registros pesados ",
		className: "org.lareferencia.backend.validation.transformer.ReduceHeavyRecords",
		form: ["maxRecordSize","fieldsToRemove",
		      { type: "submit", title: "Save changes" }
		],
		schema: {
			type: "object",
			    properties: {
			    		maxRecordSize:{ type: "integer", title: "Tamaño máximo del registro en bytes.", description: "Los campos será removidos sólo en los registros que superen el tamaño" },
						fieldsToRemove : { "type": "array", "title": "Campos para remover", 
				          items: { "type": "string", "title":"expresión de campo" }
				    }
			    }
		} /* fin schema */
	},

	
	
	
]; //***** fin de _RULES ******/// 
	


	/** mapeo de las definiciones de reglas a un objeto **/
	var rules_defs_by_class  =  {}
	$.map( _RULES, function(rule, i ) { rules_defs_by_class[rule.className] = rule; });
	
	/** export del objeto con las definiciones de reglas **/
	this.ruleDefinitionByClassName = rules_defs_by_class;

});
