<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Replace \n with <lb/> when appropriate -->
    <!-- Also clear comments -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node() except comment()'/>
        </xsl:copy>
    </xsl:template> 
    
    <xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>
    
    <xsl:template match="text()[ancestor::tei:text]">
        <xsl:variable name="count" select="count(tokenize(., '\n'))"/>
        <xsl:for-each select="tokenize(., '\n')">            
            <xsl:value-of select="."/>
            <xsl:if test="position()!=$count">
                <lb xmlns="http://www.tei-c.org/ns/1.0"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>