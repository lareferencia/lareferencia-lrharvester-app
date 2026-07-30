<?xml version="1.0" encoding="UTF-8"?>

<!-- IBICT/Oasisbr profile for the minimal VuFind 5 crosswalk. -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:import href="xoai2vufind5.xsl"/>

    <xsl:param name="ibictCompatibility" as="xs:boolean" select="true()"/>
</xsl:stylesheet>
