<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Split surfaces into different documents -->
    
    <xsl:param name="destFolder" select="'.'"/>
    
    <xsl:template match='/'>
        <xsl:apply-templates select="//tei:surface"/>
        <wwa:message>Done!</wwa:message>
    </xsl:template>
    
    <xsl:template match="tei:surface">
        <xsl:variable name="s_id">
            <xsl:value-of select="//tei:TEI/@xml:id"/>
            <xsl:text>-</xsl:text>
            <xsl:number count="//tei:surface" level="any" format="0001"/>
        </xsl:variable>
        <xsl:result-document href="{$destFolder}/{$s_id}.xml">
            <xsl:copy>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="$s_id"/>
                </xsl:attribute>
                
                <xsl:apply-templates select="@* except @xml:id|node()" mode="splitting"/>                
                              
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="splitting">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="splitting"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="orfanAnchors">
        <!-- If there are orfan anchors, lookback for a spanner 
                     and replicate it (without content!) -->
        <xsl:for-each select="ancestor::tei:surface/descendant::tei:anchor">
            <xsl:variable name="pointer" select="concat('#', @xml:id)"/>
            <xsl:if test="not(ancestor::tei:surface/descendant::*[@* = $pointer])">
                <xsl:for-each select="//*[@* = $pointer]">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="splitting"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="orfanSpanners">
        <!-- if there are spanners without anchors, add an anchor at the end -->
        <xsl:for-each select="ancestor::tei:surface/descendant::*[@spanTo] | descendant::*[@target]">
            <xsl:variable name="pointer" select="
                if (@spanTo) then substring-after(@spanTo, '#')
                else substring-after(@target, '#')"/>
            <xsl:if test="not(ancestor::tei:surface/descendant::*[@xml:id = $pointer])">
                <anchor xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$pointer}"/>
            </xsl:if>
        </xsl:for-each>  
    </xsl:template>
    
    <xsl:template match="tei:zone[@type='main'][not(tei:zone[@type='column'])]" mode="splitting">        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="splitting"/>
            
            <xsl:call-template name="orfanAnchors"/>
            
            <!-- copy the contents -->
            <xsl:apply-templates select="node()" mode="splitting"/>
            
            <xsl:call-template name="orfanSpanners"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:zone[@type='column'][1]" mode="splitting">        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="splitting"/>
            
            <xsl:call-template name="orfanAnchors"/>
            
            <!-- copy the contents -->
            <xsl:apply-templates select="node()" mode="splitting"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:zone[@type='column'][last()]" mode="splitting">        
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="splitting"/>
            
            <xsl:call-template name="orfanSpanners"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>