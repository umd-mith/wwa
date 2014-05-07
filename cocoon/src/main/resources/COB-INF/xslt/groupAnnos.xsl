<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Group top / bottom annos by place -->
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="//tei:note[tokenize(@place, ' ')=('top', 'bottom')]">
                <xsl:apply-templates mode="annos"/>
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
    
    <xsl:template match="node() | @*" mode="annos">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="annos"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[tei:note[tokenize(@place, ' ')=('top', 'bottom')]]" mode="annos">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="annos"/>
            <xsl:for-each-group select="tei:note[tokenize(@place, ' ')=('top', 'bottom')]" group-by="@place">
                <note xmlns="http://www.tei-c.org/ns/1.0" type="authorial" place="{current-grouping-key()}">
                    <xsl:for-each select="current-group()" >
                        <xsl:copy>
                            <xsl:apply-templates select="@* except @place|node()" mode="annos" />
                        </xsl:copy>       
                        <lb/>
                    </xsl:for-each>
                </note>
            </xsl:for-each-group>
            <xsl:apply-templates select="node() except tei:note[tokenize(@place, ' ')=('top', 'bottom')]" mode="annos"/>
           
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>