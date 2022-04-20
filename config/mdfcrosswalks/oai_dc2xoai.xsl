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

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"    
    exclude-result-prefixes="oai_dc dc">
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>

	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	
	<xsl:param name="timestamp" />
	<xsl:param name="identifier" />
		
	<xsl:strip-space elements="*"/>
	 
    <xsl:template match="oai_dc:dc">



<metadata xmlns="http://www.lyncode.com/xoai" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">
	<element name="dc">
		<xsl:if test="//dc:title">
			<element name="title">
				<element name="none">
					<xsl:for-each select="//dc:title">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:creator">
			<element name="creator">
				<element name="none">
					<xsl:for-each select="//dc:creator">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:subject">
			<element name="subject">
				<element name="none">
					<xsl:for-each select="//dc:subject">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:description">
			<element name="description">
				<element name="none">
					<xsl:for-each select="//dc:description">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:publisher">
			<element name="publisher">
				<element name="none">
					<xsl:for-each select="//dc:publisher">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:contributor">
			<element name="contributor">
				<element name="none">
					<xsl:for-each select="//dc:contributor">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:date">
			<element name="date">
				<element name="none">
					<xsl:for-each select="//dc:date">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:type">
			<element name="type">
				<element name="none">
					<xsl:for-each select="//dc:type">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:format">
			<element name="format">
				<element name="none">
					<xsl:for-each select="//dc:format">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:identifier">
			<element name="identifier">
				<element name="none">
					<xsl:for-each select="//dc:identifier">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:source">
			<element name="source">
				<element name="none">
					<xsl:for-each select="//dc:source">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:language">
			<element name="language">
				<element name="none">
					<xsl:for-each select="//dc:language">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:relation">
			<element name="relation">
				<element name="none">
					<xsl:for-each select="//dc:relation">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:coverage">
			<element name="coverage">
				<element name="none">
					<xsl:for-each select="//dc:coverage">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:rights">
			<element name="rights">
				<element name="none">
					<xsl:for-each select="//dc:rights">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
	</element>

	<element name="bundles" />

	<element name="others">
		<field name="handle"></field>
		<field name="identifier"><xsl:value-of select="$identifier" /></field>
		<field name="lastModifyDate"><xsl:value-of  select="format-dateTime(xs:dateTime($timestamp), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/></field>
	</element>

	<element name="repository">
		<field name="mail"></field>
		<field name="name"></field>
	</element>

</metadata>

    </xsl:template>
    
</xsl:stylesheet>