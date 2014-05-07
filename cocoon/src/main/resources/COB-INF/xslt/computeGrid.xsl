<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Group pasteons -->
    
    <xsl:param name="COLS" select="12"/>
    <xsl:param name="ROWS" select="6"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <!-- Let's try to generalize and get any element with @rend col -->
            <xsl:when test="//*[contains(@rend, 'col-')]">
            <!--<xsl:when test="//tei:zone[@type='pasteon']">-->
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
    
    <!--<xsl:template match="tei:zone[@type='pasteon'] | tei:zone[@type='main'][contains(@rend, 'col-')][*]" mode="grid">-->
    <!-- Let's try to generalize and get any element with @rend col -->
    <xsl:template match="*[contains(@rend, 'col-')][*]" mode="grid">
        <xsl:variable name="this" select="generate-id()"/>
        <xsl:copy>
            <xsl:variable name="cols">
                <!--<xsl:for-each-group select="ancestor::tei:surface//tei:zone[@type='pasteon'] | ancestor::tei:surface//tei:zone[@type='main'][contains(@rend, 'col-')][*]-->
                <xsl:for-each-group select="ancestor::tei:surface//*[contains(@rend, 'col-')][*]
                    
                    [if (number(count(distinct-values(*/local-name()))=1)) 
                     then 
                        if (distinct-values(*/local-name()='lb'))
                        then false()
                        else true()
                     else true()]" 
                    
                    group-starting-with="*[@rend[tokenize(.,' ')='new']]">
                    <xsl:variable name="tot" select="count(current-group())"/>
                    <xsl:variable name="tot_rows" select="
                        
                        sum(
                            for $val in current-group()/@rend
                            return number(replace($val, '^.*?col-(\d+).*?$', '$1'))
                        )
                        
                        "/>
                    <col tot='{$tot}'>
                        <!--<xsl:if test="$tot_rows >= $COLS">
                            <xsl:attribute name="full-row" select="'full-row'"/>
                        </xsl:if>-->
                        <!--<xsl:if test="number(tokenize(@rend, 'col-')[2]) > $COLS div $tot">
                            <xsl:attribute name="full-row" select="'full-row'"/>
                        </xsl:if>-->
                        <xsl:for-each select="current-group()">
                            <xsl:variable name="span" select="replace(@rend, '^.*?col-(\d+).*?$', '$1')"/>
                            <block span="{$span}" pos="{position()}">
                                <xsl:if test="generate-id(.) = $this">
                                    <xsl:attribute name="this" select="'true'"/>
                                </xsl:if>
                                <!--<xsl:variable name="fullrows" select="floor((sum(preceding-sibling::*/number(replace(@rend, '^.*?col-(\d+).*?$', '$1'))) + number($span)) div $COLS)"/>
                                <xsl:attribute name="full-rows" select="if (string($fullrows) != 'NaN') then $fullrows else (0)"/>-->
                            </block>
                        </xsl:for-each>                        
                    </col>
                </xsl:for-each-group>
            </xsl:variable>
            
            <xsl:variable name="tot_cols" select="count($cols//col)"/>

            <!--<xsl:variable name="cur_col" select="$tot_cols - count(following-sibling::tei:zone[@type='pasteon'][@rend[tokenize(.,' ')='new']])"/>-->
            <!-- Let's generalize to any elements with @rend col -->
            <xsl:variable name="cur_col" select="$tot_cols - count(following-sibling::*[@rend[tokenize(.,' ')='new']])"/>

            <xsl:variable name="span">
                
                <xsl:variable name="maxColsPerRow" select="$COLS div $tot_cols"/>
                
                <xsl:variable name="realPosCols">
                    <cols>
                        <xsl:for-each select="$cols//col">
                            <col>
                                <xsl:sequence select="@* except @pos"/>
                                <xsl:for-each select="block">
                                    <block>
                                        <xsl:sequence select="@*"/>
                                        <xsl:attribute name="pos" select="number(@pos) + 
                                            count(preceding::block[@pos&lt;=current()/@pos][@span > $maxColsPerRow])"/>
                                        <xsl:if test="@span > $maxColsPerRow">
                                            <xsl:attribute name="large" select="'large'"/>
                                        </xsl:if>
                                    </block>
                                </xsl:for-each>
                            </col>
                        </xsl:for-each>
                    </cols>
                </xsl:variable>
                    
                
                <!--<xsl:variable name="rows">
                    <rows>
                        <xsl:variable name="maxRows" select="max(for $c in $cols//col return count($c//block))"/>
                        <xsl:for-each select="1 to $maxRows">
                            <row>
                                <xsl:for-each select="$cols//block[@pos=current()]">
                                    <xsl:sequence select="."/>
                                </xsl:for-each>
                            </row>
                        </xsl:for-each>
                    </rows>
                </xsl:variable>-->
                
                
                
                <xsl:message>
                    <xsl:sequence select="max($cols//col/@tot/number())"/>
                </xsl:message>
                
                <!--<xsl:variable name="takenRowSpace" select="sum($cols//block[following::block[@this]][@pos=$cols//block[@this]/@pos]/@span/number())"/>-->
                
                <!--<xsl:variable name="adjust" select="count($cols//*[@full-row])"/>
                <xsl:value-of select="$rows div (1 + $adjust)"/>-->
                <!--<xsl:value-of select="$rows div (number($cols//col[$cur_col]/@tot/string()) + $adjust)"></xsl:value-of>-->
                
                
                <xsl:value-of select="$ROWS div max($cols//col/@tot/number())"/>
                
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