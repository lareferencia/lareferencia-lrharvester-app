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
	xmlns:METS="http://www.loc.gov/METS/" 
	xmlns:MODS="http://www.loc.gov/standards/mods/v3/" 
	xmlns:PREMIS="http://www.loc.gov/standards/premis"	
    xmlns:dc="http://purl.org/dc/elements/1.1/"    
    exclude-result-prefixes="METS MODS PREMIS">
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>

	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	
	<xsl:param name="vufind_id" />
	<xsl:param name="header_id" />
	<xsl:param name="record_id" />
	
	<xsl:strip-space elements="*"/>
	 
    <xsl:template match="METS:mets">


<!-- METS:dmdSec/METS:mdWrap/ -->

<metadata xmlns="http://www.lyncode.com/xoai" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">
	<element name="dc">

		<!-- TIPO DE DOCUMENTO -->

		<xsl:if test="//*:genre">
			<element name="type">
				<element name="none">
					<xsl:for-each select="//*:genre">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!-- TÍTULO -->

		<xsl:if test="//*:titleInfo[not(@*)]">
			<element name="title">
				<element name="none">
					<xsl:for-each select="//*:titleInfo[not(@*)]">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>

				<!-- TÍTULO ALTERNATIVO -->
				<xsl:if test="//*:titleInfo[@type='alternative']">	
					<xsl:for-each select="//*:titleInfo[@type='alternative']">
						<element name="alternative">
							<element>	
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</element>
					 	</element>
					</xsl:for-each>
				</xsl:if>	

			</element>
		</xsl:if>

		<!--  AUTOR -->
		
		<xsl:if test="//*:namePart[preceding-sibling::*:role/*:roleTerm='author']">
			<element name="creator">
				<element name="none">
					<xsl:for-each select="//*:namePart[preceding-sibling::*:role/*:roleTerm='author']">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!--  CONTRIBUIDORS -->

		<xsl:if test="//*:namePart[preceding-sibling::*:role/*:roleTerm='advisor']">

			<element name="contributor">

				<element name="advisor">
					<element name="none">
						<xsl:for-each select="//*:namePart[preceding-sibling::*:role/*:roleTerm='advisor']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
			    </element>

				<xsl:if test="//*:namePart[preceding-sibling::*:role/*:roleTerm='referees']">
					<element name="contributor">
						<element name="referees">
							<element name="none">
								<xsl:for-each select="//*:namePart[preceding-sibling::*:role/*:roleTerm='referees']">
									<field name="value">
										<xsl:value-of select="." />
									</field>
								</xsl:for-each>
							</element>
					    </element>
					</element>
				</xsl:if>

			</element>

		</xsl:if>

		<xsl:if test="//*:namePart[preceding-sibling::*:role/*:roleTerm='editor']">
			<element name="contributor">
				<element name="editor">
					<element name="none">
						<xsl:for-each select="//*:namePart[preceding-sibling::*:role/*:roleTerm='editor']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//*:namePart[preceding-sibling::*:role/*:roleTerm='other']">
			<element name="contributor">
				<element name="other">
					<element name="none">
						<xsl:for-each select="//*:namePart[preceding-sibling::*:role/*:roleTerm='other']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<!--  DATA  -->

	    <xsl:if test="//*:dateIssued">
			<element name="date">
				<element name="issued">
					<element name="none">
						<xsl:for-each select="//*:dateIssued">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//*:dateSubmitted">
			<element name="date">
				<element name="issued">
					<element name="none">
						<xsl:for-each select="//*:dateSubmitted">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

	    <xsl:if test="//*:dateAvailable">
			<element name="date">
				<element name="available">
					<element name="none">
						<xsl:for-each select="//*:dateAvailable">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//*:dateAccessioned">
			<element name="date">
				<element name="accessioned">
					<element name="none">
						<xsl:for-each select="//*:dateAccessioned">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>


		<!-- INSTITUIÇÃO -->

		<xsl:if test="//*:publisher">
			<element name="publisher">
				<element name="none">
					<xsl:for-each select="//*:publisher">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!-- TIPO DE ACESSO -->

		<xsl:if test="//*:accessCondition">
			<element name="rights">
				<element name="none">
					<xsl:for-each select="//*:accessCondition">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!-- RESUMO -->

		<xsl:if test="//*:abstract">
			<element name="description">
				<element name="abstract">
					<element name="none">
						<xsl:for-each select="//*:abstract">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//*:note[not(@type)]">
			<element name="description">
				<element name="abstract">
					<element name="none">
						<xsl:for-each select="//*:note[not(@type)]">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//*:resumo">
			<element name="description">
				<element name="resumo">
					<element name="none">
						<xsl:for-each select="//*:resumo">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<!-- PROVENIÊNCIA -->

		<xsl:if test="//*:note[@type='provenance']">
			<element name="description">
				<element name="provenance">
					<element name="none">
						<xsl:for-each select="//*:note[@type='provenance']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<!-- PALAVRAS-CHAVE -->

		<xsl:if test="//*:topic">
			<element name="subject">
				<element name="none">
					<xsl:for-each select="//*:topic">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!-- IDIOMA -->

		<xsl:if test="//*:languageTerm">
			<element name="language">
				<element name="none">
					<xsl:for-each select="//*:languageTerm">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<!-- URI -->

		<xsl:if test="//*:identifier[@type='uri']">
			<element name="identifier">
				<element name="uri">
					<element name="none">
						<xsl:for-each select="//*:identifier[@type='uri']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<!-- CITAÇÃO -->

		<xsl:if test="//*:text">
			<element name="identifier">
				<element name="citation">
					<element name="none">
						<xsl:for-each select="//*:text">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>


		<xsl:if test="//*:identifier[@type='citation']">
			<element name="identifier">
				<element name="citation">
					<element name="none">
						<xsl:for-each select="//*:identifier[@type='citation']">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>


		<!-- ID -->

		<xsl:if test="//*:dmdSec/@ID">
			<element name="identifier">
					<element name="none">
						<xsl:for-each select="//*:dmdSec/@ID">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
			</element>
		</xsl:if>

		<!-- TIPO DE ARQUIVO -->

		<xsl:if test="//*:formatName">
			<element name="format">
				<element name="none">
					<xsl:for-each select="//*:formatName">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>




	</element>


	<element name="bundles" />

	<xsl:if test="//*:file">
		<xsl:for-each select="//*:file">
			<element name="bitstreams">
				<element name="bitstream">
					<field name="name">
						<xsl:value-of select="fn:replace(./@OWNERID,'http.+/','')" />
					</field>
					<field name="originalName">
						<xsl:value-of select="./@OWNERID" />
					</field>
					<field name="format">
						<xsl:value-of select="./@MIMETYPE" />
					</field>
					<field name="size">
						<xsl:value-of select="./@SIZE" />
					</field>
					<field name="url">
						<xsl:value-of select="./@OWNERID" />
					</field>
					<field name="checksum">
						<xsl:value-of select="./@CHECKSUM" />
					</field>
					<field name="checksumAlgorithm">
						<xsl:value-of select="./@CHECKSUMTYPE" />
					</field>
					<field name="sid">
						<xsl:value-of select="./@ID" />
					</field>	
	 			</element>
			</element>
		</xsl:for-each>	
	</xsl:if>

	<element name="others">
		<field name="handle">
			<xsl:value-of select="$header_id" />
		</field>
		<field name="identifier">
			<xsl:value-of select="$header_id" />
		</field>
		<field name="lastModifyDate">
			<xsl:value-of
				select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')" />
		</field>
	</element>

	<element name="repository">
		<field name="mail">mail@mail.com</field>
		<field name="name">
			<xsl:value-of select="$networkName" />
			-
			<xsl:value-of select="$institutionName" />
		</field>
	</element>


</metadata>

    </xsl:template>
    
</xsl:stylesheet>
