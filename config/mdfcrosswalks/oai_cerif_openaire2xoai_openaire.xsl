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
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.lyncode.com/xoai"
    xmlns:cerif="https://www.openaire.eu/cerif-profile/1.2/"
    xmlns:fnc="http://www.lareferencia.org/xslt/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="cerif fnc xs">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="identifier"/>
    <xsl:param name="timestamp"/>

    <xsl:function name="fnc:normalized" as="xs:string">
        <xsl:param name="value" as="item()*"/>
        <xsl:sequence select="normalize-space(string-join(for $item in $value return string($item), ' '))"/>
    </xsl:function>

    <xsl:function name="fnc:publisher-name" as="xs:string">
        <xsl:param name="publisher" as="element()*"/>
        <xsl:variable name="display" select="fnc:normalized(($publisher/cerif:DisplayName, $publisher/cerif:Name, $publisher/cerif:OrgUnit/cerif:DisplayName, $publisher/cerif:OrgUnit/cerif:Name)[normalize-space()][1])"/>
        <xsl:sequence select="if ($display != '') then $display else fnc:normalized(($publisher/cerif:Acronym, $publisher/cerif:OrgUnit/cerif:Acronym)[normalize-space()][1])"/>
    </xsl:function>

    <xsl:function name="fnc:person-given-name" as="xs:string">
        <xsl:param name="person" as="element()*"/>
        <xsl:sequence select="fnc:normalized(($person/cerif:FirstNames, $person/cerif:PersonName/cerif:FirstNames)[normalize-space()][1])"/>
    </xsl:function>

    <xsl:function name="fnc:person-family-name" as="xs:string">
        <xsl:param name="person" as="element()*"/>
        <xsl:sequence select="fnc:normalized(($person/cerif:FamilyNames, $person/cerif:PersonName/cerif:FamilyNames)[normalize-space()][1])"/>
    </xsl:function>

    <xsl:function name="fnc:person-name" as="xs:string">
        <xsl:param name="person" as="element()*"/>
        <xsl:variable name="display" select="fnc:normalized(($person/cerif:DisplayName, $person/cerif:PersonName/cerif:DisplayName, $person/cerif:Name, $person/cerif:PersonName/cerif:Name)[normalize-space()][1])"/>
        <xsl:variable name="given" select="fnc:person-given-name($person)"/>
        <xsl:variable name="family" select="fnc:person-family-name($person)"/>
        <xsl:sequence select="
            if ($display != '') then $display
            else if ($family != '' and $given != '') then concat($family, ', ', $given)
            else if ($family != '') then $family
            else $given"/>
    </xsl:function>

    <xsl:function name="fnc:resource-type-uri" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="normalized" select="lower-case(normalize-space($value))"/>
        <xsl:choose>
            <xsl:when test="starts-with(normalize-space($value), 'http://purl.org/coar/resource_type/')">
                <xsl:sequence select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$normalized = ('journal article', 'article', 'journalarticle', 'info:eu-repo/semantics/article')">
                <xsl:text>http://purl.org/coar/resource_type/c_6501</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('research article', 'http://purl.org/coar/resource_type/c_2df8fbb1')">
                <xsl:text>http://purl.org/coar/resource_type/c_2df8fbb1</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('review article', 'http://purl.org/coar/resource_type/c_dcae04bc')">
                <xsl:text>http://purl.org/coar/resource_type/c_dcae04bc</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('conference paper', 'http://purl.org/coar/resource_type/c_5794')">
                <xsl:text>http://purl.org/coar/resource_type/c_5794</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('book', 'info:eu-repo/semantics/book')">
                <xsl:text>http://purl.org/coar/resource_type/c_2f33</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('book part', 'bookpart', 'info:eu-repo/semantics/bookpart')">
                <xsl:text>http://purl.org/coar/resource_type/c_3248</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('master thesis', 'masterthesis', 'info:eu-repo/semantics/masterthesis')">
                <xsl:text>http://purl.org/coar/resource_type/c_bdcc</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('doctoral thesis', 'doctoralthesis', 'info:eu-repo/semantics/doctoralthesis')">
                <xsl:text>http://purl.org/coar/resource_type/c_db06</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('report', 'info:eu-repo/semantics/report')">
                <xsl:text>http://purl.org/coar/resource_type/c_93fc</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('preprint', 'info:eu-repo/semantics/preprint')">
                <xsl:text>http://purl.org/coar/resource_type/c_816b</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>http://purl.org/coar/resource_type/c_1843</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fnc:resource-type-value" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="normalized" select="lower-case(normalize-space($value))"/>
        <xsl:choose>
            <xsl:when test="$normalized = ('journal article', 'article', 'journalarticle', 'info:eu-repo/semantics/article', 'http://purl.org/coar/resource_type/c_6501')">
                <xsl:text>journal article</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('research article', 'http://purl.org/coar/resource_type/c_2df8fbb1')">
                <xsl:text>research article</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('review article', 'http://purl.org/coar/resource_type/c_dcae04bc')">
                <xsl:text>review article</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('conference paper', 'http://purl.org/coar/resource_type/c_5794')">
                <xsl:text>conference paper</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('book', 'http://purl.org/coar/resource_type/c_2f33', 'info:eu-repo/semantics/book')">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('book part', 'bookpart', 'http://purl.org/coar/resource_type/c_3248', 'info:eu-repo/semantics/bookpart')">
                <xsl:text>book part</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('master thesis', 'masterthesis', 'http://purl.org/coar/resource_type/c_bdcc', 'info:eu-repo/semantics/masterthesis')">
                <xsl:text>master thesis</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('doctoral thesis', 'doctoralthesis', 'http://purl.org/coar/resource_type/c_db06', 'info:eu-repo/semantics/doctoralthesis')">
                <xsl:text>doctoral thesis</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('report', 'http://purl.org/coar/resource_type/c_93fc', 'info:eu-repo/semantics/report')">
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('preprint', 'http://purl.org/coar/resource_type/c_816b', 'info:eu-repo/semantics/preprint')">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fnc:rights-uri" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="normalized" select="lower-case(normalize-space($value))"/>
        <xsl:choose>
            <xsl:when test="starts-with(normalize-space($value), 'http://purl.org/coar/access_right/')">
                <xsl:sequence select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$normalized = ('open access', 'openaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_abf2</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('embargoed access', 'embargoedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_f1cf</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('restricted access', 'restrictedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_16ec</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('metadata only access', 'closedaccess')">
                <xsl:text>http://purl.org/coar/access_right/c_14cb</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fnc:rights-value" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="normalized" select="lower-case(normalize-space($value))"/>
        <xsl:choose>
            <xsl:when test="$normalized = ('open access', 'openaccess', 'http://purl.org/coar/access_right/c_abf2')">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('embargoed access', 'embargoedaccess', 'http://purl.org/coar/access_right/c_f1cf')">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('restricted access', 'restrictedaccess', 'http://purl.org/coar/access_right/c_16ec')">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when test="$normalized = ('metadata only access', 'closedaccess', 'http://purl.org/coar/access_right/c_14cb')">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="field">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="normalize-space($value) != ''">
            <field name="{$name}">
                <xsl:value-of select="$value"/>
            </field>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/">
        <metadata>
            <xsl:if test="/*[self::cerif:Publication]">
                <xsl:call-template name="dc"/>
                <xsl:call-template name="datacite"/>
                <xsl:call-template name="oaire"/>
                <element name="dcterms"/>
            </xsl:if>
        </metadata>
    </xsl:template>

    <xsl:template name="dc">
        <element name="dc">
            <xsl:for-each select="/*/cerif:Language[normalize-space()]">
                <element name="language">
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'value'"/>
                        <xsl:with-param name="value" select="normalize-space(.)"/>
                    </xsl:call-template>
                </element>
            </xsl:for-each>

            <xsl:for-each select="/*/cerif:Abstract[normalize-space()]">
                <element name="description">
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'lang'"/>
                        <xsl:with-param name="value" select="string(@xml:lang)"/>
                    </xsl:call-template>
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'value'"/>
                        <xsl:with-param name="value" select="normalize-space(.)"/>
                    </xsl:call-template>
                </element>
            </xsl:for-each>

            <xsl:for-each select="/*/cerif:Publishers/cerif:Publisher">
                <xsl:variable name="publisherName" select="fnc:publisher-name(.)"/>
                <xsl:if test="$publisherName != ''">
                    <element name="publisher">
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$publisherName"/>
                        </xsl:call-template>
                    </element>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="/*/cerif:PublishedIn">
                <xsl:variable name="sourceTitle" select="fnc:normalized((cerif:Title, cerif:Name)[normalize-space()][1])"/>
                <xsl:if test="$sourceTitle != ''">
                    <element name="source">
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$sourceTitle"/>
                        </xsl:call-template>
                    </element>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="/*/cerif:FileLocations/cerif:Medium/cerif:MimeType[normalize-space()]">
                <element name="format">
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'value'"/>
                        <xsl:with-param name="value" select="normalize-space(.)"/>
                    </xsl:call-template>
                </element>
            </xsl:for-each>
        </element>
    </xsl:template>

    <xsl:template name="datacite">
        <xsl:variable name="primaryDoi" select="fnc:normalized(/*/cerif:DOI[normalize-space()][1])"/>
        <xsl:variable name="primaryUrl" select="fnc:normalized(/*/cerif:URL[normalize-space()][1])"/>
        <xsl:variable name="fallbackIdentifier" select="fnc:normalized($identifier)"/>
        <xsl:variable name="accessValue" select="fnc:normalized(/*/cerif:Access[normalize-space()][1])"/>
        <xsl:variable name="accessUri" select="fnc:rights-uri($accessValue)"/>

        <element name="datacite">
            <xsl:if test="/*/cerif:Title[normalize-space()]">
                <element name="titles">
                    <xsl:for-each select="/*/cerif:Title[normalize-space()]">
                        <element name="title">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'lang'"/>
                                <xsl:with-param name="value" select="string(@xml:lang)"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="normalize-space(.)"/>
                            </xsl:call-template>
                        </element>
                    </xsl:for-each>
                </element>
            </xsl:if>

            <xsl:if test="/*/cerif:Authors/cerif:Author/cerif:Person">
                <element name="creators">
                    <xsl:for-each select="/*/cerif:Authors/cerif:Author/cerif:Person">
                        <xsl:variable name="creatorName" select="fnc:person-name(.)"/>
                        <xsl:variable name="givenName" select="fnc:person-given-name(.)"/>
                        <xsl:variable name="familyName" select="fnc:person-family-name(.)"/>
                        <xsl:variable name="orcid" select="fnc:normalized((cerif:ORCID, cerif:PersonName/cerif:ORCID)[normalize-space()][1])"/>
                        <xsl:if test="$creatorName != ''">
                            <element name="creator">
                                <element name="creatorName">
                                    <xsl:call-template name="field">
                                        <xsl:with-param name="name" select="'value'"/>
                                        <xsl:with-param name="value" select="$creatorName"/>
                                    </xsl:call-template>
                                </element>
                                <xsl:if test="$givenName != ''">
                                    <element name="givenName">
                                        <xsl:call-template name="field">
                                            <xsl:with-param name="name" select="'value'"/>
                                            <xsl:with-param name="value" select="$givenName"/>
                                        </xsl:call-template>
                                    </element>
                                </xsl:if>
                                <xsl:if test="$familyName != ''">
                                    <element name="familyName">
                                        <xsl:call-template name="field">
                                            <xsl:with-param name="name" select="'value'"/>
                                            <xsl:with-param name="value" select="$familyName"/>
                                        </xsl:call-template>
                                    </element>
                                </xsl:if>
                                <xsl:if test="$orcid != ''">
                                    <element name="nameIdentifier">
                                        <xsl:call-template name="field">
                                            <xsl:with-param name="name" select="'nameIdentifierScheme'"/>
                                            <xsl:with-param name="value" select="'ORCID'"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="field">
                                            <xsl:with-param name="name" select="'schemeURI'"/>
                                            <xsl:with-param name="value" select="'https://orcid.org'"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="field">
                                            <xsl:with-param name="name" select="'value'"/>
                                            <xsl:with-param name="value" select="$orcid"/>
                                        </xsl:call-template>
                                    </element>
                                </xsl:if>
                            </element>
                        </xsl:if>
                    </xsl:for-each>
                </element>
            </xsl:if>

            <xsl:if test="/*/cerif:Keyword[normalize-space()]">
                <element name="subjects">
                    <xsl:for-each select="/*/cerif:Keyword[normalize-space()]">
                        <element name="subject">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="normalize-space(.)"/>
                            </xsl:call-template>
                        </element>
                    </xsl:for-each>
                </element>
            </xsl:if>

            <xsl:if test="/*/cerif:PublicationDate[normalize-space()]">
                <element name="dates">
                    <element name="date">
                        <element name="Issued">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="normalize-space(/*/cerif:PublicationDate[1])"/>
                            </xsl:call-template>
                        </element>
                    </element>
                </element>
            </xsl:if>

            <element name="identifier">
                <xsl:choose>
                    <xsl:when test="$primaryDoi != ''">
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'identifierType'"/>
                            <xsl:with-param name="value" select="'DOI'"/>
                        </xsl:call-template>
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$primaryDoi"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$primaryUrl != ''">
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'identifierType'"/>
                            <xsl:with-param name="value" select="'URL'"/>
                        </xsl:call-template>
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$primaryUrl"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'identifierType'"/>
                            <xsl:with-param name="value" select="'OAI'"/>
                        </xsl:call-template>
                        <xsl:call-template name="field">
                            <xsl:with-param name="name" select="'value'"/>
                            <xsl:with-param name="value" select="$fallbackIdentifier"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </element>

            <xsl:if test="/*/cerif:ISSN[normalize-space()] or ($primaryUrl != '' and not($primaryUrl = $primaryDoi))">
                <element name="alternateIdentifiers">
                    <xsl:for-each select="/*/cerif:ISSN[normalize-space()]">
                        <element name="alternateIdentifier">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'alternateIdentifierType'"/>
                                <xsl:with-param name="value" select="'ISSN'"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="normalize-space(.)"/>
                            </xsl:call-template>
                        </element>
                    </xsl:for-each>
                    <xsl:if test="$primaryUrl != '' and not($primaryUrl = $primaryDoi)">
                        <element name="alternateIdentifier">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'alternateIdentifierType'"/>
                                <xsl:with-param name="value" select="'URL'"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="$primaryUrl"/>
                            </xsl:call-template>
                        </element>
                    </xsl:if>
                </element>
            </xsl:if>

            <xsl:if test="/*/cerif:PublishedIn or /*/cerif:OriginatesFrom/cerif:Project">
                <element name="relatedIdentifiers">
                    <xsl:for-each select="/*/cerif:PublishedIn">
                        <xsl:variable name="journalIdentifier" select="fnc:normalized((cerif:ISSN, @id, cerif:Title, cerif:Name)[normalize-space()][1])"/>
                        <xsl:variable name="identifierType" select="if (fnc:normalized(cerif:ISSN[1]) != '') then 'ISSN' else if (fnc:normalized(@id) != '') then 'URN' else 'URL'"/>
                        <xsl:if test="$journalIdentifier != ''">
                            <element name="relatedIdentifier">
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'relatedIdentifierType'"/>
                                    <xsl:with-param name="value" select="$identifierType"/>
                                </xsl:call-template>
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'relationType'"/>
                                    <xsl:with-param name="value" select="'IsPartOf'"/>
                                </xsl:call-template>
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'value'"/>
                                    <xsl:with-param name="value" select="$journalIdentifier"/>
                                </xsl:call-template>
                            </element>
                        </xsl:if>
                    </xsl:for-each>

                    <xsl:for-each select="/*/cerif:OriginatesFrom/cerif:Project">
                        <xsl:variable name="projectIdentifier" select="fnc:normalized((@id, cerif:Acronym, cerif:Title, cerif:Name)[normalize-space()][1])"/>
                        <xsl:if test="$projectIdentifier != ''">
                            <element name="relatedIdentifier">
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'relatedIdentifierType'"/>
                                    <xsl:with-param name="value" select="'URN'"/>
                                </xsl:call-template>
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'relationType'"/>
                                    <xsl:with-param name="value" select="'References'"/>
                                </xsl:call-template>
                                <xsl:call-template name="field">
                                    <xsl:with-param name="name" select="'value'"/>
                                    <xsl:with-param name="value" select="$projectIdentifier"/>
                                </xsl:call-template>
                            </element>
                        </xsl:if>
                    </xsl:for-each>
                </element>
            </xsl:if>

            <xsl:if test="$accessValue != ''">
                <element name="rights">
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'rightsURI'"/>
                        <xsl:with-param name="value" select="$accessUri"/>
                    </xsl:call-template>
                    <xsl:call-template name="field">
                        <xsl:with-param name="name" select="'value'"/>
                        <xsl:with-param name="value" select="fnc:rights-value(if ($accessUri != '') then $accessUri else $accessValue)"/>
                    </xsl:call-template>
                </element>
            </xsl:if>
        </element>
    </xsl:template>

    <xsl:template name="oaire">
        <xsl:variable name="accessValue" select="fnc:normalized(/*/cerif:Access[normalize-space()][1])"/>
        <xsl:variable name="accessUri" select="fnc:rights-uri($accessValue)"/>
        <xsl:variable name="typeSource">
            <xsl:choose>
                <xsl:when test="fnc:normalized(/*/cerif:Type[normalize-space()][1]) != ''">
                    <xsl:value-of select="fnc:normalized(/*/cerif:Type[1])"/>
                </xsl:when>
                <xsl:when test="/*/cerif:PublishedIn">
                    <xsl:text>journal article</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>other</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeUri" select="fnc:resource-type-uri($typeSource)"/>
        <xsl:variable name="typeValue" select="fnc:resource-type-value($typeSource)"/>

        <element name="oaire">
            <element name="resourceType">
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'uri'"/>
                    <xsl:with-param name="value" select="$typeUri"/>
                </xsl:call-template>
                <xsl:call-template name="field">
                    <xsl:with-param name="name" select="'value'"/>
                    <xsl:with-param name="value" select="$typeValue"/>
                </xsl:call-template>
            </element>

            <xsl:if test="/*/cerif:FileLocations/cerif:Medium[cerif:URI[normalize-space()]]">
                <element name="files">
                    <xsl:for-each select="/*/cerif:FileLocations/cerif:Medium[cerif:URI[normalize-space()]]">
                        <element name="file">
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'accessRightsURI'"/>
                                <xsl:with-param name="value" select="$accessUri"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'mimeType'"/>
                                <xsl:with-param name="value" select="normalize-space(cerif:MimeType[1])"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'objectType'"/>
                                <xsl:with-param name="value" select="'fulltext'"/>
                            </xsl:call-template>
                            <xsl:call-template name="field">
                                <xsl:with-param name="name" select="'value'"/>
                                <xsl:with-param name="value" select="normalize-space(cerif:URI[1])"/>
                            </xsl:call-template>
                        </element>
                    </xsl:for-each>
                </element>
            </xsl:if>

            <element name="citation"/>
        </element>
    </xsl:template>

</xsl:stylesheet>
