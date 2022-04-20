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

<!--  This file is used to transform from stored entities to entity index -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:index="http://www.lareferencia.info/schema/4.0/index" version="2.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <xsl:template match="/">
        <doc>
            <field name="id">
                <xsl:value-of select="/index:resource/@id"/>
            </field>
            <!-- we are ignoring semantic ids -->
            <field name="semantic_id"/>
            <field name="type">
                <xsl:value-of select="/index:resource/@type"/>
            </field>

            <xsl:apply-templates select="/index:resource/index:fields/index:field"/>
            <xsl:apply-templates select="/index:resource/index:relationships/index:relationship"/>
        </doc>
    </xsl:template>

    <xsl:template match="index:fields/index:field">
        <!-- language fields -->
            
        <xsl:call-template name="field">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="namePrefix">
                <xsl:choose>
                    <xsl:when test="lower-case(@lang)='por' or contains(lower-case(@lang), 'pt')">
                        <xsl:text>por.</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(@lang)='eng' or contains(lower-case(@lang), 'en')">
                        <xsl:text>eng.</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(@lang)='fra' or contains(lower-case(@lang), 'fr')">
                        <xsl:text>fra.</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(@lang)='spa' or contains(lower-case(@lang), 'es')">
                        <xsl:text>spa.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>und.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>            
            </xsl:with-param>
        </xsl:call-template>
        

        <!-- field string -->
        <xsl:call-template name="stringField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>        
        

        <xsl:apply-templates select="." mode="date"/>
        <xsl:apply-templates select="." mode="sort"/>
    </xsl:template>
    
    <xsl:template match="index:relationships/index:relationship">
        
        <xsl:apply-templates select="index:fields/index:field"/>
        
        <xsl:call-template name="relationField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- Specific sortable fields -->

    <xsl:template
        match="index:resource[@type='Publication']/index:fields/index:field[@name='CreativeWork.headline']" mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="index:resource[@type='Publication']/index:fields/index:field[@name='CreativeWork.datePublished']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="index:resource[@type='Publication']/index:fields/index:field[@name='CreativeWork.sdDatePublished']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="index:resource[@type='Publication']/index:fields/index:field[@name='CreativeWork.additionalType']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="index:resource[@type='Person']/index:fields/index:field[@name='Person.name']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="index:resource[@type='Person']/index:fields/index:field[@name='Person.familyName']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="index:resource[@type='Person']/index:fields/index:field[@name='Person.givenName']"
        mode="sort">
        <xsl:call-template name="sortField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- Specific date fields -->
    <xsl:template
        match="index:resource[@type='Publication']/index:fields/index:field[@name='CreativeWork.datePublished']"
        mode="date">
        <xsl:call-template name="dateField">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <!-- generic field templates -->
    <xsl:template name="stringField">
        <xsl:param name="node"/>
        <xsl:call-template name="field">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="namePrefix" select="'fs.'"/>
        </xsl:call-template>
    </xsl:template>    
    
    <xsl:template name="dateField">
        <xsl:param name="node"/>
        <xsl:call-template name="field">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="namePrefix" select="'df.'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="sortField">
        <xsl:param name="node"/>
        <xsl:call-template name="field">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="namePrefix" select="'sf.'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="relationField">
        <xsl:param name="node"/>
            <field>
            <xsl:attribute name="name">
                <xsl:value-of select="'is.'"/>
                <xsl:value-of select="$node/@name"/>
            </xsl:attribute>
            <xsl:value-of select="$node/@id"/>
        </field>        
    </xsl:template>    

    <xsl:template name="field">
        <xsl:param name="node"/>
        <xsl:param name="namePrefix"/>
        <xsl:variable name="parentName" select="$node/../../@name"/>        
        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="$namePrefix"/>
                <xsl:value-of select="$parentName"/>
                <xsl:if test="$parentName"><xsl:text>..</xsl:text></xsl:if>
                <xsl:value-of select="$node/@name"/>
            </xsl:attribute>
            <xsl:value-of select="$node/text()"/>
        </field>
    </xsl:template>

    <xsl:template match="*" mode="date"/>
    <xsl:template match="*" mode="sort"/>

</xsl:stylesheet>