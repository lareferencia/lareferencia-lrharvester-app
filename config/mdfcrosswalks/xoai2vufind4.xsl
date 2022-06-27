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


	<!-- xsl:variable name="type_list" select="tokenize('info:eu-repo/semantics/article,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/report,info:eu-repo/semantics/dataSet',',')"/-->


	<xsl:variable name="type_list" select="tokenize('info:eu-repo/semantics/article,info:eu-repo/semantics/bachelorThesis,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/review,info:eu-repo/semantics/conferenceObject,info:eu-repo/semantics/lecture,info:eu-repo/semantics/workingPaper,info:eu-repo/semantics/preprint,info:eu-repo/semantics/report,info:eu-repo/semantics/annotation,info:eu-repo/semantics/contributionToPeriodical,info:eu-repo/semantics/patent,info:eu-repo/semantics/other,info:eu-repo/semantics/dataset',',')"/>
	<xsl:variable name="status_list" select="tokenize('info:eu-repo/semantics/draft,info:eu-repo/semantics/acceptedVersion,info:eu-repo/semantics/submittedVersion,info:eu-repo/semantics/publishedVersion,info:eu-repo/semantics/updatedVersion',',')"/>
	<xsl:variable name="rights_list" select="tokenize('info:eu-repo/semantics/openAccess,info:eu-repo/semantics/embargoedAccess,info:eu-repo/semantics/restrictedAccess,info:eu-repo/semantics/closedAccess', ',')"/>


	<!--  Aquí se definen los prefijos utilizados para detectar contenidos con trato diferencial -->
	<xsl:variable name="driver_prefix">info:eu-repo/semantics/</xsl:variable>
	<xsl:variable name="reponame_prefix">reponame:</xsl:variable>
	<xsl:variable name="instname_prefix">instname:</xsl:variable>
	<xsl:variable name="instacron_prefix">instacron:</xsl:variable>

	<xsl:variable name="maxStringLength" select="number(30000)"/>
	
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />
	

	<xsl:param name="fingerprint" />
	<xsl:param name="identifier" />
	<xsl:param name="record_id" />
	<xsl:param name="fulltext" />

	<xsl:param name="attr_repository_id" />

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<doc>

			 <!-- ID es parámetro -->
            <field name="id">
            	<xsl:value-of select="$fingerprint"/>
            </field>

            <!-- ID es parámetro -->
            <field name="oai_identifier_str">
            	<xsl:value-of select="$identifier"/>
            </field>

             <field name="network_acronym_str">
            	<xsl:value-of select="$networkAcronym"/>
            </field>

            <!-- networkName es parámetro -->
            <field name="network_name_str">
            	<xsl:value-of select="$networkName"/>
            </field>
			
			<field name="repository_id_str">
				<xsl:value-of select="$attr_repository_id"/>
			</field>

            <!-- ALLFIELDS -->
            <field name="allfields">
                <xsl:value-of select="normalize-space()"/>
            </field>

             <!-- ALLFIELDS -->
            <field name="fulltext">
                <xsl:value-of select="normalize-space($fulltext)"/>
            </field>

			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<field name="dc.title.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.title.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.title.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.title distinct vufind fields  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value' and text()!='']|doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value' and text()!=''])">
				 <xsl:if test="position()=1">
				 	<field name="title"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
	        <field name="title_short"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
	        <field name="title_full"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
	        <field name="title_sort"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
        </xsl:if>
			</xsl:for-each>

			<!-- dc.creator -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<field name="dc.creator.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.creator.*  -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.creator.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.contributor.author -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<field name="dc.creator.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- select first author from distinct ( dc.creator | dc.contributor.author ) -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:field[@name='value'])">

			      <!-- author is not a multi-valued field, so we'll put
			                first value there and subsequent values in author2.
			      -->
		           <xsl:if test="position()=1">
		               <field name="author"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
		               <field name="author_role">author</field>
		           </xsl:if>
		           <xsl:if test="position()>1">
		               <field name="author2"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
		               <field name="author2_role">author</field>
		           </xsl:if>

			</xsl:for-each>


			<!-- dc.contributor.*  -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.contributor.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<field name="dc.contributor.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor1' or @name='advisor2' or @name='advisor-co1' or @name='advisor-co2' or @name='referee1' or @name='referee2' or @name='referee3'or @name='referee4'or @name='referee5']/doc:field[@name='value']">
				<field name="contributor_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.subject -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<field name="dc.subject.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>

				<xsl:if test="string-length(substring(normalize-space(),1,$maxStringLength)) > 0">
                	<field name="topic"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
                </xsl:if>
			</xsl:for-each>

			<!-- dc.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.subject.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>

				<xsl:if test="string-length(substring(normalize-space(),1,$maxStringLength)) > 0">
                	<field name="topic"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
                </xsl:if>

			</xsl:for-each>

			<!-- dc.description 
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:field[@name='value']">
				<field name="dc.description.{../@name}.fl_txt_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:element/doc:field[@name='value']">
				<field name="dc.description.{../../@name}.{../@name}.fl_txt_mv"><xsl:value-of select="normalize-space()" /></field>

			</xsl:for-each>
			-->

 			<!-- dc.description.* (not provenance)-->
    			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:element/doc:field[@name='value' and text()!='']|doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:field[@name='value' and text()!=''])">
            			<xsl:if test="position()=1">
                    			<field name="description"><xsl:value-of select="normalize-space()" /></field>
            			</xsl:if>
    			</xsl:for-each>


			<!-- select first year from distinct sorted ( dc.date | dc.contributor.date.XXX ) -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value' and matches(text(),'(^\d{4}$)|(^\d{4}-\d{2}$)|(^\d{4}-\d{2}-\d{2}$)|(^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}([+-]\d{2}:\d{2}|Z)$)')]|doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value' and matches(text(),'(^\d{4}$)|(^\d{4}-\d{2}$)|(^\d{4}-\d{2}-\d{2}$)|(^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}([+-]\d{2}:\d{2}|Z)$)') ])">

				<xsl:sort select="substring(., 1, 4)"/>
	            <xsl:if test="position() = 1">
					<field name="publishDate"><xsl:value-of select="substring(., 1, 4)"/></field>
					<field name="publishDateSort"><xsl:value-of select="substring(., 1, 4)"/></field>
				</xsl:if>

			</xsl:for-each>

			<!-- dc.date.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:sort select="substring(., 1, 4)"/>
				<field name="dc.date.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>

			<!-- dc.date -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<xsl:sort select="substring(., 1, 4)"/>
				<field name="dc.date.{../@name}.fl_str_mv"><xsl:value-of select="normalize-space()" /></field>
			</xsl:for-each>

			<!-- dc.type -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<field name="dc.type.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.type.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.type.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- distinct dc.type format/status  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='type']//doc:field[@name='value' and count(index-of($type_list, normalize-space()))&gt;0 ]|doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value' and count(index-of($type_list, normalize-space()))&gt;0])">
					<xsl:if test="position() = 1">
					<field name="format"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
					</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='type']//doc:field[@name='value' and count(index-of($status_list, normalize-space()))&gt;0 ]|doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value' and count(index-of($status_list, normalize-space()))&gt;0])">
					<xsl:if test="position() = 1">
					<field name="status_str"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
					</xsl:if>
			</xsl:for-each>

			<!-- dc.identifier -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
				<field name="dc.identifier.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.identifier.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.identifier.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- Distinct identifiers, url separation  -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']|doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value'])">
				<xsl:choose>
					<xsl:when test="starts-with(., 'http')">
						<field name="url"><xsl:value-of select="normalize-space()" /></field>
					</xsl:when>
					<xsl:otherwise>
						<field name="identifier_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<!-- dc.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<field name="dc.language.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.language.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.language.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
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
	                    <field name="language_invalid_str_mv">
							<xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/>
						</field>
                    </xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>


			<!-- dc.relation -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<field name="dc.relation.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.relation.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.relation.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.rights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value' and string-length() &lt; 100]">
				<field name="dc.rights.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.rights.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value' and string-length() &lt; 100]">
				<field name="dc.rights.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.rights distinct vufind field -->
			<xsl:for-each select="distinct-values(doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value' and string-length() &lt; 100]|doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value' and string-length() &lt; 100])">

				<xsl:choose>
					<xsl:when test="count(index-of($rights_list, normalize-space()))&gt;0">
						<field name="eu_rights_str_mv"><xsl:value-of select="substring(normalize-space(), string-length($driver_prefix)+1, string-length(normalize-space()))" /></field>
					</xsl:when>
					<xsl:otherwise>
						<field name="rights_invalid_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>

			<!-- dc.format -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<field name="dc.format.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.format.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.format.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- ? -->
			<xsl:for-each select="doc:metadata/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
				<field name="dc.format.bitstream.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
				<field name="dc.coverage.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.coverage.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.coverage.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<field name="dc.publisher.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.publisher.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.publisher.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.publisher distinct vufind field  -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='none']/doc:field[@name='value']">
			    <field name="publisher.none.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)"/></field>
			</xsl:for-each>

			<!-- dc.source -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<field name="dc.source.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>

			<!-- dc.source instname -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value' and starts-with(., $instname_prefix)]">
	            		<xsl:if test="position() = 1">
				<field name="instname_str">
                   			<xsl:value-of select="substring(normalize-space(), string-length($instname_prefix)+1, string-length(normalize-space()))" />
				</field>
				</xsl:if>
			</xsl:for-each>

			<!-- dc.source instacron -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value' and starts-with(., $instacron_prefix)]">
				<xsl:if test="position() = 1">
	 				<field name="instacron_str">
                   			<xsl:value-of select="substring(normalize-space(), string-length($instacron_prefix)+1, string-length(normalize-space()))" />
               				</field>
					<field name="institution">
                   			<xsl:value-of select="substring(normalize-space(), string-length($instacron_prefix)+1, string-length(normalize-space()))" />
               				</field>
				</xsl:if>
			</xsl:for-each>

			<!-- dc.source reponame -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value' and starts-with(., $reponame_prefix)]">
	            		<xsl:if test="position() = 1">
				 	<field name="reponame_str">
                   			<xsl:value-of select="substring(normalize-space(), string-length($reponame_prefix)+1, string-length(normalize-space()))" />
               				</field>
					<field name="collection">
                   			<xsl:value-of select="substring(normalize-space(), string-length($reponame_prefix)+1, string-length(normalize-space()))" />
               				</field>
				</xsl:if>
			</xsl:for-each>

		
			<!-- dc.source.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:element/doc:field[@name='value']">
				<field name="dc.source.{../../@name}.{../@name}.fl_str_mv"><xsl:value-of select="substring(normalize-space(),1,$maxStringLength)" /></field>
			</xsl:for-each>


			<xsl:for-each select="doc:metadata/doc:element/doc:element/doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
				<field name="bitstream.url.fl_str_mv"><xsl:value-of select="./doc:field[@name='url']" /></field>
				<field name="bitstream.checksum.fl_str_mv"><xsl:value-of select="./doc:field[@name='checksum']" /></field>
				<field name="bitstream.checksumAlgorithm.fl_str_mv"><xsl:value-of select="./doc:field[@name='checksumAlgorithm']" /></field>
			</xsl:for-each>


			<xsl:for-each select="doc:metadata/doc:element[@name='repository']">
				<field name="repository.name.fl_str_mv"><xsl:value-of select="./doc:field[@name='name']" /></field>
				<field name="repository.mail.fl_str_mv"><xsl:value-of select="./doc:field[@name='mail']" /></field>
			</xsl:for-each>


		</doc>
	</xsl:template>
</xsl:stylesheet>
