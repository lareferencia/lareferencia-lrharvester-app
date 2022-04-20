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
	
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />
	
	
    <xsl:param name="metadata" />
	<xsl:param name="fingerprint" />
	<xsl:param name="identifier" />
	<xsl:param name="timestamp" />
	<xsl:param name="deleted" />
	<xsl:param name="record_id" />
	
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<doc>
		
			<!-- ID es parámetro -->
            <field name="item.id"><xsl:value-of select="$record_id"/></field>
               
            <!-- ID es parámetro -->
            <field name="item.handle"><xsl:value-of select="$identifier"/></field>   
            
            
            <field name="item.lastmodified"><xsl:value-of  select="format-dateTime(xs:dateTime($timestamp), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/></field>               
			
            <field name="item.submitter">submitter</field>    
            
            <field name="item.deleted"><xsl:value-of select="$deleted"/></field>
            <field name="item.public">true</field>    
            
            <field name="item.collections"><xsl:value-of select="$networkAcronym"/></field>
            
            <field name="item.communities">com_<xsl:value-of select="$institutionAcronym"/></field>
			
			<!-- dc.title -->
			<xsl:for-each select="//doc:element[@name='title']/doc:field[@name='value']">
				<field name="metadata.dc.title"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.creator -->
			<xsl:for-each select="//doc:element[@name='creatorName']/doc:field[@name='value']">
				<field name="metadata.dc.creator"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="//doc:element[@name='contributorName']/doc:field[@name='value']">
				<field name="metadata.dc.contributor"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.subject -->
			<xsl:for-each select="//doc:element[@name='subject']/doc:field[@name='value']">
				<field name="metadata.dc.subject"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.description -->
			<xsl:for-each select="//doc:element[@name='description']/doc:field[@name='value']">
				<field name="metadata.dc.description"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.date -->
			<xsl:for-each select="//doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<field name="metadata.dc.date"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.type -->
			<xsl:for-each select="doc:metadata/doc:element[@name='oaire']/doc:element[@name='resourceType']/doc:field[@name='value']">
				<field name="metadata.dc.type"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.identifier -->
			<xsl:for-each select="doc:metadata/doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']">
				<field name="metadata.dc.identifier"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.identifier.* -->
			<xsl:for-each select="//doc:element[@name='relatedIdentifier']/doc:field[@name='value']">
				<field name="metadata.dc.identifier"><xsl:text>isPartOf:urn:</xsl:text><xsl:value-of select="../doc:field[@name='relatedIdentifierType']/text()" /><xsl:text>:</xsl:text><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.identifier.* -->
			<xsl:for-each select="//doc:element[@name='alternateIdentifier']/doc:field[@name='value']">
				<field name="metadata.dc.identifier"><xsl:text>urn:</xsl:text><xsl:value-of select="../doc:field[@name='alternateIdentifierType']/text()" /><xsl:text>:</xsl:text><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:field[@name='value']">
				<field name="metadata.dc.language"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.relation -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:field[@name='value']">
				<field name="metadata.dc.relation"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.rights -->
			<xsl:for-each select="//doc:element[@name='rights']/doc:field[@name='value']">
				<field name="metadata.dc.rights"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.format -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:field[@name='value']">
				<field name="metadata.dc.format"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:field[@name='value']">
				<field name="metadata.dc.coverage"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:field[@name='value']">
				<field name="metadata.dc.publisher"><xsl:value-of select="." /></field>
			</xsl:for-each>
			<!-- dc.source -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:field[@name='value']">
				<field name="metadata.dc.source"><xsl:value-of select="." /></field>
			</xsl:for-each>
			
			
			<field name="item.compile"><xsl:value-of select="$metadata"/></field>
			
		</doc>
	</xsl:template>
</xsl:stylesheet>

