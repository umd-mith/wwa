<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Split surfaces into different documents -->
    
    <xsl:param name="destFolder" select="'.'"/>
    
    <xsl:template match="tei:surface">
        <xsl:message>
            <xsl:value-of select="$destFolder"/>
        </xsl:message>
        <xsl:variable name="s_id">
            <xsl:value-of select="//tei:TEI/@xml:id"/>
            <xsl:text>_s</xsl:text>
            <xsl:number count="//tei:surface" level="any"/>
        </xsl:variable>
        <xsl:result-document href="{$destFolder}/{$s_id}.xml">
            <xsl:copy>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="$s_id"/>
                </xsl:attribute>
                <xsl:sequence select="@*|node()"/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="/">
        <dummy><xsl:apply-templates/></dummy>
    </xsl:template>
    
</xsl:stylesheet>