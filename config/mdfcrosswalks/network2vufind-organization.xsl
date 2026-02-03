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

	<xsl:param name="name" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />

    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="nameFrom"
        select="' ;,.:+?!\/*#@£$€àèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðøÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="nameTo"
        select="'________________aeiouaeiouyaeiouanoaeiouyaaodo0AEIOUAEIOUYAEIOUANOAEIOUYAAOCD0'"/>

	<xsl:template match="/">
			<!-- general provenance - for all entities -->
			<xsl:apply-templates select="/attributes"
				mode="OrganizationAttributes" />
	</xsl:template>


	<!-- Entity: Organization -->
	<xsl:template match="/attributes" mode="OrganizationAttributes">
		<xsl:element name="doc">
			<xsl:call-template name="identifier">
				<xsl:with-param name="node" select="$networkAcronym"/>
				<xsl:with-param name="position" select="'1'"/>
			</xsl:call-template>
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="$identifier" />
			</xsl:call-template>
			<xsl:call-template name="field">
				<xsl:with-param name="name" select="'institution'" />
				<xsl:with-param name="node" select="$institutionName" />
			</xsl:call-template>

			<xsl:call-template name="ServiceAcronym" />
			
			<xsl:apply-templates select="*"
				mode="identifier" />
			<xsl:apply-templates select="*"
				mode="organization" />
			<xsl:call-template name="institutionName" />
			<xsl:call-template name="institutionAcronym" />
			<xsl:apply-templates select="*"
				mode="organization_field" />
			<xsl:apply-templates select="."
				mode="organization_contactPoint_field" />

		</xsl:element>

	</xsl:template>

    <xsl:template name="identifier">
		<xsl:param name="node" />
		<xsl:param name="position" />

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'id'" />
			<xsl:with-param name="node">
                <xsl:value-of
                    select="translate(translate(normalize-space($node), $nameFrom, $nameTo), $uppercase, $smallcase)"/>
				<xsl:text>#__organization__</xsl:text>
				<xsl:value-of select="$position"/>
			</xsl:with-param>
		</xsl:call-template>

    </xsl:template>

	<xsl:template name="ServiceAcronym">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'service_str_mv'" />
			<xsl:with-param name="node" select="concat('urn:repositoryAcronym:',lower-case($networkAcronym))" />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes/country"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.areaServed_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="institutionName">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title'" />
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
		mode="identifier">

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.url_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>

		<xsl:call-template name="semanticIdentifier">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>

		<xsl:call-template name="organization">
			<xsl:with-param name="value" select="text()" />
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/attributes/isni"
		mode="identifier">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier.isni_str_mv'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:isni:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:isni:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ror"
		mode="identifier">
		<xsl:if test="text()!=''">

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier.ror_str_mv'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ror:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ror:',text())" />
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/grid"
		mode="identifier">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier'" />
				<xsl:with-param name="node"
					select="concat('urn:grid:',text())" />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:grid:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:grid:',text())" />
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/wikidata"
		mode="identifier">
		<xsl:if test="text()!=''">

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier'" />
				<xsl:with-param name="node"
					select="concat('urn:wikidata:',text())" />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:wikidata:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:wikidata:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/nipc"
		mode="identifier">
		<xsl:if test="text()!=''">

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.taxID'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:nipc:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:nipc:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template match="/attributes/ringold"
		mode="identifier">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier.ringgold_str_mv'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ringgold:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/attributes/ringgold"
		mode="identifier">
		<xsl:if test="text()!=''">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'Organization.identifier.ringgold_str_mv'" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>

			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value"
					select="concat('urn:ringgold:',text())" />
			</xsl:call-template>

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:ringgold:',text())" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template match="/attributes"
		mode="organization_contactPoint_field">
		<xsl:apply-templates select="*"
			mode="service_contactPoint_subfield" />
	</xsl:template>

	<xsl:template match="/attributes/email"
		mode="organization_field">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.email_str_mv'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/attributes/responsibleName"
		mode="service_contactPoint_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.contactPoint.name_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/attributes/phone"
		mode="service_contactPoint_subfield">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'Organization.contactPoint.telephone_str'" />
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
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


	<!-- organization template -->
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

	<!-- service template -->
	<xsl:template name="service">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:text>service_str_mv</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- ignore all non specified text values or attributes -->
	<xsl:template match="node()" mode="Service" />
	<xsl:template match="node()" mode="OrganizationAttributes" />
	<xsl:template match="node()" mode="Relation" />

	<xsl:template match="text() | @*" />
	<xsl:template match="text() | @*" mode="ServiceSemanticId" />
    <xsl:template match="text() | @*" mode="organization"/>
    <xsl:template match="text() | @*" mode="service"/>
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