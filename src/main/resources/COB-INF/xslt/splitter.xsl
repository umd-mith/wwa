<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="milestoneWrapper.xsl"/>
    
    <xsl:param name="splitEl" select="'pb'"/>
    
    <xsl:template match="/">
        
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:sequence select="//tei:TEI/@*"/>
            <xsl:sequence select="//tei:teiHeader"/>
            <text xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:sequence select="//tei:text/@*"/>
                <body xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:sequence select="//tei:body/@*"/>
                    
                    <xsl:for-each select="//*[local-name()=$splitEl]">
                        <xsl:variable name="cur_num"><xsl:number count="//*[local-name()=$splitEl]" level="any"/></xsl:variable>
                        <xsl:call-template name="wrap">
                            <xsl:with-param name="splitEl" select="'pb'"/>
                            <xsl:with-param name="pgNum" select="string($cur_num)"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    
                </body>
            </text>            
        </TEI>
        
    </xsl:template>
    
    
</xsl:stylesheet>