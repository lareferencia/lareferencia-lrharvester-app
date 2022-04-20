/* 
 *  This is the default license template.
 *  
 *  File: validation-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
angular.module('validation.json.schemas', []).service('JSONValidationSchemas',  function() {
	
	
	this.form = [   { "type": "section",
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
	
	
	this.rule_data_form = [ "name",
	                        "description",
	                        "mandatory",
        			        { key: "quantifier", type: "select",
						        "titleMap": {
						        	"ZERO_ONLY" : "Ninguna", 
						        	"ONE_ONLY" : "Una y sólo una",
						        	"ZERO_OR_MORE" : "Cero o más", 
						        	"ONE_OR_MORE" : "Al menos una", 
						        	"ALL" : "Todas"
						        }
        			        }
    ];
	
	this.rule_data_schema = {
			type: "object",
		    properties: {
		      name :{ type: "string", title: "Name", description: "" }, 
		      description :{ type: "string", title: "Description", description: "" },
		      mandatory :{ type: "boolean", title: "Is mandatory?", description: "Is this rule mandatory for the record to be valid" },
		      quantifier: {
		          title: "Cuantificador",
		          type: "string",
		          enum: [ "ZERO_ONLY", "ONE_ONLY", "ZERO_OR_MORE", "ONE_OR_MORE", "ALL"],
		          description: "How many field ocurrences must be valid accordint to this rule",
		          "default" : "ONE_OR_MORE"
		      }
		    }
	};
	
	
	
	var _RULES = [  
	
	{ 		
			name : "Controlled value validation",
			className: "org.lareferencia.backend.validation.validator.ControlledValueFieldContentValidatorRule",
			form: [ { "type": "help", "helpvalue": "This rule is valid if the field contains occurrences of the provided vocabulary</p>"}, 
			        "fieldname", "controlledValues", { type: "submit", title: "Save rule" }],
			schema: {
				type: "object",
				properties: {
					  fieldname :{ type: "string", title: "Field", description: "Field expresion for the field. Ej. dc.type.*" }, 
				      controlledValues : { "type": "array", "title": "Controlled values", 
				          items: { "type": "string", "title":"valor" }
				      }
				}
			} /* fin schema */
	
	},
	
	
	{
		name: "Controlled value validation (large)",
		className: "org.lareferencia.backend.validation.validator.LargeControlledValueFieldContentValidatorRule",
		form: [ { "type": "help", "helpvalue": "This rule is valid if the field contains occurrences of the provided vocabulary</p>"}, 
		        "fieldname", { "key": "controlledValuesCSV", "type": "textarea" }, { type: "submit", title: "Save rule" }],
		schema: {
			    type: "object",
			    properties: {
			      fieldname :{ type: "string", title: "Field", description: "Field expresion for the field. Ej. dc.type.*" }, 
			      controlledValuesCSV : {
			          type: "string",
			          title: "CSV Controlled values", 
			          description: "Values separated by ; with no spaces between" 
			      }
			    }
		 } /* fin schema */
	},
		
	
	{ 
			name : "Content string length validation",
			className: "org.lareferencia.backend.validation.validator.ContentLengthFieldContentValidatorRule",
			form: [ { "type": "help", "helpvalue": "This rule is valid if the content string lenght is between max and min values</p>"}, 
			        "fieldname", "minLength", "maxLength", { type: "submit", title: "Save rule" }],
			schema: {
				type: "object",
				    properties: {
						fieldname :{ type: "string", title: "Field", description: "Field expresion for the field. Ej. dc.type.*" }, 
				    	minLength :{ type: "integer", title: "Min Length", description: "Minimun accepted length" }, 
				    	maxLength :{ type: "integer", title: "Max Length", description: "Maximun accepted length" }, 
				    }
				} /* fin schema */
	},

	
	{ 
			name : "Regular expresion validation",
			className: "org.lareferencia.backend.validation.validator.RegexFieldContentValidatorRule",
			form: [ { "type": "help", "helpvalue": "Regular expresion based validation</p>"}, 
			        "fieldname",  { "key": "regexString", "type": "textarea" }, { type: "submit", title: "Save rule" }],
			schema: {
				type: "object",
				    properties: {
						fieldname :{ type: "string", title: "Field", description: "Field expresion for the field. Ej. dc.type.*" }, 
				    	regexString : {
					          type: "string",
					          title: "Regular expresion", 
					          description: "Regular expresion to be tested agains field ocurrence content" 
					      }
				    }
				} /* fin schema */
	},
	
	{ 
		name : "Complex content expresions validator",
		className: "org.lareferencia.backend.validation.validator.FieldExpressionValidatorRule",
		form: [ { "type": "help", "helpvalue": "This rule is valid if the boolean expresion based on field content is valid"}, 
		        { "key": "expression", "type": "textarea" }, { type: "submit", title: "Save rule" }],
		schema: {
			type: "object",
			    properties: {
			    	expression : {
				          type: "string",
				          title: "Expresión", 
				          description: "Please leave spaces before/after parenthesis. \n Ej: ( dc.type=='info:eu-repo/semantics/article' AND dc.rights=%'info.+' ) OR ( dc.type=='info:eu-repo/semantics/bachelorThesis' )" 
				      }
			    }
			} /* fin schema */
	},
	
	{ 
		name : "Valid URL Validation",
		className: "org.lareferencia.backend.validation.validator.URLExistFieldValidatorRule",
		form: [ { "type": "help", "helpvalue": "Check if the URL is valid by following the link</p>"}, 
		        "fieldname", "minLength", "maxLength", { type: "submit", title: "Save rule" }],
		schema: {
			type: "object",
			    properties: {
					fieldname :{ type: "string", title: "Field", description: "El Name del Field. Ej: dc.type " }, 
			    }
			} /* fin schema */
},

{ 
	name : "Dynamic Date Range Validation",
	className: "org.lareferencia.backend.validation.validator.DynamicYearRangeFieldContentValidatorRule",
	form: [ { "type": "help", "helpvalue": "Valid only if the year value <b>(year)</b> parsed by the regex is: <b> year <= actual year - lower limit </b>  AND <b> year >= actual year + upper limit</b>. Actual year depends on system time."}, 
	        "fieldname",  { "key": "regexString", "type": "textarea" }, "lowerLimit", "upperLimit", { type: "submit", title: "Save rule" }],
	schema: {
		type: "object",
		    properties: {
				fieldname :{ type: "string", title: "Field", default: "dc.date.*", description: "El Name del Field oai_dc. Ej: dc.date.*" }, 
		    	regexString : {
			          type: "string",
			          title: "Regular expresion", 
			          description: "Regular expresion must be valid", 
			          default: "^([0-9]{3,4})"
			       
			      },
				lowerLimit:{ type: "integer", title: "lower limit", default:100, description: "" }, 
				upperLimit:{ type: "integer", title: "upper limit", default:2, description: "" }, 

				
		    }
		} /* fin schema */
},

]; //***** fin de _RULES ******/// 
	


	/** mapeo de las definiciones de reglas a un objeto **/
	var rules_defs_by_class  =  {};
	$.map( _RULES, function(rule, i ) { rules_defs_by_class[rule.className] = rule; });
	
	/** export del objeto con las definiciones de reglas **/
	this.ruleDefinitionByClassName = rules_defs_by_class;

	
	
});