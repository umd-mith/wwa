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
    <xsl:template match="tei:item[ancestor::tei:text] | tei:l[ancestor::tei:text]">
        <line xmlns="http://www.tei-c.org/ns/1.0" rend="indent1">
            <xsl:apply-templates select="@*|node()"/>
        </line>
    </xsl:template>
    
    <xsl:template match="tei:p[ancestor::tei:text] 
        | tei:q[ancestor::tei:text] 
        | tei:ab[ancestor::tei:text] 
        | tei:byline[ancestor::tei:text]">        
        
        <xsl:variable name="anchor_id" select="generate-id()"/>
        <milestone xmlns="http://www.tei-c.org/ns/1.0" unit="tei:{local-name()}" spanTo="#{$anchor_id}"/>
        
        <xsl:apply-templates select="node()"/>
        
        <anchor xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$anchor_id}"/>
        
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
    
    <!-- Change attribute values to SGA conventions -->
    <xsl:template match="@place">
        <xsl:attribute name="place">
            <xsl:choose>
                <xsl:when test=".='infralinear'">
                    <xsl:text>sublinear</xsl:text>
                </xsl:when>
                <xsl:when test=".='over'">
                    <xsl:text>superlinear</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>        
    </xsl:template>
    
    <!-- generalize semantics -->
    <xsl:template match="tei:div[ancestor::tei:text] 
        | tei:div1[ancestor::tei:text] 
        | tei:list[ancestor::tei:text] 
        | tei:head[ancestor::tei:text] 
        | tei:lg[ancestor::tei:text] ">
        <xsl:variable name="anchor_id" select="generate-id()"/>
        <milestone xmlns="http://www.tei-c.org/ns/1.0" unit="tei:{local-name()}" spanTo="#{$anchor_id}">
            <xsl:if test="count(@* except @xml:id) > 0">
                <xsl:attribute name="wwa:attrs">
                    <xsl:for-each select="@* except @xml:id">
                        <xsl:value-of select="concat(local-name(),':',.,',')"/>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>  
            <xsl:apply-templates select="@xml:id"/>
        </milestone>    
        <xsl:apply-templates select="node()"/>
        
        <anchor xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$anchor_id}"/>
        
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
        <xsl:if test="not(@type='authorial') and not(@place)">
            <add hand="{@resp}" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @resp|node()"/>
                </xsl:copy>            
            </add>
        </xsl:if>
    </xsl:template>
    
    <!-- CLEANUP and ADJUSTMENTS from previous transformations -->
    
    <!-- cleanup empty blocks -->
    <xsl:template match="tei:surface[count(*)=1][tei:zone[not(*) and not(text()[normalize-space()])]]"/>
    
    <xsl:template match="tei:pb | tei:cb"/>
    
    <xsl:template name="noteToAdd">
        <add hand="{@resp}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy>
                <xsl:apply-templates select="@* except @resp except @place|node()"/>
            </xsl:copy>            
        </add>
    </xsl:template>
    
    <xsl:template match="tei:surface[descendant::tei:pb]">
        <xsl:copy>
            <xsl:attribute name="ulx">0</xsl:attribute>
            <xsl:attribute name="uly">0</xsl:attribute>
            <xsl:attribute name="lrx">1000</xsl:attribute>
            <xsl:attribute name="lry">3000</xsl:attribute>
            <xsl:attribute name="wwa:was"><xsl:text>tei:pb</xsl:text></xsl:attribute>
            <xsl:apply-templates select="@*"/>
            
            <graphic xmlns="http://www.tei-c.org/ns/1.0" url="{@facs}"/>
            
            <!-- Top-level annotations -->
            <xsl:if test="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top']">
                
                <xsl:choose>
                    <xsl:when test="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top'][tokenize(@place, ' ')='left']">
                        <zone type="top_marginalia_left" xmlns="http://www.tei-c.org/ns/1.0" >
                         <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top'][tokenize(@place, ' ')='left']">
                             <xsl:call-template name="noteToAdd"/>                             
                         </xsl:for-each>
                        </zone>
                    </xsl:when>
                    <xsl:when test="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top'][tokenize(@place, ' ')='right']">
                        <zone type="top_marginalia_right" xmlns="http://www.tei-c.org/ns/1.0" >
                            <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top'][tokenize(@place, ' ')='right']">
                                <xsl:sequence select="."/>                             
                            </xsl:for-each>
                        </zone>
                    </xsl:when>
                    <!-- Only accounting for two columns at the moment... -->
                    <xsl:otherwise>
                        <xsl:for-each select="tei:zone[descendant::tei:cb][1][descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top']]">
                            <zone type="top_marginalia_left" xmlns="http://www.tei-c.org/ns/1.0" >
                                <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top']">
                                    <xsl:call-template name="noteToAdd"/>                             
                                </xsl:for-each>
                            </zone>
                        </xsl:for-each>
                        <xsl:for-each select="tei:zone[descendant::tei:cb][2][descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top']]">
                            <zone type="top_marginalia_right" xmlns="http://www.tei-c.org/ns/1.0" >
                                <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='top']">
                                    <xsl:call-template name="noteToAdd"/>                             
                                </xsl:for-each>
                            </zone>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:if>
            
            <!-- left margin annos -->
            <xsl:if test="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='left']">
                <zone type="marginalia_left" xmlns="http://www.tei-c.org/ns/1.0" >
                    <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='left']">
                        <xsl:call-template name="noteToAdd"/>                             
                    </xsl:for-each>
                </zone>
            </xsl:if>
            
            
            <!-- content (main, columns) -->
            <xsl:apply-templates select="node()"/>
            
            <!-- right margin annos -->
            <xsl:if test="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='right']">
                <zone type="marginalia_right" xmlns="http://www.tei-c.org/ns/1.0" >
                    <xsl:for-each select="descendant::tei:note[@type='authorial'][tokenize(@place, ' ')='right']">
                        <xsl:call-template name="noteToAdd"/>                             
                    </xsl:for-each>
                </zone>
            </xsl:if>
            
            <!-- bottom-level annotations... -->
            
        </xsl:copy>        
    </xsl:template>    
    
    <!-- COLUMNS -->
        
    <!-- match the first column, replace it with a wrapper and pull in the following siblings -->
    <xsl:template match="tei:zone[descendant::tei:cb][1]">
        <!--<zone type="main" xmlns="http://www.tei-c.org/ns/1.0">-->
            <xsl:for-each select="self::* | following-sibling::tei:zone[descendant::tei:cb]">
                <xsl:copy>
                    <xsl:attribute name="wwa:was"><xsl:text>tei:cb</xsl:text></xsl:attribute>
                    <xsl:attribute name="type"><xsl:text>column</xsl:text></xsl:attribute>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:for-each>            
        <!--</zone>-->        
    </xsl:template>
    <!-- Ignore the following columns -->
    <xsl:template match="tei:zone[descendant::tei:cb][preceding-sibling::tei:zone[descendant::tei:cb]]"/>
    
    <xsl:template match="tei:zone[descendant::tei:fw]">
        <xsl:apply-templates/>
        <!--<xsl:copy>
            <xsl:choose>
                <xsl:when test="descendant::tei:fw[contains(@place,'top')]">
                    <xsl:attribute name="type"><xsl:text>running_head</xsl:text></xsl:attribute>
                </xsl:when>
            </xsl:choose>            
            <line xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates select="@*|node()"/></line>
        </xsl:copy>-->        
    </xsl:template>
    <xsl:template match="tei:lb[ancestor::tei:zone[descendant::tei:fw]]"/>
    
    <xsl:template match="tei:fw[contains(@place,'top')]">
        <zone type="running_head" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="node()"/>
        </zone>
    </xsl:template>
    
    <!-- when there are no columns, make the only zone a "main" zone -->
    <xsl:template match="tei:zone[not(descendant::tei:cb)][not(descendant::tei:fw)]">
        <xsl:copy>
            <xsl:attribute name="type">main</xsl:attribute>
            <xsl:apply-templates select="@*|node() except tei:zone[@type='pasteon']"/>
        </xsl:copy>
        <!-- Keep pasteons in separate zones -->
        <xsl:apply-templates select="tei:zone[@type='pasteon']"/>
    </xsl:template>
    
    
    <xsl:template match="tei:surface[normalize-space()=''][count(*)=1][tei:lb]"/>
    
    <xsl:template match="tei:lb[not(ancestor::tei:zone)]"/>
    
</xsl:stylesheet>