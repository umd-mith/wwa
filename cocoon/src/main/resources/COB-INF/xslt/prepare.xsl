<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wwa="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- make changes to the XML before various groupings -->
    
    <!-- Identity transform -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template> 
    
    <xsl:template match="tei:div1[not(@type=('verso'))]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:gap | tei:space | tei:div2[@type='base']"/>
    
    <!-- Make front matters into normal text -->
    
    <xsl:template match="tei:front"/>
    
    <xsl:template match="tei:body[preceding-sibling::tei:front]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="preceding-sibling::tei:front/node()"/>
            <xsl:if test="preceding-sibling::tei:pb[preceding-sibling::tei:front]">
                <xsl:apply-templates select="preceding-sibling::tei:pb[preceding-sibling::tei:front]"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        
    </xsl:template>
        
    <xsl:template match="tei:titlePage[ancestor::tei:text]
                        | tei:docTitle[ancestor::tei:text]  
                        | tei:titlePart[ancestor::tei:text] 
                        | tei:byline[ancestor::tei:text] 
                        | tei:epigraph[ancestor::tei:text] 
                        | tei:cit[ancestor::tei:text]
                        | tei:quote[ancestor::tei:text]
                        | tei:bibl[ancestor::tei:text]
                        | tei:docImprint[ancestor::tei:text]
                        | tei:pubPlace[ancestor::tei:text]
                        | tei:docDate[ancestor::tei:text]
                        | tei:opener[ancestor::tei:text]
                        | tei:floatingText[@type='letter']
                        | tei:body[parent::tei:floatingText[@type='letter']]">
       <xsl:apply-templates select="node()"/>
    </xsl:template>    
    
    <xsl:template match="tei:note[@type='footnote']
                       | tei:note[@place='inline']
                       | tei:note[@place='interlinear']
                       | tei:note[@place='infralinear']
                       | tei:note[@type='authorial'][tokenize(@place, ' ')='top'][ancestor::tei:floatingText[ancestor::tei:add[@rend='pasteon']]]
                       | tei:note[@type='authorial'][@place='left'][ancestor::tei:floatingText[@rend='flippy']]">
        <xsl:choose>
            <xsl:when test="@resp">
                <add hand="{@resp}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="hand" select="@resp"/>
                    <xsl:apply-templates select="node()"/>
                </add>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Flatten pasteons followed by columns -->
    <xsl:template match="tei:add[@rend='pasteon'][following::tei:cb]">
        <!-- make sure the cb and . share the same following pb or no pb at all -->
        <xsl:variable name="myPb" select="generate-id(following::tei:pb[1])"/>
        <xsl:variable name="cbPb" select="generate-id(following::tei:cb[1]//following::tei:pb[1])"/>
        <xsl:choose>
            <xsl:when test="not(following::tei:pb) or $myPb = $cbPb">
                <xsl:apply-templates select="descendant::tei:body/*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- remove hand from del[@rend='hashmark'] so that the text is not attributed to WW -->
    <xsl:template match="tei:del[@rend='hashmark']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @hand|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:*[tokenize(@rend, ' ')='smallcaps']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:value-of select="lower-case(.)"/>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- Change add place values for overwritten text to conform with SGA -->
    <xsl:template match="tei:add[@rend='overwrite']">
        <xsl:copy>
            <xsl:attribute name="place" select="'intralinear'"/>
            <xsl:apply-templates select="@* except @place except @rend|node()"></xsl:apply-templates>
        </xsl:copy>
            
    </xsl:template>
    
</xsl:stylesheet>