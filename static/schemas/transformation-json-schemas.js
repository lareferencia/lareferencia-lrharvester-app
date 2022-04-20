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
	  
	  { type: "submit", title: "Guardar" }
    
   ];




	this.schema = {
		type: "object",
		properties: {
			name : { type: "string", title: "Nombre", description: "" }, 
			description : { type: "string", title: "Descripción", description: "" },
		}
	};
	
	
	this.rule_data_form = [ "name", "description", "runorder"];
	
	this.rule_data_schema = {
			type: "object",
		    properties: {
		      name :{ type: "string", title: "Nombre de la regla", description: "" }, 
		      description :{ type: "string", title: "Description de la regla", description: "" },
		      runorder :{ type: "integer", title: "Orden", description: "Orden en que se aplicará la transformación" }, 

		    }
	};
	
	
	
	var _RULES = [  
	
	{ 		
			name : "Traducción de valores de campos",
			className: "org.lareferencia.backend.validation.transformer.FieldContentTranslateRule",
			form: [ 
			        { type: "submit", title: "Guardar cambios" }, "testFieldName", "writeFieldName", "replaceOccurrence", "testValueAsPrefix", "translationArray", { type: "submit", title: "Guardar cambios" }],
			schema: {
				type: "object",
				    properties: {
				    translationArray: { type: "array", title: "Listado de traducciones", description: "Si se encuentra una ocurrencia con alguno de los valores listado se reemplaza.", 
				    	items: {
				            "type": "object",
				            "title": "Traducción",
				            "properties": {
				              "search": { "type": "string", "title": "Buscar" },
				              "replace": { "type": "string", "title": "Reemplazo" },	
				            }
				    	}
				    },
				    testFieldName:{ type: "string", title: "Campo de búsqueda", description: "El nombre del campo oai_dc donde se buscara el valor. Ej: dc.type " },
				    writeFieldName:{ type: "string", title: "Campo de escritura", description: "El nombre del campo oai_dc que se creará con la ocurrencia de reemplazo Ej: dc.type " },
				    replaceOccurrence:{ type: "boolean", title: "¿Se reemplaza la ocurrencia encontrada?", description: "Indica si se eliminará la ocurrencia en el campo de búsqueda" },
				    testValueAsPrefix:{ type: "boolean", title: "¿Evaluar como prefijo?", description: "Indica si el valor de búsqueda se evaluará como prefijo del contenido del campo de búsqueda." }, 
				    	
					
				    }
				} /* fin schema */
	},
	
	{ 		
		name : "Traducción de valores de campos con orden de prioridad",
		className: "org.lareferencia.backend.validation.transformer.FieldContentPriorityTranslateRule",
		form: [ 
		        { type: "submit", title: "Guardar cambios" }, "testFieldName", "writeFieldName", "replaceOccurrence", "testValueAsPrefix", "replaceAllMatchingOccurrences", "translationArray", { type: "submit", title: "Guardar cambios" }],
		schema: {
			type: "object",
			    properties: {
			    translationArray: { type: "array", title: "Listado de traducciones", description: "Si se encuentra una ocurrencia con alguno de los valores listado se reemplaza.", 
			    	items: {
			            "type": "object",
			            "title": "Traducción",
			            "properties": {
			              "search": { "type": "string", "title": "Buscar" },
			              "replace": { "type": "string", "title": "Reemplazo" },	
			            }
			    	}
			    },
			    testFieldName:{ type: "string", title: "Campo de búsqueda", description: "El nombre del campo oai_dc donde se buscara el valor. Ej: dc.type " },
			    writeFieldName:{ type: "string", title: "Campo de escritura", description: "El nombre del campo oai_dc que se creará con la ocurrencia de reemplazo Ej: dc.type " },
			    replaceOccurrence:{ type: "boolean", title: "¿Se reemplaza la ocurrencia encontrada?", description: "Indica si se eliminará la ocurrencia en el campo de búsqueda" },
			    testValueAsPrefix:{ type: "boolean", title: "¿Evaluar como prefijo?", description: "Indica si el valor de búsqueda se evaluará como prefijo del contenido del campo de búsqueda." }, 
			    replaceAllMatchingOccurrences:{ type: "boolean", title: "¿Reemplazar todas la ocurrencias encontradas?", description: "Indica si se reemplazarán todas las ocurrencias o sólo el primer valor encontrado con orden de prioridad dado por el orden del listado de traducciones." },  	
				
			    }
			} /* fin schema */
	},
	
	{ 		
		name : "Traducción de nombres de campo",
		className: "org.lareferencia.backend.validation.transformer.FieldNameTranslateRule",
		form: [ 
		        { type: "submit", title: "Guardar cambios" }, "sourceFieldName", "targetFieldName", { type: "submit", title: "Guardar cambios" }],
		schema: {
			type: "object",
			    properties: {
			    	sourceFieldName:{ type: "string", title: "Campo origen", description: "El nombre del campo oai_dc origen. Ej: dc.type.calif " },
			    	targetFieldName:{ type: "string", title: "Campo destino", description: "El nombre del campo oai_dc de reemplazo Ej: dc.type " },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Traducción de nombres de campo (múltiple)",
		className: "org.lareferencia.backend.validation.transformer.FieldNameBulkTranslateRule",
		form: [ 
		        { type: "submit", title: "Guardar cambios" }, "translationArray", { type: "submit", title: "Guardar cambios" }],
		schema: {
			type: "object",
		    properties: {
		    translationArray: { type: "array", title: "Listado de reemplazos", description: "Se reemplazan los nombres de campo en el orden en que aparecen.", 
		    	items: {
		            "type": "object",
		            "title": "Reemplazos",
		            "properties": {
		              "search": { "type": "string", "title": "Buscar" },
		              "replace": { "type": "string", "title": "Reemplazo" },	
		            }
		    	}
		    }
		  }
		} /* fin schema */
	},
	
	{ 		
		name : "Transformación de campo por reemplazo (regexp) ",
		className: "org.lareferencia.backend.validation.transformer.RegexTranslateRule",
		form: [ 
		        { type: "submit", title: "Guardar cambios" }, "sourceFieldName", "targetFieldName", "removeMatchingOccurrences", "regexSearch", "regexReplace", { type: "submit", title: "Guardar cambios" }],
		schema: {
			type: "object",
			    properties: {
			    	sourceFieldName:{ type: "string", title: "Campo origen", description: "El nombre del campo origen. Ej: dc.subject.cnpq " },
			    	targetFieldName:{ type: "string", title: "Campo destino", description: "El nombre del campo de reemplazo Ej: dc.subject.por " },
			    	regexSearch:{ type: "string", title: "Expresion regular de búsqueda", description: "La expresion regular de búsqueda, se pueden usar grupos para referenciar en la expresión de reemplazo. Ej: CNPQ::(.+)" },
			    	regexReplace:{ type: "string", title: "Expresion regular de reemplazo", description: "La expresion de reemplazo, puede contener referencias a los grupos. Ej: $1 " },
			    	removeMatchingOccurrences:{ type: "boolean", title: "¿Se Eliminan las ocurrencias encontradas (reemplazo)?", description: "Indica si las ocurrencias que coincidentes con la expresion serán eliminadas" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Agregado de metatos de nombre repositorio",
		className: "org.lareferencia.backend.validation.transformer.AddRepoNameRule",
		form: [ "doRepoNameAppend","doRepoNameReplace","repoNameField","repoNamePrefix",
		        "doInstNameAppend","doInstNameReplace","instNameField","instNamePrefix", "instAcronField","instAcronPrefix",
		        { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
			    	doRepoNameAppend:{ type: "boolean", title: "¿Agregar ocurrencia con nombre del repositorio?", description: "" },
			    	doRepoNameReplace:{ type: "boolean", title: "¿Se reemplaza las ocurrencia existentes de nombre de repositorio?", description: "" },
			    	repoNameField:{ type: "string", title: "Campo utilizado para nombre de repositorio", description: "Ej: dc.source.none" },
			    	repoNamePrefix:{ type: "string", title: "Prefijo utilizado para nombre de repositorio", description: "Ej: reponame:" },
			    	doInstNameAppend:{ type: "boolean", title: "¿Agregar ocurrencia con nombre/acronimo de la institución?", description: "" },
			    	doInstNameReplace:{ type: "boolean", title: "¿Se reemplaza las ocurrencia existentes de nombre/acronimo de la institución?", description: "" },
			    	instNameField:{ type: "string", title: "Campo utilizado para nombre de la institución", description: "Ej: dc.source.none" },
			    	instNamePrefix:{ type: "string", title: "Prefijo utilizado para nombre de la institución", description: "Ej: instname:" },
			    	instAcronField:{ type: "string", title: "Campo utilizado para acronimo de la institución", description: "Ej: dc.source.none" },
			    	instAcronPrefix:{ type: "string", title: "Prefijo utilizado para acronimo de la institución", description: "Ej: instacron:" },
			    	
			    	
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Agregado condicional de ocurrencias de campo",
		className: "org.lareferencia.backend.validation.transformer.FieldContentConditionalAddOccrRule",
		form: [ { "key": "conditionalExpression", "type": "textarea" },"fieldName","valueToAdd","removeDuplicatedOccurrences",
		        { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
			    	conditionalExpression:{ type: "string", title: "Expresion a evaluar", description: "Es importante dejar espacios entre los paréntesis. \n Ej: ( dc.type=='info:eu-repo/semantics/article' AND dc.rights=%'info.+' ) OR ( dc.type=='info:eu-repo/semantics/bachelorThesis' )" },
			    	fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.type.*" },
			    	valueToAdd:{ type: "string", title: "Valor a agregar en caso de que se cumpla el condicional", description: "Ej: info:eu-repo/semantics/article" },
			    	removeDuplicatedOccurrences:{ type: "boolean", title: "¿Remover ocurrencias duplicadas?", description: "" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Remover ocurrencias duplicadas en un campo",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateOccrsRule",
		form: ["fieldName",
		        { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.type.*" },
			    }
		} /* fin schema */
	},


        {
                name : "Agregado de metadatos provenance",
                className: "org.lareferencia.backend.validation.transformer.AddProvenanceMetadataRule",
                form: [
                        { type: "submit", title: "Guardar cambios" }
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
		        { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.data.issued.*" },
			    }
		} /* fin schema */
	},
	
	{ 		
		name : "Remover ocurrencias con prefijo repetido",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicatePrefixedOccrs",
		form: ["fieldName", "prefix",
		        { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
			    	fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.type.*" },
			    	prefix:{ type: "string", title: "Prefijo de las occurrencias a evaluar", description: "Ej: instaname:" },

			    }
		} /* fin schema */
	},

	{ 		
		name : "Remover ocurrencias redundantes de un vocabulario",
		className: "org.lareferencia.backend.validation.transformer.RemoveDuplicateVocabularyOccrsRule",
		form: ["fieldName",
					 "vocabulary",
		      { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
						fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.type.*" },
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
		      { type: "submit", title: "Guardar cambios" }
		],
		schema: {
			type: "object",
			    properties: {
						fieldName:{ type: "string", title: "Nombre del campo a modificar", description: "Ej: dc.type.*" },
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
        {type: "submit", title: "Guardar cambios"}, "targetFieldName", "value", {
          type: "submit",
          title: "Guardar cambios"
        }],
      schema: {
        type: "object",
        properties: {
          targetFieldName: {
            type: "string",
            title: "Campo destino",
            description: "El nombre del campo oai_dc de reemplazo Ej: dc.type.none "
          },
          value: {type: "string", title: "Valor", description: "Valor a colocar no registo"},
        }
      } /* fin schema */
    },
    
    { 		
		name : "Remover campos específicos de registros pesados ",
		className: "org.lareferencia.backend.validation.transformer.ReduceHeavyRecords",
		form: ["maxRecordSize","fieldsToRemove",
		      { type: "submit", title: "Guardar cambios" }
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
