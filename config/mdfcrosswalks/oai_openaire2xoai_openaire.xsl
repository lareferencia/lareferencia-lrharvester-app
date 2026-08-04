<?xml version="1.0" encoding="UTF-8"?>
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
    xmlns="http://www.lyncode.com/xoai"
    xmlns:datacite="http://datacite.org/schema/kernel-4"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:oaire="http://namespace.openaire.eu/schema/oaire/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="utf-8" />

    <!-- root -->
    <xsl:template match="/">
        <xsl:element name="metadata">
            <xsl:call-template name="dc" />
            <xsl:call-template name="datacite" />
            <xsl:call-template name="oaire" />
            <xsl:call-template name="dcterms" />
        </xsl:element>
    </xsl:template>

    <!-- dc -->
    <xsl:template name="dc">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>dc</xsl:text>
            </xsl:attribute>
            <xsl:if test="//dc:language">
                <xsl:for-each select="//dc:language">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="//dc:publisher">
                <xsl:for-each select="//dc:publisher">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="//dc:description">
                <xsl:for-each select="//dc:description">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="//dc:format">
                <xsl:for-each select="//dc:format">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="//dc:source">
                <xsl:for-each select="//dc:source">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="//dc:coverage">
                <xsl:for-each select="//dc:coverage">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <!-- dc.language -->
    <xsl:template match="dc:language">
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>language</xsl:text>
              </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- dc.publisher -->
    <xsl:template match="dc:publisher">
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>publisher</xsl:text>
              </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- dc.description -->
    <xsl:template match="dc:description">
        <xsl:element name="element">
            <xsl:attribute name="name">
         <xsl:text>description</xsl:text>
        </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- dc.format -->
    <xsl:template match="dc:format">
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>format</xsl:text>
              </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- dc.source -->
    <xsl:template match="dc:source">
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>source</xsl:text>
              </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- dc.coverage -->
    <xsl:template match="dc:coverage">
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>coverage</xsl:text>
              </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- datacite -->
    <xsl:template name="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>datacite</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="*/datacite:titles" />
            <xsl:apply-templates select="*/datacite:creators" />
            <xsl:apply-templates
                select="*/datacite:contributors" />
            <xsl:apply-templates
                select="*/datacite:alternateIdentifiers" />
            <xsl:apply-templates
                select="*/datacite:relatedIdentifiers" />
            <xsl:apply-templates select="*/datacite:dates" />
            <xsl:apply-templates
                select="*/datacite:identifier" />
            <xsl:apply-templates select="*/datacite:rights" />
            <xsl:apply-templates select="*/datacite:subjects" />
            <xsl:apply-templates select="*/datacite:sizes" />
            <xsl:apply-templates
                select="*/datacite:geoLocations" />
        </xsl:element>
    </xsl:template>

    <!-- datacite.titles -->
    <xsl:template match="datacite:titles">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>titles</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:title">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.title -->
    <xsl:template match="datacite:title">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>title</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.creators -->
    <xsl:template match="datacite:creators">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creators</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:creator">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.creator -->
    <xsl:template match="datacite:creator">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>creator</xsl:text>
         </xsl:attribute>            
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.contributors -->
    <xsl:template match="datacite:contributors">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>contributors</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:contributor">                
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.creatorName -->
    <xsl:template match="datacite:creatorName">
        <xsl:element name="element">
                <xsl:attribute name="name">
               <xsl:text>creatorName</xsl:text>
            </xsl:attribute>
                <xsl:apply-templates select="./@*" />
                <xsl:apply-templates
                    select="./text()" mode="field" />
        </xsl:element>
    </xsl:template>        
    <!-- datacite.contributor -->
    <xsl:template match="datacite:contributor">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>contributor</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />         
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.contributorName -->
    <xsl:template match="datacite:contributorName">
        <xsl:element name="element">
                <xsl:attribute name="name">
               <xsl:text>contributorName</xsl:text>
            </xsl:attribute>
                <xsl:apply-templates select="./@*" />
                <xsl:apply-templates
                    select="./text()" mode="field" />
        </xsl:element>
    </xsl:template>        
    <xsl:template match="datacite:givenName">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>givenName</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="datacite:familyName">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>familyName</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="datacite:affiliation">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>affiliation</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite:nameIdentifier -->
    <xsl:template match="datacite:nameIdentifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>nameIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.alternateIdentifiers -->
    <xsl:template match="datacite:alternateIdentifiers">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>alternateIdentifiers</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:alternateIdentifier">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.alternateIdentifier -->
    <xsl:template match="datacite:alternateIdentifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>alternateIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.alternateIdentifier[tid] -->
    <xsl:template match="datacite:alternateIdentifier[@alternateIdentifierType='tid']">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>alternateIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*" mode="tid" />
            <xsl:variable name="value">
                <xsl:text>TID:</xsl:text>
                <xsl:value-of select="./text()"/>
            </xsl:variable>
            <xsl:apply-templates select="$value" mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.relatedIdentifiers -->
    <xsl:template match="datacite:relatedIdentifiers">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>relatedIdentifiers</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:relatedIdentifier">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.relatedIdentifier -->
    <xsl:template match="datacite:relatedIdentifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>relatedIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.dates -->
    <xsl:template match="datacite:dates">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>dates</xsl:text>
         </xsl:attribute>
            <xsl:element name="element">
                <xsl:attribute name="name">
                <xsl:text>date</xsl:text>
             </xsl:attribute>
                <!-- group by attribute dateType -->
                <xsl:for-each-group select="datacite:date"
                    group-by="@dateType">
                    <xsl:element name="element">
                        <xsl:attribute name="name">
                     <xsl:value-of select="current-grouping-key()" />
                  </xsl:attribute>
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="." />
                        </xsl:for-each>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- datacite.date -->
    <xsl:template match="datacite:date">
        <xsl:apply-templates select="./text()"
            mode="field" />
    </xsl:template>
    <!-- datacite.identifier -->
    <xsl:template match="datacite:identifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>identifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.rights -->
    <xsl:template match="datacite:rights">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>rights</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.subjects -->
    <xsl:template match="datacite:subjects">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>subjects</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:subject">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="datacite:subject">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>subject</xsl:text>
             </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.sizes -->
    <xsl:template match="datacite:sizes">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>sizes</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:size">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.size -->
    <xsl:template match="datacite:size">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>size</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocations -->
    <xsl:template match="datacite:geoLocations">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocations</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:geoLocation">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocation -->
    <xsl:template match="datacite:geoLocation">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocation</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationPoint -->
    <xsl:template match="datacite:geoLocationPoint">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocationPoint</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates
                select="datacite:pointLongitude" />
            <xsl:apply-templates
                select="datacite:pointLatitude" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationBox -->
    <xsl:template match="datacite:geoLocationBox">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocationBox</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates
                select="datacite:westBoundLongitude" />
            <xsl:apply-templates
                select="datacite:eastBoundLongitude" />
            <xsl:apply-templates
                select="datacite:southBoundLatitude" />
            <xsl:apply-templates
                select="datacite:northBoundLatitude" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationBox.westBoundLongitude -->
    <xsl:template match="datacite:westBoundLongitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>westBoundLongitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationBox.eastBoundLongitude -->
    <xsl:template match="datacite:eastBoundLongitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>eastBoundLongitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationBox.southBoundLatitude -->
    <xsl:template match="datacite:southBoundLatitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>southBoundLatitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationBox.northBoundLatitude -->
    <xsl:template match="datacite:northBoundLatitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>northBoundLatitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationPlace -->
    <xsl:template match="datacite:geoLocationPlace">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocationPlace</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.geoLocationPolygon -->
    <xsl:template match="datacite:geoLocationPolygon">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>geoLocationPolygon</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates
                select="datacite:polygonPoint" />
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.polygonPoint -->
    <xsl:template match="datacite:polygonPoint">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>polygonPoint</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates
                select="datacite:pointLongitude" />
            <xsl:apply-templates
                select="datacite:pointLatitude" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.inPolygonPoint -->
    <xsl:template match="datacite:inPolygonPoint">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>inPolygonPoint</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates
                select="datacite:pointLongitude" />
            <xsl:apply-templates
                select="datacite:pointLatitude" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.*.pointLongitude -->
    <xsl:template match="datacite:pointLongitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>pointLongitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- datacite.*.pointLatitude -->
    <xsl:template match="datacite:pointLatitude">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>pointLatitude</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>


    <!-- datacite attributes -->
    <xsl:template match="@titleType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>    
    <xsl:template match="@contributorType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@nameType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>    
    <xsl:template match="@nameIdentifierScheme">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@schemeURI">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@schemeType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@relationType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@relatedMetadataScheme">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@resourceTypeGeneral">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@relatedIdentifierType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@alternateIdentifierType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@alternateIdentifierType" mode="tid">
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:value-of select="local-name(.)" />
            </xsl:attribute>
            <xsl:text>URN</xsl:text>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@identifierType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@rightsURI">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@subjectScheme">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@valueURI">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>




    <!-- oaire -->
    <xsl:template name="oaire">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>oaire</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates
                select="*/oaire:fundingReferences" />
            <xsl:apply-templates
                select="*/oaire:resourceType" />
            <xsl:apply-templates
                select="*/oaire:licenseCondition" />
            <xsl:apply-templates select="*/oaire:version" />
            <!-- TODO: discuss this added <files> element -->
            <xsl:element name="element">
                <xsl:attribute name="name">
            <xsl:text>files</xsl:text>
         </xsl:attribute>
                <xsl:apply-templates select="*/oaire:file" />
            </xsl:element>
            <!-- TODO: discuss this added <citation> element -->
            <xsl:element name="element">
                <xsl:attribute name="name">
            <xsl:text>citation</xsl:text>
         </xsl:attribute>
                <xsl:apply-templates
                    select="*/oaire:citationTitle" />
                <xsl:apply-templates
                    select="*/oaire:citationVolume" />
                <xsl:apply-templates
                    select="*/oaire:citationIssue" />
                <xsl:apply-templates
                    select="*/oaire:citationStartPage" />
                <xsl:apply-templates
                    select="*/oaire:citationEndPage" />
                <xsl:apply-templates
                    select="*/oaire:citationEdition" />
                <xsl:apply-templates
                    select="*/oaire:citationConferencePlace" />
                <xsl:apply-templates
                    select="*/oaire:citationConferenceDate" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- oaire.resourceType -->
    <xsl:template match="oaire:resourceType">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>resourceType</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.fundingReferences -->
    <xsl:template match="oaire:fundingReferences">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>fundingReferences</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./oaire:fundingReference">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- oaire.fundingReference -->
    <xsl:template match="oaire:fundingReference">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>fundingReference</xsl:text>
         </xsl:attribute>
            <xsl:element name="element">
                <xsl:attribute name="name">
               <xsl:text>funderName</xsl:text>
            </xsl:attribute>
                <xsl:apply-templates
                    select="oaire:funderName/text()" mode="field" />
            </xsl:element>
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="oaire:fundingStream">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>fundingStream</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="oaire:awardNumber">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>awardNumber</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="oaire:awardTitle">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>awardTitle</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire:funderIdentifier -->
    <xsl:template match="oaire:funderIdentifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>funderIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.licenseCondition -->
    <xsl:template match="oaire:licenseCondition">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>licenseCondition</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.version -->
    <xsl:template match="oaire:version">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>version</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.file -->
    <xsl:template match="oaire:file">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>file</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationTitle -->
    <xsl:template match="oaire:citationTitle">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationTitle</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationVolume -->
    <xsl:template match="oaire:citationVolume">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationVolume</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationIssue -->
    <xsl:template match="oaire:citationIssue">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationIssue</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationStartPage -->
    <xsl:template match="oaire:citationStartPage">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationStartPage</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationEndPage -->
    <xsl:template match="oaire:citationEndPage">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationEndPage</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationEdition -->
    <xsl:template match="oaire:citationEdition">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationEdition</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationConferencePlace -->
    <xsl:template match="oaire:citationConferencePlace">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationConferencePlace</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- oaire.citationConferenceDate -->
    <xsl:template match="oaire:citationConferenceDate">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>citationConferenceDate</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- oaire attributes -->    
    <xsl:template match="@awardURI">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@funderIdentifierType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>    
    <xsl:template match="@uri">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@startDate">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@mimeType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@accessRightsURI">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@objectType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>

    <!-- dcterms -->
    <xsl:template name="dcterms">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>dcterms</xsl:text>
            </xsl:attribute>

            <!-- TODO: discuss this added <files> element -->
            <xsl:if test="//dcterms:audience">
                <xsl:element name="element">
                    <xsl:attribute name="name">
                <xsl:text>audience</xsl:text>
             </xsl:attribute>
                    <xsl:apply-templates
                        select="//dcterms:audience" />
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dcterms:audience">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>audience</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>


    <!-- xml attributes -->
    <xsl:template match="@*[local-name()='lang']">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>


    <!-- generic template for fields -->
    <xsl:template match="@*" mode="field">
        <xsl:element name="field">
            <xsl:attribute name="name">
            <xsl:value-of select="local-name(.)" />
         </xsl:attribute>
            <xsl:value-of select="normalize-space(.)" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()" mode="field">
        <xsl:element name="field">
            <xsl:attribute name="name">
            <xsl:text>value</xsl:text>
         </xsl:attribute>
            <xsl:value-of select="normalize-space(.)" />
        </xsl:element>
    </xsl:template>

    <!-- ignore all non specified text values or attributes -->
    <xsl:template match="text()|@*" />
</xsl:stylesheet>
