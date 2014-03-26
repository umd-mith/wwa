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
  <xsl:template match="tei:line[normalize-space()=''][count(*)=0]"/>
  
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
  
  <xsl:template match="tei:zone[not(*)]"/>
  
  <!-- cleanup ids -->
  <xsl:template match="@xml:id">
    <xsl:if test="not(preceding::*[@xml:id=current()])">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  <!--<xsl:template match="tei:zone[@type='column']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(preceding-sibling::tei:zone[@type='column']) and ancestor::tei:surface//tei:zone[@type='marginalia_left']">
          <xsl:attribute name="type" select="'column_left'"/>
        </xsl:when>
        <xsl:when test="not(following-sibling::tei:zone[@type='column']) and ancestor::tei:surface//tei:zone[@type='marginalia_right']">
          <xsl:attribute name="type" select="'column_right'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@type"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@* except @type | node()"/>
    </xsl:copy>
  </xsl:template>-->
  
  <!-- Finish linking up marginalia zones with their line -->
  <xsl:template match="tei:zone[@type=('marginalia_left', 'marginalia_right')]">
    <xsl:copy>
      <xsl:attribute name="target" select="descendant::*[@target][1]/@target"/>
      <xsl:apply-templates select="@* except @target | node()"/>
    </xsl:copy>
  </xsl:template>  
  
  <xsl:template match="tei:line[descendant::tei:anchor[@type='marginalia']]">
    <xsl:copy>
      <xsl:attribute name="xml:id" select="descendant::tei:anchor[@type='marginalia']/@xml:id"/>
      <xsl:apply-templates select="@* except @xml:id | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- remove unnecessary milestones -->
  <xsl:template match="tei:anchor[@type='marginalia']"/>
  
  <!-- take full control of targets: ie remove TEI-derived targets -->
  <xsl:template match="*[ancestor::tei:surface][@target]/@target"/>
  
  <!-- Flatten WW hands -->
  <xsl:template match="@hand | @new">
    <xsl:attribute name="{local-name()}">
      <xsl:variable name="h">
        <xsl:choose>
          <xsl:when test="starts-with(., '#')">
            <xsl:value-of select="substring-after(., '#')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="//tei:handNote[@xml:id = $h]/@scribeRef"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="tei:add[@hand='']">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
</xsl:stylesheet>