<?xml version="1.0" encoding="UTF-8" ?>

<!--
  ~   Copyright (c) 2013-2022. LA Referencia / Red CLARA and others
  ~
  ~   This program is free software: you can redistribute it and/or modify
  ~   it under the terms of the GNU Affero General Public License as published by
  ~   the Free Software Foundation, either version 3 of the License, or
  ~   (at your option) any later version.
  ~
  ~   This program is distributed in the hope that it will be useful,
  ~   but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~   GNU Affero General Public License for more details.
  ~
  ~   You should have received a copy of the GNU Affero General Public License
  ~   along with this program.  If not, see <http://www.gnu.org/licenses/>.
  ~
  ~   This file is part of LA Referencia software platform LRHarvester v4.x
  ~   For any further information please contact Lautaro Matas <lmatas@gmail.com>
  -->

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	version="2.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	
	<!-- Aquí van los listados para diferenciar type en tipo de documento y status -->    
	<xsl:variable name="type_list">info:eu-repo/semantics/article,info:eu-repo/semantics/bachelorThesis,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/review,info:eu-repo/semantics/conferenceObject,info:eu-repo/semantics/lecture,info:eu-repo/semantics/workingPaper,info:eu-repo/semantics/preprint,info:eu-repo/semantics/report,info:eu-repo/semantics/annotation,info:eu-repo/semantics/contributionToPeriodical,info:eu-repo/semantics/patent,info:eu-repo/semantics/other</xsl:variable>
	<xsl:variable name="status_list">info:eu-repo/semantics/draft,info:eu-repo/semantics/acceptedVersion,info:eu-repo/semantics/submittedVersion,info:eu-repo/semantics/publishedVersion,info:eu-repo/semantics/updatedVersion</xsl:variable>
	<xsl:variable name="rights_list" select="tokenize('info:eu-repo/semantics/openAccess,info:eu-repo/semantics/embargoedAccess,info:eu-repo/semantics/restrictedAccess,info:eu-repo/semantics/closedAccess', ',')"/>
	
	   
	<!--  Aquí se definen los prefijos utilizados para detectar contenidos con trato diferencial -->   
	<xsl:variable name="driver_prefix">info:eu-repo/semantics/</xsl:variable> 
	<xsl:variable name="reponame_prefix">reponame:</xsl:variable>  
	<xsl:variable name="instname_prefix">instname:</xsl:variable>  
	
	
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	
	<xsl:param name="fingerprint" />
	<xsl:param name="identifier" />
	<xsl:param name="record_id" />
	
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<doc>
		
			 <!-- ID es parámetro -->
            <field name="id">
            	<xsl:value-of select="$fingerprint"/>
            </field>
            
            <!-- ID es parámetro -->
            <field name="oai_identifier">
            	<xsl:value-of select="$identifier"/>
            </field>   
            
             <field name="network_acronym">
            	<xsl:value-of select="$networkAcronym"/>
            </field>
            
            <!-- networkName es parámetro -->
            <field name="network_name">
            	<xsl:value-of select="$networkName"/>
            </field>    
                                   
            <!-- RECORDTYPE -->
            <field name="recordtype">driver</field>         

            <!-- ALLFIELDS -->
            <field name="allfields">
                <xsl:value-of select="normalize-space()"/>
            </field>
            
			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.title.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.title.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.title.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.title distinct vufind fields  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value'])">				
				 <xsl:if test="position()=1">
				 	<field name="title"><xsl:value-of select="normalize-space()"/></field>
	                <field name="title_short"><xsl:value-of select="normalize-space()"/></field>
	                <field name="title_full"><xsl:value-of select="normalize-space()"/></field>
	                <field name="title_sort"><xsl:value-of select="normalize-space()"/></field>
                </xsl:if>
			</xsl:for-each>
			
			<!-- dc.creator -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.creator.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.contributor.author -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.creator"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- select first author from distinct ( dc.creator | dc.contributor.author ) -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value'])">
		
			      <!-- author is not a multi-valued field, so we'll put
			                first value there and subsequent values in author2.
			      -->
		           <xsl:if test="position()=1">
		               <field name="author"><xsl:value-of select="normalize-space()"/></field>
		               <field name="author-letter"><xsl:value-of select="normalize-space()"/></field>
		           </xsl:if>
		           <xsl:if test="position()>1">
		               <field name="author2"><xsl:value-of select="normalize-space()"/></field>
		           </xsl:if>
		
			</xsl:for-each>
			
			
			<!-- dc.contributor.*  -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.contributor.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.contributor.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.subject -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.subject.{../@name}"><xsl:value-of select="normalize-space()" /></field>
				
				<xsl:if test="string-length(normalize-space()) > 0">
                	<field name="topic"><xsl:value-of select="normalize-space()"/></field>
                </xsl:if>
			</xsl:for-each>
			
			<!-- dc.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.subject.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
				
				<xsl:if test="string-length(normalize-space()) > 0">
                	<field name="topic"><xsl:value-of select="normalize-space()"/></field>
                </xsl:if>
                
			</xsl:for-each>
			
			<!-- dc.description -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.description.{../@name}"><xsl:value-of select="normalize-space()" /></field>
				
				<xsl:if test="position()=1">
					<field name="description"><xsl:value-of select="normalize-space()" /></field>
				</xsl:if>
			</xsl:for-each>
			
			<!-- dc.description.* (not provenance)-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.description.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			
			<!-- select first year from distinct sorted ( dc.date | dc.contributor.date.XXX ) -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value'])">
			
				<xsl:sort select="substring(., 1, 4)"/>
	            <xsl:if test="position() = 1">
					<field name="publishDate"><xsl:value-of select="substring(., 1, 4)"/></field>
					<field name="publishDateSort"><xsl:value-of select="substring(., 1, 4)"/></field>
				</xsl:if>	
				
			</xsl:for-each>	
			
			<!-- dc.date.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:sort select="substring(., 1, 4)"/>	
				<field name="metadata.dc.date.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.date -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<xsl:sort select="substring(., 1, 4)"/>
				<field name="metadata.dc.date.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.type -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.type.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.type.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.type.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- distinct dc.type format/status  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value'])">
				
				<xsl:if test="starts-with(., $driver_prefix)">
 					<xsl:choose>
						<xsl:when test="contains($type_list, normalize-space())">
							<field name="format"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
						</xsl:when>
						<xsl:when test="contains($status_list, normalize-space())">
							<field name="status"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
			
			<!-- dc.identifier -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.identifier.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.identifier.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.identifier.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- Distinct identifiers, url separation  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value'])">				
				<xsl:choose>
					<xsl:when test="starts-with(., 'http')">
						<field name="url"><xsl:value-of select="normalize-space()" /></field>
					</xsl:when>
					<xsl:otherwise>
						<field name="identifier"><xsl:value-of select="normalize-space()" /></field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			
			<!-- dc.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.language.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.language.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.language.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.language distinct vufind field -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value'])">
				<xsl:choose>
	            	<xsl:when test="string-length() = 3">
						<field name="language">
							<xsl:value-of select="normalize-space()"/>
						</field>					
                    </xsl:when>
                    <xsl:otherwise>           
	                    <field name="language_invalid">
							<xsl:value-of select="normalize-space()"/>
						</field>					                    
                    </xsl:otherwise>
				</xsl:choose>  
			</xsl:for-each>
			
			
			<!-- dc.relation -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.relation.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.relation.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.relation.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.rights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.rights.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.rights.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.rights.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.rights distinct vufind field -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value'])">
				
				<xsl:choose>
					<xsl:when test="count(index-of($rights_list, normalize-space()))&gt;0">
						<field name="eu_rights"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
					</xsl:when>
					<xsl:otherwise>
						<field name="rights_invalid"><xsl:value-of select="normalize-space()" /></field>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:for-each>
			
			<!-- dc.format -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.format.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.format.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.format.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- ? -->
			<xsl:for-each select="doc:metadata/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
				<field name="metadata.dc.format"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.coverage.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.coverage.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.coverage.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.publisher.{../@name}"><xsl:value-of select="normalize-space()" /></field>		
			</xsl:for-each>
			
			<!-- dc.publisher.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.publisher.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			<!-- dc.publisher distinct vufind field  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:element/doc:field[@name='value'])">
			    <field name="publisher"><xsl:value-of select="normalize-space()"/></field>
			</xsl:for-each>
			
			<!-- dc.source -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.source.{../@name}"><xsl:value-of select="normalize-space()" /></field>
				
				<xsl:choose>
					<xsl:when test="starts-with(., $instname_prefix)">
					 	<field name="instname">
                   			<xsl:value-of select="substring(normalize-space(), string-length($instname_prefix)+1, string-length(normalize-space()))" />
               			</field>
						<field name="institution">
                   			<xsl:value-of select="substring(normalize-space(), string-length($instname_prefix)+1, string-length(normalize-space()))" />
               			</field>
					</xsl:when>
					<xsl:when test="starts-with(., $reponame_prefix)">
					 	<field name="reponame">
                   			<xsl:value-of select="substring(normalize-space(), string-length($reponame_prefix)+1, string-length(normalize-space()))" />
               			</field>
						<field name="collection">
                   			<xsl:value-of select="substring(normalize-space(), string-length($reponame_prefix)+1, string-length(normalize-space()))" />
               			</field>
					</xsl:when>
				</xsl:choose>      
			</xsl:for-each>
			
			<!-- dc.source.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.source.{../../@name}.{../@name}"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>
			
			
			<xsl:for-each select="doc:metadata/doc:element/doc:element/doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
				<field name="metadata.bitstream.url"><xsl:value-of select="./doc:field[@name='url']" /></field>
				<field name="metadata.bitstream.checksum"><xsl:value-of select="./doc:field[@name='checksum']" /></field>
				<field name="metadata.bitstream.checksumAlgorithm"><xsl:value-of select="./doc:field[@name='checksumAlgorithm']" /></field>	
			</xsl:for-each>
			
		
			<xsl:for-each select="doc:metadata/doc:element[@name='repository']">
				<field name="metadata.repository.name"><xsl:value-of select="./doc:field[@name='name']" /></field>
				<field name="metadata.repository.mail"><xsl:value-of select="./doc:field[@name='mail']" /></field>
			</xsl:for-each>
		

		</doc>
	</xsl:template>
</xsl:stylesheet>
