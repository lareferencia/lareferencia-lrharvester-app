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

<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:datacite="http://datacite.org/schema/kernel-4"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                version="2.0"
>
  
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  
  <xsl:param name="networkAcronym"/>
  <xsl:param name="networkName"/>
  <xsl:param name="institutionName"/>
  
  <xsl:param name="vufind_id"/>
  <xsl:param name="header_id"/>
  <xsl:param name="record_id"/>
  <xsl:strip-space elements="*"/>
  
  
  <xsl:template match="/">
    <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.lyncode.com/xoai"
              xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">
      <xsl:if test="//dc:title">
        <xsl:call-template name="title"/>
      </xsl:if>
      <xsl:if test="//dc:publisher">
        <xsl:call-template name="publisher"/>
      </xsl:if>
      <xsl:if test="//datacite:creator">
        <xsl:call-template name="creator"/>
      </xsl:if>
      <xsl:if test="//datacite:contributor">
        <xsl:call-template name="contributor"/>
      </xsl:if>
      <xsl:if test="//datacite:fundingReference">
        <xsl:call-template name="fundingReferences"/>
      </xsl:if>
      <xsl:if test="//datacite:relatedIdentifier">
        <xsl:call-template name="relatedIdentifier"/>
      </xsl:if>
      <xsl:if test="//datacite:alternateIdentifier">
        <xsl:call-template name="alternateIdentifier"/>
      </xsl:if>
      <xsl:if test="//dc:description">
        <xsl:call-template name="descriptions"/>
      </xsl:if>
      <xsl:if test="//dc:language">
        <xsl:call-template name="languages"/>
      </xsl:if>
      <xsl:if test="//dc:date">
        <xsl:call-template name="dates"/>
      </xsl:if>
      <xsl:if test="//dc:type">
        <xsl:call-template name="type"/>
      </xsl:if>
      <xsl:if test="//dc:rights">
        <xsl:call-template name="right"/>
      </xsl:if>
      <xsl:if test="//dc:subject">
        <xsl:call-template name="subject"/>
      </xsl:if>
      <xsl:if test="//dc:file">
        file
        <xsl:call-template name="file"/>
      </xsl:if>
    
    </metadata>
  </xsl:template>
  
  
  <xsl:template name="creator">
    
    <xsl:for-each select="//datacite:creator">
      <element name="creator">
        <element name="creatorName">
          <field name="value">
            <xsl:value-of select="datacite:creatorName"/>
          </field>
        </element>
        
        <xsl:if test="datacite:givenName">
          <element name="givenName">
            <field name="value">
              <xsl:value-of select="datacite:givenName"/>
            </field>
          </element>
        </xsl:if>
        <xsl:if test="datacite:familyName">
          <element name="familyName">
            <field name="value">
              <xsl:value-of select="datacite:familyName"/>
            </field>
          </element>
        </xsl:if>
  
        <xsl:if test="datacite:nameIdentifier">
          <xsl:for-each select="datacite:nameIdentifier">
            <element name="nameIdentifier">
              <element name="nameIdentifierScheme">
                <field name="value">
                  <xsl:value-of select="@nameIdentifierScheme"/>
                </field>
              </element>
              <element name="SchemeURI">
                <field name="value">
                  <xsl:value-of select="@SchemeURI"/>
                </field>
              </element>
              <field name="value">
                <xsl:value-of select="."/>
              </field>
            </element>
          </xsl:for-each>
        </xsl:if>
        
        <xsl:if test="datacite:affiliation">
          <element name="affiliation">
            <field name="value">
              <xsl:value-of select="datacite:affiliation"/>
            </field>
          </element>
        </xsl:if>
      </element>
    </xsl:for-each>

  </xsl:template>
  
  <xsl:template name="contributor">
    <xsl:for-each select="//datacite:contributor">
      <element name="contributor">
        <xsl:if test="datacite:contributorName">
          <element name="contributorName">
            <field name="value">
              <xsl:value-of select="datacite:contributorName"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:if test="datacite:givenName">
          <element name="givenName">
            <field name="value">
              <xsl:value-of select="datacite:givenName"/>
            </field>
          </element>
        </xsl:if>
        <xsl:if test="datacite:familyName">
          <element name="familyName">
            <field name="value">
              <xsl:value-of select="datacite:familyName"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:for-each select="datacite:nameIdentifier">
          <element name="nameIdentifier">
            <element name="nameIdentifierScheme">
              <field name="value">
                <xsl:value-of select="@nameIdentifierScheme"/>
              </field>
            </element>
            <xsl:if test="@schemeURI">
              <element name="schemeURI">
                <field name="value">
                  <xsl:value-of select="@schemeURI"/>
                </field>
              </element>
            </xsl:if>
            <field name="value">
              <xsl:value-of select="."/>
            </field>
          </element>
        </xsl:for-each>
        
        <xsl:for-each select="datacite:affiliation">
          <element name="affiliation">
            <field name="value">
              <xsl:value-of select="datacite:affiliation"/>
            </field>
          </element>
        </xsl:for-each>
        <xsl:for-each select="datacite:contributorType">
          <element name="contributorType">
            <field name="value">
              <xsl:value-of select="datacite:contributorType"/>
            </field>
          </element>
        </xsl:for-each>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="fundingReferences">
    <xsl:for-each select="//datacite:fundingReference">
      <element name="fundingReference">
        <xsl:if test="datacite:funderName">
          <element name="funderName">
            <field name="value">
              <xsl:value-of select="datacite:funderName"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:if test="datacite:fundingStream">
          <element name="fundingStream">
            <field name="value">
              <xsl:value-of select="datacite:fundingStream"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:if test="datacite:funderIdentifier">
          <element name="funderIdentifier">
            <element name="funderIdentifierType">
              <field name="value">
                <xsl:value-of select="datacite:funderIdentifier/@funderIdentifierType"/>
              </field>
            </element>
            <field name="value">
              <xsl:value-of select="datacite:funderIdentifier"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:if test="datacite:awardNumber">
          <element name="awardNumber">
            <element name="awardURI">
              <field name="value">
                <xsl:value-of select="datacite:awardNumber/@awardURI"/>
              </field>
            </element>
            <field name="value">
              <xsl:value-of select="datacite:awardNumber"/>
            </field>
          </element>
        </xsl:if>
        
        <xsl:if test="datacite:awardTitle">
          <element name="awardTitle">
            <field name="value">
              <xsl:value-of select="datacite:awardTitle"/>
            </field>
          </element>
        </xsl:if>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="alternateIdentifier">
    <xsl:for-each select="//datacite:alternateIdentifier">
      <element name="alternateIdentifier">
        <element name="alternateIdentifierType">
          <field name="value">
            <xsl:value-of select="@alternateIdentifierType"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="relatedIdentifier">
    <xsl:for-each select="//datacite:relatedIdentifier">
      <element name="relatedIdentifier">
        <element name="relatedIdentifierType">
          <field name="value">
            <xsl:value-of select="@relatedIdentifierType"/>
          </field>
        </element>
        <element name="relationType">
          <field name="value">
            <xsl:value-of select="@relationType"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="title">
    <xsl:for-each select="//dc:title">
      <element name="title">
        <element name="xml:lang">
          <field name="value">
            <xsl:value-of select="@xml:lang"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="publisher">
    <xsl:for-each select="//dc:publisher">
      <element name="publisher">
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="descriptions">
    <xsl:for-each select="//dc:description">
      <element name="description">
        <element name="xml:lang">
          <field name="value">
            <xsl:value-of select="@xml:lang"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="languages">
    <xsl:for-each select="//dc:language">
      <element name="language">
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="dates">
    <xsl:for-each select="//dc:date">
      <element name="date">
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="type">
    <xsl:for-each select="//dc:type">
      <element name="type">
        <element name="resource">
          <field name="value">
            <xsl:value-of select="@rdf:resource"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="right">
    <xsl:for-each select="//dc:rights">
      <element name="rights">
        <element name="resource">
          <field name="value">
            <xsl:value-of select="@rdf:resource"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="subject">
    <xsl:for-each select="//dc:subject">
      <element name="subject">
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="file">
    <xsl:for-each select="//dc:file">
      <element name="file">
        <element name="accessRights">
          <field>
            <xsl:value-of select="@accessRights"/>
          </field>
        </element>
        <element name="mimeType">
          <field>
            <xsl:value-of select="@mimeType"/>
          </field>
        </element>
        <field name="value">
          <xsl:value-of select="."/>
        </field>
      </element>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
