<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- 
General milestone expansion 
===========================

Adapted from a script by Wendell Piez at https://github.com/wendellpiez/MITH_XSLT/blob/master/xslt/p-promote.xsl 
    
Apache 2.0 license: http://www.apache.org/licenses/LICENSE-2.0.html
-->  
  
  <xsl:param name="milestone" select="'pb'"/>
  <xsl:param name="wrapper" select="'surface'"/>
  <xsl:param name="wrapper_parent" select="'body'"/>
  <xsl:param name="ns" select="'http://www.tei-c.org/ns/1.0'"/>
  <xsl:param name="wrapper_ns" select="'http://www.tei-c.org/ns/1.0'"/>
  <xsl:param name="debug" select="false()"/>
  
  <xsl:variable name="wrap_ns" select="if ($wrapper_ns='')
    then root()/*[1]/namespace-uri()
    else $wrapper_ns"/>
  
  <xsl:template match="*[local-name()=$wrapper_parent][namespace-uri()=$ns]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="." mode="expand"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:key name="element-by-generated-id" match="*" use="generate-id()"/>
  
  <xsl:template mode="expand" match="node()">
    <xsl:variable name="here" select="."/>
    <xsl:for-each-group select="descendant::node()[empty(node())]"
      group-starting-with="*[local-name()=$milestone]">
      
      <xsl:element name="{$wrapper}" namespace="{$wrap_ns}">
        <xsl:sequence select="current-group()[1][local-name()=$milestone]/@*"/>
        <xsl:call-template name="build">
          <xsl:with-param name="from" select="$here" tunnel="yes"/>
        </xsl:call-template>
      </xsl:element>
      
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="build">
    <xsl:param name="to-copy" select="current-group()"/>
    <xsl:param name="level" select="1" as="xs:integer"/>
    <xsl:param name="from" select="." tunnel="yes"/>
    <xsl:for-each-group select="current-group()"
      group-adjacent="generate-id((ancestor::* except $from/ancestor-or-self::*)[$level])">
      <xsl:variable name="copying" select="key('element-by-generated-id',current-grouping-key())"/>
      <xsl:sequence select="current-group()[empty($copying)]"/>
      <xsl:for-each select="$copying">
        <xsl:copy>
          <xsl:copy-of select="@* except @xml:id"/>
          <xsl:call-template name="build">
            <xsl:with-param name="level" select="$level + 1"/>
          </xsl:call-template>
        </xsl:copy>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  
  
</xsl:stylesheet>