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

    <!-- params -->
    <xsl:param name="identifier"/>
    <xsl:param name="timestamp"/>
    <xsl:param name="fingerprint"/>
    <xsl:param name="networkAcronym"/>

   	<xsl:variable name="field_list" select="tokenize('source,type,creator,title,rights,subject,identifier,date,language,description,publisher,relation,format,contributor,coverage',',')"/>
    <xsl:template match="/">
        <xsl:element name="entity-relation-data">
            <!-- general provenance - for all entities -->
            <xsl:attribute name="source"><xsl:value-of select="$networkAcronym"/></xsl:attribute>
            <xsl:attribute name="record"><xsl:value-of select="$identifier"/></xsl:attribute>

            <xsl:attribute name="lastUpdate"><xsl:value-of select="$timestamp"/></xsl:attribute>

            <xsl:element name="entities">

                <xsl:element name="entity">
                    <xsl:attribute name="type"><xsl:text>Publication</xsl:text></xsl:attribute>
                    <xsl:attribute name="ref">publication01</xsl:attribute>

                    <xsl:element name="semanticIdentifier"><xsl:value-of select="$networkAcronym"/>_<xsl:value-of select="$fingerprint"/></xsl:element>

                    <xsl:element name="field">
                        <xsl:attribute name="name">semanticIdentifier</xsl:attribute>
                        <xsl:attribute name="value"><xsl:value-of select="$networkAcronym"/>_<xsl:value-of select="$fingerprint"/></xsl:attribute>
                    </xsl:element>

                    <!-- dc.element.value -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element/doc:element/doc:field[@name='value']">
                        <xsl:if test="count(index-of($field_list, lower-case(../../@name)))&gt;0">
                        <xsl:element name="field">
                            <xsl:attribute name="name"><xsl:text>dc.</xsl:text><xsl:value-of select="../../@name"/></xsl:attribute>
                            <xsl:attribute name="value"><xsl:value-of select="normalize-space()"/></xsl:attribute>
                        </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                    
                    <!-- dc.element.x.value -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element/doc:element/doc:element/doc:field[@name='value']">
                        
                        <!-- test if ../../../@name belongs to field_list usinglower-case -->
                        <xsl:if test="count(index-of($field_list, lower-case(../../../@name)))&gt;0">
                            <xsl:element name="field">
                                <xsl:attribute name="name"><xsl:text>dc.</xsl:text><xsl:value-of select="../../../@name"/></xsl:attribute>
                                <xsl:attribute name="value"><xsl:value-of select="normalize-space()"/></xsl:attribute>
                            </xsl:element>
                        </xsl:if>

                    </xsl:for-each>

                    <!-- dc.element.x.xvalue -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element/doc:element/doc:element/doc:element/doc:field[@name='value']">
                        
                    <xsl:if test="count(index-of($field_list, lower-case(../../../../@name)))&gt;0">
                        <xsl:element name="field">
                            <xsl:attribute name="name"><xsl:text>dc.</xsl:text><xsl:value-of select="../../../../@name"/></xsl:attribute>
                             <xsl:attribute name="value"><xsl:value-of select="normalize-space()"/></xsl:attribute>
                        </xsl:element>
                        </xsl:if>
                    </xsl:for-each>

                </xsl:element>

            </xsl:element>

            <xsl:element name="relations"></xsl:element>

        </xsl:element>

    </xsl:template>


</xsl:stylesheet>