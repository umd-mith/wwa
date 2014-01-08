<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
        
    <!-- Rename the deepest only child, descendant of only children -->
    
    <xsl:param name="mil" select="'pb'"/>
    <xsl:param name="wrapper" select="'surface'"/>
    <xsl:param name="attrs">
        <!-- Key value pairs in string, like so:
            'key|value,key|value' etc.
        -->
    </xsl:param>
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[*[local-name()=$mil]]">
        <xsl:element name="{$wrapper}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:sequence select="*[local-name()=$mil]/@* except *[local-name()=$mil]/@n_added"/>
            <xsl:if test="$attrs != ''">
                <xsl:for-each select="tokenize($attrs, ',')">
                    <xsl:variable name="pair" select="tokenize(current(), '\|')"/>
                    <xsl:attribute name="{$pair[1]}">
                        <xsl:value-of select="$pair[2]"/>
                    </xsl:attribute>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[descendant::*[local-name()=$mil]][not(*[local-name()=$mil])]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match='*[local-name()=$mil]'/>
    
    
    
</xsl:stylesheet>