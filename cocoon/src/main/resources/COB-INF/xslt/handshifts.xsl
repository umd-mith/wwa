<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei"
  version="2.0">  
   
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Handshifts are only supported at line level for now. Always bring it at the very beginning -->
  <xsl:template match="tei:line[descendant::tei:handShift]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="descendant::tei:handShift"/>
      <xsl:apply-templates select="node() except tei:handShift"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>