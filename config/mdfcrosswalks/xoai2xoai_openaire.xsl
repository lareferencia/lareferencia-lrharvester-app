<?xml version="1.0"?>

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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.lyncode.com/xoai"
    xmlns:doc="http://www.lyncode.com/xoai" xmlns:rdf="http://www.w3.org/TR/rdf-concepts/" version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:element name="metadata">
            <xsl:call-template name="dc"/>
            <xsl:call-template name="datacite"/>
            <xsl:call-template name="oaire"/>
            <xsl:call-template name="dcterms"/>
        </xsl:element>
    </xsl:template>    

    <!-- dc -->
    <xsl:template name="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>dc</xsl:text>
            </xsl:attribute>
            <!-- dc:description -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']"
                mode="dc"/>

            <!-- dc:source -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']" mode="dc"/>
            
            <!-- dc:format -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']" mode="dc"/>
            <!-- dc:language -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element"
                mode="dc"/>
            <!-- dc:publisher -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']" mode="dc"/>
        </xsl:element>
    </xsl:template>


    <!-- datacite -->
    <xsl:template name="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>datacite</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']" mode="datacite"/>
            <!-- datacite:creator -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']"
                mode="datacite"/>
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']" mode="datacite"/>

            <!-- datacite:identifier -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']"
                mode="datacite_identifier"/>

            <!-- datacite:identifier -->
            <!-- if dc.identifier.uri has more than 1 value - datacite:alternateIdentifiers -->            
            <!-- datacite:relatedIdentifier -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']" mode="datacite"/>
                
            <!-- if dc.identifier.uri has more than 1 value -->
			<xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']" mode="datacite_altids"/>

            <!-- datacite:dates and embargo -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']" mode="datacite"/>

            <!-- datacite:rights -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']" mode="datacite"/>
            <!-- datacite:subject -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']" mode="datacite"/>
            <!-- datacite:size -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']" mode="datacite"/>

        </xsl:element>
    </xsl:template>

    <!-- oaire -->
    <xsl:template name="oaire">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>oaire</xsl:text>
            </xsl:attribute>
            
            <!-- oaire:file -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']" mode="oaire"/>
            <!-- oaire:citation* -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='oaire']/doc:element[@name='citation']" mode="oaire"/>            
            <!-- oaire:resourceType -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']" mode="oaire"/>
            <!-- oaire:fundingRefence -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']" mode="oaire"/>

        </xsl:element>
    </xsl:template>
    
    <!-- dcterms -->
    <xsl:template name="dcterms">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>dcterms</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>    
    
    
    <!-- dc:description -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_description.html -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']" mode="dc">
        <xsl:for-each select="doc:element/doc:field[@name='value']">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>description</xsl:text>
             </xsl:attribute>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="lang" select="../@name"/>
                </xsl:call-template>
                <xsl:apply-templates select="." mode="field"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- dc:format -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_size.html -->
    <xsl:template match="doc:element[@name='bundles']/doc:element[@name='bundle']" mode="dc">
        <xsl:if test="doc:field[@name='name' and text()='ORIGINAL']">
            <xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <xsl:apply-templates select="." mode="dc"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>format</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:field[@name='format']" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
    <!-- dc:source -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='source']" mode="dc">
        <xsl:element name="doc:element">
            <xsl:attribute name="name">
            <xsl:text>source</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:field[@name='value']" mode="field"/>
        </xsl:element>
    </xsl:template>        
    
    
    <!-- dc:language -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_language.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name!='none' and @name!='iso']"
        mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>language</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:field[@name='value']" mode="field"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='none']"
        mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>language</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:field[@name='value']" mode="field"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']"
        mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>language</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:element/doc:field[@name='value']" mode="field"/>
        </xsl:element>
    </xsl:template>
    

    <!-- dc:publisher -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publisher.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='publisher']" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>publisher</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="doc:element/doc:field[@name='value']" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
    
   <!-- datacite.titles -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_title.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='title']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>titles</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="." mode="datacite_title"/>
        </xsl:element>
    </xsl:template>

   <!-- datacite.title -->
    <xsl:template match="doc:element[@name='title']/doc:element" mode="datacite_title">
        <!-- datacite.title -->
        <xsl:for-each select="./doc:field[@name='value']">
            <xsl:element name="element">
                <xsl:attribute name="name">
                    <xsl:text>title</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="lang" select="../@name"/>
                </xsl:call-template>
                <xsl:apply-templates select="." mode="field"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>    


    <!-- datacite.creators -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_creator.html -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creators</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="." mode="datacite_creator"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='creator']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creators</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="." mode="datacite_creator"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="doc:element[@name='author']/doc:element" mode="datacite_creator">
        <xsl:apply-templates select="*" mode="datacite_creatorName"/>
    </xsl:template>
    <xsl:template match="doc:element[@name='creator']/doc:element" mode="datacite_creator">
        <xsl:apply-templates select="*" mode="datacite_creatorName"/>
    </xsl:template>

    <xsl:template match="doc:element/doc:field[@name='value']" mode="datacite_creatorName">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>creator</xsl:text>
            </xsl:attribute>
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>creatorName</xsl:text>
             </xsl:attribute>
                <xsl:apply-templates select="text()" mode="field"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="doc:element[@name='author']/doc:element/doc:field[@name!='value']"
        mode="datacite_creatorName"/>    
        
        
    <!-- datacite:relatedIdentifiers -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_relatedidentifier.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='identifier']" mode="datacite">
        <xsl:if test="count(doc:element[@name!='uri'])>0">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>relatedIdentifiers</xsl:text>
             </xsl:attribute>
                <xsl:apply-templates select="*" mode="datacite_relatedIdentifier"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

   <!-- datacite:relatedIdentifier -->
   <!-- handle: dc.identifier.issn -->
    <xsl:template match="doc:element[@name='issn']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'ISSN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.ismn -->
    <xsl:template match="doc:element[@name='ismn']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value">
                    <xsl:value-of select="concat('ISMN:',normalize-space(text()))"/>
                </xsl:with-param>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.govdoc -->
    <xsl:template match="doc:element[@name='govdoc']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value">
                    <xsl:value-of select="concat('govdoc:',normalize-space(text()))"/>
                </xsl:with-param>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.isbn -->
    <xsl:template match="doc:element[@name='isbn']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'ISBN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.sici -->
    <xsl:template match="doc:element[@name='sici']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value">
                    <xsl:value-of select="concat('sici:',normalize-space(text()))"/>
                </xsl:with-param>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.other -->
    <xsl:template match="doc:element[@name='other']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>    

    <!-- handle: dc.identifier.doi -->
    <xsl:template match="doc:element[@name='doi']" mode="datacite_relatedIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'DOI'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- handle: dc.identifier.* -->
    <xsl:template match="doc:element" mode="datacite_relatedIdentifier"/>    
    
    
    <!-- template for all relatedIdentifier -->
    <xsl:template name="relatedIdentifierTemplate">
        <xsl:param name="value"/>
        <xsl:param name="relatedIdentifierType"/>
        <xsl:param name="relationType"/>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>relatedIdentifier</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'relatedIdentifierType'"/>
                <xsl:with-param name="value" select="$relatedIdentifierType"/>
            </xsl:call-template>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'relationType'"/>
                <xsl:with-param name="value" select="$relationType"/>
            </xsl:call-template>
            <xsl:apply-templates select="$value" mode="field"/>
        </xsl:element>
    </xsl:template>    


    <!--  datacite:identifier  -->
    <!--  datacite:alternateIdentifier dc.identifier.uri  -->
    <!--  https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_alternativeidentifier.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='identifier']" mode="datacite_altids">
		<xsl:element name="element">
                <xsl:attribute name="name">
                    <xsl:text>alternateIdentifiers</xsl:text>
                 </xsl:attribute>
            <xsl:if
                test="count(./doc:element[@name='uri']/doc:element/doc:field[@name='value'])>1">
                    <xsl:apply-templates
                        select="./doc:element[@name='uri']"
                        mode="datacite_altid"/>
            </xsl:if>
            <xsl:apply-templates select="*" mode="datacite_alternateIdentifier"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']"
        mode="datacite_altid">

        <xsl:if test="count(./doc:element/doc:field[@name='value'])>1">
			<xsl:for-each select="./doc:element/doc:field[@name='value']">
				<!-- don't process the first element -->
				<xsl:if test="position()>1">
					<xsl:call-template name="alternateIdentifierTemplate">
						<xsl:with-param name="value" select="text()"/>
						<xsl:with-param name="identifierType" select="'DOI'"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- handle: dc.identifier.tid -->
    <xsl:template match="doc:element[@name='tid']" mode="datacite_alternateIdentifier">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="alternateIdentifierTemplate">
                <xsl:with-param name="value">
                    <xsl:value-of select="concat('tid:',normalize-space(text()))"/>
                </xsl:with-param>
                <xsl:with-param name="identifierType" select="'URN'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- template for all alternateIdentifier -->
    <xsl:template name="alternateIdentifierTemplate">
        <xsl:param name="value"/>
        <xsl:param name="identifierType"/>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>alternateIdentifier</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'alternateIdentifierType'"/>
                <xsl:with-param name="value" select="$identifierType"/>
            </xsl:call-template>
            <xsl:apply-templates select="$value" mode="field"/>
        </xsl:element>
    </xsl:template>
	


                        
   <!--  datacite:identifier  -->
   <!-- In the repository context Resource Identifier will be the Handle or the generated DOI that is present in dc.identifier.uri. -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_resourceidentifier.html -->
    <xsl:template match="doc:element[@name='identifier']/doc:element[@name='uri']"
        mode="datacite_identifier">
        <xsl:variable name="identifierType">
            <!--  only consider the first dc.identifier.uri -->
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="./doc:element[1]/doc:field[@name='value'][1]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>identifier</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'identifierType'"/>
                <xsl:with-param name="value" select="$identifierType"/>
            </xsl:call-template>
            <xsl:apply-templates select="./doc:element[1]/doc:field[@name='value'][1]/text()"
                mode="field"/>
        </xsl:element>
    </xsl:template>

    
   <!-- datacite:subjects -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_subject.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='subject']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>subjects</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="doc:element">
                <xsl:apply-templates select="." mode="datacite_subject"/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>    
    

   <!-- datacite:subject -->
    <xsl:template match="doc:element[@name='subject']/doc:element" mode="datacite_subject">
        <xsl:for-each select="doc:field[@name='value']">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>subject</xsl:text>
             </xsl:attribute>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="lang" select="../@name"/>
                </xsl:call-template>
                <xsl:apply-templates select="text()" mode="field"/>
            </xsl:element>
        </xsl:for-each>
        <!-- TODO handle special types like fos -->
    </xsl:template>    


    <!-- datacite.dates -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_embargoenddate.html -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationdate.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='date']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>dates</xsl:text>
            </xsl:attribute>    
        <!-- datacite:date (embargo) -->
            <xsl:for-each select="./doc:element">
                <xsl:apply-templates select="." mode="datacite"/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- datacite.date @name=issued or @name=accepted -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationdate.html -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued' or @name='accepted']"
        mode="datacite">
        <xsl:variable name="dc_date_value" select="doc:element/doc:field[@name='value']/text()"/>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>date</xsl:text>
         </xsl:attribute>
            <xsl:element name="element">
                <xsl:attribute name="name">
                    <xsl:text>Accepted</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates select="$dc_date_value" mode="field"/>
            </xsl:element>
        </xsl:element>
        <!-- 
            datacite.date issued is different from dc.date.issued
            please check - https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationdate.html
         -->
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>date</xsl:text>
         </xsl:attribute>
            <xsl:element name="element">
                <xsl:attribute name="name">
                    <xsl:text>Issued</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates select="$dc_date_value" mode="field"/>
            </xsl:element>
        </xsl:element>
    </xsl:template> 

    <!-- datacite.date @name=accessioned -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']" mode="datacite"/>

    <!-- datacite.date -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued' and @name!='accepted' and @name!='accessioned']"
        mode="datacite">
        <xsl:variable name="dateType">
            <xsl:call-template name="getDateType">
                <xsl:with-param name="elementName" select="./@name"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- only consider elements with valid date types -->
        <xsl:if test="$dateType != ''">
            <xsl:element name="element">
                <xsl:attribute name="name">
                    <xsl:text>date</xsl:text>
                </xsl:attribute>
                <xsl:element name="element">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$dateType"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="./doc:element/doc:field[@name='value']"
                        mode="field"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>


   <!-- datacite:rights -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_accessrights.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='rights']" mode="datacite">
        <xsl:variable name="rightsValue">
            <xsl:call-template name="normalizeRightsName">
                <xsl:with-param name="unNormalizedName"
                    select="doc:element[1]/doc:field[@name='value'][1]/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="rightsURI">
            <xsl:call-template name="resolveRightsURI">
                <xsl:with-param name="field" select="$rightsValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_rightsValue" select="translate($rightsValue, $uppercase, $smallcase)"/>

        <!-- We are checking to ensure that only values ending in "access" can be used as datacite:rights. 
        This is a valid solution as we pre-normalize dc.rights values in openaire4.xsl to end in the term 
        "access" according to COAR Controlled Vocabulary -->
        <xsl:if test="ends-with($lc_rightsValue,'access')">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>rights</xsl:text>
             </xsl:attribute>
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'rightsURI'"/>
                    <xsl:with-param name="value" select="$rightsURI"/>
                </xsl:call-template>
                <xsl:apply-templates select="$rightsValue" mode="field"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    

    <!-- datacite:sizes -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_size.html -->
    <xsl:template match="doc:element[@name='bundles']/doc:element[@name='bundle']" mode="datacite">
        <xsl:if test="doc:field[@name='name' and text()='ORIGINAL']">
            <xsl:element name="element">
                <xsl:attribute name="name">
                        <xsl:text>sizes</xsl:text>
                     </xsl:attribute>
                <xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                    <xsl:apply-templates select="." mode="datacite"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
     <!-- datacite:size -->
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>size</xsl:text>
             </xsl:attribute>
            <xsl:value-of select="concat(doc:field[@name='size'],' bytes')"/>
        </xsl:element>
    </xsl:template>


    <!-- oaire:resourceType -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='type']" mode="oaire">
        <xsl:variable name="typeValue">
            <xsl:call-template name="normalizeTypeName">
                <xsl:with-param name="unNormalizedName"
                    select="doc:element/doc:field[@name='value']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="resourceTypeGeneral">
            <xsl:call-template name="resolveResourceTypeGeneral">
                <xsl:with-param name="field" select="$typeValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="resourceTypeURI">
            <xsl:call-template name="resolveResourceTypeURI">
                <xsl:with-param name="field" select="$typeValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>resourceType</xsl:text>
             </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'resourceTypeGeneral'"/>
                <xsl:with-param name="value" select="$resourceTypeGeneral"/>
            </xsl:call-template>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'uri'"/>
                <xsl:with-param name="value" select="$resourceTypeURI"/>
            </xsl:call-template>
            <xsl:apply-templates select="$typeValue" mode="field"/>

        </xsl:element>
    </xsl:template>
    
    
   <!-- oaire:file -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_filelocation.html -->
    <xsl:template match="doc:element[@name='bundles']/doc:element[@name='bundle']" mode="oaire">
       <!-- only consider ORIGINAL bundle -->
        <xsl:if test="doc:field[@name='name' and text()='ORIGINAL']">
            <xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <xsl:apply-templates select="." mode="oaire"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>    
    
    <!-- oaire:file -->
    <!-- processing of each bitstream entry -->
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="oaire">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>file</xsl:text>
             </xsl:attribute>

            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'accessRightsURI'"/>
                <xsl:with-param name="value">
                    <xsl:call-template name="getRightsURI"/>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'mimeType'"/>
                <xsl:with-param name="value" select="doc:field[@name='format']"/>
            </xsl:call-template>

            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'objectType'"/>
                <xsl:with-param name="value">
                    <xsl:choose>
                            <!-- Currently there is no available way to identify the type of the bitstream -->
                        <xsl:when test="1">
                            <xsl:text>fulltext</xsl:text>
                        </xsl:when>
                            <!--xsl:when test="$type='dataset'">
                                <xsl:text>dataset</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='software'">
                                <xsl:text>software</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='article'">
                                <xsl:text>fulltext</xsl:text>
                            </xsl:when-->
                        <xsl:otherwise>
                            <xsl:text>other</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:apply-templates select="doc:field[@name='url']" mode="field"/>
        </xsl:element>
    </xsl:template>    




   <!--  -->
   <!-- Auxiliary templates - dealing with Entities -->
   <!--  -->
   
    <!-- This template will retrieve the type of a date based on the element name -->
    <xsl:template name="getDateType">
        <xsl:param name="elementName"/>
        <xsl:variable name="lc_dc_date_type" select="translate($elementName, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_dc_date_type='available' or  $lc_dc_date_type = 'embargo'">
                <xsl:text>Available</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='collected'">
                <xsl:text>Collected</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='copyrighted' or $lc_dc_date_type='copyright'">
                <xsl:text>Copyrighted</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='created'">
                <xsl:text>Created</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='submitted'">
                <xsl:text>Submitted</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='updated'">
                <xsl:text>Updated</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_date_type='valid'">
                <xsl:text>Valid</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- This template will retrieve the URI of the record type -->
    <xsl:template name="getRightsURI">
        <xsl:variable name="normalizedRightsName">
            <xsl:call-template name="normalizeRightsName">
                <xsl:with-param name="unNormalizedName"
                    select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value' and ends-with(translate(text(), $uppercase, $smallcase),'access')]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="resolveRightsURI">
            <xsl:with-param name="field" select="$normalizedRightsName"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
        Normalizing dc.rights according to COAR Controlled Vocabulary for
        Access Rights (Version 1.0) (http://vocabularies.coar-repositories.org/documentation/access_rights/)
        available at
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_accessrights.html#definition-and-usage-instruction
    -->
    <xsl:template name="normalizeRightsName">
        <xsl:param name="unNormalizedName"/>

        <xsl:variable name="stripped_unNormalizedName"
            select="replace($unNormalizedName, $info_eu_repo,'')"/>
        <xsl:variable name="lc_value"
            select="translate($stripped_unNormalizedName, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when
                test="$lc_value = 'open access' or $lc_value = 'openaccess' or $unNormalizedName = 'http://purl.org/coar/access_right/c_abf2'">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'embargoed access' or $lc_value = 'embargoedaccess' or $unNormalizedName = 'http://purl.org/coar/access_right/c_f1cf'">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'restricted access' or $lc_value = 'restrictedaccess' or $unNormalizedName = 'http://purl.org/coar/access_right/c_16ec'">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'metadata only access' or $lc_value = 'closedaccess' or $unNormalizedName = 'http://purl.org/coar/access_right/c_14cb'">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$unNormalizedName"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>        
    
    <!--
        This template will return the COAR Access Right Vocabulary URI
        like http://purl.org/coar/access_right/c_abf2
        based on a value text like 'open access'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_accessrights.html#definition-and-usage-instruction
     -->
    <xsl:template name="resolveRightsURI">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value" select="translate($field, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_value = 'open access'">
                <xsl:text>http://purl.org/coar/access_right/c_abf2</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'embargoed access'">
                <xsl:text>http://purl.org/coar/access_right/c_f1cf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'restricted access'">
                <xsl:text>http://purl.org/coar/access_right/c_16ec</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'metadata only access'">
                <xsl:text>http://purl.org/coar/access_right/c_14cb</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>    

    <!-- it will verify if a given field is an handle -->
    <xsl:template name="isHandle">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'hdl.handle.net')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is a DOI -->
    <xsl:template name="isDOI">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'doi.org') or starts-with(text(),'10.')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- it will verify if a given field is a URN - project -->
    <xsl:template name="isURNProject">
        <xsl:param name="field"/>
        <xsl:variable name="project_prefix" select="'info:eu-repo/grantAgreement'"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),$project_prefix)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
      

    <!-- it will verify if a given field is an ORCID -->
    <xsl:template name="isORCID">
        <xsl:param name="field"/>
        <xsl:variable name="lc_field" select="translate($field, $uppercase, $smallcase)"/>
        <xsl:choose>
            <xsl:when test="contains($lc_field,'orcid.org')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is an URL -->
    <xsl:template name="isURL">
        <xsl:param name="field"/>
        <xsl:variable name="lc_field" select="translate($field, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="starts-with($lc_field,'http://') or starts-with($lc_field,'https://')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- will try to resolve the field type based on the value -->
    <xsl:template name="resolveFieldType">
        <xsl:param name="field"/>
        <!-- regexp not supported on XSLTv1 -->
        <xsl:variable name="isHandle">
            <xsl:call-template name="isHandle">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isDOI">
            <xsl:call-template name="isDOI">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isURL">
            <xsl:call-template name="isURL">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isHandle = 'true'">
                <xsl:text>Handle</xsl:text>
            </xsl:when>
            <xsl:when test="$isDOI = 'true'">
                <xsl:text>DOI</xsl:text>
            </xsl:when>
            <xsl:when test="$isURL = 'true' and $isHandle = 'false' and $isDOI = 'false'">
                <xsl:text>URL</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N/A</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        Modifying and normalizing dc.language
        to ISO 639-3 (from ISO 639-1) for each language available at the submission form
     -->
    <xsl:template name="normalizeLangValue">
        <xsl:param name="lang"/>
        <xsl:variable name="lc_lang" select="translate($lang, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_lang = 'en_US'">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'en'">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'es'">
                <xsl:text>spa</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'de'">
                <xsl:text>deu</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'fr'">
                <xsl:text>fra</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'it'">
                <xsl:text>ita</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'ja'">
                <xsl:text>jpn</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'zh'">
                <xsl:text>zho</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'pt'">
                <xsl:text>por</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_lang = 'tr'">
                <xsl:text>tur</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
   <!-- xml:language -->
   <!-- this template will add a xml:lang parameter with the defined language of an element -->
    <xsl:template name="xmlLanguage">
        <xsl:param name="lang"/>
        <xsl:variable name="normalizedLang">
            <xsl:call-template name="normalizeLangValue">
                <xsl:with-param name="lang" select="$lang"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_lang" select="translate($normalizedLang, $uppercase, $smallcase)"/>
        <xsl:if test="$lc_lang!='none' and $lang!=''">
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'lang'"/>
                <xsl:with-param name="value" select="$normalizedLang"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>    

    <!-- This template will retrieve the type of a title element (like: alternative) based on the element name -->
    <xsl:template name="getTitleType">
        <xsl:param name="elementName"/>
        <xsl:variable name="lc_title_type" select="translate($elementName, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_title_type = 'alternativetitle' or $lc_title_type = 'alternative'">
                <xsl:text>AlternativeTitle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_title_type = 'subtitle'">
                <xsl:text>Subtitle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_title_type = 'translatedtitle'">
                <xsl:text>TranslatedTitle</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    

    
    <!-- Modifying and normalizing dc.type according to COAR Controlled Vocabulary for Resource Type 
        Genres (Version 2.0) (http://vocabularies.coar-repositories.org/documentation/resource_types/)
        available at 
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html#attribute-uri-m
    -->
    <xsl:template name="normalizeTypeName">
        <xsl:param name="unNormalizedName"/>

        <xsl:variable name="stripped_unNormalizedName"
            select="replace($unNormalizedName, $info_eu_repo,'')"/>
        <xsl:variable name="lc_dc_type"
            select="translate($stripped_unNormalizedName, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when
                test="$lc_dc_type = 'annotation' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_1162'">
                <xsl:text>annotation</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal'">
                <xsl:text>journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'journal article' or $lc_dc_type = 'article' or $lc_dc_type = 'journalarticle' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_6501'">
                <xsl:text>journal article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'editorial' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_b239'">
                <xsl:text>editorial</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'bachelor thesis' or $lc_dc_type = 'bachelorthesis' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_7a1f'">
                <xsl:text>bachelor thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'bibliography' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_86bc'">
                <xsl:text>bibliography</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'book' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_2f33'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'book part' or $lc_dc_type = 'bookpart' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_3248'">
                <xsl:text>book part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'book review' or $lc_dc_type = 'bookreview' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_ba08'">
                <xsl:text>book review</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'website' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_7ad9'">
                <xsl:text>website</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'interactive resource' or $lc_dc_type = 'interactiveresource' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_e9a0'">
                <xsl:text>interactive resource</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference proceedings' or $lc_dc_type = 'conferenceproceedings' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_f744'">
                <xsl:text>conference proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference object' or $lc_dc_type = 'conferenceobject' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_c94f'">
                <xsl:text>conference object</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference paper' or $lc_dc_type = 'conferencepaper' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_5794'">
                <xsl:text>conference paper</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference poster' or $lc_dc_type = 'conferenceposter' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_6670'">
                <xsl:text>conference poster</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'contribution to journal' or $lc_dc_type = 'contributiontojournal' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_3e5a'">
                <xsl:text>contribution to journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'datapaper' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_beb9'">
                <xsl:text>data paper</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'dataset' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_ddb1'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'doctoral thesis' or $lc_dc_type = 'doctoralthesis' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_db06'">
                <xsl:text>doctoral thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'image' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_c513'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'lecture' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_8544'">
                <xsl:text>lecture</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'letter' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_0857'">
                <xsl:text>letter</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'master thesis' or $lc_dc_type = 'masterthesis' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_bdcc'">
                <xsl:text>master thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'moving image' or $lc_dc_type = 'movingimage' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_8a7e'">
                <xsl:text>moving image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'periodical' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_2659'">
                <xsl:text>periodical</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'letter to the editor' or $lc_dc_type = 'lettertotheeditor' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_545b'">
                <xsl:text>letter to the editor</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'patent' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_15cd'">
                <xsl:text>patent</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'preprint' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_816b'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'report' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_93fc'">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'report part' or $lc_dc_type = 'reportpart' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_ba1f'">
                <xsl:text>report part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research proposal' or $lc_dc_type = 'researchproposal' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_baaf'">
                <xsl:text>research proposal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'review' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_efa0'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'software' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_5ce6'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'still image' or $lc_dc_type = 'stillimage' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_ecc8'">
                <xsl:text>still image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'technical documentation' or $lc_dc_type = 'technicaldocumentation' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_71bd'">
                <xsl:text>technical documentation</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'workflow' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_393c'">
                <xsl:text>workflow</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'working paper' or $lc_dc_type = 'workingpaper' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_8042'">
                <xsl:text>working paper</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'thesis' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_46ec'">
                <xsl:text>thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'cartographic material' or $lc_dc_type = 'cartographicmaterial' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_12cc'">
                <xsl:text>cartographic material</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'map' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_12cd'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'video' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_12ce'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'sound' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18cc'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'musical composition' or $lc_dc_type = 'musicalcomposition' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18cd'">
                <xsl:text>musical composition</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'text' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18cf'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference paper not in proceedings' or $lc_dc_type = 'conferencepapernotinproceedings' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18cp'">
                <xsl:text>conference paper not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference poster not in proceedings' or $lc_dc_type = 'conferenceposternotinproceedings' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18co'">
                <xsl:text>conference poster not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'musical notation' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18cw'">
                <xsl:text>musical notation</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'internal report' or $lc_dc_type = 'internalreport' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18ww'">
                <xsl:text>internal report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'memorandum' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18wz'">
                <xsl:text>memorandum</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'other type of report'  or $lc_dc_type = 'othertypeofreport' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18wq'">
                <xsl:text>other type of report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'policy report' or $lc_dc_type = 'policyreport'  or $unNormalizedName = 'http://purl.org/coar/resource_type/c_186u'">
                <xsl:text>policy report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'project deliverable' or $lc_dc_type = 'projectdeliverable' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18op'">
                <xsl:text>project deliverable</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'report to funding agency' or $lc_dc_type = 'reporttofundingagency' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18hj'">
                <xsl:text>report to funding agency</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research report' or $lc_dc_type = 'researchreport' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18ws'">
                <xsl:text>research report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'technical report' or $lc_dc_type = 'technicalreport' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_18gh'">
                <xsl:text>technical report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'review article' or $lc_dc_type = 'reviewarticle' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_dcae04bc'">
                <xsl:text>review article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research article' or $lc_dc_type = 'researcharticle' or $unNormalizedName = 'http://purl.org/coar/resource_type/c_2df8fbb1'">
                <xsl:text>research article</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>    
    
    
    <!--
        This template will return the COAR Resource Type Vocabulary URI
        like http://purl.org/coar/resource_type/c_6501
        based on a valued text like 'article'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html#attribute-uri-m
     -->
    <xsl:template name="resolveResourceTypeURI">
        <xsl:param name="field"/>
        <xsl:variable name="lc_dc_type" select="translate($field, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_dc_type = 'annotation'">
                <xsl:text>http://purl.org/coar/resource_type/c_1162</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal'">
                <xsl:text>http://purl.org/coar/resource_type/c_0640</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'article'">
                <xsl:text>http://purl.org/coar/resource_type/c_6501</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal article'">
                <xsl:text>http://purl.org/coar/resource_type/c_6501</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'editorial'">
                <xsl:text>http://purl.org/coar/resource_type/c_b239</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'bachelor thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_7a1f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'bibliography'">
                <xsl:text>http://purl.org/coar/resource_type/c_86bc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book'">
                <xsl:text>http://purl.org/coar/resource_type/c_2f33</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book part'">
                <xsl:text>http://purl.org/coar/resource_type/c_3248</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book review'">
                <xsl:text>http://purl.org/coar/resource_type/c_ba08</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'website'">
                <xsl:text>http://purl.org/coar/resource_type/c_7ad9</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'interactive resource'">
                <xsl:text>http://purl.org/coar/resource_type/c_e9a0</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_f744</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference object'">
                <xsl:text>http://purl.org/coar/resource_type/c_c94f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_5794</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference poster'">
                <xsl:text>http://purl.org/coar/resource_type/c_6670</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'contribution to journal'">
                <xsl:text>http://purl.org/coar/resource_type/c_3e5a</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'data paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_beb9</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'dataset'">
                <xsl:text>http://purl.org/coar/resource_type/c_ddb1</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'doctoral thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_db06</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'image'">
                <xsl:text>http://purl.org/coar/resource_type/c_c513</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'lecture'">
                <xsl:text>http://purl.org/coar/resource_type/c_8544</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'letter'">
                <xsl:text>http://purl.org/coar/resource_type/c_0857</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'master thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_bdcc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'moving image'">
                <xsl:text>http://purl.org/coar/resource_type/c_8a7e</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'periodical'">
                <xsl:text>http://purl.org/coar/resource_type/c_2659</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'letter to the editor'">
                <xsl:text>http://purl.org/coar/resource_type/c_545b</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'patent'">
                <xsl:text>http://purl.org/coar/resource_type/c_15cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'preprint'">
                <xsl:text>http://purl.org/coar/resource_type/c_816b</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report'">
                <xsl:text>http://purl.org/coar/resource_type/c_93fc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report part'">
                <xsl:text>http://purl.org/coar/resource_type/c_ba1f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research proposal'">
                <xsl:text>http://purl.org/coar/resource_type/c_baaf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'review'">
                <xsl:text>http://purl.org/coar/resource_type/c_efa0</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'software'">
                <xsl:text>http://purl.org/coar/resource_type/c_5ce6</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'still image'">
                <xsl:text>http://purl.org/coar/resource_type/c_ecc8</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'technical documentation'">
                <xsl:text>http://purl.org/coar/resource_type/c_71bd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'workflow'">
                <xsl:text>http://purl.org/coar/resource_type/c_393c</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'working paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_8042</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_46ec</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'cartographic material'">
                <xsl:text>http://purl.org/coar/resource_type/c_12cc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'map'">
                <xsl:text>http://purl.org/coar/resource_type/c_12cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'video'">
                <xsl:text>http://purl.org/coar/resource_type/c_12ce</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'sound'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'musical composition'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'text'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference paper not in proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cp</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference poster not in proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_18co</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'musical notation'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cw</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'internal report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18ww</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'memorandum'">
                <xsl:text>http://purl.org/coar/resource_type/c_18wz</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'other type of report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18wq</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'policy report'">
                <xsl:text>http://purl.org/coar/resource_type/c_186u</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'project deliverable'">
                <xsl:text>http://purl.org/coar/resource_type/c_18op</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report to funding agency'">
                <xsl:text>http://purl.org/coar/resource_type/c_18hj</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18ws</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'technical report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18gh</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'review article'">
                <xsl:text>http://purl.org/coar/resource_type/c_dcae04bc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research article'">
                <xsl:text>http://purl.org/coar/resource_type/c_2df8fbb1</xsl:text>
            </xsl:when>
            <!-- other -->
            <xsl:otherwise>
                <xsl:text>http://purl.org/coar/resource_type/c_1843</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        This template will return the general type of the resource
        based on a valued text like 'article'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html#attribute-resourcetypegeneral-m 
     -->
    <xsl:template name="resolveResourceTypeGeneral">
        <xsl:param name="field"/>
        <xsl:variable name="lc_dc_type" select="translate($field, $uppercase, $smallcase)"/>

        <xsl:choose>
            <xsl:when test="$lc_dc_type = 'article'">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal article'">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book'">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book part'">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book review'">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'dataset'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'software'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other research product</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    

    <!-- generic template for fields -->
    <xsl:template match="text()" mode="field">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'value'"/>
            <xsl:with-param name="value" select="normalize-space(.)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="field">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:value-of select="$name"/>
             </xsl:attribute>
            <xsl:value-of select="$value"/>
        </xsl:element>
    </xsl:template>

    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>
    <xsl:param name="info_eu_repo" select="'info:eu-repo/semantics/'"/>


    <!-- ignore all non specified text values or attributes -->
    <xsl:template match="*" mode="datacite"/>
    <xsl:template match="*" mode="dc"/>
    <xsl:template match="*" mode="oaire"/>
    <xsl:template match="*" mode="dcterms"/>
    <xsl:template match="*" mode="datacite_alternateIdentifier"/>
    <xsl:template match="text()|@*"/>
</xsl:stylesheet>