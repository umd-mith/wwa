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
  
  <xsl:template match="tei:line">
    <xsl:choose>
      <!-- remove empty lines -->
      <xsl:when test="normalize-space()='' and count(*)=1 and tei:lb"/>
      <xsl:when test="normalize-space()='' and count(*)=0"/>
      <xsl:when test="tei:anchor[@type='marginalia'] and normalize-space()='' and count(*)=1"/>
      <xsl:when test="tei:add[@source] and normalize-space()='' and count(*)=1"/>
      <xsl:when test="tei:graphic">
        <xsl:apply-templates select="tei:graphic"/>
      </xsl:when>
      <xsl:when test="(normalize-space()='' and count(*)=2 and tei:lb and tei:milestone)
        or (normalize-space()='' and count(*)=1 and tei:milestone)">
        <xsl:apply-templates select="tei:milestone"/>
      </xsl:when>
      <xsl:when test="following-sibling::tei:line[1][normalize-space()=''][count(*)=1][
        tei:line[normalize-space()=''][count(*)=1][tei:anchor[@type='marginalia']]
        ]">
        <xsl:copy>
          <xsl:attribute name="xml:id" select="following-sibling::tei:line[1][normalize-space()=''][count(*)=1]/
            tei:line[normalize-space()=''][count(*)=1][tei:anchor[@type='marginalia']]
            /tei:anchor/@xml:id"/>
          <xsl:apply-templates select="@* except @xml:id | node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="tei:line">
        <xsl:apply-templates select="node()"/>
      </xsl:when>      
      <xsl:when test="not(descendant::tei:anchor[@type='marginalia']) and following-sibling::tei:line[1][descendant::tei:anchor[@type='marginalia']][normalize-space()=''][count(*)=1]">
        <xsl:copy>
          <xsl:attribute name="xml:id" select="following-sibling::tei:line[1]/descendant::tei:anchor[@type='marginalia']/@xml:id"/>
          <xsl:apply-templates select="@* except @xml:id | node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="descendant::tei:anchor[@type='marginalia'] and not(normalize-space()='') or not(count(*)=1)">
        <xsl:copy>
          <xsl:if test="descendant::tei:anchor[@type='marginalia']/@xml:id">
            <xsl:attribute name="xml:id" select="descendant::tei:anchor[@type='marginalia']/@xml:id"/>
          </xsl:if>          
          <xsl:apply-templates select="@* except @xml:id | node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lb"/>
  
  <xsl:template match="tei:surface">
    <xsl:choose>
      <xsl:when test="normalize-space()='' and count(*)=1 and tei:zone[normalize-space()='']"/>
      <xsl:when test="normalize-space()='' and count(*)=0"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:if test="@facs">
            <xsl:attribute name="facs">
              <xsl:analyze-string select="@facs" regex="(.*)\.\w+"> <!-- important, keep lazy! -->
                <xsl:matching-substring>
                  <xsl:value-of select="regex-group(1)"/>
                  <xsl:text>.jp2</xsl:text>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:attribute>
          </xsl:if>          
          <xsl:apply-templates select="@* except @facs|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--<xsl:template match="tei:surface[normalize-space()=''][count(*)=1][tei:zone[normalize-space()='']]"/>-->
  
  <xsl:template match="tei:zone">
    <xsl:choose>
      <xsl:when test="@type='main' and normalize-space()='' and distinct-values(*/local-name())=('line','lb')"/>
      <xsl:when test="not(*)"/>
      <!-- Finish linking up marginalia zones with their line -->
      <xsl:when test="@type=('marginalia_left', 'marginalia_right')">
        <xsl:copy>
          <xsl:attribute name="target" select="descendant::*[@target][1]/@target"/>
          <xsl:apply-templates select="@* except @target | node()"/>
        </xsl:copy>
      </xsl:when>
      <!-- don't allow columnd to be mixed with main. -->
      <xsl:when test="@type='column' and parent::tei:surface[descendant::tei:zone[@type='main']]"/>         
      <xsl:when test="@type='main' and parent::tei:surface[descendant::tei:zone[@type='column']]">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
          <xsl:sequence select="parent::tei:surface/descendant::tei:zone[@type='column']/node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- cleanup ids -->
  <xsl:template match="@xml:id">
    <xsl:if test="not(preceding::*[@xml:id=current()])">
      <xsl:copy-of select="."/>
    </xsl:if>
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