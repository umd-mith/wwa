<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei"
  version="2.0">
  
  <!-- Expands a milestone without breaking the hierarchy (no promotion) -->  
  
  <xsl:param name="milestone" select="'pb'"/>
  <xsl:param name="wrapper" select="'surface'"/>
  <xsl:param name="ns" select="'http://www.tei-c.org/ns/1.0'"/>
  <xsl:param name="wrapper_ns" select="'http://www.tei-c.org/ns/1.0'"/>
  
  <xsl:variable name="wrap_ns" select="if ($wrapper_ns='')
    then root()/*[1]/namespace-uri()
    else $wrapper_ns"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:zone[tei:lb]">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:for-each-group select="node()" group-starting-with="tei:lb">
        <line xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:for-each select="current-group()">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:for-each>          
        </line>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  
  
</xsl:stylesheet>