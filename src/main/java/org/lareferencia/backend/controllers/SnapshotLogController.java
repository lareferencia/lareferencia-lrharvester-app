/*
 *   Copyright (c) 2013-2025. LA Referencia / Red CLARA and others
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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.lareferencia.core.service.management.SnapshotLogService;
import org.lareferencia.core.service.management.SnapshotLogService.LogQueryResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for accessing snapshot logs.
 * 
 * Provides API endpoints to retrieve snapshot log entries from file-based storage.
 * Compatible with the frontend API expecting Spring Data REST format.
 * 
 * Endpoint: /rest/log/search/findBySnapshotId?snapshot_id=X&size=Y&page=Z
 * 
 * Response format:
 * {
 *   "_embedded": {
 *     "log": [
 *       { "timestamp": "...", "message": "..." },
 *       ...
 *     ]
 *   },
 *   "page": { ... }
 * }
 */
@RestController
@RequestMapping("/rest/log/search")
public class SnapshotLogController {
	
	private static Logger logger = LogManager.getLogger(SnapshotLogController.class);
	
	@Autowired
	private SnapshotLogService snapshotLogService;

	/**
	 * Retrieves snapshot log entries by snapshot ID.
	 * 
	 * API endpoint compatible with Spring Data REST format.
	 * Reads logs from file: {basePath}/{NETWORK}/snapshots/snapshot_{id}/snapshot.log
	 * 
	 * @param snapshotId the snapshot ID
	 * @param page page number (0-indexed, default 0)
	 * @param size page size (default 20)
	 * @return ResponseEntity with log entries in Spring Data REST format
	 */
	@RequestMapping(value = "/findBySnapshotId", method = RequestMethod.GET)
	public ResponseEntity<Map<String, Object>> findBySnapshotId(
			@RequestParam("snapshot_id") Long snapshotId,
			@RequestParam(value = "page", defaultValue = "0") int page,
			@RequestParam(value = "size", defaultValue = "20") int size) {
		
		// Llamar al servicio para obtener logs
		LogQueryResult queryResult = snapshotLogService.getLogEntries(snapshotId, page, size);
		
		if (!queryResult.isSuccess()) {
			logger.error("Error retrieving logs for snapshot {}: {}", snapshotId, queryResult.getError());
			return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		}
		
		// Construir respuesta usando Map para control exacto de la serialización
		Map<String, Object> response = new HashMap<>();
		
		// _embedded con log entries
		Map<String, Object> embedded = new HashMap<>();
		embedded.put("log", queryResult.getEntries());
		response.put("_embedded", embedded);
		
		// page info
		Map<String, Object> pageInfo = new HashMap<>();
		pageInfo.put("number", queryResult.getCurrentPage());
		pageInfo.put("size", queryResult.getPageSize());
		pageInfo.put("totalElements", queryResult.getTotalElements());
		pageInfo.put("totalPages", queryResult.getTotalPages());
		response.put("page", pageInfo);
		
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
}
