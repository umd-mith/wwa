<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei"
  version="2.0">
  
  <!-- Cleaning up any ugliness left from the conversion process -->  
  
   
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- remove empty lines -->
  <xsl:template match="tei:line[normalize-space()=''][count(*)=1][tei:lb]"/>
  
  <xsl:template match="tei:line[tei:graphic]">
    <xsl:apply-templates select="tei:graphic"/>
  </xsl:template>
  
  <xsl:template match="tei:line[normalize-space()=''][count(*)=2][tei:lb][tei:milestone]
    | tei:line[normalize-space()=''][count(*)=1][tei:milestone]">
    <xsl:apply-templates select="tei:milestone"/>
  </xsl:template>
  
  <xsl:template match="tei:lb"/>
  
  <xsl:template match="tei:line[tei:line]">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <xsl:template match="tei:surface[normalize-space()=''][count(*)=1][tei:zone[normalize-space()='']]"/>
  
  <xsl:template match="tei:zone[@type='main'][normalize-space()=''][distinct-values(*/local-name())='line']"/>
  
</xsl:stylesheet>