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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://www.lyncode.com/xoai"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" version="2.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
  
  <!-- Aquí van los listados para diferenciar type en tipo de documento y status -->
    <xsl:variable name="type_list">
        info:eu-repo/semantics/article,info:eu-repo/semantics/bachelorThesis,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/review,info:eu-repo/semantics/conferenceObject,info:eu-repo/semantics/lecture,info:eu-repo/semantics/workingPaper,info:eu-repo/semantics/preprint,info:eu-repo/semantics/report,info:eu-repo/semantics/annotation,info:eu-repo/semantics/contributionToPeriodical,info:eu-repo/semantics/patent,info:eu-repo/semantics/other
    </xsl:variable>
    <xsl:variable name="status_list">
        info:eu-repo/semantics/draft,info:eu-repo/semantics/acceptedVersion,info:eu-repo/semantics/submittedVersion,info:eu-repo/semantics/publishedVersion,info:eu-repo/semantics/updatedVersion
    </xsl:variable>
  
  <!--  Aquí se definen los prefijos utilizados para detectar contenidos con trato diferencial -->
    <xsl:variable name="driver_prefix">
        <xsl:text>info:eu-repo/semantics/</xsl:text>
    </xsl:variable>
    <xsl:variable name="project_prefix">
        <xsl:text>info:eu-repo/grantAgreement/</xsl:text>
    </xsl:variable>
    <xsl:variable name="reponame_prefix">
        <xsl:text>reponame:</xsl:text>
    </xsl:variable>
    <xsl:variable name="instname_prefix">
        <xsl:text>instname:</xsl:text>
    </xsl:variable>
    <xsl:variable name="identifier_prefix">
        <xsl:text>oai:</xsl:text>
    </xsl:variable>
    <xsl:variable name="instacron_prefix">
        <xsl:text>instacron:</xsl:text>
    </xsl:variable>
  <!-- settings -->
    <xsl:variable name="max_string_size">
        <xsl:text>30000</xsl:text>
    </xsl:variable>


    <xsl:param name="networkAcronym"/>
    <xsl:param name="networkName"/>
    <xsl:param name="institutionName"/>
    <xsl:param name="institutionAcronym"/>
    <xsl:param name="fulltext"/>

    <xsl:param name="date.harvested"/>

    <xsl:param name="fingerprint"/>
    <xsl:param name="identifier"/>
    <xsl:param name="record_id"/>
    <xsl:param name="authorProfilesID"/>
    <xsl:param name="authorProfilesName"/>
  
  
  <!-- Params from Networks -->
  <!-- They have the prefix: "attr_"  -->
    <xsl:param name="attr_country"/>  
  <!-- / -->

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <doc>
      
      <!-- ID es parámetro -->
            <field name="id">
                <xsl:value-of select="$identifier"/>
            </field>
            <field name="fulltext">
                <xsl:value-of select="$fulltext"/>
            </field>
	  
			<!-- country -->
            <xsl:if test="$attr_country and ($attr_country != '')">
                <field name="country">
                    <xsl:value-of select="$attr_country"/>
                </field>
            </xsl:if>
            <xsl:if test="not($attr_country)">
                <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element[@name='placename']/doc:field[@name='value']">
                    <field name="country">
                        <xsl:value-of select="normalize-space()"/>
                    </field>
                </xsl:for-each>
            </xsl:if>

            <field name="date.harvested">
                <xsl:value-of select="$date.harvested"/>
            </field>

            <field name="network_acronym_str">
                <xsl:value-of select="$networkAcronym"/>
            </field>
      
			<!-- networkName es parámetro -->
            <field name="network_name_str">
                <xsl:value-of select="$networkName"/>
            </field>
      
			<!-- authorProfiles -->
            <xsl:for-each select="tokenize($authorProfilesID,';')">
                <field name="author.id">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>

            <xsl:for-each select="tokenize($authorProfilesName,';')">
                <field name="author.name">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>

            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='authorProfile']/doc:field[@name='value']">
                <field name="creatorProfile">
                    <xsl:value-of select="normalize-space()"/>
                </field>
            </xsl:for-each>

            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dc']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='oaire']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dcterms']"/>

        </doc>
    </xsl:template>


    <xsl:template match="/doc:metadata/doc:element[@name='datacite']">
        <xsl:apply-templates select="*" mode="datacite"/>
    </xsl:template>

    <xsl:template match="doc:element[@name='titles']/doc:element[@name='title']" mode="datacite">
	<!--field name="title.{../../@name}"-->
        <field name="title.main">
            <xsl:value-of select="normalize-space(doc:field[@name='value'])"/>
        </field>
    </xsl:template>


    <xsl:template match="doc:element[@name='creators']/doc:element[@name='creator']" mode="datacite">
	<!--field name="title.{../../@name}"-->
        <field name="creator">
            <xsl:value-of
                select="doc:element[@name='creatorName']/doc:field[@name='value']"/>
        </field>
    </xsl:template>
    
  <!-- dc.contributor -->
    <xsl:template match="doc:element[@name='contributors']/doc:element[@name='contributor']"
        mode="datacite">
        <field>
            <xsl:attribute name="name">
		<xsl:if test="not(doc:field[@name='contributorType'])">
			<xsl:text>contributor</xsl:text>
		</xsl:if>		
			<xsl:apply-templates select="doc:field[@name='contributorType']" mode="datacite_contributorType"/>
		</xsl:attribute>
            <xsl:value-of
                select="doc:element[@name='contributorName']/doc:field[@name='value']"/>
        </field>
    </xsl:template>


    <xsl:template match="doc:element[@name='contributor']/doc:field[@name='contributorType']"
        mode="datacite_contributorType">
        <xsl:choose>
            <xsl:when test="text()='Supervisor'">
                <xsl:text>contributor.advisor</xsl:text>
            </xsl:when>
            <xsl:when test="text()='Editor'">
                <xsl:text>contributor.editor</xsl:text>
            </xsl:when>
            <xsl:when test="text()='HostingInstitution'">
                <xsl:text>contributor.other</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>contributor.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  
  
  
      <!-- dc.subject -->
    <xsl:template match="doc:element[@name='subjects']/doc:element[@name='subject']" mode="datacite">
        <field>
            <xsl:attribute name="name">
		<xsl:if test="not(doc:field[@name='subjectScheme'])">
			<xsl:text>subject</xsl:text>
		</xsl:if>
			<xsl:apply-templates select="doc:field[@name='subjectScheme']" mode="datacite_subjectScheme"/>
		</xsl:attribute>
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
    </xsl:template>


    <xsl:template match="doc:element[@name='subject']/doc:field[@name='subjectScheme']"
        mode="datacite_subjectScheme">
        <xsl:choose>
            <xsl:when test="text()='DDC'">
                <xsl:text>subject.ddc</xsl:text>
            </xsl:when>
            <xsl:when test="text()='FOS'">
                <xsl:text>subject.fos</xsl:text>
            </xsl:when>
            <xsl:when test="text()='MESH'">
                <xsl:text>subject.mesh</xsl:text>
            </xsl:when>
            <xsl:when test="text()='OCLC'">
                <xsl:text>subject.lcc</xsl:text>
            </xsl:when>
            <xsl:when test="text()='UDC'">
                <xsl:text>subject.udc</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>subject.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

  <!-- dc.rights -->
  <!-- PG: only consider one first entry -->
    <xsl:template match="doc:element[@name='rights'][1]" mode="datacite">
		<!-- normalize rights -->
		<!--  <field name="rights.access">
            <xsl:apply-templates select="doc:field[@name='value']/text()"
                mode="datacite_rightsvalue"/>
        </field> -->
		<!-- PG 2020-09-01: we choose to use rights.access
			for COAR access type because of a legacy change that would disrupt functionality otherwise
			https://app.asana.com/0/search/1191640932776009/1188612660534431
		-->
        <field name="rights.access">
            <xsl:value-of select="normalize-space(doc:field[@name='rightsURI']/text())"/>
        </field>
        <field name="rights.uri">
            <xsl:value-of select="normalize-space(doc:field[@name='rightsURI']/text())"/>
        </field>

    </xsl:template>

    <xsl:template match="doc:element[@name='rights'][1]/doc:field[@name='value']/text()"
        mode="datacite_rightsvalue">
        <xsl:choose>
            <xsl:when test=".='open access'">
                <xsl:text>openAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='restricted access'">
                <xsl:text>restrictedAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='embargoed access'">
                <xsl:text>embargoedAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='restricted access'">
                <xsl:text>closedAccess</xsl:text>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>  
  <!--
  info:eu-repo/semantics/openAccess
  info:eu-repo/semantics/embargoedAccess
  info:eu-repo/semantics/restrictedAccess
  info:eu-repo/semantics/closedAccess
  info:eu-repo/semantics/RestrictAccess  
  -->
    </xsl:template>  
  
  <!-- dc.identifier -->
    <xsl:template match="doc:element[@name='identifier']" mode="datacite">
        <field>
            <xsl:attribute name="name">
		<xsl:if test="not(doc:field[@name='identifierType'])">
			<xsl:text>identifier</xsl:text>
		</xsl:if>		
			<xsl:apply-templates select="doc:field[@name='identifierType']" mode="datacite_identifierType"/>
		</xsl:attribute>
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
        <field name="link">
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
    </xsl:template>

    <xsl:template match="doc:element[@name='identifier']/doc:field[@name='identifierType']"
        mode="datacite_identifierType">
        <xsl:choose>
            <xsl:when test="text()='ARK'">
                <xsl:text>identifier.other</xsl:text>
            </xsl:when>
            <xsl:when test="text()='Handle'">
                <xsl:text>identifier.url</xsl:text>
            </xsl:when>		
		<!-- TODO evaluate this mapping -->
            <xsl:when test="text()='URN'">
                <xsl:text>identifier.other</xsl:text>
            </xsl:when>
            <xsl:when test="text()='DOI'">
                <xsl:text>identifier.doi</xsl:text>
            </xsl:when>
            <xsl:when test="text()='PURL'">
                <xsl:text>identifier.other</xsl:text>
            </xsl:when>
            <xsl:when test="text()='URL'">
                <xsl:text>identifier.url</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>identifier.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="doc:element[@name='relatedIdentifiers']/doc:element[@name='relatedIdentifier']"
        mode="datacite">
        <field>
            <xsl:attribute name="name">
		<xsl:if test="not(doc:field[@name='relatedIdentifierType'])">
			<xsl:text>identifier.other</xsl:text>
		</xsl:if>	
			<xsl:apply-templates select="doc:field[@name='relatedIdentifierType']"
                mode="datacite_relatedIdentifierType"/>
		</xsl:attribute>
            <xsl:value-of select="normalize-space(doc:field[@name='value'])"/>
        </field>
    </xsl:template>


    <xsl:template match="doc:element[@name='relatedIdentifier']/doc:field[@name='relatedIdentifierType']"
        mode="datacite_relatedIdentifierType">
        <xsl:choose>
            <xsl:when test="text()='URL'">
                <xsl:text>identifier.url</xsl:text>
            </xsl:when>
            <xsl:when test="text()='Handle'">
                <xsl:text>identifier.url</xsl:text>
            </xsl:when>		
		<!-- TODO evaluate this mapping -->
            <xsl:when test="text()='URN'">
                <xsl:text>identifier.other</xsl:text>
            </xsl:when>
            <xsl:when test="text()='DOI'">
                <xsl:text>identifier.doi</xsl:text>
            </xsl:when>
            <xsl:when test="text()='ISBN'">
                <xsl:text>identifier.isbn</xsl:text>
            </xsl:when>
            <xsl:when test="text()='ISSN'">
                <xsl:text>identifier.issn</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>identifier.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
	
<!--
identifier.ismn
identifier.govdoc
identifier.slug
identifier.tid
identifier.sici	
-->
    </xsl:template>

    <xsl:template
        match="doc:element[@name='alternateIdentifiers']/doc:element[@name='alternateIdentifier']" mode="datacite">
        <field>
            <xsl:attribute name="name">
		<xsl:if test="not(doc:field[@name='alternateIdentifierType'])">
			<xsl:text>identifier.other</xsl:text>
		</xsl:if>	
			<xsl:apply-templates select="doc:field[@name='alternateIdentifierType']"
                mode="datacite_alternateIdentifierType"/>
		</xsl:attribute>
            <xsl:value-of select="normalize-space(doc:field[@name='value'])"/>
        </field>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='alternateIdentifier']/doc:field[@name='alternateIdentifierType']"
        mode="datacite_alternateIdentifierType">
        <xsl:choose>
            <xsl:when test="text()='tid'">
                <xsl:text>identifier.tid</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>identifier.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="doc:element[@name='date']/doc:element[@name='Issued']" mode="datacite">
        <xsl:for-each select="tokenize(normalize-space(doc:field[@name='value']/text()),'-')">
                    <!-- to only consider the year in this date -->
            <xsl:if test="matches(.,'[0-9]{4}')">
                <field name="date.issued">
                    <xsl:value-of select="."/>
                </field>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="doc:element[@name='date']/doc:element[@name='Available']/doc:field[@name='value']"
        mode="datacite">
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}(.\d)?Z$')">
            <field name="date.available">
                <xsl:value-of select="normalize-space(text())"/>
            </field>
        </xsl:if>
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}$')">
            <field name="date.available">
                <xsl:value-of select="concat(normalize-space(text()),'T00:00:00Z')"/>
            </field>
        </xsl:if>
    </xsl:template>


    <xsl:template match="doc:element[@name='date']/doc:element[@name='Accepted']/doc:field[@name='value']"
        mode="datacite">
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}(.\d)?Z$')">
            <field name="date.lastModified">
                <xsl:value-of select="normalize-space(text())"/>
            </field>
        </xsl:if>
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}$')">
            <field name="date.lastModified">
                <xsl:value-of select="concat(normalize-space(text()),'T00:00:00Z')"/>
            </field>
        </xsl:if>
        <!-- embargoed date -->
        <xsl:if
            test="normalize-space(text()) != normalize-space(../../doc:element[@name='Available']/doc:field[last()][@name='value']/text())">
            <field name="date.embargoed">
                <xsl:value-of
                    select="normalize-space(../../doc:element[@name='Available']/doc:field[last()][@name='value']/text())"/>
            </field>
        </xsl:if>
    </xsl:template>

    <!-- don't to nothing with date of type submitted-->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Submitted']/doc:field[@name='value']"
        mode="datacite"/>    


    <!-- the model don't support sizes, don't to nothing -->
    <xsl:template match="doc:element[@name='sizes']/doc:element[@name='size']" mode="datacite"/>

      <!-- TODO -->
      <!-- relation -->      
      <!-- relation.publisherversion -->
      <!-- relation.uri -->



    <xsl:template match="/doc:metadata/doc:element[@name='dc']">
        <xsl:apply-templates select="*" mode="dc"/>
    </xsl:template>
  	<xsl:template match="doc:element" mode="dc">
		<xsl:apply-templates select="*" mode="dc"/>
	</xsl:template>

      <!-- dc.language -->
    <xsl:template match="doc:element[@name='language']/doc:field[@name='value']" mode="dc">
        <field name="language">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>

	<!-- dc.description -->
    <xsl:template match="doc:element[@name='description']/doc:field[@name='value']" mode="dc">
        <field name="abstract">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>  
  
      <!-- dc.publisher -->
    <xsl:template match="doc:element[@name='publisher']/doc:field[@name='value']" mode="dc">
        <field name="publisher">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>        

      <!-- dc.format -->
    <xsl:template match="doc:element[@name='format']/doc:field[@name='value']" mode="dc">
        <field name="format">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>         

      <!-- dc.source -->
    <xsl:template match="doc:element[@name='source']/doc:field[@name='value']" mode="dc">
        <field name="source">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>      

      <!-- dc.coverage -->
    <xsl:template match="doc:element[@name='coverage']/doc:field[@name='value']" mode="dc">
        <field name="coverage">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>

    <xsl:template match="/doc:metadata/doc:element[@name='oaire']">
        <xsl:apply-templates select="*" mode="oaire"/>
    </xsl:template>  

   <!-- resourceType -->
    <xsl:template match="doc:element[@name='resourceType']" mode="oaire">
        <field name="type">
		<!-- normalize types -->
            <xsl:apply-templates select="doc:field[@name='value']/text()" mode="oaire_typevalue"/>
        </field>
        <xsl:apply-templates select="doc:field[@name='uri']" mode="oaire"/>
    </xsl:template>

    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='value']/text()"
        mode="oaire_typevalue">
        <xsl:choose>
            <xsl:when test=".='journal article'">
	<!--journalArticle http://purl.org/coar/resource_type/c_6501-->
                <xsl:text>article</xsl:text>
            </xsl:when>
            <xsl:when test=".='book'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when test=".='book part'">
                <xsl:text>bookPart</xsl:text>
            </xsl:when>
            <xsl:when test=".='book part'">
                <xsl:text>journal</xsl:text>
            </xsl:when>
            <xsl:when test=".='interative resource'">
                <xsl:text>interativeResource</xsl:text>
            </xsl:when>
            <xsl:when test=".='website'">
                <xsl:text>website</xsl:text>
            </xsl:when>
            <xsl:when test=".='dataset'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test=".='image'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when test=".='moving image'">
                <xsl:text>movingImage</xsl:text>
            </xsl:when>
            <xsl:when test=".='video'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when test=".='still image'">
                <xsl:text>stillImage</xsl:text>
            </xsl:when>
            <xsl:when test=".='software'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test=".='workflow'">
                <xsl:text>workflow</xsl:text>
            </xsl:when>
            <xsl:when test=".='carthographic material'">
                <xsl:text>carthographicMaterial</xsl:text>
            </xsl:when>
            <xsl:when test=".='map'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when test=".='sound'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when test=".='musicalComposition'">
                <xsl:text>musical composition</xsl:text>
            </xsl:when>
            <xsl:when test=".='text'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when test=".='annotation'">
                <xsl:text>annotation</xsl:text>
            </xsl:when>
            <xsl:when test=".='bibliography'">
                <xsl:text>bibliography</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference object'">
                <xsl:text>conferenceObject</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference proceedings'">
                <xsl:text>conferenceProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference paper'">
                <xsl:text>conferencePaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference poster'">
                <xsl:text>conferencePoster</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference paper not in proceedings'">
                <xsl:text>conferencePaperNotInProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference poster not in proceedings'">
                <xsl:text>conferencePosterNotInProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='lecture'">
                <xsl:text>lecture</xsl:text>
            </xsl:when>
            <xsl:when test=".='letter'">
                <xsl:text>letter</xsl:text>
            </xsl:when>
            <xsl:when test=".='periodical'">
                <xsl:text>periodical</xsl:text>
            </xsl:when>
            <xsl:when test=".='contribution to journal'">
                <xsl:text>contributionToPeriodical</xsl:text>
            </xsl:when>
            <xsl:when test=".='review article'">
                <xsl:text>reviewArticle</xsl:text>
            </xsl:when>
            <xsl:when test=".='research article'">
                <xsl:text>researchArticle</xsl:text>
            </xsl:when>
            <xsl:when test=".='editorial'">
                <xsl:text>editorial</xsl:text>
            </xsl:when>
            <xsl:when test=".='data paper'">
                <xsl:text>dataPaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='letter to the editor'">
                <xsl:text>letterToTheEditor</xsl:text>
            </xsl:when>
            <xsl:when test=".='patent'">
                <xsl:text>patent</xsl:text>
            </xsl:when>
            <xsl:when test=".='preprint'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when test=".='report'">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when test=".='report part'">
                <xsl:text>reportPart</xsl:text>
            </xsl:when>
            <xsl:when test=".='internal report'">
                <xsl:text>internalReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='memorandum'">
                <xsl:text>memorandum</xsl:text>
            </xsl:when>
            <xsl:when test=".='other type of report'">
                <xsl:text>otherTypeOfReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='policy report'">
                <xsl:text>policyReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='project deliverable'">
                <xsl:text>projectDeliverable</xsl:text>
            </xsl:when>
            <xsl:when test=".='report to funding agency'">
                <xsl:text>reportToFundingAgency</xsl:text>
            </xsl:when>
            <xsl:when test=".='research report'">
                <xsl:text>researchReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='technical report'">
                <xsl:text>technicalReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='research proposal'">
                <xsl:text>researchProposal</xsl:text>
            </xsl:when>
            <xsl:when test=".='review'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when test=".='book review'">
                <xsl:text>bookReview</xsl:text>
            </xsl:when>
            <xsl:when test=".='technical documentation'">
                <xsl:text>technicalDocumentation</xsl:text>
            </xsl:when>
            <xsl:when test=".='working paper'">
                <xsl:text>workingPaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='thesis'">
                <xsl:text>thesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='bachelor thesis'">
                <xsl:text>bachelorThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='doctoral thesis'">
                <xsl:text>doctoralThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='master thesis'">
                <xsl:text>masterThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='musical notation'">
                <xsl:text>musicalNotation</xsl:text>
            </xsl:when>
            <xsl:when test=".='pedagogical publication'">
                <xsl:text>pedagogicalPublication</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> 

        <!-- dc.type -->
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='uri']" mode="oaire">
        <field name="type.coar">
            <xsl:value-of select="normalize-space(text())"/>
        </field>
    </xsl:template>


    <xsl:template match="doc:element[@name='fundingReferences']" mode="oaire">
        <xsl:apply-templates select="*" mode="oaire"/>
    </xsl:template>

    <xsl:template match="doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']"
        mode="oaire">
        <xsl:apply-templates select="*" mode="oaire_fundingReference"/>

        <xsl:variable name="funderAcronym">
            <xsl:apply-templates
                select="doc:element[@name='funderIdentifier']/doc:field[@name='value']/text()"
                mode="oaire_funderAcronym"/>
        </xsl:variable>
        <xsl:variable name="fundingStream">
            <xsl:value-of select="doc:element[@name='fundingStream']/doc:field[@name='value']/text()"/>
        </xsl:variable>
        <xsl:variable name="identifier">
            <xsl:value-of select="doc:element[@name='awardNumber']/doc:field[@name='value']/text()"/>
        </xsl:variable>
        <xsl:variable name="funderJuridiction">
            <xsl:apply-templates
                select="doc:element[@name='funderIdentifier']/doc:field[@name='value']/text()"
                mode="oaire_funderJuridiction"/>
        </xsl:variable>

        <xsl:if test="$identifier">
		<!-- project:  info:eu-repo/grantAgreement/FCT/5876-PPCDTI/99063/PT -->
            <field name="project">
                <xsl:value-of
                    select="normalize-space(concat($project_prefix, $funderAcronym, '/', $fundingStream, '/', $identifier, '/', $funderJuridiction))"/>
            </field>
        </xsl:if>

    </xsl:template>    
  

	<!-- don't do nothing with funder name -->
    <xsl:template match="doc:element[@name='fundingReference']/doc:element[@name='funderName']"
        mode="oaire_fundingReference"/>


    <xsl:template match="doc:element[@name='fundingReference']/doc:element[@name='funderIdentifier']"
        mode="oaire_fundingReference">
        <xsl:if test="doc:field[@name='funderIdentifierType']/text()='Crossref Funder ID'">

            <field name="project_juridiction">
                <xsl:apply-templates select="doc:field[@name='value']/text()"
                    mode="oaire_funderJuridiction"/>
            </field>

            <field name="funder_acronym">
                <xsl:apply-templates select="doc:field[@name='value']/text()"
                    mode="oaire_funderAcronym"/>
            </field>

        </xsl:if>
    </xsl:template>

    <xsl:template match="doc:element[@name='funderIdentifier']/doc:field[@name='value']/text()"
        mode="oaire_funderAcronym">
        <xsl:choose>
            <xsl:when test=".='http://doi.org/10.13039/501100001871'">
                <xsl:text>FCT</xsl:text>
            </xsl:when>
            <xsl:when test=".='http://doi.org/10.13039/501100008530'">
                <xsl:text>EC</xsl:text>
            </xsl:when>
            <xsl:when test=".='http://doi.org/10.13039/100010269'">
                <xsl:text>WT</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="doc:element[@name='funderIdentifier']/doc:field[@name='value']/text()"
        mode="oaire_funderJuridiction">
        <xsl:choose>
            <xsl:when test=".='http://doi.org/10.13039/501100001871'">
                <xsl:text>PT</xsl:text>
            </xsl:when>
            <xsl:when test=".='http://doi.org/10.13039/501100008530'">
                <xsl:text>EU</xsl:text>
            </xsl:when>
            <xsl:when test=".='http://doi.org/10.13039/100010269'">
                <xsl:text>UK</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="doc:element[@name='fundingReference']/doc:element[@name='fundingStream']"
        mode="oaire_fundingReference">
        <field name="funding_program">
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
    </xsl:template>

    <xsl:template match="doc:element[@name='fundingReference']/doc:element[@name='awardNumber']"
        mode="oaire_fundingReference">
        <field name="project_id">
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
    </xsl:template>

    <xsl:template match="doc:element[@name='licenseCondition']" mode="oaire">

        <xsl:if test="contains(doc:field[@name='uri']/text(), 'creativecommons.org')">
            <field name="rights.cclicence">
                <xsl:value-of select="normalize-space(doc:field[@name='uri']/text())"/>
            </field>
        </xsl:if>

        <field name="rights.copyright">
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>

    </xsl:template>


    <xsl:template match="doc:element[@name='files']" mode="oaire">
	<!-- I can only have one full text -->
        <xsl:for-each select="doc:element[@name='file'][doc:field[@name='objectType']/text()='fulltext']">
            <xsl:if test="position() = 1">
                <field name="fulltext.url">
                    <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
                </field>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="doc:element[@name='version']" mode="oaire">
        <field name="description.version">
            <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        </field>
    </xsl:template>
	
	<!-- citation -->
    <xsl:template match="doc:element[@name='citation']" mode="oaire">

        <xsl:variable name="resourceType">
            <xsl:apply-templates
                select="../doc:element[@name='resourceType']/doc:field[@name='value']/text()" mode="oaire_typevalue"/>
        </xsl:variable>
        <xsl:variable name="key">
            <xsl:value-of
                select="../../doc:element/doc:element[@name='identifier']/doc:field[@name='value']/text()"/>
        </xsl:variable>

        <field name="identifier.citation">
            <xsl:text>@</xsl:text>
            <xsl:value-of select="normalize-space($resourceType)"/>
            <xsl:text>{</xsl:text>
            <xsl:value-of select="normalize-space($key)"/>
            <xsl:text>,</xsl:text>
            <xsl:apply-templates select="*" mode="oaire"/>
            <xsl:text>}</xsl:text>
        </field>
    </xsl:template>

    <xsl:template match="doc:element[@name='citation']/doc:element[@name='citationTitle']" mode="oaire">
        <xsl:text>title = {</xsl:text>
        <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        <xsl:text>},</xsl:text>
    </xsl:template>

    <xsl:template match="doc:element[@name='citation']/doc:element[@name='citationVolume']" mode="oaire">
        <xsl:text>volume = {</xsl:text>
        <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        <xsl:text>},</xsl:text>
    </xsl:template>

    <xsl:template match="doc:element[@name='citation']/doc:element[@name='citationConferencePlace']"
        mode="oaire">
        <xsl:text>conferencePlace = {</xsl:text>
        <xsl:value-of select="normalize-space(doc:field[@name='value']/text())"/>
        <xsl:text>},</xsl:text>
    </xsl:template>


    <xsl:template match="/doc:metadata/doc:element[@name='dcterms']">
    </xsl:template>

    <xsl:template match="*" mode="openaire"/>
    <xsl:template match="*" mode="dc"/>
    <xsl:template match="*" mode="oaire"/>
    <xsl:template match="text()|@*"/>
</xsl:stylesheet>
