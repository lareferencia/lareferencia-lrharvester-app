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
        version="2.0">
  <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
  
  <!-- Aquí van los listados para diferenciar type en tipo de documento y status -->
  <xsl:variable name="type_list">
    info:eu-repo/semantics/article,info:eu-repo/semantics/bachelorThesis,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/review,info:eu-repo/semantics/conferenceObject,info:eu-repo/semantics/lecture,info:eu-repo/semantics/workingPaper,info:eu-repo/semantics/preprint,info:eu-repo/semantics/report,info:eu-repo/semantics/annotation,info:eu-repo/semantics/contributionToPeriodical,info:eu-repo/semantics/patent,info:eu-repo/semantics/other
  </xsl:variable>
  <xsl:variable name="status_list">
    info:eu-repo/semantics/draft,info:eu-repo/semantics/acceptedVersion,info:eu-repo/semantics/submittedVersion,info:eu-repo/semantics/publishedVersion,info:eu-repo/semantics/updatedVersion
  </xsl:variable>
  
  <!--  Aquí se definen los prefijos utilizados para detectar contenidos con trato diferencial -->
  <xsl:variable name="driver_prefix">info:eu-repo/semantics/</xsl:variable>
  <xsl:variable name="project_prefix">info:eu-repo/grantAgreement/</xsl:variable>
  <xsl:variable name="reponame_prefix">reponame:</xsl:variable>
  <xsl:variable name="instname_prefix">instname:</xsl:variable>
  <xsl:variable name="identifier_prefix">oai:</xsl:variable>
  <xsl:variable name="instacron_prefix">instacron:</xsl:variable>
  
  
  <xsl:param name="networkAcronym"/>
  <xsl:param name="networkName"/>
  <xsl:param name="institutionName"/>
  <xsl:param name="institutionAcronym"/>
  <xsl:param name="fulltext"/>
  
  
  <xsl:param name="country"/>
  <xsl:param name="date.harvested"/>
  
  <xsl:param name="fingerprint"/>
  <xsl:param name="identifier"/>
  <xsl:param name="record_id"/>
  <xsl:param name="authorProfilesID"/>
  <xsl:param name="authorProfilesName"/>
  
  
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
      
      <field name="country">
        <xsl:value-of select="$country"/>
      </field>
      
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
      
      
      <!-- dc.title -->
      <xsl:for-each select="doc:metadata/doc:element/doc:element[@name='title']/doc:element/doc:field[@name='value']">
        <field name="title.main">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.title.* -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
        <field name="title.{../../@name}">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.creator -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
        <field name="creator">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <!-- dc.contributor.author -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
        <field name="creator">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.contributor.author -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='contributor']/doc:element[@name='author']/doc:field[@name='value']">
        <field name="creator">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.contributor.*  -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='contributor' or @name='creator']/doc:element/doc:element/doc:field[@name='value']">
        <xsl:choose>
          <xsl:when test="(starts-with(../../@name,'advisor'))">
            <field name="contributor.advisor">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(../../@name,'editor'))">
            <field name="contributor.editor">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:otherwise>
            <field name="contributor.other">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      
      <!-- dc.contributor -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
        <field name="contributor">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='authorProfile']/doc:field[@name='value']">
        <field name="creatorProfile">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <!-- dc.subject -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
        <field name="subject">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.subject.* -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
        <xsl:choose>
          <xsl:when test="(starts-with(../../@name,'ddc'))">
            <field name="subject.ddc">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(../../@name,'fos'))">
            <field name="subject.fos">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(../../@name,'mesh'))">
            <field name="subject.mesh">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(../../@name,'lcc'))">
            <field name="subject.lcc">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(../../@name,'udc'))">
            <field name="subject.udc">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:otherwise>
            <field name="subject.other">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:otherwise>
        </xsl:choose>
        <field name="subject.all">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
        <field name="abstract">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='description']/doc:element/doc:field[@name='value']">
        <field name="abstract">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='description']/doc:element[@name='version']/doc:element/doc:field[@name='value']">
        <field name="description.version">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <!-- dc.date.* -->
      <xsl:for-each
              select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element">
        <!--PG: fails when you have multiple doc:field for a date type -->
		<!--xsl:sort select="substring(doc:field[@name='value'], 1, 4)"/-->
		<!--/ -->

        <xsl:choose>
          <xsl:when test="contains(@name,'issued')">
			<xsl:for-each select="./doc:element">
				<xsl:for-each select="tokenize(doc:field[@name='value']/text(),'-')">
					<!-- to only consider the year in this date -->
					<xsl:if test="matches(.,'[0-9]{4}')">
					  <field name="date.issued">
						<xsl:value-of select="normalize-space(.)"/>
					  </field>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
          </xsl:when>
          <xsl:when test="contains(@name,'embargoed')">
            <field name="date.embargoed">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="contains(@name,'available')">
			<xsl:for-each select="./doc:element">
				<xsl:if test="matches(doc:field[@name='value']/text(),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}Z$')" > 			
					<field name="date.available">
					  <xsl:value-of select="normalize-space()"/>
					</field>
				</xsl:if>
			</xsl:for-each>
          </xsl:when>		  
          <xsl:when test="contains(@name,'accessioned')">
			<xsl:for-each select="./doc:element">
				<xsl:if test="matches(doc:field[@name='value']/text(),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}Z$')" > 			
					<field name="date.accessioned">
					  <xsl:value-of select="normalize-space()"/>
					</field>
				</xsl:if>
			</xsl:for-each>				
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      
      <!-- rcaap.date.lastModified -->
      <xsl:for-each
              select="doc:metadata/doc:element[@name='rcaap']/doc:element[@name='date']/doc:element[@name='lastModified']/doc:field[@name='value']">
        <field name="date.lastModified">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <!-- dc.type -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='type']/doc:element[@name='coar']/doc:element/doc:field[@name='value']">
        <field name="type.coar">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.identifier -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='identifier']/doc:field[@name='value']">
        <field name="identifier">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.identifier.*-->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='identifier']/doc:element">
        <xsl:choose>
          
          <xsl:when test="(starts-with(@name,'uri'))">
			<xsl:for-each select="doc:element/doc:field[@name='value']">
				<field name="link">
				  <xsl:value-of select="normalize-space()"/>
				</field>
			</xsl:for-each>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'url'))">
            <field name="identifier.url">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'citation'))">
            <field name="identifier.citation">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'doi'))">
            <field name="identifier.doi">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'handle'))">
            <field name="identifier.handle">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'isbn'))">
            <field name="identifier.isbn">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'ismn'))">
            <field name="identifier.ismn">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'issn'))">
            <field name="identifier.issn">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'other'))">
            <field name="identifier.other">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'govdoc'))">
            <field name="identifier.govdoc">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'slug'))">
            <field name="identifier.slug">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'tid'))">
            <field name="identifier.tid">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:when test="(starts-with(@name,'sici'))">
            <field name="identifier.sici">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      
      
      <!-- dc.language -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='language']/doc:element/doc:field[@name='value']">
        <field name="language">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.language.* -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
        <field name="language">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each select="doc:metadata/doc:element/doc:element[@name='project']/doc:field[@name='value']">
        <xsl:choose>
          <xsl:when test="starts-with(normalize-space(), $project_prefix)">
            <xsl:for-each select="tokenize(.,'/')">
              <xsl:if test="position()=3">
                <field name="funder_acronym">
                  <xsl:value-of select="normalize-space()"/>
                </field>
              </xsl:if>
              <xsl:if test="position()=4">
                <field name="funding_program">
                  <xsl:value-of select="normalize-space()"/>
                </field>
              </xsl:if>
              <xsl:if test="position()=5">
                <field name="project_id">
                  <xsl:value-of select="normalize-space()"/>
                </field>
              </xsl:if>
              <xsl:if test="position()=6">
                <field name="project_juridiction">
                  <xsl:value-of select="normalize-space()"/>
                </field>
              </xsl:if>
            
            </xsl:for-each>
            <field name="project">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      
      <!-- dc.relation -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
        <field name="relation">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.relation.publisherVersion -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='relation']/doc:element[@name='publisherversion']/doc:element/doc:field[@name='value']">
        <field name="relation.publisherversion">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.relation.uri -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='relation']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
        <field name="relation.uri">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='rights']/doc:element[@name='cclicence']/doc:element/doc:field[@name='value']">
        <field name="rights.cclicence">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='rights']/doc:element[@name='copyright']/doc:element/doc:field[@name='value']">
        <field name="rights.copyright">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='rights']/doc:element[@name='access']/doc:element/doc:field[@name='value']">
        <xsl:choose>
          <xsl:when test="position()=1">
            <field name="rights.access">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      
      <xsl:for-each select="doc:metadata/doc:element/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
        <xsl:choose>
          <xsl:when test="position()=1">
            <field name="rights.access">
              <xsl:value-of select="normalize-space()"/>
            </field>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      
      
      <!-- dc.format -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='format']/doc:element/doc:field[@name='value']">
        <field name="format">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      
      <!-- ? -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
        <field name="format">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.coverage -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
        <field name="coverage">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.coverage.* -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
        <field name="coverage.{../../@name}">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.publisher -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
        <field name="publisher">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:element[@name=bitstreams]/doc:element[@name='bitstream']/doc:field[@name='url']">
        <field name="fulltext.url">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.source -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='source']/doc:element/doc:field[@name='value']">
        <field name="source">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
      
      <!-- dc.source.* -->
      <xsl:for-each
              select="doc:metadata/doc:element/doc:element[@name='source']/doc:element/doc:element/doc:field[@name='value']">
        <field name="source.{../../@name}">
          <xsl:value-of select="normalize-space()"/>
        </field>
      </xsl:for-each>
    
    </doc>
  </xsl:template>
</xsl:stylesheet>
