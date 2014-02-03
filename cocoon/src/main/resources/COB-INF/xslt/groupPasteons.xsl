<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Group pasteons -->
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="//tei:floatingText/tei:surface">
                <xsl:apply-templates mode="pasteons"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="gothrough"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="gothrough">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="gothrough"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="pasteons">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="pasteons"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Merge pasteons already in the right place with their containing surface --> 
    <xsl:template match="tei:surface[parent::tei:floatingText][@facs=ancestor::tei:surface/@facs]" mode="pasteons">
        <zone xmlns="http://www.tei-c.org/ns/1.0" type="pasteon">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates select="tei:body/node()" mode="pasteons"/>
        </zone>
    </xsl:template>
    
    <xsl:template match="tei:surface[ancestor::tei:add][preceding-sibling::tei:surface][@facs!=preceding-sibling::tei:surface/@facs]" mode="pasteons">
        MATCH!
    </xsl:template>
    
    <xsl:template match="tei:add[@rend='pasteon']" mode="pasteons">
        <xsl:variable name="facs" select="descendant::tei:surface[1]/@facs"/>
        fff<xsl:value-of select="$facs"/>
        <!--<xsl:copy>
            <xsl:apply-templates select="//tei:surface[@facs=$facs]" mode="pasteons"/>
        </xsl:copy>-->
        
        <!--<xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="pasteons"/>
        </xsl:copy>-->
    </xsl:template>
    
</xsl:stylesheet>