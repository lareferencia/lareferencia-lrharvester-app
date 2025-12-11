/* 
 *  This is the default license template.
 *  
 *  File: transformation-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */

angular.module('transformation.json.schemas', []).service('JSONTransformationSchemas', ['$http', '$q', function ($http, $q) {

	var self = this;

	this.form = [
		{
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


	this.rule_data_form = ["name", "description", "runorder"];

	this.rule_data_schema = {
		type: "object",
		properties: {
			name: { type: "string", title: "Nombre de la regla", description: "" },
			description: { type: "string", title: "Description de la regla", description: "" },
			runorder: { type: "integer", title: "Orden", description: "Orden en que se aplicará la transformación" },

		}
	};

	this.ruleDefinitionByClassName = {};

	var loaded = false;
	var loadingPromise = null;

	this.load = function (locale) {
		if (loaded) return $q.when(self.ruleDefinitionByClassName);
		if (loadingPromise) return loadingPromise;

		var url = '/public/validation/transformer-rules-schemas';
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
