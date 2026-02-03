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


	<!-- Aquí van los listados para diferenciar type en tipo de documento y status -->


	<!-- xsl:variable name="type_list" select="tokenize('info:eu-repo/semantics/article,info:eu-repo/semantics/masterThesis,info:eu-repo/semantics/doctoralThesis,info:eu-repo/semantics/book,info:eu-repo/semantics/bookPart,info:eu-repo/semantics/report,info:eu-repo/semantics/dataSet',',')"/-->


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
		<doc>

			 <!-- ID es parámetro -->
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'id'" />
				<xsl:with-param name="node" select="$fingerprint" />
			</xsl:call-template>

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

			<xsl:call-template name="service">
				<xsl:with-param name="value" select="concat('urn:repositoryAcronym:',lower-case($networkAcronym))" />
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

			<xsl:call-template name="organization">
				<xsl:with-param name="value" select="concat('urn:organizationAcronym:',lower-case($institutionAcronym))" />
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


            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dc']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='datacite']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='oaire']"/>
            <xsl:apply-templates select="/doc:metadata/doc:element[@name='dcterms']"/>

		</doc>
	</xsl:template>


	<xsl:template match="/doc:metadata/doc:element[@name='datacite']">
		<xsl:apply-templates select="*" mode="datacite"/>
	</xsl:template>

	<!-- datacite.titles.title -->
	<xsl:template match="doc:element[@name='titles']/doc:element[@name='title'][1]" mode="datacite">

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.titles.title.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.title.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title_short'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title_full'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'title_sort'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="doc:element[@name='titles']/doc:element[@name='title'][position()>1]" mode="datacite">	
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.titles.title.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.title.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>
	</xsl:template>

	<!-- datacite.creators.creator -->
	<xsl:template match="doc:element[@name='creators']/doc:element[@name='creator'][1]" mode="datacite">
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

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'author'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'author_role'" />
			<xsl:with-param name="node" select="'author'" />
		</xsl:call-template>

		<!-- search all person field -->
		<xsl:apply-templates select="*" mode="person"/>

	</xsl:template>

	<!-- datacite.creators.creator -->
	<xsl:template match="doc:element[@name='creators']/doc:element[@name='creator'][position()>1]" mode="datacite">
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

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'author2'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='creatorName']/doc:field[@name='value']),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'author2_role'" />
			<xsl:with-param name="node" select="'author'" />
		</xsl:call-template>

		<!-- search all person field -->
		<xsl:apply-templates select="*" mode="person"/>

	</xsl:template>

  <!-- datacite.contributors.contributor -->
    <xsl:template match="doc:element[@name='contributors']/doc:element[@name='contributor']"
        mode="datacite">
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

		<!--
			<field name="author"><xsl:value-of select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']),1,$maxStringLength)"/></field>
			<field name="author_role">author</field>
		-->
		
		<xsl:if test="doc:field[@name='contributorType' and text()!='HostingInstitution']">
			<xsl:call-template name="field">
				<xsl:with-param name="name">
					<xsl:if test="not(doc:field[@name='contributorType'])">
						<xsl:text>contributor</xsl:text>
					</xsl:if>
					<xsl:apply-templates select="doc:field[@name='contributorType']" mode="datacite_contributorType"/>
				</xsl:with-param>
				<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']),1,$maxStringLength)" />
			</xsl:call-template>

			<!-- search all person field -->
			<xsl:apply-templates select="*" mode="person"/>

		</xsl:if>
		
		<!-- TODO: address advisor1' or @name='advisor2' or @name='advisor-co1' or @name='advisor-co2' or @name='referee1' or @name='referee2' or @name='referee3'or @name='referee4'or @name='referee5' -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'contributor_name_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:element[@name='contributorName']/doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>
		<!-- TODO: address contributor type service -->
    </xsl:template>

    <xsl:template match="doc:element[@name='contributor']/doc:field[@name='contributorType']"
        mode="datacite_contributorType">
        <xsl:choose>
            <xsl:when test="text()='Supervisor'">
                <xsl:text>contributor.advisor.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='Editor'">
                <xsl:text>contributor.editor.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='HostingInstitution'">
                <xsl:text>contributor.other.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>contributor.other.fl_str_mv</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  


    <xsl:template match="doc:element[@name='contributor']/doc:field[@name='contributorType' and text()='HostingInstitution']"
        mode="datacite">
			<!-- dc.source reponame -->
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'reponame_str'" />
				<xsl:with-param name="node" select="normalize-space(../doc:element[@name='contributorName']/doc:field[@name='value']/text())" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'repository.name.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(../doc:element[@name='contributorName']/doc:field[@name='value']/text())" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'collection'" />
				<xsl:with-param name="node" select="normalize-space(../doc:element[@name='contributorName']/doc:field[@name='value']/text())" />
			</xsl:call-template>

			<xsl:if test="../doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='e-mail']">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'repository.mail.fl_str_mv'" />
					<xsl:with-param name="node" select="../doc:element[@name='nameIdentifier']/doc:field[@name='nameIdentifierScheme' and text()='e-mail']/../doc:field[@name='nameIdentifier']/text()" />
				</xsl:call-template>
			</xsl:if>
    </xsl:template>	


<!-- Person -->
    <xsl:template
        match="doc:element[@name='creatorName']/doc:field[(not(@name='nameType')) or (@name='nameType' and text()!='Organizational')]"
        mode="person">

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="substring(normalize-space(../doc:field[@name='value']),1,$maxStringLength)" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='contributorName']/doc:field[(not(@name='nameType')) or (@name='nameType' and text()!='Organizational')]"
        mode="person">

        <xsl:call-template name="person">
            <xsl:with-param name="value" select="substring(normalize-space(../doc:field[@name='value']),1,$maxStringLength)" />
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

<!-- Organization -->

<!-- Service -->




      <!-- dc.subject -->
    <xsl:template match="doc:element[@name='subjects']/doc:element[@name='subject']" mode="datacite">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.subjects.subject.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(doc:field[@name='value']/text(),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.subject.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name">
				<xsl:if test="not(doc:field[@name='subjectScheme'])">
					<xsl:text>subject.fl_str_mv</xsl:text>
				</xsl:if>
				<xsl:apply-templates select="doc:field[@name='subjectScheme']" mode="datacite_subjectScheme"/>
			</xsl:with-param>
			<xsl:with-param name="node" select="normalize-space(doc:field[@name='value']/text())" />
		</xsl:call-template>

		<xsl:if test="string-length(substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)) > 0">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'topic'" />
				<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
			</xsl:call-template>
		</xsl:if>

    </xsl:template>


    <xsl:template match="doc:element[@name='subject']/doc:field[@name='subjectScheme']"
        mode="datacite_subjectScheme">
        <xsl:choose>
            <xsl:when test="text()='DDC'">
                <xsl:text>subject.ddc.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='FOS'">
                <xsl:text>subject.fos.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='MESH'">
                <xsl:text>subject.mesh.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='OCLC'">
                <xsl:text>subject.lcc.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='UDC'">
                <xsl:text>subject.udc.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>subject.other.fl_str_mv</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


  <!-- dc.rights -->
  <!-- PG: only consider one first entry -->
    <xsl:template match="doc:element[@name='rights'][1]" mode="datacite">
		<!-- normalize rights -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'eu_rights_str_mv'" />
			<xsl:with-param name="node">
				<xsl:apply-templates select="doc:field[@name='value']/text()"
                mode="datacite_rightsvalue"/>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.rights.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='rightsURI']/text()),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'datacite.rights.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='rightsURI']/text()),1,$maxStringLength)" />
		</xsl:call-template>

    </xsl:template>



    <xsl:template match="doc:element[@name='rights'][1]/doc:field[@name='value']/text()"
        mode="datacite_rightsvalue">
        <xsl:choose>
            <xsl:when test=".='open access'">
                <xsl:text>openAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='restricted access'">
                <xsl:text>restrictedAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='embargoed access'">
                <xsl:text>embargoedAccess</xsl:text>
            </xsl:when>
            <xsl:when test=".='metadata only access'">
                <xsl:text>metadataOnlyAccess</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>  
  <!--
  info:eu-repo/semantics/openAccess
  info:eu-repo/semantics/embargoedAccess
  info:eu-repo/semantics/restrictedAccess
  info:eu-repo/semantics/closedAccess
  info:eu-repo/semantics/RestrictAccess  
  -->
    </xsl:template>  

    <xsl:template match="doc:element[@name='licenseCondition']" mode="oaire">

        <xsl:if test="contains(doc:field[@name='uri']/text(), 'creativecommons.org')">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.rights.cclincense.fl_str_mv'" />
				<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='uri']/text()),1,$maxStringLength)" />
			</xsl:call-template>
        </xsl:if>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.rights.rights.copyright.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>

    </xsl:template>

	<!-- datacite.date.issued -->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Issued']" mode="datacite">
        <xsl:for-each select="tokenize(normalize-space(doc:field[@name='value']/text()),'-')">
                    <!-- to only consider the year in this date -->
            <xsl:if test="matches(.,'[0-9]{4}')">

				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'publishDate'" />
					<xsl:with-param name="node" select="substring(., 1, 4)" />
				</xsl:call-template>

				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'publishDateSort'" />
					<xsl:with-param name="node" select="substring(., 1, 4)" />
				</xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

	<!-- datacite.date.available -->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Available']/doc:field[@name='value']"
        mode="datacite">
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}(.\d)?Z$')">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.date.available.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(text())" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.date.available.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(text())" />
			</xsl:call-template>
        </xsl:if>
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}$')">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.date.available.fl_str_mv'" />
				<xsl:with-param name="node" select="concat(normalize-space(text()),'T00:00:00Z')" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.date.available.fl_str_mv'" />
				<xsl:with-param name="node" select="concat(normalize-space(text()),'T00:00:00Z')" />
			</xsl:call-template>

        </xsl:if>
    </xsl:template>


    <xsl:template match="doc:element[@name='date']/doc:element[@name='Accepted']/doc:field[@name='value']"
        mode="datacite">
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}(.\d)?Z$')">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.date.Accepted.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(text())" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.date.Accepted.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(text())" />
			</xsl:call-template>
        </xsl:if>
        <xsl:if test="matches(normalize-space(text()),'^\d{4}\-\d{2}\-\d{2}$')">
			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.date.Accepted.fl_str_mv'" />
				<xsl:with-param name="node" select="concat(normalize-space(text()),'T00:00:00Z')" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.date.Accepted.fl_str_mv'" />
				<xsl:with-param name="node" select="concat(normalize-space(text()),'T00:00:00Z')" />
			</xsl:call-template>
        </xsl:if>
        <!-- embargoed date -->
        <xsl:if
            test="normalize-space(text()) != normalize-space(../../doc:element[@name='Available']/doc:field[last()][@name='value']/text())">

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'dc.date.embargoed.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(../../doc:element[@name='Available']/doc:field[last()][@name='value']/text())" />
			</xsl:call-template>

			<xsl:call-template name="field">
				<xsl:with-param name="name"
					select="'datacite.date.embargoed.fl_str_mv'" />
				<xsl:with-param name="node" select="normalize-space(../../doc:element[@name='Available']/doc:field[last()][@name='value']/text())" />
			</xsl:call-template>

        </xsl:if>
    </xsl:template>

    <!-- don't to nothing with date of type submitted-->
    <xsl:template match="doc:element[@name='date']/doc:element[@name='Submitted']/doc:field[@name='value']"
        mode="datacite"/>  

    <!-- the model don't support sizes, don't to nothing -->
    <xsl:template match="doc:element[@name='sizes']/doc:element[@name='size']" mode="datacite"/>

	<!-- TODO -->
	<!-- relation -->      
	<!-- relation.publisherversion -->
	<!-- relation.uri -->

    <xsl:template match="/doc:metadata/doc:element[@name='dc']">
        <xsl:apply-templates select="*" mode="dc"/>
    </xsl:template>
  	<xsl:template match="doc:element" mode="dc">
		<xsl:apply-templates select="*" mode="dc"/>
	</xsl:template>

      <!-- dc.language -->
    <xsl:template match="doc:element[@name='language']/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.language.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(),1,$maxStringLength)" />
		</xsl:call-template>

		<!-- dc.language distinct vufind field -->
		<xsl:choose>
			<xsl:when test="string-length() = 3">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'language'" />
					<xsl:with-param name="node" select="normalize-space()" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'language_invalid_str_mv'" />
					<xsl:with-param name="node" select="substring(normalize-space(),1,$maxStringLength)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>


	<!-- dc.description -->
	<!-- TODO: address description language -->
    <xsl:template match="doc:element[@name='description'][1]/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'description'" />
			<xsl:with-param name="node" select="normalize-space(text())" />
		</xsl:call-template>
    </xsl:template>

    <xsl:template match="doc:element[@name='description'][position()>1]/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.description.none.fl_str_mv'" />
			<xsl:with-param name="node" select="normalize-space(text())" />
		</xsl:call-template>
    </xsl:template>
  
      <!-- dc.publisher -->
    <xsl:template match="doc:element[@name='publisher']/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.publisher.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>

		<!-- dc.publisher distinct vufind field  -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'publisher.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
    </xsl:template>        

      <!-- dc.format -->
    <xsl:template match="doc:element[@name='format']/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.format.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
    </xsl:template>

      <!-- dc.source -->
    <xsl:template match="doc:element[@name='source']/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.source.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
    </xsl:template>      


      <!-- dc.coverage -->
    <xsl:template match="doc:element[@name='coverage']/doc:field[@name='value']" mode="dc">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.coverage.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
    </xsl:template>

	<!-- dc.relation -->
	<!-- NOT SUPPORTED in OpenAIRE 4 schema -->
	<!--
    <xsl:template match="doc:element[@name='relation']/doc:field[@name='value']" mode="dc">
        <field name="dc.relation.none.fl_str_mv">
            <xsl:value-of select="substring(normalize-space(text()),1,$maxStringLength)"/>
        </field>
    </xsl:template>
	 -->


    <xsl:template match="/doc:metadata/doc:element[@name='oaire']">
        <xsl:apply-templates select="*" mode="oaire"/>
    </xsl:template>  

   <!-- resourceType -->
    <xsl:template match="doc:element[@name='resourceType']" mode="oaire">
		<!-- normalize types -->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'format'" />
			<xsl:with-param name="node">
				<xsl:apply-templates select="doc:field[@name='value']/text()" mode="oaire_typevalue"/> 
			</xsl:with-param>
		</xsl:call-template>

        <xsl:apply-templates select="doc:field[@name='uri']" mode="oaire"/>
    </xsl:template>

    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='value']/text()"
        mode="oaire_typevalue">
        <xsl:choose>
            <xsl:when test=".='journal article'">
			<!--journalArticle http://purl.org/coar/resource_type/c_6501-->
                <xsl:text>article</xsl:text>
            </xsl:when>
            <xsl:when test=".='book'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when test=".='book part'">
                <xsl:text>bookPart</xsl:text>
            </xsl:when>
            <xsl:when test=".='book part'">
                <xsl:text>journal</xsl:text>
            </xsl:when>
            <xsl:when test=".='interative resource'">
                <xsl:text>interativeResource</xsl:text>
            </xsl:when>
            <xsl:when test=".='website'">
                <xsl:text>website</xsl:text>
            </xsl:when>
            <xsl:when test=".='dataset'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test=".='image'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when test=".='moving image'">
                <xsl:text>movingImage</xsl:text>
            </xsl:when>
            <xsl:when test=".='video'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when test=".='still image'">
                <xsl:text>stillImage</xsl:text>
            </xsl:when>
            <xsl:when test=".='software'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test=".='workflow'">
                <xsl:text>workflow</xsl:text>
            </xsl:when>
            <xsl:when test=".='carthographic material'">
                <xsl:text>carthographicMaterial</xsl:text>
            </xsl:when>
            <xsl:when test=".='map'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when test=".='sound'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when test=".='musicalComposition'">
                <xsl:text>musical composition</xsl:text>
            </xsl:when>
            <xsl:when test=".='text'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when test=".='annotation'">
                <xsl:text>annotation</xsl:text>
            </xsl:when>
            <xsl:when test=".='bibliography'">
                <xsl:text>bibliography</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference object'">
                <xsl:text>conferenceObject</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference proceedings'">
                <xsl:text>conferenceProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference paper'">
                <xsl:text>conferencePaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference poster'">
                <xsl:text>conferencePoster</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference paper not in proceedings'">
                <xsl:text>conferencePaperNotInProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='conference poster not in proceedings'">
                <xsl:text>conferencePosterNotInProceedings</xsl:text>
            </xsl:when>
            <xsl:when test=".='lecture'">
                <xsl:text>lecture</xsl:text>
            </xsl:when>
            <xsl:when test=".='letter'">
                <xsl:text>letter</xsl:text>
            </xsl:when>
            <xsl:when test=".='periodical'">
                <xsl:text>periodical</xsl:text>
            </xsl:when>
            <xsl:when test=".='contribution to journal'">
                <xsl:text>contributionToPeriodical</xsl:text>
            </xsl:when>
            <xsl:when test=".='review article'">
                <xsl:text>reviewArticle</xsl:text>
            </xsl:when>
            <xsl:when test=".='research article'">
                <xsl:text>researchArticle</xsl:text>
            </xsl:when>
            <xsl:when test=".='editorial'">
                <xsl:text>editorial</xsl:text>
            </xsl:when>
            <xsl:when test=".='data paper'">
                <xsl:text>dataPaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='letter to the editor'">
                <xsl:text>letterToTheEditor</xsl:text>
            </xsl:when>
            <xsl:when test=".='patent'">
                <xsl:text>patent</xsl:text>
            </xsl:when>
            <xsl:when test=".='preprint'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when test=".='report'">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when test=".='report part'">
                <xsl:text>reportPart</xsl:text>
            </xsl:when>
            <xsl:when test=".='internal report'">
                <xsl:text>internalReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='memorandum'">
                <xsl:text>memorandum</xsl:text>
            </xsl:when>
            <xsl:when test=".='other type of report'">
                <xsl:text>otherTypeOfReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='policy report'">
                <xsl:text>policyReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='project deliverable'">
                <xsl:text>projectDeliverable</xsl:text>
            </xsl:when>
            <xsl:when test=".='report to funding agency'">
                <xsl:text>reportToFundingAgency</xsl:text>
            </xsl:when>
            <xsl:when test=".='research report'">
                <xsl:text>researchReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='technical report'">
                <xsl:text>technicalReport</xsl:text>
            </xsl:when>
            <xsl:when test=".='research proposal'">
                <xsl:text>researchProposal</xsl:text>
            </xsl:when>
            <xsl:when test=".='review'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when test=".='book review'">
                <xsl:text>bookReview</xsl:text>
            </xsl:when>
            <xsl:when test=".='technical documentation'">
                <xsl:text>technicalDocumentation</xsl:text>
            </xsl:when>
            <xsl:when test=".='working paper'">
                <xsl:text>workingPaper</xsl:text>
            </xsl:when>
            <xsl:when test=".='thesis'">
                <xsl:text>thesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='bachelor thesis'">
                <xsl:text>bachelorThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='doctoral thesis'">
                <xsl:text>doctoralThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='master thesis'">
                <xsl:text>masterThesis</xsl:text>
            </xsl:when>
            <xsl:when test=".='musical notation'">
                <xsl:text>musicalNotation</xsl:text>
            </xsl:when>
            <xsl:when test=".='pedagogical publication'">
                <xsl:text>pedagogicalPublication</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> 	

    <!-- dc.type -->
    <xsl:template match="doc:element[@name='resourceType']/doc:field[@name='uri']" mode="oaire">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.type.none.fl_str_mv'" />
			<xsl:with-param name="node" select="normalize-space(text())" />
		</xsl:call-template>
    </xsl:template>


    <xsl:template match="doc:element[@name='files']" mode="oaire">
	<!-- I can only have one full text -->
        <xsl:for-each select="doc:element[@name='file'][doc:field[@name='objectType']/text()='fulltext']">
            <xsl:if test="position() = 1">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'fulltext.url.fl_str_mv'" />
					<xsl:with-param name="node" select="normalize-space(doc:field[@name='value']/text())" />
				</xsl:call-template>
            </xsl:if>
        </xsl:for-each>
		<xsl:for-each select="doc:element[@name='file']">
			<xsl:apply-templates select="." mode="oaire"/>
		</xsl:for-each>
    </xsl:template>

	<xsl:template match="doc:element[@name='files']/doc:element[@name='file']/doc:field[@name='mimeType']" mode="oaire">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.format.bitstream.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="doc:element[@name='files']/doc:element[@name='file']/doc:field[@name='value']" mode="oaire">
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'bitstream.url.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(text()),1,$maxStringLength)" />
		</xsl:call-template>
	</xsl:template>

	<!-- oaire.version -->
    <xsl:template match="doc:element[@name='version']" mode="oaire">
		<!-- count(index-of($status_list, normalize-space()))&gt;0 ]|doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value' and count(index-of($status_list, normalize-space()))&gt;0])-->
		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'status_str'" />
			<xsl:with-param name="node" select="normalize-space(doc:field[@name='value']/text())" />
		</xsl:call-template>
    </xsl:template>


	<!-- dc.identifier -->
    <xsl:template match="doc:element[@name='identifier']" mode="datacite">
		<xsl:call-template name="field">
			<xsl:with-param name="name">
				<xsl:if test="not(doc:field[@name='identifierType'])">
					<xsl:text>identifier_str_mv</xsl:text>
				</xsl:if>
				<xsl:apply-templates select="doc:field[@name='identifierType']" mode="datacite_identifierType"/>
			</xsl:with-param>
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:call-template name="field">
			<xsl:with-param name="name"
				select="'dc.identifier.none.fl_str_mv'" />
			<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
		</xsl:call-template>

		<xsl:choose>
			<xsl:when test="starts-with(doc:field[@name='value']/text(), 'http')">
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'url'" />
					<xsl:with-param name="node" select="normalize-space(doc:field[@name='value']/text())" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="field">
					<xsl:with-param name="name"
						select="'identifier_str_mv'" />
					<xsl:with-param name="node" select="substring(normalize-space(doc:field[@name='value']/text()),1,$maxStringLength)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>


    <xsl:template match="doc:element[@name='identifier']/doc:field[@name='identifierType']"
        mode="datacite_identifierType">
        <xsl:choose>
            <xsl:when test="text()='ARK'">
                <xsl:text>identifier.other.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='Handle'">
                <xsl:text>identifier.url.fl_str_mv</xsl:text>
            </xsl:when>		
		<!-- TODO evaluate this mapping -->
            <xsl:when test="text()='URN'">
                <xsl:text>identifier.other.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='DOI'">
                <xsl:text>identifier.doi.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='PURL'">
                <xsl:text>identifier.other.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:when test="text()='URL'">
                <xsl:text>identifier.url.fl_str_mv</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>identifier.other.fl_str_mv</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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

	<!-- person template -->
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

	<!-- funding template -->
	<xsl:template name="funding">
		<xsl:param name="value" />
		<xsl:if test="$value">
			<xsl:element name="field">
				<xsl:attribute name="name">
					<xsl:text>funding_str_mv</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

    <xsl:template match="/doc:metadata/doc:element[@name='dcterms']"/>
    <xsl:template match="*" mode="dc"/>
    <xsl:template match="*" mode="oaire"/>
    <xsl:template match="text() | @*" mode="person"/>
    <xsl:template match="text() | @*" mode="organization"/>
    <xsl:template match="text() | @*" mode="service"/>
    <xsl:template match="text() | @*" mode="funding"/>
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>
