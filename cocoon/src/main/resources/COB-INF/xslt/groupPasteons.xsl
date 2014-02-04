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
    
    <xsl:template name="makeCompoundId">
        <xsl:param name="count" select="1" tunnel="yes"/>
        <xsl:variable name="tot" select="count(current-group())"/>
        <xsl:value-of select="current-group()[$count]/@xml:id"/>
        <xsl:if test="$count != $tot">
            <xsl:text>_</xsl:text>
            <xsl:call-template name="makeCompoundId">
                <xsl:with-param name="count" select="$count + 1" tunnel="yes"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:text" mode="pasteons">
        <xsl:copy>
            <xsl:for-each-group select="//tei:surface[@facs]" group-by="@facs">
                <xsl:variable name="ids">
                    <xsl:call-template name="makeCompoundId"/>
                </xsl:variable>
                <surface xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$ids}" facs="{current-grouping-key()}">
                    <xsl:for-each select="current-group()">
                        <xsl:variable name="add_id" select="ancestor::tei:add/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="tei:body">
                                <zone type="pasteon">
                                    <xsl:apply-templates select="tei:body/node() except tei:add[@rend='pasteon'] except tei:note[@target]" mode="pasteons"/>
                                    <xsl:apply-templates select="//tei:text//tei:note[@target=concat('#', $add_id)]" mode="pasteons"/>
                                </zone>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="node() except tei:add[@rend='pasteon'] except tei:note[@target]" mode="pasteons"/>
                                <xsl:apply-templates select="//tei:text//tei:note[@target=concat('#', $add_id)]" mode="pasteons"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </surface>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="tei:add[@rend='pasteon'][count(descendant::tei:surface[@facs])>1]" mode="pasteons">
        <xsl:variable name="facs" select="descendant::tei:surface[@facs][1]/@facs"/>
        <xsl:copy>
            <xsl:for-each select="//tei:surface[ancestor::tei:add][@facs=$facs]">
                <zone xmlns="http://www.tei-c.org/ns/1.0" type="pasteon">
                    <xsl:sequence select="@*"/>
                    <xsl:sequence select="tei:body/node()" />
                </zone>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>-->
    
</xsl:stylesheet>