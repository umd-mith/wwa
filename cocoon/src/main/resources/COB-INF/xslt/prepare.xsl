<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- make changes to the XML before various groupings -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template> 
    
    <xsl:template match="tei:div1[@type=('pasteon', 'section')]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:gap | tei:space | tei:div2[@type='base']"/>
    
</xsl:stylesheet>