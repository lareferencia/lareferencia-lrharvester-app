/*
 *   Copyright (c) 2013-2022. LA Referencia / Red CLARA and others
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   This file is part of LA Referencia software platform LRHarvester v4.x
 *   For any further information please contact Lautaro Matas <lmatas@gmail.com>
 */

package org.lareferencia.backend.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.lareferencia.backend.domain.Network;
import org.lareferencia.backend.domain.Transformer;
import org.lareferencia.backend.domain.TransformerRule;
import org.lareferencia.backend.domain.Validator;
import org.lareferencia.backend.domain.ValidatorRule;
import org.lareferencia.backend.repositories.jpa.NetworkRepository;
import org.lareferencia.backend.repositories.jpa.TransformerRepository;
import org.lareferencia.backend.repositories.jpa.ValidatorRepository;
import org.lareferencia.backend.taskmanager.NetworkAction;
import org.lareferencia.backend.taskmanager.NetworkActionkManager;
import org.lareferencia.backend.taskmanager.NetworkProperty;
import org.lareferencia.core.monitor.LoadingProcessMonitorService;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import lombok.Getter;
import lombok.Setter;

/**
 * Handles requests for the application home page.
 */
@RestController
public class ActionsController {
	
	private static Logger logger = LogManager.getLogger(ActionsController.class);

	@Autowired
	private NetworkRepository networkRepository;
	
	@Autowired
	private NetworkActionkManager networkActionManager;
	
	@Autowired
	private ValidatorRepository validatorRepository;
	
	@Autowired
	private TransformerRepository transformerRepository;
	
    @Autowired
    private LoadingProcessMonitorService monitorService;

	
	
	@ResponseBody
	@RequestMapping(value = "/private/listNetworkActions", method = RequestMethod.GET)
	public List<NetworkAction> networkActions() {
		return networkActionManager.getActions();
	}
	
	@ResponseBody
	@RequestMapping(value = "/private/listNetworkProperties", method = RequestMethod.GET)
	public List<NetworkProperty> networkProperties() {
		return networkActionManager.getProperties();
	}
	
	
	@ResponseBody
	@RequestMapping(value = "/public/listValidatorRulesByNetworkID/{id}", method = RequestMethod.GET)
	public List<ValidatorRule> listValidatorRulesByNetworkID(@PathVariable Long id) throws Exception {

		Optional<Network> network = networkRepository.findById(id);
		if (!network.isPresent())
			throw new Exception("No Network found");

		return network.get().getValidator().getRules();

	}
	
	@ResponseBody
	@RequestMapping(value = "/private/cloneValidator/{id}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> cloneValidator(@PathVariable Long id) throws Exception {
		
		logger.info("Clone validator: " + id);
		
		Optional<Validator> optValidator = validatorRepository.findById(id);
		
		if ( optValidator.isPresent() ) {
	
			Validator srcValidator = optValidator.get();
			Validator dstValidator = new Validator();
			BeanUtils.copyProperties(srcValidator, dstValidator, "id", "rules");			
			dstValidator.setName( dstValidator.getName() + " - copy");
			
			List<ValidatorRule> rules = optValidator.get().getRules();
			for (ValidatorRule srcRule : rules) {
				ValidatorRule dstRule = new ValidatorRule();
				BeanUtils.copyProperties(srcRule, dstRule, "id");
				dstValidator.getRules().add(dstRule);
			}
			
			validatorRepository.save(dstValidator);
		}
		
		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);
	}
	
	@ResponseBody
	@RequestMapping(value = "/private/cloneTransformer/{id}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> cloneTransformer(@PathVariable Long id) throws Exception {
		
		logger.info("Clone transformer: " + id);
		
		Optional<Transformer> optTransformer = transformerRepository.findById(id);
		
		if ( optTransformer.isPresent() ) {
	
			Transformer srcTransformer = optTransformer.get();
			Transformer dstTransformer = new Transformer();
			BeanUtils.copyProperties(srcTransformer, dstTransformer, "id", "rules");			
			dstTransformer.setName( dstTransformer.getName() + " - copy");
			
			List<TransformerRule> rules = optTransformer.get().getRules();
			for (TransformerRule srcRule : rules) {
				TransformerRule dstRule = new TransformerRule();
				BeanUtils.copyProperties(srcRule, dstRule, "id");
				dstTransformer.getRules().add(dstRule);
			}
			
			transformerRepository.save(dstTransformer);
		}
		
		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);
	}

	
	
	class SimpleResponse {
		
		@Getter
		private String msg;
		
		public SimpleResponse(String msg) {
			this.msg = msg;
		}
		
	}

	@ResponseBody
	@RequestMapping(value = "/private/killNetworkTasks/{ids}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> killNetworkTasks(@PathVariable Long... ids) {

		List<Long> networkIdsWithErrors = new ArrayList<Long>();

		for (Long id : ids) {

			// Se obtiene la red en cuestión
			Optional<Network> network = networkRepository.findById(id);

			// Si la red no existe se agrega a la list de redes con error
			if (!network.isPresent()) {
				networkIdsWithErrors.add(id);
				logger.warn("Netword:" + id + " doesn't exists.");
			}
			else {
				networkActionManager.killAndUnqueueActions(network.get());
				break;
			}
			
			logger.info("Killing proccesses for: " + (network.isPresent() ? (network.get().getAcronym() + "(id:"+ network.get().getId() + ")") : id));
		}
				
		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);
	}
	
	@ResponseBody
	@RequestMapping(value = "/private/rescheduleNetworkTasks/{ids}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> rescheduleNetworkTasks(@PathVariable Long... ids) {

		List<Long> networkIdsWithErrors = new ArrayList<Long>();

		for (Long id : ids) {

			// Se obtiene la red en cuestión
			Optional<Network> network = networkRepository.findById(id);

			// Si la red no existe se agrega a la list de redes con error
			if (!network.isPresent()) {
				networkIdsWithErrors.add(id);
				logger.warn("Network:" + id + " doesn't exists.");
			}
			else {
				networkActionManager.rescheduleNetwork(network.get());
				break;
			}
			
			logger.info("Rescheduling tasks for: " + (network.isPresent() ? (network.get().getAcronym() + "(id:"+ network.get().getId() + ")") : id));
		}
				
		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);
	}
	
	
	@ResponseBody
	@RequestMapping(value = "/public/getRunningStatus", method = RequestMethod.GET)
	public RunningStatus getRunningStatus() {

		RunningStatus status = new RunningStatus();
		
		for (Network network : networkRepository.findAll() ) {
			
			String runningContextID = NetworkRunningContext.buildID(network);
			
			List<String> running = networkActionManager.getTaskManager().getRunningTasksByRunningContextID(runningContextID);
			List<String> queued = networkActionManager.getTaskManager().getQueuedTasksByRunningContextID(runningContextID);
			List<String> scheduled = networkActionManager.getTaskManager().getScheduledTasksByRunningContextID(runningContextID);
			
			if ( !running.isEmpty() )
				status.getRunning().put(network.getAcronym(), running );
				monitorService.getRunning().put(network.getAcronym(), running);
			
			if ( !queued.isEmpty() )
				status.getQueued().put(network.getAcronym(), queued );
				monitorService.getQueued().put(network.getAcronym(), running);
			
			if ( !scheduled.isEmpty() ) 
				status.getScheduled().put(network.getAcronym(),  scheduled);
				monitorService.getScheduled().put(network.getAcronym(), running);


		}
	
		return status;
	}
	
	@Getter
	@Setter
	class RunningStatus {
		
		Map<String, List<String>> running = new HashMap<String, List<String>>();
		Map<String, List<String>> scheduled = new HashMap<String, List<String>>();
		Map<String, List<String>> queued = new HashMap<String, List<String>>();
		
	}
	
	
	@ResponseBody
	@RequestMapping(value = "/private/networkAction/{action}/{incremental}/{ids}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> networkAction(@PathVariable String action, @PathVariable Boolean incremental, @PathVariable Long... ids) {
		loadingProcessInitilize();
		List<Long> networkIdsWithErrors = new ArrayList<Long>();

		for (Long id : ids) {

			// Se obtiene la red en cuestión
			Optional<Network> network = networkRepository.findById(id);

			// Si la red no existe se agrega a la list de redes con error
			if (!network.isPresent()) {
				networkIdsWithErrors.add(id);
				monitorService.getNetworkIdsWithErrors().add(id);
				logger.warn( "Network:" + id + " doesn't exist.");
			}
			else {
				networkActionManager.executeAction(action, incremental, network.get());
			}
			
			logger.info(action + ":: incremental:" + incremental  +  " :: network: " + (network.isPresent() ? (network.get().getAcronym() + "(id:"+ network.get().getId() + ")") : id));
		}
				

		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);

	}
	
	private void loadingProcessInitilize() {
		monitorService.setIsLoadingProcessInProgress(Boolean.TRUE);
		getRunningStatus();
		monitorService.setDiscardedEntities(3);
		monitorService.setDuplicatedEntities(3);
		monitorService.setErrorFiles(3);
		monitorService.setLoadedEntities(3);
		System.out.println("!!!===>>> monitorService::getDiscardedEntities: "+monitorService.getDiscardedEntities());
		
	}

	@ResponseBody
	@RequestMapping(value = "/private/networkActions/{ids}", method = RequestMethod.GET)
	public ResponseEntity<SimpleResponse> networkActions(@PathVariable Long... ids) {

		List<Long> networkIdsWithErrors = new ArrayList<Long>();

		for (Long id : ids) {

			// Se obtiene la red en cuestión
			Optional<Network> network = networkRepository.findById(id);

			// Si la red no existe se agrega a la list de redes con error
			if (!network.isPresent()) {
				networkIdsWithErrors.add(id);
				logger.warn("Network:" + id + " doesn't exist.");
			}
			else {
				networkActionManager.executeActions(network.get());
				logger.info("Executing configured actions over network: " + network.get().getAcronym() + "(id:"+ network.get().getId() + ")" );

			}
			
		}
				

	
		return new ResponseEntity<SimpleResponse>(new SimpleResponse("DONE"), HttpStatus.OK);
	}

}
