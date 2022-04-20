<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

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

<xsl:stylesheet xmlns:doc="http://www.lyncode.com/xoai" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>

    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="publicationName" select="'Publication1'"/>
    <xsl:param name="nameFrom"
        select="' ;,.:+?!\/*#@£$€àèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðøÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="nameTo"
        select="'________________aeiouaeiouyaeiouanoaeiouyaaodo0AEIOUAEIOUYAEIOUANOAEIOUYAAOCD0'"/>
	
    
    <!-- params -->
    <xsl:param name="identifier"/>
    <xsl:param name="timestamp"/>
    <xsl:param name="fingerprint"/>
    <xsl:param name="networkAcronym"/>


    <xsl:template name="uppercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $smallcase, $uppercase)"/>
    </xsl:template>
    <xsl:template name="lowercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $uppercase, $smallcase)"/>
    </xsl:template>
    <xsl:template name="ucfirst">
        <xsl:param name="value"/>
        <xsl:call-template name="uppercase">
            <xsl:with-param name="value" select="substring($value, 1, 1)"/>
        </xsl:call-template>
        <xsl:call-template name="lowercase">
            <xsl:with-param name="value" select="substring($value, 2)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="/">
        <xsl:element name="entity-relation-data">
            <!-- general provenance - for all entities -->
            <xsl:attribute name="source"><xsl:value-of select="$networkAcronym"/></xsl:attribute>
            <xsl:attribute name="record"><xsl:value-of select="$identifier"/></xsl:attribute>
            <xsl:attribute name="lastUpdate">
                    <xsl:value-of select="$timestamp"/>
                </xsl:attribute>
            <xsl:element name="entities">
                <xsl:call-template name="publication"/>
            </xsl:element>
            <xsl:element name="relations">
            </xsl:element>
        </xsl:element>

    </xsl:template>  

  <!-- Entity: Publication -->
    <xsl:template name="publication">
        <xsl:element name="entity">
            <xsl:attribute name="type">
            <xsl:text>Publication</xsl:text>
            </xsl:attribute>

            <xsl:attribute name="ref">
                <xsl:value-of select="$publicationName"/>
            </xsl:attribute>

            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='identifier']" mode="semanticId"/>

            <xsl:element name="field">
                <xsl:attribute name="name">Source.acronym</xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:value-of select="$networkAcronym"/>
                </xsl:attribute>
            </xsl:element>

            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']/doc:element" mode="Publication"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dc']/doc:element" mode="Publication"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='source']" mode="Source"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='oaire']/doc:element" mode="Publication"/>
            
            <xsl:for-each select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='resourceType']">
                <xsl:if test="position()=1">
                    <xsl:apply-templates select="doc:field"/>
                </xsl:if>
            </xsl:for-each>   
                
            
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
    </xsl:template> 
    
    <!-- title -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='titles']" mode="Publication">
        <xsl:for-each select="doc:element[@name='title']">
            <xsl:choose>
                <xsl:when test="./doc:field[@name='titleType']">
                    <xsl:apply-templates select="./doc:field[@name='titleType']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="doc:element[@name='title']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.headline'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='title']/doc:field[@name='titleType']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.alternativeHeadline'"/>
            <xsl:with-param name="node" select=".."/>
        </xsl:call-template>
    </xsl:template>

    <!-- creators -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='creators']" mode="Publication">
        <xsl:for-each select="doc:element[@name='creator']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="doc:element[@name='creator']/doc:element[@name='creatorName']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.author'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- Publication Identifier Fields -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='relatedIdentifiers']"
        mode="Publication">
        <xsl:for-each select="doc:element[@name='relatedIdentifier']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <!-- related identifier -->
    <xsl:template match="doc:element[@name='relatedIdentifier']/doc:field[@name='relatedIdentifierType']">
        <xsl:variable name="name">
            <xsl:call-template name="fieldNameByIdentifierType">
                <xsl:with-param name="idType" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="$name"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>


      <!-- Publication Alternate Identifier Fields -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='alternateIdentifiers']" mode="Publication">
        <xsl:for-each select="doc:element[@name='alternateIdentifier']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <!-- alternateIdentifier identifier -->
    <xsl:template match="doc:element[@name='alternateIdentifier']/doc:field[@name='alternateIdentifierType' and text()='OAI']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.identifier.oai'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- source  -->
    <xsl:template match="doc:element[@name='source']/doc:field[starts-with(text(), 'reponame:')]" mode="Source">
        <xsl:call-template name="field_with_prefix">
            <xsl:with-param name="name" select="'Source.reponame'"/>
            <xsl:with-param name="prefix" select="'reponame:'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='source']/doc:field[starts-with(text(), 'instname:')]" mode="Source">
        <xsl:call-template name="field_with_prefix">
            <xsl:with-param name="name" select="'Source.instname'"/>
            <xsl:with-param name="prefix" select="'instname:'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='source']/doc:field[not(starts-with(text(), 'instname:') or starts-with(text(), 'reponame:')) ]" mode="Source">
    </xsl:template>

    <!-- identifier -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='identifier']" mode="Publication">
        <xsl:variable name="name">
            <xsl:call-template name="fieldNameByIdentifierType">
                <xsl:with-param name="idType" select="doc:field[@name='identifierType']"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="$name"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="fieldNameByIdentifierType">
        <xsl:param name="idType"/>
        <xsl:variable name="lc_name">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$idType"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_name='handle'">
                <xsl:text>CreativeWork.identifier.handle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_name='issn'">
                <xsl:text>CreativeWorkSeries.issn</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_name='doi'">
                <xsl:text>CreativeWork.identifier.doi</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_name='url'">
                <xsl:text>CreativeWork.identifier.url</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_name='isbn'">
                <xsl:text>Book.isbn</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_name='issn'">
                <xsl:text>CreativeWorkSeries.issn</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>CreativeWork.identifier.other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Publication dates Fields -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='dates']" mode="Publication">
        <xsl:call-template name="system_date"/>
        <xsl:apply-templates select="doc:element[@name='date']/doc:element"/>
    </xsl:template>

    <!-- system date -->
    <xsl:template name="system_date">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.dateCreated'"/>
            <!-- expose current date based on ISO 8601 -->
            <xsl:with-param name="value"
                select="format-dateTime(current-dateTime()
                                            ,'[Y0001]-[D01]-[M01]T[H01]:[m01]:[s01] [z]')"/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- date Available -->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Available']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.datePublished'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- date Accepted -->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Accepted']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.dateAccepted'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- date issued -->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Issued']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.sdDatePublished'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- rights -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='rights' and starts-with(./doc:field[@name='value']/text(),'info:eu-repo')] " mode="Publication">
        <xsl:apply-templates select="./doc:field" mode="rights"/>
    </xsl:template>
    <xsl:template match="doc:field[@name='value']" mode="rights">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.conditionsOfAccess'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- license -->
    <xsl:template match="doc:element[@name='oaire']/doc:element[@name='licenseCondition']"
        mode="Publication">
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:text>CreativeWork.license</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="./doc:field" mode="license"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:field[@name='startDate']" mode="license">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.license.datePublished'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:field[@name='uri']" mode="license">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.license.url'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:field[@name='value']" mode="license">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.license.description'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- language -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='language']" mode="Publication">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.inLanguage'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- type -->
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='resourceTypeGeneral']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.genre'"/>
            <xsl:with-param name="value" select="normalize-space(.)"/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='uri']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.additionalType.url'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='value']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.additionalType'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- description -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='description']" mode="Publication">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.description'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- format -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='format']" mode="Publication">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.encodingFormat'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- publisher -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='publisher']" mode="Publication">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.publisher.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- subjects -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='subjects']" mode="Publication">
            <xsl:apply-templates select="doc:element[@name='subject']"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='subject']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.keyword'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
   
    <!-- sizes -->
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='sizes']" mode="Publication">
        <xsl:apply-templates select="doc:element[@name='size']"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='size']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'MediaObject.contentSize'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- file -->
    <xsl:template match="doc:element[@name='oaire']/doc:element[@name='files']" mode="Publication">
        <xsl:for-each select="./doc:element[@name='file']">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>MediaObject</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="./doc:field">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="doc:element[@name='file']/doc:field[@name='value']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'MediaObject.contentUrl'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='file']/doc:field[@name='mimeType']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'MediaObject.encodingFormat'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='file']/doc:field[@name='objectType']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'MediaObject.additionalType'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='file']/doc:field[@name='accessRightsURI']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'MediaObject.conditionsOfAccess.uri'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- version -->
    <xsl:template match="doc:element[@name='oaire']/doc:element[@name='version']" mode="Publication">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.schemaVersion'"/>
            <xsl:with-param name="value" select="./doc:field[@name='uri']/text()"/>
            <xsl:with-param name="lang" select="''"/>
            <!-- TODO no Dspace7 não é suportado -->
        </xsl:call-template>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.version'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


  <!-- //////////////////////////////////////////////////////////////  -->

    
    <!-- Static Service based on the params -->
    <xsl:template name="relationRepositoryService">
        <xsl:element name="relation">
            <xsl:attribute name="type">
                <xsl:text>CreativeWork.provider</xsl:text>
            </xsl:attribute>

            <xsl:attribute name="fromEntityRef">
            	<xsl:value-of select="$publicationName"/>
            </xsl:attribute>
            
            <xsl:attribute name="toEntityRef">
            	<xsl:value-of select="concat('repositoryService_',$networkAcronym)"/>
            </xsl:attribute>
            	
			<xsl:element name="attributes">
			<xsl:call-template name="field_value">
                <xsl:with-param name="name" select="'CreativeWork.contributor.alternateName'"/>
                <xsl:with-param name="value" select="$networkAcronym"/>
            </xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>	


 
   <!-- field template -->
    <xsl:template name="field">
        <xsl:param name="name"/>
        <xsl:param name="node"/>
        <xsl:for-each select="$node/doc:field[@name='value']">
            <xsl:call-template name="field_value">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="lang" select="../doc:field[@name='lang']/text()"/>
                <xsl:with-param name="value" select="./text()"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="field_with_prefix">
        <xsl:param name="name"/>
        <xsl:param name="prefix"/>
        <xsl:param name="node"/>
        <xsl:for-each select="$node/doc:field[@name='value']">
            <xsl:call-template name="field_value">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="lang" select="../doc:field[@name='lang']/text()"/>
                <xsl:with-param name="value" select="substring-after(./text(), $prefix)"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="field_value">
        <xsl:param name="name"/>
        <xsl:param name="lang"/>
        <xsl:param name="value"/>
        <xsl:if test="$value">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
                <xsl:if test="$lang">
                    <xsl:attribute name="lang">
                        <xsl:value-of select="$lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="value">
                    <xsl:value-of select="$value"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>
   
   <!-- semantic identifier template -->
    <xsl:template name="semanticIdentifier">
        <xsl:param name="value"/>
        <xsl:if test="$value">
            <xsl:element name="semanticIdentifier">
                <xsl:value-of select="$value"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
  
  <!-- ignore all non specified text values or attributes -->
    <xsl:template match="node()" mode="Publication"/>
    <xsl:template match="node()" mode="Person"/>
    <xsl:template match="node()" mode="Funding"/>
    <xsl:template match="node()" mode="Funder"/>
    <xsl:template match="node()" mode="Organization"/>
    <xsl:template match="node()" mode="Award"/>

    <xsl:template match="text() | @*"/>
    <xsl:template match="text() | @*" mode="semanticId"/>
    <xsl:template match="text() | @*" mode="serviceSemanticId"/>
</xsl:stylesheet>