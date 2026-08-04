/* 
 *  This is the default license template.
 *  
 *  File: validation-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
angular.module('validation.json.schemas', []).service('JSONValidationSchemas', ['$http', '$q', function ($http, $q) {

	var self = this;

	this.form = [{
		"type": "section",
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
			name: { type: "string", title: "Nombre", description: "" },
			description: { type: "string", title: "Descripción", description: "" },
		}
	};


	this.rule_data_form = ["name",
		"description",
		"mandatory",
		{
			key: "quantifier", type: "select",
			"titleMap": {
				"ZERO_ONLY": "Ninguna",
				"ONE_ONLY": "Una y sólo una",
				"ZERO_OR_MORE": "Cero o más",
				"ONE_OR_MORE": "Al menos una",
				"ALL": "Todas"
			}
		}
	];

	this.rule_data_schema = {
		type: "object",
		properties: {
			name: { type: "string", title: "Nombre", description: "" },
			description: { type: "string", title: "Description", description: "" },
			mandatory: { type: "boolean", title: "¿Es obligatoria?", description: "La regla es determinante en la validez de registro" },
			quantifier: {
				title: "Cuantificador",
				type: "string",
				enum: ["ZERO_ONLY", "ONE_ONLY", "ZERO_OR_MORE", "ONE_OR_MORE", "ALL"],
				description: "¿Cuántas ocurrencias deben cumplir la regla?",
				"default": "ONE_OR_MORE"
			}
		}
	};

	this.ruleDefinitionByClassName = {};

	var loaded = false;
	var loadingPromise = null;

	this.load = function (locale) {
		if (loaded) return $q.when(self.ruleDefinitionByClassName);
		if (loadingPromise) return loadingPromise;

		var url = '/public/validation/validator-rules-schemas';
		if (locale) {
			url += '?locale=' + locale;
		}

		loadingPromise = $http.get(url).then(function (response) {
			var rules = response.data;
			angular.forEach(rules, function (rule) {
				self.ruleDefinitionByClassName[rule.className] = rule;
			});
			loaded = true;
			return self.ruleDefinitionByClassName;
		});
		return loadingPromise;
	};

}]);