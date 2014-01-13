<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- From text-oriented TEI to document-oriented -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <sourceDoc xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*|node()"/>
        </sourceDoc>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <line xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*|node()"/>
        </line>
    </xsl:template>
    
    <!-- cleanup empty blocks form previous transforms -->
    <xsl:template match="tei:surface[count(*)=1][tei:zone[not(*) and not(text()[normalize-space()])]]"/>
    
    <xsl:template match="tei:pb | tei:cb"/>
    
    <xsl:template match="tei:zone[tei:cb]">
        <xsl:copy>
            <xsl:attribute name="type"><xsl:text>column</xsl:text></xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>        
    </xsl:template>
    
</xsl:stylesheet>