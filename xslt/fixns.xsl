<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
        
    <!-- Change WWA namespace into TEI -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Previous namespace -> current. No other changes required. -->
    <xsl:template match='wwa:*'>
        <xsl:element name='{local-name()}' namespace='http://www.tei-c.org/ns/1.0'>
            <xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
            <xsl:apply-templates select='@* | node()'/>
        </xsl:element>
    </xsl:template>    
    
</xsl:stylesheet>