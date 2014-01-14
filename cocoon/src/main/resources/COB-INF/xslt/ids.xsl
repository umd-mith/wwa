<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
        
    <!-- 
        Add generated xml:id to given elements.
        This is namespace agnostic: only local-names are checked.
    -->
    
    <!-- Because these XSLTs are part of an XProc pipe, parameters will always be strings. -->
    <xsl:param name="elements" select="'pb,cb'">
        <!-- 
            Accepted values:
            * 'all' -> Generates IDs for all elements without one.
            * comma-separated elements 'pb,cb' -> Generates IDs for all elements with listed local-name.
        -->
    </xsl:param>
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$elements='all' and self::element() and not(@xml:id)">
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                    <xsl:apply-templates select='@* | node()'/>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:apply-templates select='@*|node()'/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="element()[not(@xml:id)][local-name()=tokenize($elements, ',')]">   
        <xsl:copy>
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>