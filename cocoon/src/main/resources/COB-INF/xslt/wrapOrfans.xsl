<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei"
  version="2.0">
  
  <!-- Wrap orfan elements in a main zone -->
  
   
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:zone[last()][not(@type='main')]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:if test="following-sibling::*">
      <zone xmlns="http://www.tei-c.org/ns/1.0" type="main">
        <xsl:sequence select="following-sibling::node()"/>
      </zone>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:surface/node()[not(self::tei:zone)]"/>  
  
</xsl:stylesheet>