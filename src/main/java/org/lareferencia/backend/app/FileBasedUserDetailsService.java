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

package org.lareferencia.backend.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;

/**
 * File-based UserDetailsService implementation.
 * 
 * Reads users from a properties file with format:
 * username=bcrypt_encoded_password,ROLE_ADMIN,ROLE_USER
 * 
 * Features:
 * - In-memory cache for fast lookups
 * - Automatic reload when user not found (allows adding users without restart)
 * - BCrypt password encoding support
 * 
 * @author LA Referencia Team
 */
@Service
public class FileBasedUserDetailsService implements UserDetailsService {

    private static final Logger logger = LoggerFactory.getLogger(FileBasedUserDetailsService.class);

    @Value("${security.users.file:config/users.properties}")
    private String usersFilePath;

    private final ResourceLoader resourceLoader;
    
    private final ConcurrentHashMap<String, UserDetails> usersCache = new ConcurrentHashMap<>();

    public FileBasedUserDetailsService(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
        logger.info("FileBasedUserDetailsService instantiated");
    }

    @PostConstruct
    public void init() {
        logger.info("FileBasedUserDetailsService @PostConstruct called");
        loadUsersFromFile();
    }

    /**
     * Load or reload users from the properties file.
     * Thread-safe operation that clears and repopulates the cache.
     * 
     * Tries multiple locations:
     * 1. File path as-is (absolute or relative to working directory)
     * 2. As a Spring resource (file:, classpath:, etc.)
     */
    public synchronized void loadUsersFromFile() {
        logger.info("Attempting to load users from: {}", usersFilePath);
        logger.info("Current working directory: {}", System.getProperty("user.dir"));
        
        BufferedReader reader = null;
        String resolvedPath = usersFilePath;
        
        try {
            // First try as a regular file path
            Path path = Paths.get(usersFilePath);
            if (Files.exists(path)) {
                resolvedPath = path.toAbsolutePath().toString();
                logger.info("Found users file at: {}", resolvedPath);
                reader = Files.newBufferedReader(path, StandardCharsets.UTF_8);
            } else {
                logger.info("File not found at relative path, trying Spring ResourceLoader...");
                
                // Try as Spring resource with file: prefix
                Resource resource = resourceLoader.getResource("file:" + usersFilePath);
                if (resource.exists()) {
                    resolvedPath = resource.getFile().getAbsolutePath();
                    logger.info("Found users file via ResourceLoader at: {}", resolvedPath);
                    reader = new BufferedReader(new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8));
                } else {
                    // Try classpath
                    resource = resourceLoader.getResource("classpath:" + usersFilePath);
                    if (resource.exists()) {
                        resolvedPath = "classpath:" + usersFilePath;
                        logger.info("Found users file in classpath: {}", resolvedPath);
                        reader = new BufferedReader(new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8));
                    }
                }
            }
            
            if (reader == null) {
                logger.error("Users file not found at: {}. Tried absolute path: {}", 
                            usersFilePath, Paths.get(usersFilePath).toAbsolutePath());
                return;
            }
            
            loadUsersFromReader(reader, resolvedPath);
            
        } catch (IOException e) {
            logger.error("Error reading users file: {}", usersFilePath, e);
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    logger.warn("Error closing reader", e);
                }
            }
        }
    }
    
    /**
     * Load users from the provided reader.
     */
    private void loadUsersFromReader(BufferedReader reader, String sourcePath) throws IOException {
        ConcurrentHashMap<String, UserDetails> newCache = new ConcurrentHashMap<>();
        
        String line;
        int lineNumber = 0;
        
        while ((line = reader.readLine()) != null) {
            lineNumber++;
            line = line.trim();
            
            // Skip empty lines and comments
            if (line.isEmpty() || line.startsWith("#")) {
                continue;
            }

            logger.debug("Parsing line {}: {}", lineNumber, line.substring(0, Math.min(20, line.length())) + "...");
            
            try {
                UserDetails user = parseUserLine(line);
                if (user != null) {
                    newCache.put(user.getUsername(), user);
                    logger.info("Loaded user: {} with {} authorities", 
                               user.getUsername(), user.getAuthorities().size());
                }
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid user entry at line {}: {}", lineNumber, e.getMessage());
            }
        }

        // Atomic swap of the cache
        usersCache.clear();
        usersCache.putAll(newCache);
        
        logger.info("Successfully loaded {} users from {}", usersCache.size(), sourcePath);
    }

    /**
     * Parse a line from the users file.
     * Format: username=bcrypt_password,ROLE_1,ROLE_2,...
     * 
     * BCrypt passwords start with $2a$, $2b$, or $2y$ followed by cost factor
     * Example: admin=$2b$10$xyz...,ROLE_ADMIN
     * 
     * @param line the line to parse
     * @return UserDetails object or null if line is invalid
     */
    private UserDetails parseUserLine(String line) {
        int equalsIndex = line.indexOf('=');
        if (equalsIndex <= 0) {
            throw new IllegalArgumentException("Missing '=' separator");
        }

        String username = line.substring(0, equalsIndex).trim();
        String rest = line.substring(equalsIndex + 1).trim();

        if (username.isEmpty()) {
            throw new IllegalArgumentException("Empty username");
        }

        if (rest.isEmpty()) {
            throw new IllegalArgumentException("Empty password and roles for user: " + username);
        }

        // Find the comma that separates password from roles
        // BCrypt hashes look like: $2b$10$XXXX... (60 chars total, no commas inside)
        // So we find ",ROLE_" which marks the start of roles
        
        String encodedPassword;
        String[] roles;
        
        int roleIndex = rest.indexOf(",ROLE_");
        if (roleIndex == -1) {
            throw new IllegalArgumentException("No roles found for user: " + username + ". Expected format: password,ROLE_XXX");
        }
        
        encodedPassword = rest.substring(0, roleIndex).trim();
        String rolesStr = rest.substring(roleIndex + 1).trim();
        roles = rolesStr.split(",");
        
        if (encodedPassword.isEmpty()) {
            throw new IllegalArgumentException("Empty password for user: " + username);
        }
        
        // Validate BCrypt format
        if (!encodedPassword.startsWith("$2")) {
            logger.warn("Password for user '{}' does not appear to be BCrypt encoded (should start with $2a$, $2b$, or $2y$)", username);
        }
        
        logger.debug("Parsed user '{}' with password hash length {} and {} roles", 
                     username, encodedPassword.length(), roles.length);
        
        // Collect roles
        var authorities = Arrays.stream(roles)
                .map(String::trim)
                .filter(role -> !role.isEmpty())
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        if (authorities.isEmpty()) {
            throw new IllegalArgumentException("No roles defined for user: " + username);
        }

        return User.builder()
                .username(username)
                .password(encodedPassword)
                .authorities(authorities)
                .build();
    }

    /**
     * Load user by username.
     * If user is not found in cache, reloads the file and tries again.
     * This allows adding new users without restarting the application.
     * 
     * @param username the username to look up
     * @return UserDetails for the user
     * @throws UsernameNotFoundException if user is not found even after reload
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        logger.debug("loadUserByUsername called for: '{}'", username);
        
        // First, try to find in cache
        UserDetails cachedUser = usersCache.get(username);
        
        if (cachedUser != null) {
            logger.debug("User '{}' found in cache", username);
            // Return a COPY to prevent Spring Security from erasing the password in our cache
            return User.withUserDetails(cachedUser).build();
        }

        // User not found - reload file and try again
        logger.info("User '{}' not found in cache, reloading users file...", username);
        loadUsersFromFile();

        cachedUser = usersCache.get(username);
        
        if (cachedUser == null) {
            logger.warn("User '{}' not found after reloading users file", username);
            throw new UsernameNotFoundException("User not found: " + username);
        }

        // Return a COPY to prevent Spring Security from erasing the password in our cache
        return User.withUserDetails(cachedUser).build();
    }

    /**
     * Get the number of users currently loaded.
     * @return count of users in cache
     */
    public int getUserCount() {
        return usersCache.size();
    }
}
