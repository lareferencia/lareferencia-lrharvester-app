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

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	version="2.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" encoding="utf-8" />

	<!-- params -->
	<xsl:param name="identifier" />
	<xsl:param name="timestamp" />
	<xsl:param name="networkName" />
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkPublished" />

	<xsl:param name="name" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />

	<!-- image support -->
	<xsl:variable name="img_path">
		<xsl:text>/images/repositories/</xsl:text>
	</xsl:variable>
	<xsl:variable name="img_logo">
		<xsl:value-of select="concat($img_path,$networkAcronym,'.jpg')" />
	</xsl:variable>

	<xsl:variable name="facet_delimiter">{{{_:::_}}}</xsl:variable>

	<xsl:template match="/">
		<xsl:element name="doc">
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'id'" />
				<xsl:with-param name="node" select="$identifier" />
			</xsl:call-template>
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'repository_id_str'" />
				<xsl:with-param name="node" select="concat('urn:repositoryAcronym:',lower-case($networkAcronym))" />
			</xsl:call-template>

			<xsl:call-template name="ServiceAcronymSemanticId" />

			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'logo_str'" />
				<xsl:with-param name="node" select="$img_logo" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'network_acronym_str'" />
				<xsl:with-param name="node" select="$networkAcronym" />
			</xsl:call-template>

			<!-- general provenance - for all entities -->
			<xsl:apply-templates select="/attributes"
				mode="Service" />
			<!-- consider the record is always clean -->
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'dirty'" />
				<xsl:with-param name="node" select="'0'" />
			</xsl:call-template>
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'status'" />
				<xsl:with-param name="node" select="'SINGLETON'" />
			</xsl:call-template>
			<xsl:call-template name="ServiceName" />
			<xsl:call-template name="ServiceAcronym" />
			<xsl:call-template name="ServiceVisibility" />
			<xsl:call-template name="institutionName"/>
			<xsl:call-template name="institutionAcronym"/>
		</xsl:element>
	</xsl:template>


	<!-- Entity: Service -->
	<xsl:template match="/attributes" mode="Service">

		<xsl:apply-templates select="*"
			mode="ServiceSemanticId" />
		<xsl:apply-templates select="*"
			mode="service_field" />
		<xsl:apply-templates select="."
			mode="service_periodical_field" />
		<xsl:apply-templates select="."
			mode="service_oaipmh_field" />
		<xsl:apply-templates select="."
			mode="service_repository_field" />

		<xsl:apply-templates select="*"
			mode="organization" />

	</xsl:template>

	<xsl:template match="/attributes/eissn"
		mode="ServiceSemanticId">
		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/pissn"
		mode="ServiceSemanticId">
		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/issnL"
		mode="ServiceSemanticId">
		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>
	</xsl:template>
	<!--xsl:template match="/attributes/email" mode="ServiceSemanticId"> <xsl:call-template 
		name="semanticIdentifier"> <xsl:with-param name="value" select="text()"/> 
		</xsl:call-template> </xsl:template -->
	<xsl:template name="ServiceAcronymSemanticId">
		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value"
				select="concat('urn:repositoryAcronym:',lower-case($networkAcronym))" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ServiceVisibility">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'visible'" />
			<xsl:with-param name="node">
				<xsl:choose>
					<xsl:when test="lower-case($networkPublished)='true'">
						<xsl:text>1</xsl:text>
					</xsl:when>
					<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ServiceName">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'title'" />
			<xsl:with-param name="node" select="$networkName" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'title_sort'" />
			<xsl:with-param name="node" select="$networkName" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ServiceAcronym">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'titleAlt_str'" />
			<xsl:with-param name="node" select="$networkAcronym" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/type"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.serviceType_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/url" mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/email"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'contact_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/country"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.areaServed_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/description_pt"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'descriptions_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/description_en"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'descriptions_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/tags"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'tags_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes"
		mode="service_periodical_field">
		<xsl:apply-templates select="*"
			mode="service_periodical_subfield" />
		<!-- <field name="CreativeWorkSeries.issn" -->
	</xsl:template>


	<xsl:template match="/attributes/doiPrefix"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'RCAAP.doiPrefix_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/pissn"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'issn'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/eissn"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'issn'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/issnL"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'issn'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/sherpa"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.sherpa.url_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes"
		mode="service_oaipmh_field">
		<xsl:apply-templates select="*"
			mode="service_oaipmh_subfield" />
	</xsl:template>

	<xsl:template match="/attributes/oaiURL"
		mode="service_oaipmh_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'sourceUrl_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/software"
		mode="service_oaipmh_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'software_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes"
		mode="service_repository_field">
		<xsl:apply-templates select="*"
			mode="service_repository_subfield" />
	</xsl:template>

	<xsl:template match="/attributes/handlePrefix"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.handlePrefix_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/openDoar"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.openDoar.url_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/roarMap"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.roarMap.url_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/indexarURL"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'indexarUrl_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes/degois"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'degois'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/cienciaVitae"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'cienciaVitae'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/cienciaId"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'cienciaId'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/openAIRE"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'openAIRE'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/openAIRE4"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'openAIRE4'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/driver"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'driver'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/fct" mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'fct'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/thesis"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'thesis'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/fulltext"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node" select="'fulltext'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/accessibleContent"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories_str_mv'" />
				<xsl:with-param name="node"
					select="'accessibleContent'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

<!-- organization -->
	<xsl:template name="institutionName">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'institution'" />
			<xsl:with-param name="node" select="$institutionName" />
		</xsl:call-template>
		
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.legalName_str_mv'" />
			<xsl:with-param name="node" select="$institutionName" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="institutionAcronym">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.alternateName_str_mv'" />
			<xsl:with-param name="node"
				select="$institutionAcronym" />
		</xsl:call-template>

		<xsl:call-template name="organization">
			<xsl:with-param name="value" select="concat('urn:organizationAcronym:',lower-case($institutionAcronym))" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/institutionURL"
		mode="organization">
		<xsl:if test="text() != ''">
			<xsl:call-template name="organization">
				<xsl:with-param name="value"
					select="text()" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/isni"
		mode="organization">
		<xsl:if test="text() != ''">
			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:isni:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ringold"
		mode="organization">
		<xsl:if test="text() != ''">
			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ringgold"
		mode="organization">
		<xsl:if test="text() != ''">
			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ror"
		mode="organization">
		<xsl:if test="text() != ''">
			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ror:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ////////////////////////////////////////////////////////////// -->


	<!-- field template -->
	<xsl:template name="field">
		<xsl:param name="name" />
		<xsl:param name="node" />
		<xsl:if test="$node">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:value-of select="$name" />
				</xsl:attribute>
				<xsl:value-of select="$node" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- semantic identifier template -->
	<xsl:template name="organization">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:text>organization_str_mv</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- semantic identifier template -->
	<xsl:template name="semanticIdentifier">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:text>semanticIdentifier_str_mv</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- ignore all non specified text values or attributes -->
	<xsl:template match="node()" mode="Service" />
	<xsl:template match="node()" mode="organization" />
	<xsl:template match="node()" mode="Relation" />

	<xsl:template match="text() | @*" />
	<xsl:template match="text() | @*" mode="ServiceSemanticId" />
	<xsl:template match="text() | @*"
		mode="OrganizationSemanticId" />
	<xsl:template match="text() | @*" mode="service_field" />
	<xsl:template match="text() | @*"
		mode="organization_field" />
	<xsl:template match="text() | @*"
		mode="service_periodical_subfield" />
	<xsl:template match="text() | @*"
		mode="service_oaipmh_subfield" />
	<xsl:template match="text() | @*"
		mode="service_repository_subfield" />
	<xsl:template match="text() | @*"
		mode="service_contactPoint_subfield" />

</xsl:stylesheet>