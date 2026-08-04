<?xml version="1.0" encoding="UTF-8"?>

<!--
  Minimal XOAI to VuFind/Solr crosswalk.

  Version 5 intentionally emits only fields used for discovery, display,
  filtering and record management. It does not mirror the complete Dublin
  Core tree into dynamic Solr fields.
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:lrf="urn:lareferencia:xslt:functions"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="maxStringLength" as="xs:integer" select="30000"/>
    <xsl:variable name="driverPrefix" as="xs:string" select="'info:eu-repo/semantics/'"/>
    <xsl:variable name="repositoryNamePrefix" as="xs:string" select="'reponame:'"/>
    <xsl:variable name="institutionNamePrefix" as="xs:string" select="'instname:'"/>
    <xsl:variable name="institutionAcronymPrefix" as="xs:string" select="'instacron:'"/>

    <xsl:variable name="typeList" as="xs:string*" select="(
        'info:eu-repo/semantics/article',
        'info:eu-repo/semantics/bachelorThesis',
        'info:eu-repo/semantics/masterThesis',
        'info:eu-repo/semantics/doctoralThesis',
        'info:eu-repo/semantics/book',
        'info:eu-repo/semantics/bookPart',
        'info:eu-repo/semantics/review',
        'info:eu-repo/semantics/conferenceObject',
        'info:eu-repo/semantics/lecture',
        'info:eu-repo/semantics/workingPaper',
        'info:eu-repo/semantics/preprint',
        'info:eu-repo/semantics/report',
        'info:eu-repo/semantics/annotation',
        'info:eu-repo/semantics/contributionToPeriodical',
        'info:eu-repo/semantics/patent',
        'info:eu-repo/semantics/other',
        'info:eu-repo/semantics/dataset'
    )"/>

    <xsl:variable name="statusList" as="xs:string*" select="(
        'info:eu-repo/semantics/draft',
        'info:eu-repo/semantics/acceptedVersion',
        'info:eu-repo/semantics/submittedVersion',
        'info:eu-repo/semantics/publishedVersion',
        'info:eu-repo/semantics/updatedVersion'
    )"/>

    <xsl:variable name="rightsList" as="xs:string*" select="(
        'info:eu-repo/semantics/openAccess',
        'info:eu-repo/semantics/embargoedAccess',
        'info:eu-repo/semantics/restrictedAccess',
        'info:eu-repo/semantics/closedAccess'
    )"/>

    <xsl:param name="networkAcronym"/>
    <xsl:param name="networkName"/>
    <xsl:param name="fingerprint"/>
    <xsl:param name="identifier"/>
    <xsl:param name="attr_repository_id"/>
    <xsl:param name="ibictCompatibility" as="xs:boolean" select="false()"/>

    <xsl:function name="lrf:clean" as="xs:string">
        <xsl:param name="value" as="item()?"/>
        <xsl:sequence select="substring(normalize-space(string($value)), 1, $maxStringLength)"/>
    </xsl:function>

    <xsl:template match="/">
        <xsl:variable name="dc" select="doc:metadata/doc:element[@name='dc']"/>

        <xsl:variable name="titles" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='title']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="authors" as="xs:string*" select="
            distinct-values((
                for $value in $dc/doc:element[@name='creator']//doc:field[@name='value']
                return lrf:clean($value),
                for $value in $dc/doc:element[@name='contributor']
                    //doc:element[@name='author']//doc:field[@name='value']
                return lrf:clean($value)
            ))[. != '']"/>

        <xsl:variable name="contributors" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='contributor']
                    //doc:element[@name=('advisor1', 'advisor2', 'advisor-co1', 'advisor-co2',
                                        'referee1', 'referee2', 'referee3', 'referee4', 'referee5')]
                    //doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="subjects" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='subject']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="descriptions" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='description']
                    //doc:element[not(@name='provenance')]//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="dateValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='date']//doc:field[@name='value']
                return lrf:clean($value)
            )[matches(., '^\d{4}(-\d{2}(-\d{2}(T\d{2}:\d{2}:\d{2}([+-]\d{2}:\d{2}|Z)?)?)?)?$')]"/>

        <xsl:variable name="typeValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='type']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="identifierValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='identifier']
                    //doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="darkIdentifiers" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='identifier']
                    /doc:element[@name='dark']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="doiIdentifiers" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='identifier']
                    /doc:element[@name='doi']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="unqualifiedIdentifiers" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='identifier']
                    /doc:element[@name='none']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="languageValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='language']//doc:field[@name='value']
                return lower-case(lrf:clean($value))
            )[. != '']"/>

        <xsl:variable name="rightsValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='rights']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="publisherValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='publisher']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="sourceValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='source']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="sourceReferenceValues" as="xs:string*" select="
            distinct-values(
                for $value in $dc/doc:element[@name='source']
                    /doc:element[@name='none']//doc:field[@name='value']
                return lrf:clean($value)
            )[. != '']"/>

        <xsl:variable name="bitstreamUrls" as="xs:string*" select="
            distinct-values(
                for $value in doc:metadata//doc:element[@name='bitstream']/doc:field[@name='url']
                return lrf:clean($value)
            )[. != '']"/>

        <doc>
            <field name="id"><xsl:value-of select="lrf:clean($fingerprint)"/></field>
            <field name="oai_identifier_str"><xsl:value-of select="lrf:clean($identifier)"/></field>

            <xsl:if test="normalize-space($networkAcronym) != ''">
                <field name="network_acronym_str"><xsl:value-of select="lrf:clean($networkAcronym)"/></field>
            </xsl:if>
            <xsl:if test="normalize-space($networkName) != ''">
                <field name="network_name_str"><xsl:value-of select="lrf:clean($networkName)"/></field>
            </xsl:if>
            <xsl:if test="normalize-space($attr_repository_id) != ''">
                <field name="repository_id_str"><xsl:value-of select="lrf:clean($attr_repository_id)"/></field>
            </xsl:if>

            <!-- Selected discovery text only; avoids copying the complete XOAI tree. -->
            <xsl:variable name="searchValues" as="xs:string*" select="
                distinct-values((
                    $titles,
                    $authors,
                    $contributors,
                    $subjects,
                    $descriptions,
                    $publisherValues,
                    $identifierValues,
                    if ($ibictCompatibility) then $sourceReferenceValues else ()
                ))[. != '']"/>
            <xsl:if test="exists($searchValues)">
                <field name="allfields"><xsl:value-of select="string-join($searchValues, ' ')"/></field>
            </xsl:if>

            <xsl:if test="exists($titles)">
                <field name="title"><xsl:value-of select="$titles[1]"/></field>
                <field name="title_short"><xsl:value-of select="$titles[1]"/></field>
                <field name="title_full"><xsl:value-of select="$titles[1]"/></field>
                <field name="title_sort"><xsl:value-of select="$titles[1]"/></field>
            </xsl:if>

            <xsl:for-each select="$authors">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <field name="author"><xsl:value-of select="."/></field>
                        <field name="author_role">author</field>
                    </xsl:when>
                    <xsl:otherwise>
                        <field name="author2"><xsl:value-of select="."/></field>
                        <field name="author2_role">author</field>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="$contributors">
                <field name="contributor_str_mv"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <xsl:for-each select="$subjects">
                <field name="topic"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <xsl:if test="exists($descriptions)">
                <field name="description"><xsl:value-of select="$descriptions[1]"/></field>
            </xsl:if>

            <xsl:for-each select="$dateValues">
                <xsl:sort select="substring(., 1, 4)" data-type="number"/>
                <xsl:if test="position() = 1">
                    <field name="publishDate"><xsl:value-of select="substring(., 1, 4)"/></field>
                    <field name="publishDateSort"><xsl:value-of select="substring(., 1, 4)"/></field>
                </xsl:if>
            </xsl:for-each>

            <xsl:if test="exists($typeValues[. = $typeList])">
                <field name="format">
                    <xsl:value-of select="substring-after($typeValues[. = $typeList][1], $driverPrefix)"/>
                </field>
            </xsl:if>
            <xsl:if test="exists($typeValues[. = $statusList])">
                <field name="status_str">
                    <xsl:value-of select="substring-after($typeValues[. = $statusList][1], $driverPrefix)"/>
                </field>
            </xsl:if>

            <xsl:for-each select="$identifierValues[
                matches(., '^https?://', 'i') and not(. = $darkIdentifiers)
            ]">
                <field name="url"><xsl:value-of select="."/></field>
            </xsl:for-each>
            <xsl:for-each select="distinct-values((
                $doiIdentifiers,
                $unqualifiedIdentifiers[not(matches(., '^https?://', 'i'))]
            ))[not(. = $darkIdentifiers)]">
                <field name="identifier_str_mv"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <!-- Published DARK/ARK identifier from dc.identifier.dark. -->
            <xsl:if test="exists($darkIdentifiers)">
                <field name="identifier_dark_str"><xsl:value-of select="$darkIdentifiers[1]"/></field>
            </xsl:if>

            <xsl:for-each select="$languageValues[string-length(.) = 3]">
                <field name="language"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <xsl:for-each select="$rightsValues[. = $rightsList]">
                <field name="eu_rights_str_mv">
                    <xsl:value-of select="substring-after(., $driverPrefix)"/>
                </field>
            </xsl:for-each>

            <xsl:for-each select="$publisherValues">
                <field name="publisher"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <xsl:for-each select="$sourceValues[starts-with(., $institutionAcronymPrefix)]">
                <xsl:if test="position() = 1">
                    <field name="institution">
                        <xsl:value-of select="substring-after(., $institutionAcronymPrefix)"/>
                    </field>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="not(exists($sourceValues[starts-with(., $institutionAcronymPrefix)]))">
                <xsl:for-each select="$sourceValues[starts-with(., $institutionNamePrefix)]">
                    <xsl:if test="position() = 1">
                        <field name="institution">
                            <xsl:value-of select="substring-after(., $institutionNamePrefix)"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>

            <xsl:for-each select="$sourceValues[starts-with(., $repositoryNamePrefix)]">
                <xsl:if test="position() = 1">
                    <field name="collection">
                        <xsl:value-of select="substring-after(., $repositoryNamePrefix)"/>
                    </field>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="$bitstreamUrls">
                <field name="bitstream_url_str_mv"><xsl:value-of select="."/></field>
            </xsl:for-each>

            <!--
              IBICT/Oasisbr profile. These are intentionally selected fields,
              not a generic mirror of the Dublin Core hierarchy.
            -->
            <xsl:if test="$ibictCompatibility">
                <xsl:for-each select="$sourceValues[starts-with(., $repositoryNamePrefix)]">
                    <xsl:if test="position() = 1">
                        <field name="reponame_str">
                            <xsl:value-of select="substring-after(., $repositoryNamePrefix)"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$sourceValues[starts-with(., $institutionNamePrefix)]">
                    <xsl:if test="position() = 1">
                        <field name="instname_str">
                            <xsl:value-of select="substring-after(., $institutionNamePrefix)"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='identifier']
                    /doc:element[@name='uri']//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="identifier_uri_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$sourceReferenceValues">
                    <field name="source_reference_txt_mv"><xsl:value-of select="."/></field>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='identifier']
                    /doc:element[@name='citation']//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="identifier_citation_txt_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='identifier']
                    /doc:element[@name='issn']//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="issn_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='identifier']
                    /doc:element[@name='isbn']//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="isbn_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='language']
                    /doc:element[@name='iso']//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="language_iso_str_mv">
                            <xsl:value-of select="lower-case(lrf:clean(.))"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('advisor1', 'advisor2')]//doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="advisor_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('advisor1Lattes', 'advisor2Lattes')]
                    //doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="advisor_lattes_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('co', 'advisor-co1', 'advisor-co2')]
                    //doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="coadvisor_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('advisor-co1Lattes', 'advisor-co2Lattes')]
                    //doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="coadvisor_lattes_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('referee1', 'referee2', 'referee3', 'referee4', 'referee5')]
                    //doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="committee_member_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$dc/doc:element[@name='contributor']
                    /doc:element[@name=('referee1Lattes', 'referee2Lattes', 'referee3Lattes',
                                        'referee4Lattes', 'referee5Lattes')]
                    //doc:field[@name='value']">
                    <xsl:if test="lrf:clean(.) != ''">
                        <field name="committee_lattes_str_mv"><xsl:value-of select="lrf:clean(.)"/></field>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </doc>
    </xsl:template>
</xsl:stylesheet>
