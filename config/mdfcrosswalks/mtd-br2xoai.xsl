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
    xmlns:mtd-br="http://www.ibict.br/schema/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"    
    exclude-result-prefixes="mtd-br">
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>

	<xsl:param name="networkAcronym" />
	<xsl:param name="networkName" />
	<xsl:param name="institutionName" />
	
	<xsl:param name="vufind_id" />
	<xsl:param name="header_id" />
	<xsl:param name="record_id" />
	
	<xsl:strip-space elements="*"/>
	 
    <xsl:template match="mtd-br:mtdbr">



<metadata xmlns="http://www.lyncode.com/xoai" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.lyncode.com/xoai http://www.lyncode.com/xsd/xoai.xsd">
	<element name="dc">

		<xsl:if test="//mtd-br:Grau">
			<element name="type">
				<element name="none">
					<xsl:for-each select="//mtd-br:Grau">
                       <xsl:if test="//mtd-br:Grau='Mestre'"><field name="value">Dissertação</field></xsl:if>
                       <xsl:if test="//mtd-br:Grau='Doutor'"><field name="value">Tese</field></xsl:if>
                    </xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:Titulo[1]">
			<element name="title">
					<xsl:for-each select="//mtd-br:Titulo[1]">
						<element>
						 	<xsl:attribute name="name">
    							<xsl:value-of select="./@Idioma" /> 
  						 	</xsl:attribute>
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</element>
					</xsl:for-each>
				<xsl:if test="//mtd-br:Titulo[position()>1]">	
					<xsl:for-each select="//mtd-br:Titulo[position()>1]">
						<element name="alternative">
							<element>	
								<xsl:attribute name="name">
	    							<xsl:value-of select="./@Idioma" /> 
	  							</xsl:attribute>
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</element>
					 	</element>
					</xsl:for-each>
				</xsl:if>	
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:Direitos">
			<element name="rights">
				<element name="pt">
					<xsl:for-each select="//mtd-br:Direitos[1]">
							<xsl:if test="fn:contains(//mtd-br:Direitos[1],'R')" ><field name="value">Acesso Restrito</field></xsl:if>
							<xsl:if test="fn:contains(//mtd-br:Direitos[1],'E')" ><field name="value">Acesso Embargado</field></xsl:if>
                            <xsl:if test="fn:not(fn:contains(//mtd-br:Direitos[1],'R')) and 
                            			  fn:not(fn:contains(//mtd-br:Direitos[1],'E'))" ><field name="value">Acesso Aberto</field></xsl:if>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:DataDefesa">
			<element name="date">
				<element name="issued">
					<element name="none">
						<xsl:for-each select="//mtd-br:DataDefesa">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:Autor/mtd-br:Nome">
			<element name="creator">
				<element name="none">
					<xsl:for-each select="//mtd-br:Autor/mtd-br:Nome">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
				<xsl:if test="//mtd-br:Autor/mtd-br:CPF">
					<element name="ID">
						<element name="none">
							<xsl:for-each select="//mtd-br:Autor/mtd-br:CPF">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
					</element>
				</xsl:if>
				<xsl:if test="//mtd-br:Autor/mtd-br:Lattes">
					<element name="Lattes">
						<element name="none">
							<xsl:for-each select="//mtd-br:Autor/mtd-br:Lattes">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
					</element>
				</xsl:if>
			</element>
		</xsl:if>


		<xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:Nome">
			<element name="contributor">
				<element name="advisor1">
					<element name="none">
						<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:Nome">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
			    </element>
			    <xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:CPF">
				    <element name="advisor1ID">
								<element name="none">
									<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:CPF">
										<field name="value">
											<xsl:value-of select="." />
										</field>
									</xsl:for-each>
								</element>
					</element>	
				</xsl:if>
				<xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:Lattes">
					<element name="advisor1Lattes">
								<element name="none">
									<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][1]/mtd-br:Lattes">
										<field name="value">
											<xsl:value-of select="." />
										</field>
									</xsl:for-each>
								</element>
					</element>
				</xsl:if>

				<xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:Nome">
					<element name="advisor2">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:CPF">
					    <element name="advisor2ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
								</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:Lattes">
						<element name="advisor2Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Orientador'][2]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>

				<xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:Nome">
					<element name="advisor-co1">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:CPF">
					    <element name="advisor-co1ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
								</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:Lattes">
						<element name="advisor-co1Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][1]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>


				<xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:Nome">
					<element name="advisor-co2">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:CPF">
					    <element name="advisor-co2ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
								</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:Lattes">
						<element name="advisor-co2Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Co-Orientador'][2]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>


				<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:Nome">
					<element name="referee1">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:CPF">
					    <element name="referee1ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:Lattes">
						<element name="referee1Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][1]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>

				<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:Nome">
					<element name="referee2">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:CPF">
					    <element name="referee2ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:Lattes">
						<element name="referee2Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][2]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>

				<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:Nome">
					<element name="referee3">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:CPF">
					    <element name="referee3ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:Lattes">
						<element name="referee3Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][3]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>

				<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:Nome">
					<element name="referee4">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:CPF">
					    <element name="referee4ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:Lattes">
						<element name="referee4Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][4]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>


				<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:Nome">
					<element name="referee5">
						<element name="none">
							<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:Nome">
								<field name="value">
									<xsl:value-of select="." />
								</field>
							</xsl:for-each>
						</element>
				    </element>
				    <xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:CPF">
					    <element name="referee5ID">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:CPF">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>	
					</xsl:if>
					<xsl:if test="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:Lattes">
						<element name="referee5Lattes">
									<element name="none">
										<xsl:for-each select="//mtd-br:Contribuidor[@Papel='Membro da Banca'][5]/mtd-br:Lattes">
											<field name="value">
												<xsl:value-of select="." />
											</field>
										</xsl:for-each>
									</element>
						</element>
					</xsl:if>
				</xsl:if>


			</element>
		</xsl:if>

	
		<xsl:if test="//mtd-br:Programa/mtd-br:Instituicao/mtd-br:Nome">
			<element name="publisher">
				<element name="none">
					<xsl:for-each select="//mtd-br:Programa/mtd-br:Instituicao/mtd-br:Nome">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
				<xsl:if test="//mtd-br:Programa/mtd-br:Instituicao/mtd-br:Sigla">
					<xsl:for-each select="//mtd-br:Instituicao/mtd-br:Sigla">
						<element name="initials">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</element>
					</xsl:for-each>
				</xsl:if>	
				<xsl:if test="//mtd-br:Programa/mtd-br:Instituicao/mtd-br:Pais">
					<xsl:for-each select="//mtd-br:Programa/mtd-br:Instituicao/mtd-br:Pais">
						<element name="country">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</element>
					</xsl:for-each>
				</xsl:if>	
				<xsl:if test="//mtd-br:Programa/mtd-br:Nome">
					<xsl:for-each select="//mtd-br:Programa/mtd-br:Nome">
						<element name="program">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</element>
					</xsl:for-each>
				</xsl:if>	
			</element>
		</xsl:if>


		<xsl:if test="//mtd-br:Idioma">
			<element name="language">
				<element name="none">
					<xsl:for-each select="//mtd-br:Idioma">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:Assunto[@Esquema='Palavra-chave']">
			<element name="subject">
				<xsl:for-each select="//mtd-br:Assunto[@Esquema='Palavra-chave']">
					<element>
						<xsl:attribute name="name">
	    						<xsl:value-of select="./@Idioma" /> 
	  					</xsl:attribute>
						<field>
							<xsl:value-of select="." />
						</field>
					</element>
				</xsl:for-each>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:Assunto[@Esquema='Tabela CNPQ']">
			<element name="subject">
				<xsl:for-each select="//mtd-br:Assunto[@Esquema='Tabela CNPQ']">
					<element name="cnpq">
						<element>
							<xsl:attribute name="name">
		    						<xsl:value-of select="./@Idioma" /> 
		  					</xsl:attribute>
							<field>
								<xsl:value-of select="." />
							</field>
						</element>
					</element>
				</xsl:for-each>
			</element>
		</xsl:if>



		<element name="description">
			<xsl:for-each select="//mtd-br:Resumo[1]">
				<element name='resumo'>
					<element>
						<xsl:attribute name="name">
	    						<xsl:value-of select="./@Idioma" /> 
	  					</xsl:attribute>
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</element>
				</element>
			</xsl:for-each>
			<xsl:if test="//mtd-br:Resumo[position()>1]">	
				<xsl:for-each select="//mtd-br:Resumo[position()>1]">
					<element name="abstract">
						<element>	
							<xsl:attribute name="name">
	    							<xsl:value-of select="./@Idioma" /> 
	  						</xsl:attribute>
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</element>
				 	</element>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="//mtd-br:AgenciaFomento/mtd-br:Nome">
				<element name="sponsorship">
					<element name="none">
						<xsl:for-each select="//mtd-br:AgenciaFomento/mtd-br:Nome">
							<field name="value">
								<xsl:value-of select="." />
							</field>
						</xsl:for-each>
					</element>
				</element>
			</xsl:if>
		</element>


		<xsl:if test="//mtd-br:BibliotecaDigital/mtd-br:URLDocumento">
			<element name="identifier">
				<element name="uri">
					<xsl:for-each select="//mtd-br:BibliotecaDigital/mtd-br:URLDocumento">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//mtd-br:BibliotecaDigital/mtd-br:URL/@Formato">
			<element name="format">
				<element name="none">
					<xsl:for-each select="//mtd-br:BibliotecaDigital/mtd-br:URL/@Formato">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

<!--

		<xsl:if test="//dc:source">
			<element name="source">
				<element name="none">
					<xsl:for-each select="//dc:source">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

		<xsl:if test="//dc:relation">
			<element name="relation">
				<element name="none">
					<xsl:for-each select="//dc:relation">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>
		<xsl:if test="//dc:coverage">
			<element name="coverage">
				<element name="none">
					<xsl:for-each select="//dc:coverage">
						<field name="value">
							<xsl:value-of select="." />
						</field>
					</xsl:for-each>
				</element>
			</element>
		</xsl:if>

-->
	</element>


	<element name="bundles" />

	<element name="others">
		<field name="handle">
			<xsl:value-of select="$header_id" />
		</field>
		<field name="identifier">
			<xsl:value-of select="$header_id" />
		</field>
		<field name="lastModifyDate">
			<xsl:value-of
				select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')" />
		</field>
	</element>

	<element name="repository">
		<field name="mail">mail@mail.com</field>
		<field name="name">
			<xsl:value-of select="$networkName" />
			-
			<xsl:value-of select="$institutionName" />
		</field>
	</element>



</metadata>

    </xsl:template>
    
</xsl:stylesheet>
