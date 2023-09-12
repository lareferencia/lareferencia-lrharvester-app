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
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="utf-8" />

    <!-- root -->
    <xsl:template match="/">
        <xsl:element name="metadata">
            <xsl:call-template name="datacite" />
        </xsl:element>
    </xsl:template>

    <!-- datacite -->
    <xsl:template name="datacite">
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>dc</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="*/datacite:language" />
            <xsl:apply-templates select="*/datacite:descriptions" />
            <xsl:apply-templates select="*/datacite:publisher" />
            <xsl:apply-templates select="*/datacite:formats" />
        </xsl:element>
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>datacite</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="*/datacite:identifier" />
            <xsl:apply-templates select="*/datacite:creators" />
            <xsl:apply-templates select="*/datacite:titles" />
            <xsl:apply-templates select="*/datacite:subjects" />
            <xsl:apply-templates
                select="*/datacite:contributors" />
            <xsl:apply-templates select="*/datacite:dates" />
            
            <xsl:apply-templates
                select="*/datacite:alternateIdentifiers" />
            <xsl:apply-templates
                select="*/datacite:relatedIdentifiers" />
            
            <xsl:apply-templates select="*/datacite:rightsList" mode="accessType" />
            
            <xsl:apply-templates select="*/datacite:sizes" />
            <xsl:apply-templates
                select="*/datacite:geoLocations" />
        </xsl:element>
        <xsl:element name="element">
            <xsl:attribute name="name">
               <xsl:text>oaire</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="*/datacite:resourceType" />
            <xsl:apply-templates select="*/datacite:version" />
            <xsl:apply-templates select="*/datacite:rightsList" mode="license" />
            <xsl:apply-templates select="*/datacite:fundingReferences" />
        </xsl:element>
    </xsl:template>


    <!-- DC -->

    <!-- dc.language -->
    <xsl:template match="datacite:language">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>language</xsl:text>
         </xsl:attribute>
            <xsl:for-each select="./datacite:language">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- dc.description -->
    <xsl:template match="datacite:descriptions">
        <xsl:for-each select="./datacite:description">
            <xsl:apply-templates select="." />
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="datacite:description">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>description</xsl:text>
             </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- dc.publisher -->
    <xsl:template match="datacite:publisher">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>publisher</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- dc.format -->
    <xsl:template match="datacite:formats">
        <xsl:for-each select="./datacite:format">
            <xsl:apply-templates select="." />
        </xsl:for-each>
    </xsl:template>
    <!-- datacite.format -->
    <xsl:template match="datacite:format">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>format</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- DATACITE -->

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
                <xsl:apply-templates select="//datacite:publicationYear" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- datacite.date -->
    <xsl:template match="datacite:date">
        <xsl:apply-templates select="./text()"
            mode="field" />
    </xsl:template>

    <!-- datacite.dates.date dateType="Issued" -->
    <xsl:template match="datacite:publicationYear">
        <xsl:apply-templates select="./@*" />
        <xsl:element name="element">
            <xsl:attribute name="name">
                 <xsl:text>Issued</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'value'"/>
                <xsl:with-param name="value" select="."/>
            </xsl:call-template>
        </xsl:element>
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
    <xsl:template match="datacite:rightsList" mode="accessType">
        <xsl:variable name="eu_prefix" select="'info:eu-repo/semantics/'"/>
        <xsl:for-each select="./datacite:rights">
            <xsl:if test="starts-with(@rightsURI, $eu_prefix)">
                <xsl:apply-templates select="." mode="accessType"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="datacite:rights" mode="accessType">
        <xsl:variable name="rightsURI">
            <xsl:call-template name="resolveRightsURI">
                <xsl:with-param name="field" select="@rightsURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="rightsValue">
            <xsl:call-template name="resolveRightsValue">
                <xsl:with-param name="field" select="$rightsURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>rights</xsl:text>
             </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'rightsURI'"/>
                <xsl:with-param name="value" select="$rightsURI"/>
            </xsl:call-template>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'value'"/>
                <xsl:with-param name="value" select="$rightsValue"/>
            </xsl:call-template>
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



    <!-- OAIRE -->


    <!-- oaire.resourceType -->
    <xsl:template match="datacite:resourceType">
        <xsl:variable name="uri">
            <xsl:call-template name="resolveResourceTypeURI">
                <xsl:with-param name="field" select="./text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="resourceType">
            <xsl:call-template name="resolveResourceType">
                <xsl:with-param name="field" select="$uri"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>resourceType</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'uri'"/>
                <xsl:with-param name="value" select="$uri"/>
            </xsl:call-template>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'value'"/>
                <xsl:with-param name="value" select="$resourceType"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="datacite:version">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>version</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- oaire.rights -->
    <xsl:template match="datacite:rightsList" mode="license">
        <xsl:variable name="creativecommons" select="'creativecommons.org/licenses'"/>
        <xsl:for-each select="./datacite:rights">
            <xsl:if test="contains(@rightsURI, $creativecommons)">
                <xsl:apply-templates select="." mode="license"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="datacite:rights" mode="license">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>licenseCondition</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="field">
                <xsl:with-param name="name" select="'uri'"/>
                <xsl:with-param name="value" select="@rightsURI"/>
            </xsl:call-template>
            <xsl:apply-templates select="./text()"
                    mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- oaire.fundingReferences -->
    <xsl:template match="datacite:fundingReferences">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>fundingReferences</xsl:text>
            </xsl:attribute>
            <xsl:for-each select="./datacite:fundingReference">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- oaire.fundingReferences.fundingReference -->
    <xsl:template match="datacite:fundingReference">
        <xsl:element name="element">
            <xsl:attribute name="name">
                <xsl:text>fundingReference</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="*" />
        </xsl:element>
    </xsl:template>

    <!-- oaire.fundingReferences.fundingReference.funderName -->
    <xsl:template match="datacite:funderName">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>funderName</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>


    <!-- oaire.fundingReferences.fundingReference.funderIdentifier -->
    <xsl:template match="datacite:funderIdentifier">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>funderIdentifier</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>

    <!-- oaire.fundingReferences.fundingReference.awardNumber -->
    <xsl:template match="datacite:awardNumber">
        <xsl:element name="element">
            <xsl:attribute name="name">
            <xsl:text>awardNumber</xsl:text>
         </xsl:attribute>
            <xsl:apply-templates select="./@*" />
            <xsl:apply-templates select="./text()"
                mode="field" />
        </xsl:element>
    </xsl:template>
    <!-- // -->

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
        <xsl:call-template name="field">
            <xsl:with-param name="name" select="local-name(.)"/>
            <xsl:with-param name="value" select="'URN'"/>
        </xsl:call-template>
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
    <xsl:template match="@funderIdentifierType">
        <xsl:apply-templates select="." mode="field" />
    </xsl:template>
    <xsl:template match="@awardURI">
        <xsl:apply-templates select="." mode="field" />
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
    
    
    <xsl:template name="resolveRightsValue">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="$lc_value = 'open access' or ends-with($lc_value,'openaccess') or $field = 'http://purl.org/coar/access_right/c_abf2'">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'embargoed access' or ends-with($lc_value,'embargoedaccess') or $field = 'http://purl.org/coar/access_right/c_f1cf'">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'restricted access' or ends-with($lc_value,'restrictedaccess') or $field = 'http://purl.org/coar/access_right/c_16ec'">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_value = 'metadata only access' or ends-with($lc_value,'closedaccess') or $field = 'http://purl.org/coar/access_right/c_14cb'">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$field"/>
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
            <!-- openaire 4.0 doesn't support narrower concepts for datasets - it will be used a broader term -->
            <xsl:when test="$lc_dc_type = 'dataset' or $lc_dc_type = 'clinical trial data' or $lc_dc_type = 'encoded data' or $lc_dc_type = 'recorded data' or $lc_dc_type = 'genomic data' or $lc_dc_type = 'measurement and test data' or $lc_dc_type = 'laboratory notebook' or $lc_dc_type = 'simulation data' or $lc_dc_type = 'aggregated data' or $lc_dc_type = 'compiled data' or $lc_dc_type = 'survey data' or $lc_dc_type = 'geospatial data' or $lc_dc_type = 'observational data' or $lc_dc_type = 'experimental data'">
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
    <xsl:template name="resolveResourceType">
        <xsl:param name="field"/>
        <xsl:variable name="lc_field">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="$lc_field = 'annotation' or $field = 'http://purl.org/coar/resource_type/c_1162'">
                <xsl:text>annotation</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'journal'">
                <xsl:text>journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'journal article' or $lc_field = 'article' or $lc_field = 'journalarticle' or $field = 'http://purl.org/coar/resource_type/c_6501' or $field = 'info:eu-repo/semantics/article'">
                <xsl:text>journal article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'editorial' or $field = 'http://purl.org/coar/resource_type/c_b239'">
                <xsl:text>editorial</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'bachelor thesis' or $lc_field = 'bachelorthesis' or $field = 'info:eu-repo/semantics/bachelorThesis' or $field = 'http://purl.org/coar/resource_type/c_7a1f'">
                <xsl:text>bachelor thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'bibliography' or $field = 'http://purl.org/coar/resource_type/c_86bc'">
                <xsl:text>bibliography</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'book' or $field = 'http://purl.org/coar/resource_type/c_2f33' or $field = 'info:eu-repo/semantics/book'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'book part' or $lc_field = 'bookpart' or $field = 'http://purl.org/coar/resource_type/c_3248' or $field = 'info:eu-repo/semantics/bookPart'">
                <xsl:text>book part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'book review' or $lc_field = 'bookreview' or $field = 'http://purl.org/coar/resource_type/c_ba08'">
                <xsl:text>book review</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'website' or $field = 'http://purl.org/coar/resource_type/c_7ad9'">
                <xsl:text>website</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'interactive resource' or $lc_field = 'interactiveresource' or $field = 'http://purl.org/coar/resource_type/c_e9a0'">
                <xsl:text>interactive resource</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference proceedings' or $lc_field = 'conferenceproceedings' or $field = 'http://purl.org/coar/resource_type/c_f744'">
                <xsl:text>conference proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference object' or $lc_field = 'conferenceobject' or $field = 'http://purl.org/coar/resource_type/c_c94f'">
                <xsl:text>conference object</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference paper' or $lc_field = 'conferencepaper' or $field = 'http://purl.org/coar/resource_type/c_5794'">
                <xsl:text>conference paper</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference poster' or $lc_field = 'conferenceposter' or $field = 'http://purl.org/coar/resource_type/c_6670'">
                <xsl:text>conference poster</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'contribution to journal' or $lc_field = 'contributiontojournal' or $field = 'http://purl.org/coar/resource_type/c_3e5a'">
                <xsl:text>contribution to journal</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'datapaper' or $field = 'http://purl.org/coar/resource_type/c_beb9'">
                <xsl:text>data paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'dataset' or $field = 'http://purl.org/coar/resource_type/c_ddb1'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'doctoral thesis' or $lc_field = 'doctoralthesis' or $field = 'http://purl.org/coar/resource_type/c_db06' or $field = 'info:eu-repo/semantics/doctoralThesis'">
                <xsl:text>doctoral thesis</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'image' or $field = 'http://purl.org/coar/resource_type/c_c513'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'lecture' or $field = 'http://purl.org/coar/resource_type/c_8544'">
                <xsl:text>lecture</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'letter' or $field = 'http://purl.org/coar/resource_type/c_0857'">
                <xsl:text>letter</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'master thesis' or $lc_field = 'masterthesis' or $field = 'http://purl.org/coar/resource_type/c_bdcc' or $field = 'info:eu-repo/semantics/masterThesis'">
                <xsl:text>master thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'moving image' or $lc_field = 'movingimage' or $field = 'http://purl.org/coar/resource_type/c_8a7e'">
                <xsl:text>moving image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'periodical' or $field = 'http://purl.org/coar/resource_type/c_2659'">
                <xsl:text>periodical</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'letter to the editor' or $lc_field = 'lettertotheeditor' or $field = 'http://purl.org/coar/resource_type/c_545b'">
                <xsl:text>letter to the editor</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'patent' or $field = 'http://purl.org/coar/resource_type/c_15cd'">
                <xsl:text>patent</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'preprint' or $field = 'http://purl.org/coar/resource_type/c_816b'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'report' or $field = 'http://purl.org/coar/resource_type/c_93fc' or $field = 'info:eu-repo/semantics/report'">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'report part' or $lc_field = 'reportpart' or $field = 'http://purl.org/coar/resource_type/c_ba1f'">
                <xsl:text>report part</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'research proposal' or $lc_field = 'researchproposal' or $field = 'http://purl.org/coar/resource_type/c_baaf'">
                <xsl:text>research proposal</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'review' or $field = 'http://purl.org/coar/resource_type/c_efa0'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'software' or $field = 'http://purl.org/coar/resource_type/c_5ce6'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'still image' or $lc_field = 'stillimage' or $field = 'http://purl.org/coar/resource_type/c_ecc8'">
                <xsl:text>still image</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'technical documentation' or $lc_field = 'technicaldocumentation' or $field = 'http://purl.org/coar/resource_type/c_71bd'">
                <xsl:text>technical documentation</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'workflow' or $field = 'http://purl.org/coar/resource_type/c_393c'">
                <xsl:text>workflow</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'working paper' or $lc_field = 'workingpaper' or $field = 'http://purl.org/coar/resource_type/c_8042'">
                <xsl:text>working paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'thesis' or $field = 'http://purl.org/coar/resource_type/c_46ec'">
                <xsl:text>thesis</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'cartographic material' or $lc_field = 'cartographicmaterial' or $field = 'http://purl.org/coar/resource_type/c_12cc'">
                <xsl:text>cartographic material</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'map' or $field = 'http://purl.org/coar/resource_type/c_12cd'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'video' or $field = 'http://purl.org/coar/resource_type/c_12ce'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'sound' or $field = 'http://purl.org/coar/resource_type/c_18cc'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'musical composition' or $lc_field = 'musicalcomposition' or $field = 'http://purl.org/coar/resource_type/c_18cd'">
                <xsl:text>musical composition</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_field = 'text' or $field = 'http://purl.org/coar/resource_type/c_18cf'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference paper not in proceedings' or $lc_field = 'conferencepapernotinproceedings' or $field = 'http://purl.org/coar/resource_type/c_18cp'">
                <xsl:text>conference paper not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'conference poster not in proceedings' or $lc_field = 'conferenceposternotinproceedings' or $field = 'http://purl.org/coar/resource_type/c_18co'">
                <xsl:text>conference poster not in proceedings</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'musical notation' or $field = 'http://purl.org/coar/resource_type/c_18cw'">
                <xsl:text>musical notation</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'internal report' or $lc_field = 'internalreport' or $field = 'http://purl.org/coar/resource_type/c_18ww'">
                <xsl:text>internal report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'memorandum' or $field = 'http://purl.org/coar/resource_type/c_18wz'">
                <xsl:text>memorandum</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'other type of report'  or $lc_field = 'othertypeofreport' or $field = 'http://purl.org/coar/resource_type/c_18wq'">
                <xsl:text>other type of report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'policy report' or $lc_field = 'policyreport'  or $field = 'http://purl.org/coar/resource_type/c_186u'">
                <xsl:text>policy report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'project deliverable' or $lc_field = 'projectdeliverable' or $field = 'http://purl.org/coar/resource_type/c_18op'">
                <xsl:text>project deliverable</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'report to funding agency' or $lc_field = 'reporttofundingagency' or $field = 'http://purl.org/coar/resource_type/c_18hj'">
                <xsl:text>report to funding agency</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'research report' or $lc_field = 'researchreport' or $field = 'http://purl.org/coar/resource_type/c_18ws'">
                <xsl:text>research report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'technical report' or $lc_field = 'technicalreport' or $field = 'http://purl.org/coar/resource_type/c_18gh'">
                <xsl:text>technical report</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'review article' or $lc_field = 'reviewarticle' or $field = 'http://purl.org/coar/resource_type/c_dcae04bc'">
                <xsl:text>review article</xsl:text>
            </xsl:when>
            <xsl:when
                test="$lc_field = 'research article' or $lc_field = 'researcharticle' or $field = 'http://purl.org/coar/resource_type/c_2df8fbb1'">
                <xsl:text>research article</xsl:text>
            </xsl:when>

            <!-- other cases -->
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

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
    <xsl:template match="text()|@*" />
</xsl:stylesheet>
