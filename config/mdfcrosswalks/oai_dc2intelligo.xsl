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
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"    
    exclude-result-prefixes="oai_dc dc">
    
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
    
	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	
	<xsl:param name="vufind_id" />
	<xsl:param name="header_id" />
	<xsl:param name="record_id" />
	    
    <xsl:param name="ab_es" />
    <xsl:param name="ab_en" />
    <xsl:param name="ab_pt" />
    
    <xsl:param name="ti_es" />
    <xsl:param name="ti_en" />
    <xsl:param name="ti_pt" />
	
	 
    <xsl:template match="oai_dc:dc">
            <doc>
                <!-- ID es parámetro -->
                <field name="id">
                	<xsl:value-of select="$record_id"/>
                </field>
                
                 <field name="md.network_acronym">
                	<xsl:value-of select="$networkAcronym"/>
                </field>
                
                 <!-- URL -->
				<xsl:for-each select="//dc:identifier">
					<xsl:choose>
						<xsl:when test="starts-with(., 'http')">
							<field name="url">
								<xsl:value-of select="." />
							</field>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				
				 <!-- TITLE -->
                <xsl:if test="//dc:title[normalize-space()]">
                    <field name="title">
                        <xsl:value-of select="//dc:title[normalize-space()]"/>
                    </field>
                </xsl:if>
                 
                
                <!-- LANGUAGE -->
                <xsl:if test="//dc:language">
                    <xsl:for-each select="//dc:language">
                        <xsl:if test="string-length() > 0">
							<field name="language">
                                    <xsl:value-of select="normalize-space()"/>
                            </field>
					    </xsl:if>
                    </xsl:for-each>
                </xsl:if>

              
                <!-- AUTHOR -->
                <xsl:if test="//dc:creator">
                    <xsl:for-each select="//dc:creator">
                        <xsl:if test="normalize-space()">
                                <field name="author">
                                    <xsl:value-of select="normalize-space()"/>
                                </field>
                        </xsl:if>        
                    </xsl:for-each>
                </xsl:if>
                
                 <!-- AUTHOR2 - Contributor -->
                <xsl:if test="//dc:contributor">
                    <xsl:for-each select="//dc:contributor">
                                <field name="contributor">
                                    <xsl:value-of select="normalize-space()"/>
                                </field>
                    </xsl:for-each>
                </xsl:if>
                

                <!-- PUBLISHER -->
                <xsl:if test="//dc:publisher[normalize-space()]">
                    <field name="publisher">
                        <xsl:value-of select="//dc:publisher[normalize-space()]"/>
                    </field>
                </xsl:if>

                <!-- SUBJECT -->
                <xsl:if test="//dc:subject">
                    <xsl:for-each select="//dc:subject">
                        <xsl:if test="string-length(normalize-space()) > 0">
                            <field name="topic">
                                <xsl:value-of select="normalize-space()"/>
                            </field>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>

               
                <!-- PUBLISHDATE -->
                <xsl:if test="//dc:date">
                
                    <xsl:for-each select="//dc:date">
                        <field name="year">
                        	<xsl:value-of select="substring(., 1, 4)"/>
                    	</field>                   
                    </xsl:for-each>
                </xsl:if>
                
               <!-- rights -->
               <xsl:for-each select="//dc:rights">
            
              		<field name="rights">
						<xsl:value-of select="." />
					</field>
		   
               </xsl:for-each>

				 <!-- ab -->
                <field name="ab_es">
                	<xsl:value-of select="$ab_es"/>
                </field>	
				<field name="ab_en">
                	<xsl:value-of select="$ab_en"/>
                </field>	
				<field name="ab_pt">
                	<xsl:value-of select="$ab_pt"/>
                </field>
                
                <!-- ti -->
                <field name="ti_es">
                	<xsl:value-of select="$ti_es"/>
                </field>	
				<field name="ti_en">
                	<xsl:value-of select="$ti_en"/>
                </field>	
				<field name="ti_pt">
                	<xsl:value-of select="$ti_pt"/>
                </field>		
               
            </doc>
    </xsl:template>
</xsl:stylesheet>
