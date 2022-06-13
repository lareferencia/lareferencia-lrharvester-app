<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:datacite="http://datacite.org/schema/kernel-4"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="2.0">

<xsl:output method="xml" indent="yes" encoding="utf-8"/>

<xsl:strip-space elements="*"/>

  <xsl:template match="/">

    <metadata
      xmlns="http://www.lyncode.com/xoai"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">

      <element name="dc">

        <xsl:if test="//datacite:identifier">
          <xsl:for-each select="//datacite:identifier">
            <element name="identifier">
              <element name="url">
                <field name="value">
                  <xsl:if test="@identifierType='DOI'">
                    <xsl:value-of select="concat('https://doi.org/',.)"/>
                  </xsl:if>
                  <xsl:if test="@identifierType='Handle'">
                    <xsl:value-of select="concat('https://hdl.handle.net/',.)"/>
                  </xsl:if>
                </field>
              </element>
            </element>
        </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:creator">
          <xsl:for-each select="//datacite:creator">
            <element name="contributor">
              <element name="author">
                <field name="value">
                  <xsl:value-of select="datacite:creatorName"/>
                </field>
              </element>
            </element>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:title">
          <xsl:for-each select="//datacite:title">
            <element name="title">
              <!--
              <element name="xml:lang">
                <field name="value">
                  <xsl:value-of select="@xml:lang"/>
                </field>
              </element> -->
              <element name="none">
                <field name="value">
                  <xsl:value-of select="."/>
                </field>
              </element>
            </element>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:publisher">
          <xsl:for-each select="//datacite:publisher">
            <element name="publisher">
              <element name="none">
                <field name="value">
                  <xsl:value-of select="."/>
                </field>
              </element>
            </element>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:description">
          <xsl:for-each select="//datacite:description">
            <xsl:if test='@descriptionType="Abstract" '>
              <element name="description">
                <!--
                <element name="xml:lang">
                  <field name="value">
                    <xsl:value-of select="@xml:lang"/>
                  </field>
                </element> -->
                <element name="abstract">
                  <field name="value">
                    <xsl:value-of select="."/>
                  </field>
                </element>
              </element>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:language">
          <xsl:for-each select="//datacite:language">
            <element name="language">
              <element name="iso">
                  <field name="value">
                    <xsl:value-of select="."/>
                  </field>
              </element>
            </element>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:date">
          <xsl:for-each select="//datacite:date">
            <xsl:if test='@dateType="Updated" '>
              <element name="date">
                <element name="issued">
                  <field name="value">
                    <xsl:value-of select="."/>
                  </field>
                </element>
              </element>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:rights">
          <xsl:for-each select="//datacite:rights">
            <xsl:if test="@rightsURI">
              <element name="rights">
                <element name="openaire">
                  <field name="value">
                    <xsl:value-of select="@rightsURI"/>
                  </field>
                </element>
              </element>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="//datacite:subject">
          <xsl:for-each select="//datacite:subject">
            <element name="subject">
              <element name="none">
                <field name="value">
                  <xsl:value-of select="."/>
                </field>
              </element>
            </element>
          </xsl:for-each>
        </xsl:if>

        <element name="type">
          <element name="openaire">
          <field name="value">info:eu-repo/semantics/dataset</field>
          </element>
        </element>

      </element>

    </metadata>
  </xsl:template>
</xsl:stylesheet>
