<!--
  Copyright (c) 2026. LA Referencia / Red CLARA and others

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
-->

<!--
  DSpace Intermediate Metadata (DIM) to XOAI.

  DIM represents every metadata value as dim:field with an mdschema, element
  and optional qualifier.  The XOAI hierarchy preserves that model as:

    mdschema.element.qualifier.value

  Fields without a DIM qualifier use the conventional XOAI "none" element.
  The transformation is deliberately schema-agnostic, so local DSpace schemas
  are retained in addition to Dublin Core fields.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns="http://www.lyncode.com/xoai"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs dim">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Set by OCLCBasedHarvesterImpl from the OAI-PMH record header. -->
    <xsl:param name="timestamp" as="xs:string"/>
    <xsl:param name="identifier" as="xs:string"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="dim:dim">
        <metadata xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">
            <xsl:for-each-group
                select="dim:field[normalize-space(@mdschema) != '' and normalize-space(@element) != '' and normalize-space(.) != '']"
                group-by="normalize-space(@mdschema)">
                <element name="{current-grouping-key()}">
                    <xsl:for-each-group select="current-group()" group-by="normalize-space(@element)">
                        <element name="{current-grouping-key()}">
                            <xsl:for-each-group select="current-group()"
                                group-by="if (normalize-space(@qualifier) != '') then normalize-space(@qualifier) else 'none'">
                                <element name="{current-grouping-key()}">
                                    <xsl:for-each select="current-group()">
                                        <field name="value"><xsl:value-of select="."/></field>
                                        <xsl:if test="normalize-space(@lang) != ''">
                                            <field name="language"><xsl:value-of select="normalize-space(@lang)"/></field>
                                        </xsl:if>
                                    </xsl:for-each>
                                </element>
                            </xsl:for-each-group>
                        </element>
                    </xsl:for-each-group>
                </element>
            </xsl:for-each-group>

            <element name="bundles"/>
            <element name="others">
                <field name="handle"/>
                <field name="identifier"><xsl:value-of select="$identifier"/></field>
                <field name="lastModifyDate">
                    <xsl:choose>
                        <xsl:when test="$timestamp castable as xs:dateTime">
                            <xsl:value-of select="format-dateTime(xs:dateTime($timestamp), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$timestamp"/></xsl:otherwise>
                    </xsl:choose>
                </field>
            </element>
            <element name="repository">
                <field name="mail"/>
                <field name="name"/>
            </element>
        </metadata>
    </xsl:template>
</xsl:stylesheet>
