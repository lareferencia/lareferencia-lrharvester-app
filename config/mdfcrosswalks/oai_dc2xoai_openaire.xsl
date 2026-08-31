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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.lyncode.com/xoai"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:rdf="http://www.w3.org/TR/rdf-concepts/"
    version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <!-- params -->
    <xsl:param name="identifier"/>
    <xsl:param name="timestamp"/>

    <xsl:template match="/">
        <xsl:element name="metadata">
            <xsl:apply-templates select="." mode="datacite"/>

            <xsl:apply-templates select="." mode="dc"/>

            <xsl:apply-templates select="." mode="oaire"/>

            <xsl:apply-templates select="." mode="dcterms"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="oai_dc:dc" mode="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>datacite</xsl:text>
         </xsl:attribute>
            <xsl:call-template name="datacite_wrapper">
                <xsl:with-param name="wrapper" select="'titles'"/>
                <xsl:with-param name="nodes" select="dc:title"/>
            </xsl:call-template>
            <xsl:call-template name="datacite_wrapper">
                <xsl:with-param name="wrapper" select="'creators'"/>
                <xsl:with-param name="nodes" select="dc:creator"/>
            </xsl:call-template>
            <xsl:call-template name="datacite_wrapper">
                <xsl:with-param name="wrapper" select="'subjects'"/>
                <xsl:with-param name="nodes" select="dc:subject"/>
            </xsl:call-template>
            <xsl:apply-templates select="*" mode="datacite"/>
            <xsl:apply-templates select="." mode="datacite_identifier"/>
            <xsl:call-template name="datacite_relatedId_wrapper">
                <xsl:with-param name="relations" select="dc:relation"/>
                <xsl:with-param name="identifiers" select="dc:identifier"/>
            </xsl:call-template>
            <xsl:call-template name="datacite_alternativeId_wrapper">
                <xsl:with-param name="identifiers" select="dc:identifier"/>
            </xsl:call-template>
            <xsl:call-template name="datacite_date_wrapper">
                <xsl:with-param name="nodes" select="dc:date"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>


    <xsl:template name="datacite_wrapper">
        <xsl:param name="wrapper"/>
        <xsl:param name="nodes"/>
        <xsl:if test="$nodes">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:value-of select="$wrapper"/>
             </xsl:attribute>
                <xsl:for-each select="$nodes">
                    <xsl:apply-templates select="." mode="datacite_child"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="datacite_date_wrapper">
        <xsl:param name="nodes"/>
        <xsl:if test="$nodes">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>dates</xsl:text>
             </xsl:attribute>
                <xsl:element name="element">
                    <xsl:attribute name="name">
                <xsl:text>date</xsl:text>
             </xsl:attribute>
                    <xsl:for-each select="$nodes">
                        <xsl:apply-templates select="." mode="datacite_child"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="datacite_relatedId_wrapper">
        <xsl:param name="relations"/>
        <xsl:param name="identifiers"/>
        <xsl:if test="$identifiers or $relations">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>relatedIdentifiers</xsl:text>
             </xsl:attribute>
                <xsl:for-each select="$identifiers">
                    <xsl:apply-templates select="." mode="datacite_relatedchild"/>
                </xsl:for-each>
                <xsl:for-each select="$relations">
                    <xsl:apply-templates select="." mode="datacite_child"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="datacite_alternativeId_wrapper">
        <xsl:param name="identifiers"/>
        <xsl:if test="$identifiers">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>alternateIdentifiers</xsl:text>
             </xsl:attribute>
                <xsl:for-each select="$identifiers">
                    <xsl:apply-templates select="." mode="datacite_alternatechild"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template> 
    
    

   <!-- datacite.title -->   
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_title.html -->
    <xsl:template match="dc:title" mode="datacite_child">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>title</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>   

    
    <!-- datacite.creator -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_creator.html -->
    <xsl:template match="dc:creator" mode="datacite_child">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creator</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="." mode="creatorName"/>
        </xsl:element>
    </xsl:template>    
    
    <!-- datacite.creator.creatorName -->
    <xsl:template match="dc:creator" mode="creatorName">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creatorName</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
    
   <!-- datacite:subjects -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_subject.html -->
    <xsl:template match="dc:subject" mode="datacite_child">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>subject</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>        
    
   <!-- datacite:rights -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_accessrights.html -->
    <xsl:template match="dc:rights" mode="datacite">
        <xsl:variable name="normalizedRights">
            <xsl:copy>
                <xsl:apply-templates select="."/>
            </xsl:copy>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>rights</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="$normalizedRights" mode="datacite_rights"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:rights" mode="datacite_rights">
        <xsl:apply-templates select="text()" mode="field"/>
        <xsl:apply-templates select="." mode="datacite_rightsURI"/>
    </xsl:template>

    <xsl:template match="dc:rights" mode="datacite_rightsURI">
        <xsl:variable name="rightsURI">
            <xsl:call-template name="resolveRightsURI">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'rightsURI'"/>
            <xsl:with-param name="value" select="$rightsURI"/>
        </xsl:call-template>
    </xsl:template>    
    
    
    <!-- datacite.dates -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_embargoenddate.html -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationdate.html -->
    <xsl:template match="dc:date[3]" mode="datacite_child">
        <!-- accessioned -->
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>Accepted</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:date[2]" mode="datacite_child">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>Available</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:date[1]" mode="datacite_child">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>Issued</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
   <!--  datacite:identifier  -->
   <!-- In the repository context Resource Identifier will be the Handle or the generated DOI that is present in dc.identifier.uri. -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_resourceidentifier.html -->
    <xsl:template match="oai_dc:dc[dc:identifier]" mode="datacite_identifier">
        <xsl:variable name="identifierHandle">
            <xsl:call-template name="generateByIdentifierType">
                <xsl:with-param name="nodes" select="dc:identifier"/>
                <xsl:with-param name="type" select="'Handle'"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- if is an handle -->
        <xsl:if test="string-length($identifierHandle)!=0">
            <xsl:copy-of select="$identifierHandle"/>
        </xsl:if>

        <xsl:if test="string-length($identifierHandle)=0">
            <xsl:variable name="identifierDOI">
                <xsl:call-template name="generateByIdentifierType">
                    <xsl:with-param name="nodes" select="dc:identifier" />
                    <xsl:with-param name="type" select="'DOI'"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- if is a DOI -->
            <xsl:if test="string-length($identifierDOI)!=0">
                
                <xsl:copy-of select="$identifierDOI"/>                
            </xsl:if>

            <xsl:if test="string-length($identifierDOI)=0">
                <xsl:variable name="identifierURL">
                    <xsl:call-template name="generateByIdentifierType">
                        <xsl:with-param name="nodes" select="dc:identifier"/>
                        <xsl:with-param name="type" select="'URL'"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- if is a URL -->
                <xsl:if test="string-length($identifierURL)!=0">
                    <xsl:copy-of select="$identifierURL"/>
                </xsl:if>
            </xsl:if>
        </xsl:if>

    </xsl:template>


    <xsl:template name="generateByIdentifierType">
        <xsl:param name="nodes"/>
        <xsl:param name="type"/>
        <xsl:for-each select="$nodes">
            <xsl:variable name="identifierType">
                <xsl:call-template name="resolveFieldType">
                    <xsl:with-param name="field" select="."/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$identifierType = $type">
            <!-- only process the first element -->
                <xsl:apply-templates select="." mode="datacite_identifierField"/>
            </xsl:if>                
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="dc:identifier" mode="datacite_prefix_doi">
        <xsl:variable name="doiPrefix" select="'https://doi.org/'"/>
        <xsl:choose>
            <xsl:when test="starts-with(., $doiPrefix)">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>https://doi.org/</xsl:text>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:identifier" mode="datacite_identifierField">
        <xsl:variable name="identifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>identifier</xsl:text>
         </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$identifierType = 'DOI'">
                    <xsl:variable name="identifierDOI">
                        <xsl:apply-templates select="." mode="datacite_prefix_doi"/>
                    </xsl:variable>                    
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'value'"/>
                        <xsl:with-param name="value" select="$identifierDOI"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="text()" mode="field"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates select="." mode="datacite_identifierType"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:identifier" mode="datacite_identifierType">
        <xsl:variable name="identifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'identifierType'"/>
            <xsl:with-param name="value" select="$identifierType"/>
        </xsl:call-template>
    </xsl:template>        
    
    
    <!-- datacite:relatedIdentifiers -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_relatedidentifier.html -->
   <!-- datacite:relatedIdentifier -->
    <xsl:template match="dc:identifier" mode="datacite_relatedchild">
        <xsl:variable name="identifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="isTID">
            <xsl:call-template name="isTID">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- we will only consider related identifiers some specific types of identifiers -->
        <xsl:if test="$isTID = 'false' and $identifierType != 'DOI' and $identifierType != 'Handle'">
        
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>relatedIdentifier</xsl:text>
             </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$identifierType = 'DOI'">
                        <xsl:variable name="identifierDOI">
                            <xsl:apply-templates select="." mode="datacite_prefix_doi"/>
                        </xsl:variable>                    
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$identifierDOI"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="text()" mode="field"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="." mode="datacite_relatedIdentifierType"/>
                <xsl:apply-templates select="." mode="datacite_relationType"/>
            </xsl:element>
            
        </xsl:if>
    </xsl:template>


    <xsl:template match="dc:identifier" mode="datacite_relatedIdentifierType">
        <xsl:variable name="relatedIdentifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'relatedIdentifierType'"/>
            <xsl:with-param name="value" select="$relatedIdentifierType"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="dc:relation" mode="datacite_child">
        <xsl:variable name="isURL">
            <xsl:call-template name="isURL">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$isURL = 'true'">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>relatedIdentifier</xsl:text>
             </xsl:attribute>
                <xsl:apply-templates select="text()" mode="field"/>
                <xsl:apply-templates select="." mode="datacite_relatedIdentifierType"/>
                <xsl:apply-templates select="." mode="datacite_relationType"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="dc:relation" mode="datacite_relatedIdentifierType">
        <xsl:variable name="relatedIdentifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'relatedIdentifierType'"/>
            <xsl:with-param name="value" select="$relatedIdentifierType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dc:identifier" mode="datacite_relationType">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'relationType'"/>
            <xsl:with-param name="value" select="'HasVersion'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dc:relation" mode="datacite_relationType">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'relationType'"/>
            <xsl:with-param name="value" select="'HasVersion'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- datacite:relatedIdentifiers -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_relatedidentifier.html -->
   <!-- datacite:alternateIdentifier -->
    <xsl:template match="dc:identifier" mode="datacite_alternatechild">
        <xsl:variable name="identifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="isTID">
            <xsl:call-template name="isTID">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>

        <!-- we will only consider alternate identifiers some specific types of identifiers -->
        <xsl:if test="$isTID = 'true' or $identifierType = 'DOI' or $identifierType = 'Handle'">

            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>alternateIdentifier</xsl:text>
             </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$identifierType = 'DOI'">
                        <xsl:variable name="identifierDOI">
                            <xsl:apply-templates select="." mode="datacite_prefix_doi"/>
                        </xsl:variable>                    
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$identifierDOI"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$identifierType = 'URN' and $isTID = 'true'">
                        <xsl:variable name="identifierTID">
                            <xsl:apply-templates select="." mode="datacite_prefix_tid"/>
                        </xsl:variable>
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$identifierTID"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="text()" mode="field"/>
                    </xsl:otherwise>
                </xsl:choose>            
                <xsl:apply-templates select="." mode="datacite_alternateIdentifierType"/>
            </xsl:element>
        
        </xsl:if>
        
    </xsl:template>
    
    
    <xsl:template match="dc:identifier" mode="datacite_prefix_tid">
        <xsl:variable name="tidPrefix" select="'TID:'"/>
        <xsl:choose>
            <xsl:when test="starts-with(., $tidPrefix)">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>TID:</xsl:text>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    
    <xsl:template match="dc:identifier" mode="datacite_alternateIdentifierType">
        <xsl:variable name="alternateIdentifierType">
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'alternateIdentifierType'"/>
            <xsl:with-param name="value" select="$alternateIdentifierType"/>
        </xsl:call-template>
    </xsl:template>


    <!-- dc -->
    <xsl:template match="oai_dc:dc" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>dc</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="*" mode="dc"/>
        </xsl:element>
    </xsl:template>      
    

    <!-- dc:description -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_description.html -->
    <xsl:template match="dc:description" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>description</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
    <!-- dc:publisher -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publisher.html -->
    <xsl:template match="dc:publisher" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>publisher</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>
    

    <!-- dc:language -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_language.html -->
    <xsl:template match="dc:language" mode="dc">
        <xsl:variable name="normalizedLang">
            <xsl:copy>
                <xsl:apply-templates select="."/>
            </xsl:copy>
        </xsl:variable>

        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>language</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="$normalizedLang//text()" mode="field"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:source" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>source</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:format" mode="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>format</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="text()" mode="field"/>
        </xsl:element>
    </xsl:template>    
    
    <!-- oaire -->
    <xsl:template match="oai_dc:dc" mode="oaire">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>oaire</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="*" mode="oaire"/>

            <xsl:call-template name="oaire_wrapper">
                <xsl:with-param name="wrapper" select="'fundingReferences'"/>
                <xsl:with-param name="nodes" select="dc:relation"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>


    <xsl:template name="oaire_wrapper">
        <xsl:param name="wrapper"/>
        <xsl:param name="nodes"/>
        <xsl:if test="$nodes">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:value-of select="$wrapper"/>
             </xsl:attribute>
                <xsl:for-each select="$nodes">
                    <xsl:apply-templates select="." mode="oaire_child"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>     
    
    <!-- oaire:resourceType -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html -->
    <xsl:template
        match="dc:type[not(text()='info:eu-repo/semantics/publishedVersion' 
            or text()='info:eu-repo/semantics/submittedVersion' 
            or text()='info:eu-repo/semantics/acceptedVersion'
            or text()='info:eu-repo/semantics/draft'
            or text()='info:eu-repo/semantics/updatedVersion' )]"
        mode="oaire">
        <xsl:variable name="normalizedType">
            <xsl:copy>
                <xsl:apply-templates select="."/>
            </xsl:copy>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>resourceType</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="$normalizedType" mode="oaire_type"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:type" mode="oaire_type">
        <xsl:apply-templates select="text()" mode="field"/>
        <xsl:apply-templates select="." mode="oaire_typeURI"/>
        <xsl:apply-templates select="." mode="oaire_generaltype"/>
    </xsl:template>


    <xsl:template match="dc:type" mode="oaire_typeURI">
        <xsl:variable name="resourceTypeURI">
            <xsl:call-template name="resolveResourceTypeURI">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'uri'"/>
            <xsl:with-param name="value" select="$resourceTypeURI"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="dc:type" mode="oaire_generaltype">
        <xsl:variable name="resourceTypeURI">
            <xsl:call-template name="resolveResourceTypeGeneral">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'resourceTypeGeneral'"/>
            <xsl:with-param name="value" select="$resourceTypeURI"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- oaire:version -->
    <xsl:template
        match="dc:type[text()='info:eu-repo/semantics/publishedVersion' 
            or text()='info:eu-repo/semantics/submittedVersion' 
            or text()='info:eu-repo/semantics/acceptedVersion'
            or text()='info:eu-repo/semantics/draft'
            or text()='info:eu-repo/semantics/updatedVersion']"
        mode="oaire">
        <xsl:variable name="normalizedVersion">
            <xsl:copy>
                <xsl:apply-templates select="."/>
            </xsl:copy>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>version</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="$normalizedVersion" mode="oaire_version"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:type" mode="oaire_version">
        <xsl:apply-templates select="text()" mode="field"/>
        <xsl:apply-templates select="." mode="oaire_versionURI"/>
    </xsl:template>

    <xsl:template match="dc:type" mode="oaire_versionURI">
        <xsl:variable name="resourceVersionURI">
            <xsl:call-template name="resolveVersionURI">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'uri'"/>
            <xsl:with-param name="value" select="$resourceVersionURI"/>
        </xsl:call-template>
    </xsl:template>


    <!-- oaire:fundingReferences -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_projectid.html -->
    <!-- oaire:fundingReference -->
    <xsl:template match="dc:relation" mode="oaire_child">
        <xsl:variable name="isURNProject">
            <xsl:call-template name="isURNProject">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$isURNProject = 'true'">
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>fundingReference</xsl:text>
             </xsl:attribute>
                <xsl:call-template name="processFundingReference">
                    <xsl:with-param name="reference" select="."/>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="processFundingReference">
        <xsl:param name="reference"/>
        <xsl:variable name="eu_prefix" select="'info:eu-repo/grantAgreement/'"/>
        <xsl:variable name="uri_stripped" select="substring-after($reference/text(),$eu_prefix)"/>
        <xsl:variable name="funder" select="substring-before($uri_stripped,'/')"/>
        <xsl:variable name="program"
            select="substring-before(substring-after($uri_stripped,concat($funder,'/')),'/')"/>
        <xsl:variable name="awardNumber"
            select="substring-before(substring-after($uri_stripped,concat($funder,'/',$program,'/')),'/')"/>


        <xsl:call-template name="oaire_funderName">
            <xsl:with-param name="field" select="$funder"/>
        </xsl:call-template>
        <xsl:call-template name="oaire_funderDOI">
            <xsl:with-param name="field" select="$funder"/>
        </xsl:call-template>

        <xsl:call-template name="oaire_fundingStream">
            <xsl:with-param name="field" select="$program"/>
        </xsl:call-template>
        <xsl:call-template name="oaire_awardNumber">
            <xsl:with-param name="field" select="$awardNumber"/>
        </xsl:call-template>        
        
        <!-- it would be useful an OpenAIRE resolving service for the given URI 
            to be used in oaire.awardURI
        -->
    </xsl:template>
         
         
         
    <!-- This template creates the sub-element <oaire:awardTitle> from a Funded Project built entity -->
    <xsl:template name="oaire_awardTitle">
        <xsl:param name="field"/>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>awardTitle</xsl:text>
             </xsl:attribute>
            <xsl:apply-templates select="$field" mode="field"/>
        </xsl:element>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:funderName> from a Funded Project built entity -->
    <xsl:template name="oaire_funderName">
        <xsl:param name="field"/>
        <xsl:variable name="funderName">
            <xsl:call-template name="resolveFunderNameByAcronym">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>funderName</xsl:text>
             </xsl:attribute>
            <xsl:apply-templates select="$funderName" mode="field"/>
        </xsl:element>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:funderIdentifier> from a Funded Project built entity -->
    <xsl:template name="oaire_funderDOI">
        <xsl:param name="field"/>
        <xsl:variable name="funderDOI">
            <xsl:call-template name="resolveCrossrefFunderId">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>funderIdentifier</xsl:text>
             </xsl:attribute>
            <xsl:apply-templates select="$funderDOI" mode="field"/>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'funderIdentifierType'"/>
                <xsl:with-param name="value" select="'Crossref Funder ID'"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:fundingStream> from a Funded Project built entity -->
    <xsl:template name="oaire_fundingStream">
        <xsl:param name="field"/>

        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>fundingStream</xsl:text>
             </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'value'"/>
                <xsl:with-param name="value" select="normalize-space($field)"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:awardNumber> from a Funded Project built entity -->
    <xsl:template name="oaire_awardNumber">
        <xsl:param name="field"/>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>awardNumber</xsl:text>
             </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'value'"/>
                <xsl:with-param name="value" select="normalize-space($field)"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>



   <!--  -->
   <!-- Other Auxiliary templates -->
   <!--  -->
    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>    

   <!-- to retrieve a string in uppercase -->
    <xsl:template name="uppercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $smallcase, $uppercase)"/>
    </xsl:template>

   <!-- to retrieve a string in lowercase -->
    <xsl:template name="lowercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $uppercase, $smallcase)"/>
    </xsl:template>

    <!-- to retrieve a string which the first letter is in uppercase -->
    <xsl:template name="ucfirst">
        <xsl:param name="value"/>
        <xsl:call-template name="uppercase">
            <xsl:with-param name="value" select="substring($value, 1, 1)"/>
        </xsl:call-template>
        <xsl:call-template name="lowercase">
            <xsl:with-param name="value" select="substring($value, 2)"/>
        </xsl:call-template>
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

    <!-- it will verify if a given field is a TID identifier -->
    <xsl:template name="isTID">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="string(number($field/text())) != 'NaN' and string-length($field/text()) = 9">
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
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'orcid.org')]">
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
        <xsl:variable name="lc_field">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_field[starts-with(text(),'http://') or starts-with(text(),'https://')]">
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
        <xsl:variable name="isTID">
            <xsl:call-template name="isTID">
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
            <xsl:when test="$isURL = 'true' and $isHandle = 'false'">
                <xsl:text>URL</xsl:text>
            </xsl:when>
            <xsl:when test="$isTID = 'true'">
                <xsl:text>URN</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N/A</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
   <!-- 
    This template is temporary.
    it's only purpose it to provide a funders name based on the URI
   -->
    <xsl:template name="resolveFunderNameByAcronym">
        <xsl:param name="field"/>
        <xsl:variable name="lc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_type='ec'">
                <xsl:text>European Commission</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_type='fct'">
                <xsl:text>Fundação para a Ciência e Tecnologia</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_type='wt'">
                <xsl:text>Welcome Trust</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lc_type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   <!-- 
    This template is temporary.
    it's only purpose it to provide a funders doi based on the URI
   -->
    <xsl:template name="resolveCrossrefFunderId">
        <xsl:param name="field"/>
        <xsl:variable name="lc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>http://doi.org/</xsl:text>
        <xsl:choose>
            <xsl:when test="$lc_type='ec'">
                <xsl:text>10.13039/501100008530</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_type='fct'">
                <xsl:text>10.13039/501100001871</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_type='wt'">
                <xsl:text>10.13039/100010269</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>      

    <!--
        This template will return the general type of the resource
        based on a valued text like 'article'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html#attribute-resourcetypegeneral-m 
     -->
    <xsl:template name="resolveResourceTypeGeneral">
        <xsl:param name="field"/>
        <xsl:variable name="lc_dc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
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
            <xsl:otherwise>other research product</xsl:otherwise>
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
        <xsl:variable name="lc_dc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
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



<!-- Modifying and normalizing dc.type according to COAR Controlled Vocabulary for Resource Type 
        Genres (Version 2.0) (http://vocabularies.coar-repositories.org/documentation/resource_types/)
        available at 
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html#attribute-uri-m
    -->
    <xsl:template match="dc:type/text()">
        <xsl:variable name="dc_type" select="."/>
        <xsl:variable name="lc_dc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="$lc_dc_type = 'annotation' or $dc_type = 'http://purl.org/coar/resource_type/c_1162'">
                <xsl:text>annotation</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal'">
                <xsl:text>journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'journal article' or $lc_dc_type = 'article' or $lc_dc_type = 'journalarticle' or $dc_type = 'http://purl.org/coar/resource_type/c_6501' or $dc_type = 'info:eu-repo/semantics/article'">
                <xsl:text>journal article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'editorial' or $dc_type = 'http://purl.org/coar/resource_type/c_b239'">
                <xsl:text>editorial</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'bachelor thesis' or $lc_dc_type = 'bachelorthesis' or $dc_type = 'info:eu-repo/semantics/bachelorThesis' or $dc_type = 'http://purl.org/coar/resource_type/c_7a1f'">
                <xsl:text>bachelor thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'bibliography' or $dc_type = 'http://purl.org/coar/resource_type/c_86bc'">
                <xsl:text>bibliography</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book' or $dc_type = 'http://purl.org/coar/resource_type/c_2f33' or $dc_type = 'info:eu-repo/semantics/book'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'book part' or $lc_dc_type = 'bookpart' or $dc_type = 'http://purl.org/coar/resource_type/c_3248' or $dc_type = 'info:eu-repo/semantics/bookPart'">
                <xsl:text>book part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'book review' or $lc_dc_type = 'bookreview' or $dc_type = 'http://purl.org/coar/resource_type/c_ba08'">
                <xsl:text>book review</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'website' or $dc_type = 'http://purl.org/coar/resource_type/c_7ad9'">
                <xsl:text>website</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'interactive resource' or $lc_dc_type = 'interactiveresource' or $dc_type = 'http://purl.org/coar/resource_type/c_e9a0'">
                <xsl:text>interactive resource</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference proceedings' or $lc_dc_type = 'conferenceproceedings' or $dc_type = 'http://purl.org/coar/resource_type/c_f744'">
                <xsl:text>conference proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference object' or $lc_dc_type = 'conferenceobject' or $dc_type = 'http://purl.org/coar/resource_type/c_c94f'">
                <xsl:text>conference object</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference paper' or $lc_dc_type = 'conferencepaper' or $dc_type = 'http://purl.org/coar/resource_type/c_5794'">
                <xsl:text>conference paper</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference poster' or $lc_dc_type = 'conferenceposter' or $dc_type = 'http://purl.org/coar/resource_type/c_6670'">
                <xsl:text>conference poster</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'contribution to journal' or $lc_dc_type = 'contributiontojournal' or $dc_type = 'http://purl.org/coar/resource_type/c_3e5a'">
                <xsl:text>contribution to journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'datapaper' or $dc_type = 'http://purl.org/coar/resource_type/c_beb9'">
                <xsl:text>data paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'dataset' or $dc_type = 'http://purl.org/coar/resource_type/c_ddb1'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'doctoral thesis' or $lc_dc_type = 'doctoralthesis' or $dc_type = 'http://purl.org/coar/resource_type/c_db06' or $dc_type = 'info:eu-repo/semantics/doctoralThesis'">
                <xsl:text>doctoral thesis</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'image' or $dc_type = 'http://purl.org/coar/resource_type/c_c513'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'lecture' or $dc_type = 'http://purl.org/coar/resource_type/c_8544'">
                <xsl:text>lecture</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'letter' or $dc_type = 'http://purl.org/coar/resource_type/c_0857'">
                <xsl:text>letter</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'master thesis' or $lc_dc_type = 'masterthesis' or $dc_type = 'http://purl.org/coar/resource_type/c_bdcc' or $dc_type = 'info:eu-repo/semantics/masterThesis'">
                <xsl:text>master thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'moving image' or $lc_dc_type = 'movingimage' or $dc_type = 'http://purl.org/coar/resource_type/c_8a7e'">
                <xsl:text>moving image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'periodical' or $dc_type = 'http://purl.org/coar/resource_type/c_2659'">
                <xsl:text>periodical</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'letter to the editor' or $lc_dc_type = 'lettertotheeditor' or $dc_type = 'http://purl.org/coar/resource_type/c_545b'">
                <xsl:text>letter to the editor</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'patent' or $dc_type = 'http://purl.org/coar/resource_type/c_15cd'">
                <xsl:text>patent</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'preprint' or $dc_type = 'http://purl.org/coar/resource_type/c_816b'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report' or $dc_type = 'http://purl.org/coar/resource_type/c_93fc' or $dc_type = 'info:eu-repo/semantics/report'">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'report part' or $lc_dc_type = 'reportpart' or $dc_type = 'http://purl.org/coar/resource_type/c_ba1f'">
                <xsl:text>report part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research proposal' or $lc_dc_type = 'researchproposal' or $dc_type = 'http://purl.org/coar/resource_type/c_baaf'">
                <xsl:text>research proposal</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'review' or $dc_type = 'http://purl.org/coar/resource_type/c_efa0'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'software' or $dc_type = 'http://purl.org/coar/resource_type/c_5ce6'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'still image' or $lc_dc_type = 'stillimage' or $dc_type = 'http://purl.org/coar/resource_type/c_ecc8'">
                <xsl:text>still image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'technical documentation' or $lc_dc_type = 'technicaldocumentation' or $dc_type = 'http://purl.org/coar/resource_type/c_71bd'">
                <xsl:text>technical documentation</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'workflow' or $dc_type = 'http://purl.org/coar/resource_type/c_393c'">
                <xsl:text>workflow</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'working paper' or $lc_dc_type = 'workingpaper' or $dc_type = 'http://purl.org/coar/resource_type/c_8042'">
                <xsl:text>working paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'thesis' or $dc_type = 'http://purl.org/coar/resource_type/c_46ec'">
                <xsl:text>thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'cartographic material' or $lc_dc_type = 'cartographicmaterial' or $dc_type = 'http://purl.org/coar/resource_type/c_12cc'">
                <xsl:text>cartographic material</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'map' or $dc_type = 'http://purl.org/coar/resource_type/c_12cd'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'video' or $dc_type = 'http://purl.org/coar/resource_type/c_12ce'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'sound' or $dc_type = 'http://purl.org/coar/resource_type/c_18cc'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'musical composition' or $lc_dc_type = 'musicalcomposition' or $dc_type = 'http://purl.org/coar/resource_type/c_18cd'">
                <xsl:text>musical composition</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'text' or $dc_type = 'http://purl.org/coar/resource_type/c_18cf'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference paper not in proceedings' or $lc_dc_type = 'conferencepapernotinproceedings' or $dc_type = 'http://purl.org/coar/resource_type/c_18cp'">
                <xsl:text>conference paper not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'conference poster not in proceedings' or $lc_dc_type = 'conferenceposternotinproceedings' or $dc_type = 'http://purl.org/coar/resource_type/c_18co'">
                <xsl:text>conference poster not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'musical notation' or $dc_type = 'http://purl.org/coar/resource_type/c_18cw'">
                <xsl:text>musical notation</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'internal report' or $lc_dc_type = 'internalreport' or $dc_type = 'http://purl.org/coar/resource_type/c_18ww'">
                <xsl:text>internal report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'memorandum' or $dc_type = 'http://purl.org/coar/resource_type/c_18wz'">
                <xsl:text>memorandum</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'other type of report'  or $lc_dc_type = 'othertypeofreport' or $dc_type = 'http://purl.org/coar/resource_type/c_18wq'">
                <xsl:text>other type of report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'policy report' or $lc_dc_type = 'policyreport'  or $dc_type = 'http://purl.org/coar/resource_type/c_186u'">
                <xsl:text>policy report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'project deliverable' or $lc_dc_type = 'projectdeliverable' or $dc_type = 'http://purl.org/coar/resource_type/c_18op'">
                <xsl:text>project deliverable</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'report to funding agency' or $lc_dc_type = 'reporttofundingagency' or $dc_type = 'http://purl.org/coar/resource_type/c_18hj'">
                <xsl:text>report to funding agency</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research report' or $lc_dc_type = 'researchreport' or $dc_type = 'http://purl.org/coar/resource_type/c_18ws'">
                <xsl:text>research report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'technical report' or $lc_dc_type = 'technicalreport' or $dc_type = 'http://purl.org/coar/resource_type/c_18gh'">
                <xsl:text>technical report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'review article' or $lc_dc_type = 'reviewarticle' or $dc_type = 'http://purl.org/coar/resource_type/c_dcae04bc'">
                <xsl:text>review article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_dc_type = 'research article' or $lc_dc_type = 'researcharticle' or $dc_type = 'http://purl.org/coar/resource_type/c_2df8fbb1'">
                <xsl:text>research article</xsl:text>
            </xsl:when>
            
            <!-- when dc:type holds publishing status -->
            <xsl:when test="$dc_type = 'info:eu-repo/semantics/publishedVersion'">
                <xsl:text>VoR</xsl:text>
            </xsl:when>
            <xsl:when test="$dc_type = 'info:eu-repo/semantics/submittedVersion'">
                <xsl:text>SMUR</xsl:text>
            </xsl:when>
            <xsl:when test="$dc_type = 'info:eu-repo/semantics/acceptedVersion'">
                <xsl:text>AM</xsl:text>
            </xsl:when>
            <xsl:when test="$dc_type = 'info:eu-repo/semantics/draft'">
                <xsl:text>AO</xsl:text>
            </xsl:when>
            <xsl:when test="$dc_type = 'info:eu-repo/semantics/updatedVersion'">
                <xsl:text>CVoR</xsl:text>
            </xsl:when>    

            <!-- other cases -->
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
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
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'open access' or ends-with($lc_value,'openaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_abf2</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'embargoed access' or ends-with($lc_value,'embargoedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_f1cf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'restricted access' or ends-with($lc_value,'restrictedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_16ec</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'metadata only access' or ends-with($lc_value,'closedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_14cb</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="dc:rights/text()">
        <xsl:variable name="value" select="."/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="$lc_value = 'open access' or ends-with($lc_value,'openaccess') or $value = 'http://purl.org/coar/access_right/c_abf2'">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'embargoed access' or ends-with($lc_value,'embargoedaccess') or $value = 'http://purl.org/coar/access_right/c_f1cf'">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'restricted access' or ends-with($lc_value,'restrictedaccess') or $value = 'http://purl.org/coar/access_right/c_16ec'">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'metadata only access' or ends-with($lc_value,'closedaccess') or $value = 'http://purl.org/coar/access_right/c_14cb'">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    


    <!-- 
        Resource Version mapping URI
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_resourceversion.html
    -->
    <xsl:template name="resolveVersionURI">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field = 'info:eu-repo/semantics/publishedVersion' or $field = 'VoR'">
                <xsl:text>http://purl.org/coar/version/c_970fb48d4fbd8a85</xsl:text>
            </xsl:when>
            <xsl:when test="$field = 'info:eu-repo/semantics/submittedVersion' or $field = 'SMUR'">
                <xsl:text>http://purl.org/coar/version/c_71e4c1898caa6e32</xsl:text>
            </xsl:when>
            <xsl:when test="$field = 'info:eu-repo/semantics/acceptedVersion' or $field = 'AM'">
                <xsl:text>http://purl.org/coar/version/c_ab4af688f83e57aa</xsl:text>
            </xsl:when>
            <xsl:when test="$field = 'info:eu-repo/semantics/draft' or $field = 'AO'">
                <xsl:text>http://purl.org/coar/version/c_b1a7d7d4d402bcce</xsl:text>
            </xsl:when>
            <xsl:when test="$field = 'info:eu-repo/semantics/updatedVersion' or $field = 'CVoR'">
                <xsl:text>http://purl.org/coar/version/c_e19f295774971610</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- 
        Modifying and normalizing dc.language
        to ISO 639-3 (from ISO 639-1) for each language available at the submission form
     -->
    <xsl:template match="dc:language/text()">
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'en_US'">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'en'">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'es'">
                <xsl:text>spa</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'de'">
                <xsl:text>deu</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'fr'">
                <xsl:text>fra</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'it'">
                <xsl:text>ita</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'ja'">
                <xsl:text>jap</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'zh'">
                <xsl:text>zho</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'pt'">
                <xsl:text>por</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'tr'">
                <xsl:text>tur</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
   <!-- xml:language -->
   <!-- this template will add a xml:lang parameter with the defined language of an element -->
    <xsl:template match="@xml:lang">
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="'lang'"/>
            <xsl:with-param name="value" select="."/>
        </xsl:call-template>
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

    <!-- ignore all non specified text values or attributes -->
    <xsl:template match="*" mode="datacite"/>
    <xsl:template match="*" mode="dc"/>
    <xsl:template match="*" mode="oaire"/>
    <xsl:template match="*" mode="dcterms"/>
    <xsl:template match="text()|@*"/>
</xsl:stylesheet>