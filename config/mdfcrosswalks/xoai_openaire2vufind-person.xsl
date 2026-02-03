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
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" encoding="utf-8" />


    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="nameFrom"
        select="' ;,.:+?!\/*#@£$€àèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðøÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="nameTo"
        select="'________________aeiouaeiouyaeiouanoaeiouyaaodo0AEIOUAEIOUYAEIOUANOAEIOUYAAOCD0'"/>


	<!-- Aquí van los listados para diferenciar type en tipo de documento y status -->


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


	<xsl:variable name="maxStringLength" select="number(30000)"/>
	
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	<xsl:param name="institutionAcronym" />
	

	<xsl:param name="fingerprint" />
	<xsl:param name="identifier" />
	<xsl:param name="record_id" />
	<xsl:param name="fulltext" />

	<!-- Params from Networks -->
	<!-- They have the prefix: "attr_"  -->
	<xsl:param name="attr_repository_id" />
	<xsl:param name="attr_country"/>  
	<!-- / -->

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']" mode="datacite"/>
	</xsl:template>

    <xsl:template match="/doc:metadata/doc:element[@name='datacite']" mode="datacite">
        <xsl:apply-templates select="doc:element[@name='creators']" mode="datacite"/>
        <xsl:apply-templates select="doc:element[@name='contributors']" mode="datacite"/>
    </xsl:template>

	<xsl:template match="doc:element[@name='creators']" mode="datacite">
		<xsl:for-each select="doc:element[@name='creator']">
			<xsl:if test="(not(doc:element[@name='creatorName']/doc:field[@name='nameType'])) 
							or (doc:element[@name='creatorName']/doc:field[@name='nameType' and text()!='Organizational'])">
				<xsl:element name="doc">
					<xsl:call-template name="identifier">
						<xsl:with-param name="node" select="."/>
						<xsl:with-param name="position" select="position()"/>
					</xsl:call-template>
					<xsl:apply-templates
							select="."
							mode="datacite"/>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<!-- datacite.creators.creator -->
    <xsl:template match="doc:element[@name='creators']/doc:element[@name='creator'][1]" mode="datacite">

			<xsl:call-template name="settings"/>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'title'" />
				<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.creators.creator.creatorName.fl_str_mv'" />
				<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.creator.none.fl_str_mv'" />
				<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
			</xsl:call-template>

			<!-- other fields -->
			<xsl:apply-templates select="*" mode="datacite"/>

			<!-- semanticIdentifier -->
			<xsl:apply-templates select="*" mode="semanticId"/>
			
			<!-- search all person field -->
			<xsl:apply-templates select="*" mode="person"/>
    </xsl:template>

	<!-- datacite.creators.creator -->
    <xsl:template match="doc:element[@name='creators']/doc:element[@name='creator'][position()>1]" mode="datacite">

		<xsl:call-template name="settings"/>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.creators.creator.creatorName.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.creator.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:apply-templates select="*" mode="datacite"/>

		<!-- semanticIdentifier -->
		<xsl:apply-templates select="*" mode="semanticId"/>

		<!-- search all person field -->
		<xsl:apply-templates select="*" mode="person"/>

    </xsl:template>

	<xsl:template match="doc:element[@name='contributors']" mode="datacite">
		<xsl:for-each select="doc:element[@name='contributor']">
			<xsl:if test="(not(doc:element[@name='contributorName']/doc:field[@name='nameType'])) 
						or (doc:element[@name='contributorName']/doc:field[@name='nameType' and text()!='Organizational'])">
				<xsl:element name="doc">
					<xsl:call-template name="identifier">
						<xsl:with-param name="node" select="."/>
						<xsl:with-param name="position" select="position()"/>
					</xsl:call-template>
					<xsl:apply-templates
							select="."
							mode="datacite"/>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

  <!-- datacite.contributors.contributor -->
    <xsl:template match="doc:element[@name='contributors']/doc:element[@name='contributor']"
        mode="datacite">

		<xsl:call-template name="settings"/>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.contributors.contributor.contributorName.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>


		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.contributor.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<!-- TODO: address advisor1' or @name='advisor2' or @name='advisor-co1' or @name='advisor-co2' or @name='referee1' or @name='referee2' or @name='referee3'or @name='referee4'or @name='referee5' -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'contributor_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:apply-templates select="*" mode="datacite"/>

		<!-- semanticIdentifier -->
		<xsl:apply-templates select="*" mode="semanticId"/>

		<!-- search all person field -->
		<xsl:apply-templates select="*" mode="person"/>

    </xsl:template>

	<xsl:template match="doc:element[@name='nameIdentifier']" mode="datacite">
		<xsl:apply-templates select="*" mode="datacite"/>
	</xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='http://orcid.org']/doc:field[@name='value']"
        mode="datacite">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'orcid.fl_str_mv'" />
			<xsl:with-param name="node" select="normalize-space(text())" />
		</xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='https://www.ciencia-id.pt']/doc:field[@name='value']"
        mode="datacite">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'cienciaID.fl_str_mv'" />
			<xsl:with-param name="node" select="normalize-space(text())" />
		</xsl:call-template>
    </xsl:template>


<!-- semanticID -->
	<xsl:template match="doc:element[@name='nameIdentifier']" mode="semanticId">
		<xsl:apply-templates select="*" mode="semanticId"/>
	</xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='nameIdentifierScheme' and ./doc:field/text()='isni']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="concat('',text())"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='http://orcid.org']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="concat('http://orcid.org/',text())"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='https://www.ciencia-id.pt']/doc:field[@name='value']"
        mode="semanticId">
        <xsl:call-template name="semanticIdentifier">
            <xsl:with-param name="value" select="concat('https://www.ciencia-id.pt/',text())"/>
        </xsl:call-template>
    </xsl:template>

<!-- Person -->
    <xsl:template
        match="doc:element[@name='creatorName' and ./doc:field/@name='value']"
        mode="person">

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="substring(normalize-space(./doc:field[@name='value']),1,$maxStringLength)" />
        </xsl:call-template>

    </xsl:template>

    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='http://orcid.org']/doc:field[@name='value']"
        mode="person">

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="concat('http://orcid.org/',text())" />
        </xsl:call-template>

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="normalize-space(text())" />
        </xsl:call-template>
    </xsl:template>


    <xsl:template
        match="doc:element[@name='nameIdentifier' and ./doc:field/@name='schemeURI' and ./doc:field/text()='https://www.ciencia-id.pt']/doc:field[@name='value']"
        mode="person">

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="concat('https://www.ciencia-id.pt/',text())" />
        </xsl:call-template>

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="normalize-space(text())" />
        </xsl:call-template>

    </xsl:template>


    <xsl:template name="identifier">
		<xsl:param name="node" />
		<xsl:param name="position" />

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'id'" />
			<xsl:with-param name="node">
                <xsl:value-of
                    select="translate(translate(normalize-space(//doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']/text()), $nameFrom, $nameTo), $uppercase, $smallcase)"/>

			<xsl:choose>
				<xsl:when test="$node/@name = 'creator'">
					<xsl:text>#__creator__</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>#__contributor__</xsl:text>
				  </xsl:otherwise>
				</xsl:choose>
                <xsl:value-of select="$position"/>
			</xsl:with-param>
		</xsl:call-template>

    </xsl:template>



	<!-- global settings template -->
	<xsl:template name="settings">
		<!-- ID es parámetro -->
		<!--
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'id'" />
			<xsl:with-param name="node" select="$fingerprint" />
		</xsl:call-template>
		-->

			<!-- ID es parámetro -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'oai_identifier_str'" />
			<xsl:with-param name="node" select="$identifier" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'network_acronym_str'" />
			<xsl:with-param name="node" select="$networkAcronym" />
		</xsl:call-template>

			<!-- networkName es parámetro -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'network_name_str'" />
			<xsl:with-param name="node" select="$networkName" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'repository_id_str'" />
			<xsl:with-param name="node" select="concat('urn:repositoryAcronym:',lower-case($networkAcronym))" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'reponame_str'" />
			<xsl:with-param name="node" select="normalize-space($networkName)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'instacron_str'" />
			<xsl:with-param name="node" select="normalize-space($institutionAcronym)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'institution'" />
			<xsl:with-param name="node" select="normalize-space($institutionName)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'instname_str'" />
			<xsl:with-param name="node" select="normalize-space($institutionName)" />
		</xsl:call-template>


			<xsl:if test="$attr_country and ($attr_country != '')">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'country_str'" />
					<xsl:with-param name="node" select="normalize-space($attr_country)" />
				</xsl:call-template>
			</xsl:if>

			<!-- ALLFIELDS -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'allfields'" />
			<xsl:with-param name="node" select="normalize-space()" />
		</xsl:call-template>


			 <!-- FULLTEXT -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'fulltext'" />
			<xsl:with-param name="node" select="normalize-space($fulltext)" />
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

	<!-- semantic identifier template -->
	<xsl:template name="person">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:text>person_str_mv</xsl:text>
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

	<xsl:template match="node()" mode="Person"/>
	<xsl:template match="doc:element[@name='titles']" mode="datacite"/>
	<xsl:template match="doc:element[@name='relatedIdentifiers']" mode="datacite"/>
	<xsl:template match="doc:element[@name='dates']" mode="datacite"/>
	<xsl:template match="doc:element[@name='identifier']" mode="datacite"/>
	<xsl:template match="doc:element[@name='rights']" mode="datacite"/>
	<xsl:template match="doc:element[@name='subjects']" mode="datacite"/>
	<xsl:template match="doc:element[@name='sizes']" mode="datacite"/>
	<xsl:template match="text() | @*" mode="identifier"/>
	<xsl:template match="text() | @*" mode="semanticId"/>
	<xsl:template match="text() | @*" mode="person"/>
	<xsl:template match="*" mode="openaire"/>
	<xsl:template match="*" mode="datacite"/>
	<xsl:template match="*" mode="dc"/>
	<xsl:template match="*" mode="oaire"/>
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>
