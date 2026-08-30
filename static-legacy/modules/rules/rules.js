/* 
 *  This is the default license template.
 *  
 *  File: rules.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
/**
 * @module Rules
 * @summary Rules module
 */

angular.module('rules', [
	'ngResource',
	'ui.bootstrap',
	'ui.router',
	'schemaForm',
	'table.services',
	'rest.url.helper',
	'data.services',
	'transformation.json.schemas'
])


	.config(['$stateProvider', function ($stateProvider) {
		'use strict';

		$stateProvider
			.state('rules', {
				url: '/rules',
				views: {
					'main@': {
						templateUrl: 'modules/rules/rules.html'
					}
				}
			})
			.state('rules.new', {
				url: '/:type/new'
			})
			.state('rules.edit', {
				url: '/:type/:rulesID',
			});

	}])

	/* Controlador de edición de regla */
	.controller('RuleEditCtrl', ['$scope', '$uibModalInstance', 'RestURLHelper', 'DataSrv', 'schemas', 'type', 'rule', 'isNew', 'parent', function ($scope, $uibModalInstance, RestURLHelper, DataSrv, schemas, type, rule, isNew, parent) {

		// Accciones de los botones del modal
		$scope.ok = function () { $uibModalInstance.close(null); };
		$scope.cancel = function () { $uibModalInstance.dismiss('cancel'); };

		$scope.parent = parent;
		$scope.type = type;
		$scope.rule = rule;

		$scope.is_rule_visible = true;
		$scope.is_rule_new = isNew;
		$scope.is_rule_saved = false;

		/** schema y formulario de la parte genérica de una regla **/
		$scope.rule_data_schema = schemas.rule_data_schema;
		$scope.rule_data_form = schemas.rule_data_form;

		if (isNew) { /*es una regla nueva */

			$scope.rule_data_model = {}; // si es una regla nueva no tenemos schema
			$scope.rule_model = { '@class': rule.className }; // para una regla nueva no tenemos modelo de regla

			$scope.rule_definition = rule;

		} else { /* es una edición de regla existente */

			$scope.rule_data_model = rule; // si es una regla a editar tenemos al objeto como parámetro
			$scope.rule_model = JSON.parse(rule.jsonserialization); // el modelo de la regla conreta se deserializa del objeto rule campo jsonserialization

			var className = $scope.rule_model["@class"];
			$scope.rule_definition = schemas.ruleDefinitionByClassName[className];

			// Fallback for legacy package names
			if (!$scope.rule_definition) {
				if (className.indexOf('org.lareferencia.backend.validation.validator') === 0) {
					var newClassName = className.replace('org.lareferencia.backend.validation.validator', 'org.lareferencia.core.worker.validation.validator');
					$scope.rule_definition = schemas.ruleDefinitionByClassName[newClassName];
				} else if (className.indexOf('org.lareferencia.backend.validation.transformer') === 0) {
					var newClassName = className.replace('org.lareferencia.backend.validation.transformer', 'org.lareferencia.core.worker.validation.transformer');
					$scope.rule_definition = schemas.ruleDefinitionByClassName[newClassName];
				}
			}
		}

		/** schema y formulario de la parte específica de una regla **/
		$scope.rule_schema = $scope.rule_definition.schema;
		$scope.rule_form = $scope.rule_definition.form;


		/***
		 * Rule forms submit handler
		 */
		$scope.on_rule_submit = function (rule_data_form, rule_form) {

			// Se convierte a string el json del formulario de la regla y se actualiza en el model de datos de regla	
			$scope.rule_data_model.jsonserialization = JSON.stringify($scope.rule_model);

			// Si es una regla nueva 
			if ($scope.is_rule_new) {

				// Se llama al servicio de add con url de rule y el modelo de regla
				DataSrv.add(RestURLHelper.ruleURLByType($scope.type), $scope.rule_data_model,

					function (rule) { // callback de creación exitosa
						// se actualiza el modelo del form con el objeto actualizable
						$scope.rule_data_model = rule;

						// Agregar el origen a la colecction origins de la network
						$scope.parent.addToCollection('rules', RestURLHelper.urlFromEntity(rule),
							// Callback agregado exitosa de rule al rules
							function () {
								$scope.is_rule_saved = true;
								$scope.is_rule_new = false;
							},
							onRuleSaveError
						); /* fin de agregar */

					}, // fin callback de add rule 
					onRuleSaveError
				); // fin de add rule

			} // fin de nueva regla
			else { // si es una regla existente

				// Se graba el modelo en la bd	
				$scope.rule_data_model.updateItem(
					$scope.rule_data_model,
					function () { // success callback
						$scope.is_rule_saved = true;
					},
					onRuleSaveError
				); // fin de rule_model.update

			} /* fin del rule ya grabado */

		}; /* fin de on rule submit */


		/**
		 * Handler de errores de almacenamiento en la bd
		 */
		function onRuleSaveError(error) { // error callback
			$scope.rule_saved = false;
			$scope.rule_save_error = true;
			$scope.rule_save_error_message = error.status + ": " + error.statusText;
		};


	}]) /* Fin controlador de edición de regla */

	.controller('rules', ['$rootScope', '$scope', '$state', '$stateParams', '$uibModal', 'TableSrv', 'RestURLHelper', 'DataSrv', 'JSONTransformationSchemas', 'JSONValidationSchemas', function ($rootScope, $scope, $state, $stateParams, $uibModal, TableSrv, RestURLHelper, DataSrv, JSONTransformationSchemas, JSONValidationSchemas) {
		'use strict';


		/* en principio el model está vacío */
		$scope.rules_model = {};

		/* variables de estado*/
		$scope.is_rules_new = true;
		$scope.is_rules_saved = false;
		$scope.is_new = $state.includes('rules.new');

		// Se toma el tipo de editor: validator o transformer de los parámetros de las url
		$scope.type = $stateParams.type;

		/* se parametriza el editor de acuerdo al tipo */
		if ($scope.type == 'transformer') {
			$scope.schemas = JSONTransformationSchemas;
			JSONTransformationSchemas.load(navigator.language).then(function () {
				$scope.ruleDefinitionByClassName = $scope.schemas.ruleDefinitionByClassName;
			});
		}
		else if ($scope.type == 'validator') {
			$scope.schemas = JSONValidationSchemas;
			JSONValidationSchemas.load(navigator.language).then(function () {
				$scope.ruleDefinitionByClassName = $scope.schemas.ruleDefinitionByClassName;
			});
		} else {
			alert("Error!! Llamada inválida del editor de reglas ")
		}


		$scope.rules_schema = $scope.schemas.schema;
		$scope.rules_form = $scope.schemas.form;


		if ($stateParams.rulesID != null) {

			$scope.rules_id = Number($stateParams.rulesID);
			$scope.is_rules_new = false;

			// obtención de datos,  utilizando el id obtiene la url y luego el servico de datos entrega una network, eso va al form model
			DataSrv.get(RestURLHelper.rulesURLByTypeAndID($scope.type, $scope.rules_id),
				function (rules) {
					// el objeto de red obtenido es ahora el modelo del formulario
					$scope.rules_model = rules;

					// Carga las reglas
					$scope.rulesTable = TableSrv.createNgTableFromGetData(function (params) {

						var rules = $scope.rules_model.getLinkItems('rules');
						return $scope.rules_model.getLinkItems('rules');

					});

				}
			);

		}


		/***
		 *  Callback de refresh de redes  
		 **/
		$scope.rulesTableRefreshCallback = function () {

			if ($scope.rulesTable == null) // Si la tabla es null, la crea
				$scope.rulesTable = TableSrv.createNgTableFromGetData(function (params) { return $scope.rules_model.getLinkItems('rules'); });

			$scope.rules_model.reload(function (obj) { $scope.rulesTable.reload(); });
		};

		/**
		 * Edit rule
		 */
		$scope.editRule = function (parent, rule, isNew) {

			var modalInstance = $uibModal.open({
				animation: true,
				templateUrl: 'modules/rules/edit-rule-tpl.html',
				controller: 'RuleEditCtrl',
				backdrop: 'static',
				size: 'lg',
				resolve: {
					type: function () { return $scope.type; },
					schemas: function () { return $scope.schemas; },
					parent: function () { return parent; },
					rule: function () { return rule; },
					isNew: function () { return isNew; }
				}
			});


			modalInstance.result.then(function () {
				$scope.rulesTableRefreshCallback();
			}, function () {
				$scope.rulesTableRefreshCallback();
			});


		};


		/** 
		 * deleteTransformerRule: Borrado de una regla
		 ***/
		$scope.deleteTransformerRule = function (rule) {

			if (confirm("¿Esta seguro que desea borrar esta regla?")) {

				$scope.is_rule_visible = false;

				// llamada al borrado
				rule.remove(function () {
					$scope.rulesTableRefreshCallback();
				}
					///// ATENCION: FALTA LA LLAMADA AL CALLBACK DE ERROR
				);
			}
		};

		/***
		 * Transformer forms submit handler
		 */
		$scope.on_rules_submit = function (rules_form) {

			// Si es una regla nueva 
			if ($scope.is_rules_new) {

				// Se llama al servicio de add con url de rules y el modelo de regla
				DataSrv.add(RestURLHelper.rulesURLByType($scope.type), $scope.rules_model,

					function (rules) { // callback de creación exitosa
						// se actualiza el modelo del form con el objeto actualizable
						$scope.rules_model = rules;
						$scope.is_rules_new = false;
					}, // fin callback de add rules
					onSaveError
				); // fin de add rules

			} // fin de nueva regla

			else { // si es una regla existente

				// Se graba el modelo en la bd	
				$scope.rules_model.updateItem(
					$scope.rules_model,
					function () { // success callback
						$scope.is_rules_saved = true;
					},
					onSaveError
				); // fin de rules_model.update

			} /* fin del rules ya grabado */

		};

		/**
		 * Handler de errores de almacenamiento en la bd
		 */
		function onSaveError(error) { // error callback
			$scope.is_rules_saved = false;
			$scope.rules_save_error = true;
			$scope.rules_save_error_message = error.status + ": " + error.statusText;
		};


	}]);


