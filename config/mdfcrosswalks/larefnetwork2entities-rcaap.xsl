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
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="utf-8" />

	<!-- params -->
	<xsl:param name="identifier" />
	<xsl:param name="timestamp" />
	<xsl:param name="networkAcronym" />

	<xsl:param name="name" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />

	<xsl:template match="/">
		<xsl:element name="entity-relation-data">
			<!-- general provenance - for all entities -->
			<xsl:attribute name="source">
                <xsl:value-of select="concat(lower-case($networkAcronym),'.properties')" />
			</xsl:attribute>
			<xsl:attribute name="record">
                <xsl:value-of select="$identifier" />
            </xsl:attribute>
			<xsl:attribute name="lastUpdate">
                <xsl:value-of select="$timestamp" />
            </xsl:attribute>
			<xsl:element name="entities">
				<xsl:apply-templates select="/attributes"
					mode="Service" />
				<xsl:apply-templates select="/attributes"
					mode="Organization" />
			</xsl:element>
			<xsl:element name="relations">
				<xsl:apply-templates select="/attributes"
					mode="Relation" />
			</xsl:element>
		</xsl:element>
	</xsl:template>


	<!-- Entity: Service -->
	<xsl:template match="/attributes" mode="Service">
		<xsl:element name="entity">
			<xsl:attribute name="type">
            <xsl:text>Service</xsl:text>
        </xsl:attribute>
			<xsl:attribute name="ref">
            <xsl:value-of select="'Service1'" />
        </xsl:attribute>
			<xsl:call-template name="ServiceAcronymSemanticId" />
			<xsl:apply-templates select="*"
				mode="ServiceSemanticId" />
			<xsl:call-template name="ServiceName" />
			<xsl:call-template name="ServiceAcronym" />
			<xsl:apply-templates select="*"
				mode="service_field" />
			<xsl:apply-templates select="."
				mode="service_periodical_field" />
			<xsl:apply-templates select="."
				mode="service_oaipmh_field" />
			<xsl:apply-templates select="."
				mode="service_repository_field" />

		</xsl:element>

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

	<xsl:template name="ServiceName">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'Service.name'" />
			<xsl:with-param name="node" select="$name" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ServiceAcronym">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.alternateName'" />
			<xsl:with-param name="node" select="$networkAcronym" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/type"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.serviceType'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/url" mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'Service.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/email"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.email'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/country"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.areaServed'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/description_pt"
		mode="service_field">
		<xsl:call-template name="field_lang">
			<xsl:with-param name="name"
				select="'Service.description'" />
			<xsl:with-param name="lang" select="'pt'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/description_en"
		mode="service_field">
		<xsl:call-template name="field_lang">
			<xsl:with-param name="name"
				select="'Service.description'" />
			<xsl:with-param name="lang" select="'en'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/tags"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Service.category'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes/directoryURL"
		mode="service_field">
		<xsl:element name="field">
			<xsl:attribute name="name">
            <xsl:text>RCAAP.directory</xsl:text>
        </xsl:attribute>
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'Thing.url'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>


	<xsl:template match="/attributes"
		mode="service_periodical_field">
		<xsl:element name="field">
			<xsl:attribute name="name">
            <xsl:text>RCAAP.periodical</xsl:text>
        </xsl:attribute>

			<xsl:apply-templates select="*"
				mode="service_periodical_subfield" />
			<!-- <field name="CreativeWorkSeries.issn" -->
		</xsl:element>
	</xsl:template>


	<xsl:template match="/attributes/doiPrefix"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'RCAAP.doiPrefix'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/pissn"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.identifier.pissn'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/eissn"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.identifier.eissn'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/issnL"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.identifier.issnL'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/sherpa"
		mode="service_periodical_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.sherpa.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes"
		mode="service_oaipmh_field">
		<xsl:element name="field">
			<xsl:attribute name="name">
            <xsl:text>RCAAP.oaipmh</xsl:text>
        </xsl:attribute>
			<xsl:apply-templates select="*"
				mode="service_oaipmh_subfield" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/attributes/oaiURL"
		mode="service_oaipmh_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'Thing.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/software"
		mode="service_oaipmh_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'SoftwareApplication.applicationCategory'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes"
		mode="service_repository_field">
		<xsl:element name="field">
			<xsl:attribute name="name">
            <xsl:text>RCAAP.repository</xsl:text>
        </xsl:attribute>
			<xsl:apply-templates select="*"
				mode="service_repository_subfield" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/attributes/handlePrefix"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.handlePrefix'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/openDoar"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.openDoar.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/roarMap"
		mode="service_repository_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.roarMap.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes/degois"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'degois'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/cienciaVitae"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'cienciaVitae'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/cienciaId"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'cienciaId'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/openAIRE"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'openAIRE'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/openAIRE4"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'openAIRE4'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/driver"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'driver'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/fct" mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'fct'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/thesis"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'thesis'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/fulltext"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node" select="'fulltext'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/accessibleContent"
		mode="service_field">
		<xsl:if test=".= true()">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'RCAAP.additionalCategories'" />
				<xsl:with-param name="node"
					select="'accessibleContent'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/internalNotes"
		mode="service_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'RCAAP.description'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>



	<xsl:template match="/attributes" mode="Organization">
		<xsl:element name="entity">
			<xsl:attribute name="type">
            <xsl:text>Organization</xsl:text>
        </xsl:attribute>
			<xsl:attribute name="ref">
            <xsl:value-of select="'Organization1'" />
        </xsl:attribute>
			<xsl:apply-templates select="*"
				mode="OrganizationSemanticId" />
			<xsl:call-template name="institutionName" />
			<xsl:call-template name="institutionAcronym" />
			<xsl:apply-templates select="*"
				mode="organization_field" />
			<xsl:apply-templates select="."
				mode="organization_contactPoint_field" />
		</xsl:element>
	</xsl:template>

	<xsl:template name="institutionName">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.legalName'" />
			<xsl:with-param name="node" select="$institutionName" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="institutionAcronym">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.alternateName'" />
			<xsl:with-param name="node"
				select="$institutionAcronym" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/institutionURL"
		mode="OrganizationSemanticId">
		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/ringold"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ringgold"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/isni"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:isni:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ror"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ror:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/grid"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:grid:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/wikidata"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:wikidata:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/nipc"
		mode="OrganizationSemanticId">
		<xsl:if test="text()!=''">
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:nipc:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/email"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.email'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/ringold"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.identifier.ringgold'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/ringgold"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.identifier.ringgold'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/isni"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.identifier.isni'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/ror"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.identifier.ror'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/institutionURL"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.url'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/grid"
		mode="organization_field">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier'" />
				<xsl:with-param name="node"
					select="concat('urn:grid:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/wikidata"
		mode="organization_field">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier'" />
				<xsl:with-param name="node"
					select="concat('urn:wikidata:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/nipc"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.taxID'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes"
		mode="organization_contactPoint_field">
		<xsl:element name="field">
			<xsl:attribute name="name">
            <xsl:text>Organization.contactPoint</xsl:text>
        </xsl:attribute>
			<xsl:apply-templates select="*"
				mode="service_contactPoint_subfield" />

		</xsl:element>
	</xsl:template>


	<xsl:template match="/attributes/responsibleName"
		mode="service_contactPoint_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.contactPoint.name'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/phone"
		mode="service_contactPoint_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.contactPoint.telephone'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>



	<!-- ////////////////////////////////////////////////////////////// -->

	<!-- Relation Service.provider -->
	<xsl:template match="/attributes" mode="Relation">
		<xsl:element name="relation">
			<xsl:attribute name="type">
                        <xsl:text>Service.provider</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="fromEntityRef">
                <xsl:text>Service1</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="toEntityRef">				
				<xsl:text>Organization1</xsl:text>
            </xsl:attribute>

			<xsl:element name="attributes">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'Organization.legalName'" />
					<xsl:with-param name="node"
						select="$institutionName" />
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>


	<!-- field template -->
	<xsl:template name="field">
		<xsl:param name="name" />
		<xsl:param name="node" />
		<xsl:if test="$node">
			<xsl:element name="field">
				<xsl:attribute name="name">
                    <xsl:value-of select="$name" />
                </xsl:attribute>
				<xsl:attribute name="value">
                    <xsl:value-of select="$node" />
                </xsl:attribute>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="field_lang">
		<xsl:param name="name" />
		<xsl:param name="node" />
		<xsl:param name="lang" />
		<xsl:if test="$node">
			<xsl:element name="field">
				<xsl:attribute name="name">
                    <xsl:value-of select="$name" />
                </xsl:attribute>
				<xsl:if test="$lang">
					<xsl:attribute name="lang">
                        <xsl:value-of select="$lang" />
                    </xsl:attribute>
				</xsl:if>
				<xsl:attribute name="value">
                    <xsl:value-of select="$node" />
                </xsl:attribute>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- semantic identifier template -->
	<xsl:template name="semanticIdentifier">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="semanticIdentifier">
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- ignore all non specified text values or attributes -->
	<xsl:template match="node()" mode="Service" />
	<xsl:template match="node()" mode="Organization" />
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