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

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.web.context.ConfigurableWebApplicationContext;

public class MainAppContextInitializer implements ApplicationContextInitializer<ConfigurableWebApplicationContext> {
	
	private static Logger logger = LogManager.getLogger(MainAppContextInitializer.class);

	@Override
	public void initialize(ConfigurableWebApplicationContext applicationContext) {
		
		
		//final String configFilePath = applicationContext.getServletContext().getInitParameter("mainConfigFilePath");
		
		class TrustAll implements X509TrustManager
		{
		    public void checkClientTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException
		    {
		    }

		    public void checkServerTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException
		    {
		    }

		    public X509Certificate[] getAcceptedIssuers()
		    {
		        return new X509Certificate[0];
		    }
		}


		try {

			// Se agregan las propiedades del archivo de configuración
//			ResourcePropertySource source = new ResourcePropertySource("file:" + configFilePath);
//			applicationContext.getEnvironment().getPropertySources().addFirst(source);
//
//			// Se agrega una propieedad con el paht del archivo de conf para ser
//			// accedido desde el xml de contextos
//			Properties lrConfigProperties = new Properties();
//			lrConfigProperties.put("backend.properties.path", backendPropertiesPath);

//			PropertiesPropertySource pathsPSource = new PropertiesPropertySource("lrpaths", lrConfigProperties);
//			applicationContext.getEnvironment().getPropertySources().addFirst(pathsPSource);
			
			SSLContext ctx = SSLContext.getInstance("TLS");
		    
		    ctx.init(null, new TrustManager[] { new TrustAll() }, null);
		    HttpsURLConnection.setDefaultSSLSocketFactory(ctx.getSocketFactory());

//			logger.info("\n\n\n******************** Inicializando configuración desde  " + backendPropertiesPath + "  !!!\n\n\n");
			

	//	} catch (IOException e) {

	//		logger.error("\n\n\nNo se puede acceder al archivo de configuración principal:" + backendPropertiesPath +"\n\n\n");

			// handle error
		} catch (KeyManagementException | NoSuchAlgorithmException e) {
			logger.error("\n\n Problemas en la definicion de conexiones ssl en AppContextInitializer");
		} 
	}
}