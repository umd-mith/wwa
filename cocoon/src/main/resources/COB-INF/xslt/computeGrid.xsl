<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Group pasteons -->
    
    <xsl:param name="cols" select="12"/>
    <xsl:param name="rows" select="6"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="//tei:zone[@type='pasteon']">
                <xsl:apply-templates mode="grid"/>
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
    
    <xsl:template match="node() | @*" mode="grid">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="grid"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:zone[@type='pasteon'] | tei:zone[@type='main'][contains(@rend, 'col-')][*]" mode="grid">
        <xsl:copy>
            <xsl:variable name="cols">
                <xsl:for-each-group select="ancestor::tei:surface//tei:zone[@type='pasteon'] | ancestor::tei:surface//tei:zone[@type='main'][contains(@rend, 'col-')][*]
                    
                    [if (number(count(distinct-values(*/local-name()))=1)) 
                     then 
                        if (distinct-values(*/local-name()='lb'))
                        then false()
                        else true()
                     else true()]" 
                    
                    group-starting-with="*[@rend[tokenize(.,' ')='new']]">
                    <xsl:variable name="tot" select="count(current-group())"/>
                    <col tot='{$tot}'>
                        <xsl:if test="number(tokenize(@rend, 'col-')[2]) > $cols div $tot">
                            <xsl:attribute name="full-row" select="'full-row'"/>
                        </xsl:if>                        
                    </col>
                </xsl:for-each-group>
            </xsl:variable>
            
            <xsl:variable name="tot_cols" select="count($cols//col)"/>

            <xsl:variable name="cur_col" select="$tot_cols - count(following-sibling::tei:zone[@type='pasteon'][@rend[tokenize(.,' ')='new']])"/>

            <xsl:variable name="span">
                <xsl:variable name="adjust" select="if ($cols//col[$cur_col]/preceding-sibling::col[1][@full-row]) then 1 else 0"/>
                <xsl:value-of select="$rows div (number($cols//col[$cur_col]/@tot/string()) + $adjust)"></xsl:value-of>
            </xsl:variable>
            
            <xsl:attribute name="rend">
                <xsl:value-of select="@rend"/>
                <xsl:text> row-</xsl:text>
                <xsl:value-of select="$span"/>
            </xsl:attribute>
            
            <xsl:apply-templates select="@* except @rend | node()" mode="grid"/>
            
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>