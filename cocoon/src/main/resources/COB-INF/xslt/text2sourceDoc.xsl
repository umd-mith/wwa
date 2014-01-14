<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- From text-oriented TEI to document-oriented -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <!-- TOP LEVEL transformations -->
    
    <xsl:template match="tei:text">
        <sourceDoc xmlns="http://www.tei-c.org/ns/1.0" wwa:was="tei:text">
            <xsl:apply-templates select="@*|node()"/>
        </sourceDoc>
    </xsl:template>
    
    <xsl:template match="tei:body">
            <xsl:apply-templates select="@*|node()"/>        
    </xsl:template>
    
    <!-- TEXT- to DOCUMENT-FOCUSED transformations -->
    
    <!-- Line-level elements -->
    <xsl:template match="tei:item[ancestor::tei:text] | tei:p[ancestor::tei:text] | tei:l[ancestor::tei:text]">
        <line xmlns="http://www.tei-c.org/ns/1.0" wwa:was="tei:{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </line>
    </xsl:template>
    
    <!-- For now, we flatten choices -->
    <xsl:template match="tei:choice[ancestor::tei:text][tei:sic or tei:orig]">
        <seg wwa:was="{if (tei:sic) then 'tei:sic' else 'tei:orig'}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="tei:sic/node() | tei:orig/node()"/>
        </seg>
    </xsl:template>
    
    <!-- subst to mod -->
    <xsl:template match="tei:subst">
        <mod xmlns="http://www.tei-c.org/ns/1.0" wwa:was="tei:subst">
            <xsl:apply-templates select="@*|node()"/>
        </mod>
    </xsl:template>
    
    <!-- generalize semantics -->
    <xsl:template match="tei:div[ancestor::tei:text] | tei:div1[ancestor::tei:text] | tei:list[ancestor::tei:text] | tei:head[ancestor::tei:text] | tei:lg[ancestor::tei:text] | tei:q[ancestor::tei:text] | tei:fw[ancestor::tei:text] | tei:ab[ancestor::tei:text]">
        <zone xmlns="http://www.tei-c.org/ns/1.0" type="logical">          
            <xsl:attribute name="wwa:was">
                <xsl:value-of select="concat('tei:', local-name())"/>
            </xsl:attribute>
            <xsl:if test="count(@* except @xml:id except @type) > 0">
                <xsl:attribute name="wwa:attrs">
                    <xsl:for-each select="@* except @xml:id except @type">
                        <xsl:value-of select="concat(local-name(),':',.,',')"/>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@type">
                <xsl:attribute name="subtype">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@xml:id|node()"/>
        </zone>
    </xsl:template>
    
    <!-- Make spans into metamarks -->
    <xsl:template match="tei:span">
        <add hand="{@hand}" xmlns="http://www.tei-c.org/ns/1.0">
            <metamark xmlns="http://www.tei-c.org/ns/1.0" function="marginalia" spanTo="{@to}" wwa:was="tei:span">
                <xsl:apply-templates select="@* except @hand except @from except @to|node()"/>
            </metamark>
        </add>        
    </xsl:template>
    
    <!-- make notes into additions -->
    <xsl:template match="tei:note[ancestor::tei:text]">
        <add hand="{@resp}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy>
                <xsl:apply-templates select="@* except @resp|node()"/>
            </xsl:copy>            
        </add>
    </xsl:template>
    
    <!-- CLEANUP and ADJUSTMENTS from previous transformations -->
    
    <!-- cleanup empty blocks -->
    <xsl:template match="tei:surface[count(*)=1][tei:zone[not(*) and not(text()[normalize-space()])]]"/>
    
    <xsl:template match="tei:pb | tei:cb"/>
    
    <xsl:template match="tei:surface[descendant::tei:pb]">
        <xsl:copy>
            <xsl:attribute name="ulx">0</xsl:attribute>
            <xsl:attribute name="uly">0</xsl:attribute>
            <xsl:attribute name="lrx">0</xsl:attribute>
            <xsl:attribute name="lry">0</xsl:attribute>
            <xsl:attribute name="wwa:was"><xsl:text>tei:pb</xsl:text></xsl:attribute>
            <xsl:apply-templates select="@*"/>
            
            <graphic xmlns="http://www.tei-c.org/ns/1.0" url="{@facs}"/>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>        
    </xsl:template>    
    
    <!-- COLUMNS -->
        
    <!-- match the first column, replace it with a wrapper and pull in the following siblings -->
    <xsl:template match="tei:zone[descendant::tei:cb][1]">
        <zone type="main" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="self::* | following-sibling::tei:zone[descendant::tei:cb]">
                <xsl:copy>
                    <xsl:attribute name="wwa:was"><xsl:text>tei:cb</xsl:text></xsl:attribute>
                    <xsl:attribute name="type"><xsl:text>column</xsl:text></xsl:attribute>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:for-each>            
        </zone>        
    </xsl:template>
    <!-- Ignore the following columns -->
    <xsl:template match="tei:zone[descendant::tei:cb][preceding-sibling::tei:zone[descendant::tei:cb]]"/>
    
    <xsl:template match="tei:zone[descendant::tei:fw]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="descendant::tei:fw[contains(@place,'top')]">
                    <xsl:attribute name="type"><xsl:text>top</xsl:text></xsl:attribute>
                </xsl:when>
            </xsl:choose>            
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>        
    </xsl:template>
    
    <!-- when there are no columns, make the only zone a "main" zone -->
    <xsl:template match="tei:zone[not(descendant::tei:cb)][not(descendant::tei:fw)]">
        <xsl:copy>
            <xsl:attribute name="type">main</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>