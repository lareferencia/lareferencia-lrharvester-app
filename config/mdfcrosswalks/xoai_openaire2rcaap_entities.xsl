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
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='creators']/doc:element[@name='creator']"
                    mode="entity"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='creators']/doc:element[@name='creator']"
                    mode="entity_affiliation"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='contributors']/doc:element[@name='contributor']"
                    mode="entity"/>
				<!-- if there isn't any hostingInstitution -->
                <xsl:if
                    test="not(/doc:metadata/doc:element[@name='datacite']/doc:element[@name='contributors']/doc:element[@name='contributor']/doc:field[@name='contributorType' and text()='HostingInstitution'])">
                    <xsl:call-template name="repositoryService"/>
                </xsl:if>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']"
                    mode="entity"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']"
                    mode="entity_funder"/>
            </xsl:element>
            <xsl:element name="relations">
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='creators']/doc:element[@name='creator']"
                    mode="relation"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='contributors']/doc:element[@name='contributor']"
                    mode="relation"/>
				<!-- if there isn't any hostingInstitution -->
                <xsl:if
                    test="not(/doc:metadata/doc:element[@name='datacite']/doc:element[@name='contributors']/doc:element[@name='contributor']/doc:field[@name='contributorType' and text()='HostingInstitution'])">
                    <xsl:call-template name="relationRepositoryService"/>
                </xsl:if>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='creators']/doc:element[@name='creator']"
                    mode="relation_affiliation"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']"
                    mode="relation"/>
                <xsl:apply-templates
                    select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']"
                    mode="relation_funder"/>

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

            <xsl:apply-templates
                select="/doc:metadata/doc:element[@name='datacite']/doc:element[@name='identifier']" mode="semanticId"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']/doc:element"
                mode="Publication"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dc']/doc:element"
                mode="Publication"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='oaire']/doc:element"
                mode="Publication"/>
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
    <xsl:template match="doc:element[@name='datacite']/doc:element[@name='rights']" mode="Publication">

        <xsl:variable name="open_access">
            <xsl:choose>
                <!-- is open access ? -->
                <xsl:when
                    test="doc:field[@name='rightsURI' and text()='http://purl.org/coar/access_right/c_abf2']">
                    <xsl:text>true</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>false</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.isAccessibleForFree'"/>
            <xsl:with-param name="value" select="$open_access"/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>

        <xsl:apply-templates select="./doc:field" mode="rights"/>
    </xsl:template>
    <xsl:template match="doc:field[@name='rightsURI']" mode="rights">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.conditionsOfAccess.uri'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
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
    <xsl:template match="doc:element[@name='oaire']/doc:element[@name='resourceType']" mode="Publication">
        <xsl:apply-templates select="doc:field"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='resourceTypeGeneral']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.genre'"/>
            <xsl:with-param name="value" select="."/>
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
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:text>CreativeWork.about</xsl:text>
            </xsl:attribute>
			<xsl:apply-templates select="doc:field"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:element[@name='subject']/doc:field[@name='value']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.keywords'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='subject']/doc:field[@name='subjectScheme']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.about.name'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='subject']/doc:field[@name='schemeURI']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.about.additionalType'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='subject']/doc:field[@name='valueURI']">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'CreativeWork.about.url'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
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

    <!-- citation -->
    <xsl:template match="doc:element[@name='oaire']/doc:element[@name='citation']" mode="Publication">
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:text>CreativeWork.citation</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="doc:element"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationTitle']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'CreativeWork.citation.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationStartPage']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'PublicationIssue.pageStart'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationEndPage']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'PublicationIssue.pageEnd'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationVolume']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'PublicationVolume.volumeNumber'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationIssue']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'PublicationIssue.issueNumber'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationEdition']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'PublicationIssue.bookEdition'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationConferencePlace']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Event.location'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='citationConferenceDate']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Event.startDate'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- Entity: Creator Entities (Person or Organization) -->
    <xsl:template match="doc:element[@name='creator']" mode="entity">
        <xsl:variable name="lc_nameType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value"
                    select="doc:element[@name='creatorName']/doc:field[@name='nameType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- Choose which Entity type Organization/Person -->
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="$lc_nameType='organizational'">
                    <xsl:text>Organization</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Person</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="entity">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
            <xsl:attribute name="ref">
                <xsl:value-of select="concat('Creator',position())"/>
            </xsl:attribute>
            <!-- semanticIdentifier -->
            <xsl:apply-templates select="*" mode="semanticId"/>
            
            <!-- name -->
            <xsl:choose>
                <xsl:when test="$type='Organization'">
                    <xsl:apply-templates select="doc:element[@name='creatorName']"
                        mode="Organization"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="doc:element[@name='creatorName']" mode="Person"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="*"/>

        </xsl:element>
    </xsl:template>

    <!-- Person / Organization entities semanticIdentifier -->
    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='nameIdentifierScheme' and ./doc:field/text()='isni']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='nameIdentifierScheme' and ./doc:field/text()='orcid']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='nameIdentifierScheme' and ./doc:field/text()='cienciaID']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
    </xsl:template>

    <!--xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='nameIdentifierScheme' and ./doc:field/text()='e-mail']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
    </xsl:template-->

    <xsl:template
        match="doc:element[@name='contributorName']/doc:field[@name='nameType' and	text()='Organizational']"
        mode="serviceSemanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value"
                select="concat('urn:repositoryAcronym:',translate($networkAcronym, $uppercase, $smallcase))"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='creatorName']/doc:field[@name='value']" mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value">
                <xsl:value-of
                    select="//doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']/text()"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="translate(normalize-space(text()), $nameFrom, $nameTo)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='contributorName']/doc:field[@name='value']" mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value">
                <xsl:value-of
                    select="//doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']/text()"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="translate(normalize-space(text()), $nameFrom, $nameTo)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 

    <!-- Entity: Affiliation Entities -->
    <xsl:template match="doc:element[@name='creator']" mode="entity_affiliation">
        <!-- if affiliation is defined -->
        <xsl:if test="./doc:element[@name='affiliation']">
            <xsl:element name="entity">
                <xsl:attribute name="type">
                    <xsl:text>Organization</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="ref">
                    <xsl:value-of select="concat('Affiliation',position())"/>
                </xsl:attribute>
                <xsl:apply-templates select="doc:element[@name='affiliation']" mode="semanticId"/>
                <xsl:apply-templates select="doc:element[@name='affiliation']" mode="affiliation"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- affiliation -->
    <xsl:template match="doc:element[@name='affiliation']" mode="affiliation">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

	<!-- affiliation - semanticId -->
    <xsl:template match="doc:element[@name='affiliation']" mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value">
                <xsl:value-of
                    select="//doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']/text()"/>
                <xsl:text>#_affiliation__</xsl:text>
                <xsl:value-of
                    select="translate(normalize-space(doc:field[@name='value']/text()), $nameFrom, $nameTo)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 


    <!-- Entity: Contributor Entities (Person, Services or Organization) -->
    <xsl:template match="doc:element[@name='contributor']" mode="entity">
        <xsl:variable name="lc_nameType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value"
                    select="doc:element[@name='contributorName']/doc:field[@name='nameType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_contributorType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="doc:field[@name='contributorType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- Choose which Entity type Service/Organization/Person -->
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="($lc_nameType='organizational' and $lc_contributorType='hostinginstitution') or ($lc_contributorType='hostinginstitution')">
                    <xsl:text>Service</xsl:text>
                </xsl:when>
                <xsl:when test="$lc_nameType='organizational'">
                    <xsl:text>Organization</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Person</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="entity">
            <xsl:attribute name="type">     
                <xsl:value-of select="$type"/>
            </xsl:attribute>
            <xsl:attribute name="ref">
                <xsl:value-of select="concat('Contributor',position())"/>
            </xsl:attribute>

            <!-- name -->
            <xsl:choose>
                <xsl:when test="$type='Service'">
                    <!-- semanticIdentifier -->
                    <xsl:apply-templates select="doc:element[@name='contributorName']"
                        mode="serviceSemanticId"/>
                    <xsl:apply-templates select="doc:element[@name='nameIdentifier']"
                        mode="semanticId"/>
                    <xsl:apply-templates select="doc:element[@name='contributorName']"
                        mode="Service"/>
                </xsl:when>
                <xsl:when test="$type='Organization'">
                    <xsl:apply-templates select="*" mode="semanticId"/>
                    <xsl:apply-templates select="doc:element[@name='contributorName']"
                        mode="Organization"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- semanticIdentifier -->
                    <xsl:apply-templates select="*" mode="semanticId"/>
                    <xsl:apply-templates select="doc:element[@name='contributorName']" mode="Person"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="./*"/>

        </xsl:element>
    </xsl:template>
	
    <!-- Static Service based on the params -->
    <xsl:template name="repositoryService">
        <xsl:element name="entity">
            <xsl:attribute name="type">     
                <xsl:text>Service</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ref">
				<xsl:value-of select="concat('repositoryService_',$networkAcronym)"/>
            </xsl:attribute>
            <xsl:call-template name="semanticIdentifier">
                <xsl:with-param name="value"
                    select="concat('urn:repositoryAcronym:',translate($networkAcronym, $uppercase, $smallcase))"/>
            </xsl:call-template>
            <xsl:call-template name="field_value">
                <xsl:with-param name="name" select="'Service.alternateName'"/>
                <xsl:with-param name="value" select="$networkAcronym"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!-- creatorName -->
    <xsl:template match="doc:element[@name='creatorName']" mode="Person">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='creatorName']" mode="Organization">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- contributorName -->
    <xsl:template match="doc:element[@name='contributorName']" mode="Person">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='contributorName']" mode="Organization">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='contributorName']" mode="Service">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Service.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- familyName -->
    <xsl:template match="doc:element[@name='familyName']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.familyName'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- givenName -->
    <xsl:template match="doc:element[@name='givenName']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.givenName'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers -->

    <!-- identifiers - orcid -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='http://orcid.org']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.orcid'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>
    <!-- TODO: o novo DSpace irá expor os identificadores de maneira ligeiramente diferente, ajustamos o atual OpenAIRE dspace5? -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='orcid']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.orcid'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - scopus -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='https://www.scopus.com']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.scopusAuthorID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='scopusAuthorID']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.scopusAuthorID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - researcher id -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='https://www.researcherid.com']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.researcherID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='researcherID']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.researcherID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - ciencia-id -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='https://www.ciencia-id.pt']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.cienciaID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='cienciaID']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.cienciaID'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - google scholar -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='https://scholar.google.com']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.other'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - isni -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='schemeURI' and text()='http://www.isni.org']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.identifier.isni'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - other -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='other']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Person.identifier.other'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>

    <!-- identifiers - service email -->
    <xsl:template
        match="doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='e-mail']">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.email'"/>
            <xsl:with-param name="node" select="../."/>
        </xsl:call-template>
    </xsl:template>


    <!-- Entity: Funding -->
    <xsl:template match="doc:element[@name='fundingReference']" mode="entity">
        <xsl:variable name="semanticId">
            <xsl:call-template name="generateFundingSemanticId">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="entity">
            <xsl:attribute name="type">
                <xsl:text>Funding</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ref">
                <xsl:value-of select="concat('Funding',position())"/>
            </xsl:attribute>
            <!-- semanticIdentifier -->
            <xsl:call-template name="semanticIdentifier">
                <xsl:with-param name="value" select="$semanticId"/>
            </xsl:call-template>
            <xsl:apply-templates select="*" mode="Funding"/>
            <xsl:apply-templates select="doc:element" mode="Award"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="generateFundingSemanticId">
        <xsl:param name="node"/>
        <xsl:value-of
            select="concat(
                    substring-after(
                        $node/doc:element[@name='funderIdentifier']/doc:field[@name='value' and contains(text(),'http://doi.org/')]/text()
                        , 'http://doi.org/')
                     ,'/', $node/doc:element[@name='fundingStream']/doc:field[@name='value']/text()
                     ,'/',$node/doc:element[@name='awardNumber']/doc:field[@name='value']/text()
                     )"/>
    </xsl:template>

    <xsl:template match="doc:element[@name='fundingStream']" mode="Funding">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Funding.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- award -->
    <xsl:template match="doc:element[@name='awardNumber']" mode="Award">
        <xsl:apply-templates select="doc:field" mode="Award"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='awardNumber']/doc:field[@name='value']" mode="Award">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'ResearchProject.award.identifier'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='awardNumber']/doc:field[@name='awardURI']" mode="Award">
        <xsl:call-template name="field_value">
            <xsl:with-param name="name" select="'ResearchProject.award.url'"/>
            <xsl:with-param name="value" select="."/>
            <xsl:with-param name="lang" select="''"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="doc:element[@name='awardTitle']" mode="Award">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'ResearchProject.award.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='fundingReference']" mode="entity_funder">
        <!-- if funder is defined -->
        <xsl:if test="./doc:element[@name='funderName']">
            <xsl:element name="entity">
                <xsl:attribute name="type">
                    <xsl:text>Organization</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="ref">
                    <xsl:value-of select="concat('Funder',position())"/>
                </xsl:attribute>
                <!-- semanticIdentifier -->
                <xsl:call-template name="semanticIdentifier">
                    <xsl:with-param name="value"
                        select="doc:element[@name='funderIdentifier']/doc:field[@name='value' and contains(text(),'http://doi.org/')]/text()"/>
                </xsl:call-template>
                <xsl:apply-templates select="*" mode="Funder"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="doc:element[@name='funderName']" mode="Funder">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.legalName'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.name'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='funderIdentifier']" mode="Funder">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Organization.identifier'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

  <!-- //////////////////////////////////////////////////////////////  -->

  <!-- Relation Creator -->
    <xsl:template match="doc:element[@name='creator']" mode="relation">
        <xsl:variable name="lc_nameType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value"
                    select="doc:element[@name='creatorName']/doc:field[@name='nameType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="relation">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="$lc_nameType='organizational'">
                        <xsl:text>CreativeWork.author.organization</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>CreativeWork.author</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="fromEntityRef">
                <xsl:value-of select="$publicationName"/>
            </xsl:attribute>
            
            <xsl:attribute name="toEntityRef">
                <xsl:value-of select="concat('Creator',position())"/>
            </xsl:attribute>
            
            <xsl:element name="attributes">
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'CreativeWork.author.name'"/>
                    <xsl:with-param name="node" select="doc:element[@name='creatorName']"/>
                </xsl:call-template>
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'CreativeWork.author.affiliation.name'"/>
                    <xsl:with-param name="node" select="doc:element[@name='affiliation']"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>

  <!-- Relation Contributor -->
    <xsl:template match="doc:element[@name='contributor']" mode="relation">
        <xsl:variable name="lc_nameType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value"
                    select="doc:element[@name='contributorName']/doc:field[@name='nameType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_contributorType">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="doc:field[@name='contributorType']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="relation">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when
                test="($lc_nameType='organizational' and $lc_contributorType='hostinginstitution') or ($lc_contributorType='hostinginstitution')">
                        <xsl:text>CreativeWork.provider</xsl:text>
                    </xsl:when>
                    <xsl:when test="$lc_nameType='organizational'">
                        <xsl:text>CreativeWork.contributor.organization</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>CreativeWork.contributor.person</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="fromEntityRef">
                    <xsl:value-of select="$publicationName"/>
            </xsl:attribute>
            
            <xsl:attribute name="toEntityRef">
                    <xsl:value-of select="concat('Contributor',position())"/>
            </xsl:attribute>
            
            <xsl:element name="attributes">
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'CreativeWork.contributor.name'"/>
                    <xsl:with-param name="node" select="doc:element[@name='contributorName']"/>
                </xsl:call-template>
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'CreativeWork.contributor.affiliation.name'"/>
                    <xsl:with-param name="node" select="doc:element[@name='affiliation']"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>
	
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


  <!-- Relation Person Affiliation -->
    <xsl:template match="doc:element[@name='creator']" mode="relation_affiliation">
        <!-- if affiliation is defined -->
        <xsl:if test="./doc:element[@name='affiliation']">
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>Person.affiliation</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="fromEntityRef">
                    <xsl:value-of select="concat('Creator',position())"/>
                </xsl:attribute>
                <xsl:attribute name="toEntityRef">
                        <xsl:value-of select="concat('Affiliation',position())"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>

  <!-- Relation Funding - Grant.fundedItem -->
    <xsl:template match="doc:element[@name='fundingReference']" mode="relation">
        <xsl:element name="relation">
            <xsl:attribute name="type">
                <xsl:text>Grant.fundedItem</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="fromEntityRef">
            	<xsl:value-of select="$publicationName"/>
            </xsl:attribute>
            
            <xsl:attribute name="toEntityRef">
                    <xsl:value-of select="concat('Funding',position())"/>
            </xsl:attribute>
            
            
            <xsl:element name="attributes">
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'MonetaryGrant.funder.name'"/>
                    <xsl:with-param name="node" select="doc:element[@name='funderName']"/>
                </xsl:call-template>
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'MonetaryGrant.funder.identifier'"/>
                    <xsl:with-param name="node" select="doc:element[@name='funderIdentifier']"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Relation Funder - MonetaryGrant.funder -->
    <xsl:template match="doc:element[@name='fundingReference']" mode="relation_funder">
        <!-- if funder is defined -->
        <xsl:if test="./doc:element[@name='funderName']">
            <xsl:element name="relation">
                <xsl:attribute name="type">
                    <xsl:text>MonetaryGrant.funder</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="fromEntityRef">
                    <xsl:value-of select="concat('Funding',position())"/>
                </xsl:attribute>
        
                <xsl:attribute name="toEntityRef">
                    <xsl:value-of select="concat('Funder',position())"/>
                </xsl:attribute>
   
                <xsl:element name="attributes">
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'MonetaryGrant.funder.name'"/>
                        <xsl:with-param name="node" select="doc:element[@name='funderName']"/>
                    </xsl:call-template>
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'MonetaryGrant.funder.identifier'"/>
                        <xsl:with-param name="node" select="doc:element[@name='funderIdentifier']"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
        </xsl:if>
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