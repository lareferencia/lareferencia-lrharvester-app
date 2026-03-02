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


	<!-- xsl:variable name="type_list" select="tokenize('info:eu-repo/semantics/article,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/report,info:eu-repo/semantics/dataSet',',')"/-->

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

	<xsl:variable name="type_list" select="tokenize('info:eu-repo/semantics/article,info:eu-repo/semantics/bachelorThesis,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/review,info:eu-repo/semantics/conferenceObject,info:eu-repo/semantics/lecture,info:eu-repo/semantics/workingPaper,info:eu-repo/semantics/preprint,info:eu-repo/semantics/report,info:eu-repo/semantics/annotation,info:eu-repo/semantics/contributionToPeriodical,info:eu-repo/semantics/patent,info:eu-repo/semantics/other,info:eu-repo/semantics/dataset',',')"/>
	<xsl:variable name="status_list" select="tokenize('info:eu-repo/semantics/draft,info:eu-repo/semantics/acceptedVersion,info:eu-repo/semantics/submittedVersion,info:eu-repo/semantics/publishedVersion,info:eu-repo/semantics/updatedVersion',',')"/>
	<xsl:variable name="rights_list" select="tokenize('info:eu-repo/semantics/openAccess,info:eu-repo/semantics/embargoedAccess,info:eu-repo/semantics/restrictedAccess,info:eu-repo/semantics/closedAccess', ',')"/>


	<!--  Aquí se definen los prefijos utilizados para detectar contenidos con trato diferencial -->
	<xsl:variable name="driver_prefix">info:eu-repo/semantics/</xsl:variable>
	<xsl:variable name="reponame_prefix">reponame:</xsl:variable>
	<xsl:variable name="instname_prefix">instname:</xsl:variable>
	<xsl:variable name="instacron_prefix">instacron:</xsl:variable>

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
		<xsl:for-each select="/doc:metadata/doc:element[@name='oaire']/doc:element[@name='fundingReferences']/doc:element[@name='fundingReference']">
			<xsl:element name="doc">
				<xsl:call-template name="identifier">
					<xsl:with-param name="fundingReference" select="."/>
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
				<xsl:apply-templates
						select="."
						mode="oaire"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>



    <xsl:template match="doc:element[@name='fundingReference']" mode="oaire">
			<xsl:variable name="semanticId">
				<xsl:call-template name="generateFundingSemanticId">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:call-template name="settings"/>

			<!-- Identifier -->
			<!--xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'id'" />
				<xsl:with-param name="node"
					select="$fingerprint" />
			</xsl:call-template-->

			<!-- semanticIdentifier -->
			<xsl:call-template name="semanticIdentifier">
				<xsl:with-param name="value" select="$semanticId"/>
			</xsl:call-template>
			<xsl:apply-templates select="*" mode="Funding"/>
			<xsl:apply-templates select="doc:element" mode="Award"/>
			<xsl:apply-templates select="*" mode="Funder"/>

    </xsl:template>

    <xsl:template name="identifier">
		<xsl:param name="fundingReference" />
		<xsl:param name="position" />
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'id'" />
			<xsl:with-param name="node">
                <xsl:value-of
                    select="translate(translate(normalize-space(//doc:element[@name='datacite']/doc:element[@name='identifier']/doc:field[@name='value']/text()), $nameFrom, $nameTo), $uppercase, $smallcase)"/>
                <xsl:text>#__funding__</xsl:text>
                <xsl:value-of select="$position"/>
			</xsl:with-param>
		</xsl:call-template>

    </xsl:template>

    <xsl:template match="doc:element[@name='fundingStream']" mode="Funding">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'Funding.name_str_mv'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- award -->
    <xsl:template match="doc:element[@name='awardNumber']" mode="Award">
        <xsl:apply-templates select="doc:field" mode="Award"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='awardNumber']/doc:field[@name='value']" mode="Award">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'ResearchProject.award.identifier_str_mv'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="doc:element[@name='awardNumber']/doc:field[@name='awardURI']" mode="Award">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'ResearchProject.award.url_str_mv'"/>
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


	<xsl:template match="doc:element[@name='awardTitle']" mode="Award">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'title'"/>
			<xsl:with-param name="node" select="."/>
		</xsl:call-template>
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'ResearchProject.award.name_str_mv'"/>
			<xsl:with-param name="node" select="."/>
		</xsl:call-template>
	</xsl:template>

	<!-- funder -->
	<xsl:template match="doc:element[@name='funderName']" mode="Funder">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'MonetaryGrant.funder.name_str_mv'"/>
			<xsl:with-param name="node" select="normalize-space(doc:field[@name='value'])"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="doc:element[@name='funderIdentifier']" mode="Funder">
		<xsl:call-template name="field">
			<xsl:with-param name="name" select="'MonetaryGrant.funder.identifier_str_mv'"/>
			<xsl:with-param name="node" select="normalize-space(doc:field[@name='value'])"/>
		</xsl:call-template>
		<xsl:call-template name="organization">
				<xsl:with-param name="value" select="normalize-space(doc:field[@name='value'])" />
			</xsl:call-template>
	</xsl:template>

	<!-- global settings template -->
	<xsl:template name="settings">

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
			<xsl:with-param name="node" select="$attr_repository_id" />
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

    <xsl:template name="generateFundingSemanticId">
        <xsl:param name="node"/>
        <xsl:value-of
            select="concat(
                    substring-after(
                        $node/doc:element[@name='funderIdentifier']/doc:field[@name='value' and contains(text(),'http://doi.org/')]/text()
                        , 'http://doi.org/')
                     ,'/', $node/doc:element[@name='fundingStream']/doc:field[@name='value']/text()
                     ,'/',$node/doc:element[@name='awardNumber']/doc:field[@name='value']/text()
                     )"/>
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

	<xsl:template match="text() | @*" mode="identifier"/>
	<xsl:template match="text() | @*" mode="semanticId"/>
	<xsl:template match="*" mode="Funding"/>
	<xsl:template match="*" mode="Funder"/>
	<xsl:template match="*" mode="Award"/>
	<xsl:template match="*" mode="openaire"/>
	<xsl:template match="*" mode="datacite"/>
	<xsl:template match="*" mode="dc"/>
	<xsl:template match="*" mode="oaire"/>
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>
