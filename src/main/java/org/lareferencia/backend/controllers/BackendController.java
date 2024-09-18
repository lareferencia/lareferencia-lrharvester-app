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

import java.io.File;
import java.io.FileInputStream;
import java.io.UnsupportedEncodingException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.lareferencia.backend.domain.Network;
import org.lareferencia.backend.domain.NetworkSnapshot;
import org.lareferencia.backend.domain.OAIBitstream;
import org.lareferencia.backend.domain.OAIBitstreamStatus;
import org.lareferencia.backend.domain.SnapshotIndexStatus;
import org.lareferencia.backend.domain.SnapshotStatus;
import org.lareferencia.backend.domain.Transformer;
import org.lareferencia.backend.domain.TransformerRule;
import org.lareferencia.backend.domain.ValidationStatObservation;
import org.lareferencia.backend.domain.Validator;
import org.lareferencia.backend.domain.ValidatorRule;
import org.lareferencia.backend.repositories.jpa.NetworkRepository;
import org.lareferencia.backend.repositories.jpa.NetworkSnapshotRepository;
import org.lareferencia.backend.repositories.jpa.OAIBitstreamRepository;
import org.lareferencia.backend.repositories.jpa.OAIRecordRepository;
import org.lareferencia.backend.repositories.jpa.TransformerRepository;
import org.lareferencia.backend.repositories.jpa.ValidatorRepository;
import org.lareferencia.backend.services.ValidationStatisticsService;
import org.lareferencia.backend.services.ValidationStatisticsService.ValidationRuleOccurrencesCount;
import org.lareferencia.backend.taskmanager.NetworkAction;
import org.lareferencia.backend.taskmanager.NetworkActionkManager;
import org.lareferencia.backend.taskmanager.NetworkProperty;
import org.lareferencia.core.metadata.MDFormatTransformerService;
import org.lareferencia.core.metadata.MedatadaDOMHelper;
import org.lareferencia.backend.domain.OAIRecord;
import org.lareferencia.core.metadata.IMetadataRecordStoreService;
import org.lareferencia.core.util.JsonDateSerializer;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import lombok.Getter;
import lombok.Setter;

/**
 * Handles requests for the application home page.
 */
@RestController
public class BackendController {
	
	private static Logger logger = LogManager.getLogger(BackendController.class);

	@Value("${downloaded.files.path}")
	private String BITSTREAM_PATH;
	
	@Autowired
	private OAIBitstreamRepository bitstreamRepository;

	@Autowired
	private NetworkRepository networkRepository;
	
	@Autowired
	private IMetadataRecordStoreService metadataStoreService;
	
	@Autowired
	private NetworkSnapshotRepository networkSnapshotRepository;
	
	@Autowired
	private ValidationStatisticsService validationStatisticsService;

	@Autowired
	private NetworkActionkManager networkActionManager;
	
	@Autowired
	private MDFormatTransformerService mdTransformationService;
	
	
	/******************************************************
	 * Login Services
	 ******************************************************/

//	@RequestMapping(value = "/", method = RequestMethod.GET)
//	public String root(Locale locale, Model model) {
//		return "static/home.html";
//	}

//	@RequestMapping(value = "/home", method = RequestMethod.GET)
//	public String home(Locale locale, Model model) {
//		return "home";
//	}
//
/*	@RequestMapping(value = "/login", method = RequestMethod.GET)
	public String login(Locale locale, Model model) {
		return "login";
	}

	@RequestMapping(value = "/login", params = "errorLogin", method = RequestMethod.GET)
	public String loginFailed(Locale locale, Model model) {
		model.addAttribute("loginFailed", true);
		return "login";
	}
	@RequestMapping(value="/logout", method = RequestMethod.GET)
	public String logoutPage (HttpServletRequest request, HttpServletResponse response) {
	    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
	    if (auth != null){    
	        new SecurityContextLogoutHandler().logout(request, response, auth);
	    }
	    return "redirect:/login";
	}
*/
	
	@ResponseBody
	@RequestMapping(value = "/public/getRecordMetadataByID/{id}", method = RequestMethod.GET, produces = "application/xml; charset=utf-8")
	public String getRecordMetadataByID(@PathVariable Long id) throws Exception {

		OAIRecord record = metadataStoreService.findRecordByRecordId(id);
		if (record != null )
			return metadataStoreService.getPublishedMetadata(record).toString();
		else
			return "No record found - Probably the diagnose report is outdated";

	}

	@ResponseBody
	@RequestMapping(value = "/public/getRecordMetadataBySnapshotAndIdentifier/{snapshotId}/{identifier}", method = RequestMethod.GET, produces = "application/xml; charset=utf-8")
	public String getRecordMetadataBySnapshotAndIdentifier(@PathVariable Long snapshotId, @PathVariable String identifier) throws Exception {

		// replace %2F by /
		identifier = identifier.replace("%2F", "/");

		//System.out.println("getRecordMetadataBySnapshotAndIdentifier: " + snapshotId + " - " + identifier);

		OAIRecord record = metadataStoreService.findRecordByIdentifier(snapshotId, identifier);
		if (record != null )
			return metadataStoreService.getPublishedMetadata(record).toString();
		else
			return "No record found - Probably the diagnose report is outdated";

	}
	
	
	/******************************************************
	 * Diagnose Services
	 ******************************************************/


	@RequestMapping(value = "/public/diagnose/{snapshotID}/{fq}", method = RequestMethod.GET)
	@ResponseBody
	public ValidationStatisticsService.ValidationStats diagnoseListRules(@PathVariable Long snapshotID, @PathVariable List<String> fq) throws Exception {

		Optional<NetworkSnapshot> snapshot = networkSnapshotRepository.findById(snapshotID);

		if (!snapshot.isPresent()) // TODO: Implementar Exc
			throw new Exception("No snapshot found with id: " + snapshotID);
		

		return validationStatisticsService.queryValidatorRulesStatsBySnapshot(snapshot.get(), fq);
	}
	
	@RequestMapping(value = "/public/diagnose/{snapshotID}", method = RequestMethod.GET)
	@ResponseBody
	public ValidationStatisticsService.ValidationStats diagnoseListRules(@PathVariable Long snapshotID) throws Exception {
		
		List<String> fq = new ArrayList<String>();

		Optional<NetworkSnapshot> snapshot = networkSnapshotRepository.findById(snapshotID);

		if (!snapshot.isPresent()) // TODO: Implementar Exc
			throw new Exception("No snapshot found with id: " + snapshotID);
		

		return validationStatisticsService.queryValidatorRulesStatsBySnapshot(snapshot.get(), fq);
	}

	@RequestMapping(value = "/public/diagnoseValidationOcurrences/{snapshotID}/{ruleID}/{fq}", method = RequestMethod.GET)
	@ResponseBody
	public ValidationRuleOccurrencesCount diagnoseValidationOcurrences(@PathVariable Long snapshotID, @PathVariable Long ruleID, @PathVariable List<String> fq) throws Exception {

		Optional<NetworkSnapshot> snapshot = networkSnapshotRepository.findById(snapshotID);

		if (!snapshot.isPresent()) // TODO: Implementar Exc
			throw new Exception("No snapshot found with id: " + snapshotID);


		return validationStatisticsService.queryValidRuleOcurrencesCountBySnapshotID(snapshotID, ruleID, fq);
	}

	@RequestMapping(value = "/public/diagnoseValidationOcurrences/{snapshotID}/{ruleID}", method = RequestMethod.GET)
	@ResponseBody
	public ValidationRuleOccurrencesCount diagnoseValidationOcurrences(@PathVariable Long snapshotID, @PathVariable Long ruleID) throws Exception {

		List<String> fq = new ArrayList<String>();
		
		Optional<NetworkSnapshot> snapshot = networkSnapshotRepository.findById(snapshotID);

		if (!snapshot.isPresent()) // TODO: Implementar Exc
			throw new Exception("No snapshot found with id: " + snapshotID);


		return validationStatisticsService.queryValidRuleOcurrencesCountBySnapshotID(snapshotID, ruleID, fq);
	}

	
    @RequestMapping(value = "/public/diagnoseListRecordValidationResults/{snapshotID}/{fq}", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Page<ValidationStatObservation>> diagnoseListRecordValidationResults(
            @PathVariable Long snapshotID, @PathVariable List<String> fq, @RequestParam Map<String, String> params) {

        int count = Integer.parseInt(params.get("count"));
        int page = Integer.parseInt(params.get("page"));
        
        fq.addAll(buildDiagnoseQueryFilterFromParam(params));

        Pageable pageable = PageRequest.of(page, count);
        return new ResponseEntity<Page<ValidationStatObservation>>(
                validationStatisticsService.queryValidationStatsObservationsBySnapshotID(snapshotID, fq, pageable),
                HttpStatus.OK);
    }


    @RequestMapping(value = "/public/diagnoseListRecordValidationResults/{snapshotID}/fq", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Page<ValidationStatObservation>> diagnoseListRecordValidationResults(
            @PathVariable Long snapshotID, @RequestParam Map<String, String> params) {

        List<String> fq = new ArrayList<String>();
        int count = Integer.parseInt(params.get("count"));
        int page = Integer.parseInt(params.get("page"));

        fq.addAll(buildDiagnoseQueryFilterFromParam(params));

        Pageable pageable = PageRequest.of(page, count);

        return new ResponseEntity<Page<ValidationStatObservation>>(
                validationStatisticsService.queryValidationStatsObservationsBySnapshotID(snapshotID, fq, pageable),
                HttpStatus.OK);
    }

    private List<String> buildDiagnoseQueryFilterFromParam(Map<String, String> params) {
        List<String> fq = new ArrayList<String>();

        Pattern filterPattern = Pattern.compile("filter\\[(.*)\\]");
        String filterColumn;
        String filterNameExpression = null;

        for (String key : params.keySet()) {
            filterColumn = null;
            if (key.startsWith("filter")) {

                Matcher matcher = filterPattern.matcher(key);

                if (matcher.find()) {
                    filterColumn = matcher.group(1);
                    filterNameExpression = key;
                }

                if (filterColumn != null) {

                    switch (filterColumn) {

                        case "identifier":
                            String filterExpression = "oai_identifier:*" + params.get(filterNameExpression) + "*";
                            try {
                                filterExpression = java.net.URLDecoder.decode(filterExpression, "UTF-8");
                            } catch (UnsupportedEncodingException e) {
                            }

                            fq.add(filterExpression);
                            break;
                        default:
                            break;
                    }

                }
            }
        }

        return fq;
    }

	

	/**************************** FrontEnd ************************************/

	@ResponseBody
	@RequestMapping(value = "/public/lastGoodKnowSnapshotByNetworkID/{id}", method = RequestMethod.GET)
	public ResponseEntity<NetworkSnapshot> getLGKSnapshot(@PathVariable Long id) {

		NetworkSnapshot snapshot = networkSnapshotRepository.findLastGoodKnowByNetworkID(id);
		ResponseEntity<NetworkSnapshot> response = new ResponseEntity<NetworkSnapshot>(snapshot, snapshot == null ? HttpStatus.NOT_FOUND : HttpStatus.OK);
		return response;
	}

	@ResponseBody
	@RequestMapping(value = "/public/getSnapshotByID/{id}", method = RequestMethod.GET)
	public ResponseEntity<NetworkSnapshot> getSnapshotByID(@PathVariable Long id) {

		Optional<NetworkSnapshot> snapshot = networkSnapshotRepository.findById(id);
		ResponseEntity<NetworkSnapshot> response = new ResponseEntity<NetworkSnapshot>(snapshot.get(), !snapshot.isPresent() ? HttpStatus.NOT_FOUND : HttpStatus.OK);
		return response;
	}

	@ResponseBody
	@RequestMapping(value = "/public/getSnapshotInfoByID/{id}", method = RequestMethod.GET)
	public NetworkInfo getSnapshotInfoByID(@PathVariable Long id) throws Exception {

		Optional<NetworkSnapshot> optionalSnapshot = networkSnapshotRepository.findById(id);

		if (!optionalSnapshot.isPresent()) // TODO: Implementar Exc
			throw new Exception("No snapshot found with id: " + id);

		NetworkSnapshot snapshot = optionalSnapshot.get();
		
		Network network = snapshot.getNetwork();

		NetworkInfo ninfo = new NetworkInfo();
		ninfo.networkID = network.getId();
		ninfo.acronym = network.getAcronym();
		ninfo.name = network.getName();

		ninfo.snapshotID = snapshot.getId();
		ninfo.datestamp = snapshot.getEndTime();
		ninfo.size = snapshot.getSize();
		ninfo.validSize = snapshot.getValidSize();
		ninfo.transformedSize = snapshot.getTransformedSize();

		return ninfo;
	}

	@ResponseBody
	@RequestMapping(value = "/public/lastGoodKnowSnapshotByNetworkAcronym/{acronym}", method = RequestMethod.GET)
	public ResponseEntity<NetworkSnapshot> getLGKSnapshot(@PathVariable String acronym) throws Exception {

		Network network = networkRepository.findByAcronym(acronym);
		if (network == null) // TODO: Implementar Exc
			throw new Exception("No Network found: " + acronym);

		NetworkSnapshot snapshot = networkSnapshotRepository.findLastGoodKnowByNetworkID(network.getId());
		if (snapshot == null) // TODO: Implementar Exc
			throw new Exception("No valid Snapshot found for Network: " + acronym);

		ResponseEntity<NetworkSnapshot> response = new ResponseEntity<NetworkSnapshot>(snapshot, snapshot == null ? HttpStatus.NOT_FOUND : HttpStatus.OK);

		return response;
	}

	@ResponseBody
	@RequestMapping(value = "/public/listSnapshotsByNetworkAcronym/{acronym}", method = RequestMethod.GET)
	public ResponseEntity<List<NetworkSnapshot>> listSnapshotsByAcronym(@PathVariable String acronym) throws Exception {

		Network network = networkRepository.findByAcronym(acronym);
		if (network == null)
			throw new Exception("No Network found: " + acronym);

		ResponseEntity<List<NetworkSnapshot>> response = new ResponseEntity<List<NetworkSnapshot>>(networkSnapshotRepository.findByNetworkOrderByEndTimeAsc(network), HttpStatus.OK);

		return response;
	}
	
	@ResponseBody
	@RequestMapping(value = "/public/listMetadataFormats", method = RequestMethod.GET)
	public ResponseEntity<List<String>> listMetadataFormats() throws Exception {		
		ResponseEntity<List<String>> response = new ResponseEntity<List<String>>(mdTransformationService.getSourceMetadataFormats() , HttpStatus.OK);
		return response;
	}
	
	@ResponseBody
	@RequestMapping(value = "/public/getBitstream/{hash}", method = RequestMethod.GET)
	public ResponseEntity<InputStreamResource> getBitstream(@PathVariable String hash, HttpServletResponse response) throws Exception {		
		
	    try {
	    
	      OAIBitstream bitstream = bitstreamRepository.findOneByHash(hash);
	      
	      if ( bitstream != null && bitstream.getStatus() == OAIBitstreamStatus.DOWNLOADED ) {
	    	
		    	// get your file as InputStream
			  File file = new File( BITSTREAM_PATH + "/" + hash);
			  
		      HttpHeaders respHeaders = new HttpHeaders();
			    respHeaders.setContentType( MediaType.parseMediaType( bitstream.getMime())  );
			    respHeaders.setContentDispositionFormData("attachment", bitstream.getFilename());
	
			  InputStreamResource isr = new InputStreamResource(new FileInputStream(file));
			  
			  return new ResponseEntity<InputStreamResource>(isr, respHeaders, HttpStatus.OK);
	      } else
	    	  return new ResponseEntity<InputStreamResource>(HttpStatus.NOT_FOUND);
	    
	    } catch (Exception ex) {
	    	//log.info("Error writing file to output stream. Filename was '{}'", ex);
	    	return new ResponseEntity<InputStreamResource>(HttpStatus.NOT_FOUND);
	    }

	}
	
	


	// //////////////////////// Listar Redes y sus datos
	// //////////////////////////

	private List<NetworkInfo> networkList2netinfoList(List<Network> networks) {

		List<NetworkInfo> ninfoList = new ArrayList<NetworkInfo>();

		for (Network network : networks) {

			NetworkInfo ninfo = new NetworkInfo();
			ninfo.networkID = network.getId();
			ninfo.acronym = network.getAcronym();
			ninfo.name = network.getName();
			ninfo.institution = network.getInstitutionName();
			ninfo.institutionAcronym = network.getInstitutionAcronym();
			ninfo.setAttributes( network.getAttributes() );
			
			
			String runningContextID = NetworkRunningContext.buildID(network);
			
			ninfo.running = networkActionManager.getTaskManager().getRunningTasksByRunningContextID(runningContextID);
			ninfo.queued = networkActionManager.getTaskManager().getQueuedTasksByRunningContextID(runningContextID);
			ninfo.scheduled = networkActionManager.getTaskManager().getScheduledTasksByRunningContextID(runningContextID);
	

			NetworkSnapshot lstSnapshot = networkSnapshotRepository.findLastByNetworkID(network.getId());
			if (lstSnapshot != null) {

				ninfo.lstSnapshotID = lstSnapshot.getId();
				ninfo.lstSnapshotDate = lstSnapshot.getEndTime();
				ninfo.lstSize = lstSnapshot.getSize();
				ninfo.lstValidSize = lstSnapshot.getValidSize();
				ninfo.lstTransformedSize = lstSnapshot.getTransformedSize();
				ninfo.lstSnapshotStatus = lstSnapshot.getStatus();
				ninfo.lstIndexStatus = lstSnapshot.getIndexStatus();
			}

			NetworkSnapshot lgkSnapshot = networkSnapshotRepository.findLastGoodKnowByNetworkID(network.getId());
			if (lgkSnapshot != null) {

				ninfo.snapshotID = lgkSnapshot.getId();
				ninfo.datestamp = lgkSnapshot.getEndTime();
				ninfo.size = lgkSnapshot.getSize();
				ninfo.validSize = lgkSnapshot.getValidSize();
				ninfo.transformedSize = lgkSnapshot.getTransformedSize();

				ninfo.lgkSnapshotID = lgkSnapshot.getId();
				ninfo.lgkSnapshotDate = lgkSnapshot.getEndTime();
				ninfo.lgkSize = lgkSnapshot.getSize();
				ninfo.lgkValidSize = lgkSnapshot.getValidSize();
				ninfo.lgkTransformedSize = lgkSnapshot.getTransformedSize();

			}
			ninfoList.add(ninfo);
		}
		return ninfoList;
	}

	// listado de redes publicadas
	@ResponseBody
	@RequestMapping(value = "/public/listNetworks", method = RequestMethod.GET)
	@CrossOrigin
	public ResponseEntity<List<NetworkInfo>> listNetworks() {

		List<NetworkInfo> ninfoList = networkList2netinfoList(networkRepository.findByPublishedOrderByNameAsc(true));
		return new ResponseEntity<List<NetworkInfo>>(ninfoList, HttpStatus.OK);
	}

	// listado de todas las redes
	@ResponseBody
	@RequestMapping(value = "/private/networks", method = RequestMethod.GET)
	public ResponseEntity<NetworksListResponse> listNetworks(@RequestParam Map<String, String> params) {
	
		NetworksListResponse response = new NetworksListResponse(findByParams(params));
		return new ResponseEntity<NetworksListResponse>(response, HttpStatus.OK);
	}

	private Page<Network> findByParams(Map<String, String> params) {

		int page = Integer.parseInt(params.get("page"));
		// Correción para que la paginación empiece en 1
		page--;

		int count = Integer.parseInt(params.get("count"));

		Pageable pageRequest = PageRequest.of(page, count, Direction.ASC, "id");

		String filterColumn = null;
		String filterExpression = null;

		Pattern sortingPattern = Pattern.compile("sorting\\[(.*)\\]");
		Pattern filterPattern = Pattern.compile("filter\\[(.*)\\]");

		// Matcher matcher = pattern.matcher(ISBN);

		for (String key : params.keySet()) {

			if (key.startsWith("sorting")) {

				Direction sortDirection = Direction.ASC;
				Matcher matcher = sortingPattern.matcher(key);

				if (matcher.find()) {
					String columnName = matcher.group(1);
					if (params.get(key).equals("desc"))
						sortDirection = Direction.DESC;
					pageRequest = PageRequest.of(page, count, sortDirection, columnName);
				}
			}

			if (key.startsWith("filter")) {

				Matcher matcher = filterPattern.matcher(key);

				if (matcher.find()) {
					filterColumn = matcher.group(1);
					filterExpression = params.get(key);
					try {
						filterExpression = java.net.URLDecoder.decode(filterExpression, "UTF-8");
					} catch (UnsupportedEncodingException e) {}
				}
			}
		}

		if (filterColumn != null) {

			switch (filterColumn) {
			
			case "id":
				return networkRepository.findById(filterExpression, pageRequest);

			case "name":
				return networkRepository.findByNameIgnoreCaseContaining(filterExpression, pageRequest);

			case "institution":
				return networkRepository.findByInstitutionNameIgnoreCaseContaining(filterExpression, pageRequest);
				
			case "status":
				SnapshotStatus filterStatus = SnapshotStatus.fromString(filterExpression);
				return networkRepository.customFindByStatus( filterStatus, pageRequest);
			
			case "indexStatus":
				SnapshotIndexStatus filterIndexStatus = SnapshotIndexStatus.fromString(filterExpression);
				return networkRepository.customFindByIndexStatus( filterIndexStatus, pageRequest);
				
			case "acronym":
				return networkRepository.findByAcronymIgnoreCaseContaining(filterExpression, pageRequest);

			default:
				return networkRepository.findAll(pageRequest);

			}
		} else
			return networkRepository.findAll(pageRequest);

	}

	@ResponseBody
	@RequestMapping(value = "/public/listNetworksHistory", method = RequestMethod.GET)
	public ResponseEntity<List<NetworkHistory>> listNetworksHistory() {

		List<Network> allNetworks = networkRepository.findByPublishedOrderByNameAsc(true);// OrderByName();
		List<NetworkHistory> NHistoryList = new ArrayList<NetworkHistory>();

		for (Network network : allNetworks) {
			NetworkHistory nhistory = new NetworkHistory();
			nhistory.name = network.getName();
			nhistory.networkID = network.getId();
			nhistory.acronym = network.getAcronym();
			nhistory.validSnapshots = networkSnapshotRepository.findByNetworkAndStatusOrderByEndTimeAsc(network, SnapshotStatus.VALID);
			NHistoryList.add(nhistory);
		}

		ResponseEntity<List<NetworkHistory>> response = new ResponseEntity<List<NetworkHistory>>(NHistoryList, HttpStatus.OK);

		return response;
	}

	/************** Clases de retorno de resultados *******************/

	@Getter
	@Setter
	class NetworkInfo {
		
		private Long networkID;
		public String institutionAcronym;
		public String acronym;
		private String name;
		private String institution;
		private Map<String,Object> attributes;
			
		private List<String> running;
		private List<String> queued;
		private List<String> scheduled;

		// DEPRECATED
		/** Esto queda por legacy pero es depreacted **/
		private Long snapshotID;
		@JsonSerialize(using = JsonDateSerializer.class)
		private LocalDateTime datestamp;
		private int size;
		private int validSize;
		private int transformedSize;
		/** fin deprecated **/

		private Long lgkSnapshotID;
		@JsonSerialize(using = JsonDateSerializer.class)
		private LocalDateTime lgkSnapshotDate;
		private int lgkSize;
		private int lgkValidSize;
		private int lgkTransformedSize;

		private Long lstSnapshotID;
		@JsonSerialize(using = JsonDateSerializer.class)
		private LocalDateTime lstSnapshotDate;
		private SnapshotStatus lstSnapshotStatus;
		public  SnapshotIndexStatus lstIndexStatus;
		private int lstSize;
		private int lstValidSize;
		private int lstTransformedSize;
	}

	@Getter
	@Setter
	class NetworkHistory {
		public String name;
		public String acronym;
		private Long networkID;
		private List<NetworkSnapshot> validSnapshots;
	}

	@Getter
	@Setter
	class NetworksListResponse {

		private long totalElements;
		private int totalPages;
		private int pageNumber;
		private int pageSize;
		private List<NetworkInfo> networks;

		public NetworksListResponse(Page<Network> page) {
			super();
			this.networks = networkList2netinfoList(page.getContent());
			this.totalElements = page.getTotalElements();
			this.totalPages = page.getTotalPages();
			this.pageNumber = page.getNumber();
			this.pageSize = page.getSize();
		}
	}

}
