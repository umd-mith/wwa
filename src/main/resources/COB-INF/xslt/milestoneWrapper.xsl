<?xml version="1.0" encoding="UTF-8"?>

<!-- 
  
    name: milestoneSplitter.xsl (was: getPage.xsl)
    version: 2.0
  
    project: Jane Austen's Fictional Manuscripts
    project2: Walter Whitman Archive
    author: Raffaele Viglianti / King's College London / University of Maryland
    licence: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html
    
    version: 1.0
    start-date: 2009-07-15
    
    desc: retrieves the xml for the required page, closing stepping-over elements]
    
    version: 1.1
    Further development according to pagination (number on top of page) requests.
    + Fix to lastpage
    start-date: 2009-09-28
    
    version: 1.2
    Added templates to determine page of patches for interlinking (displacement)
    Added templates to move insertions in the right place ptr (insertion)
    Added debugging:change parameter "debug" to true() do display mode and provenance of created and sequenced elements.
    start-date: 2009-12-04
    
    version: 1.3
    Added pgRange parameter and adjusted templates for selecting multiple pages.
    start-date: 2011-10-25
    
    version: 2.0
    Generalized script to split around given milestone. Moved to Walter Whitman Archive (WWA) project.
    start-date: 2014-01-06
    
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:au="http://www.cch.kcl.ac.uk/xmlns/austen"  
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output encoding="UTF-8" exclude-result-prefixes="#all" indent="yes" method="xml" />
  <xsl:strip-space elements="*" />

  <!-- Parameter for page required -->

  <!--<xsl:param name="manuscriptname"/>
  
  <xsl:param name="splitEl" select="'cb'"/>
  
  <xsl:param name="pgNum" select="'1'" />
  
  <xsl:param name="pgRange" select="'1'"/>-->
  
  <xsl:param name="contextPath" select="'.'"/>
  <!-- OMIT EXTENSION -->
  <xsl:param name="outputLoc" select="'/output'"/>
  
  <xsl:param name="debug" select="false()"/>

  <!-- Functions -->
  <xsl:function name="au:noText">

    <xsl:param name="element" />
                        

    <xsl:variable name="values">

      <xsl:for-each select="$element//text()">

        <xsl:choose>
          <xsl:when test="matches(., '^\s*$')">
            <xsl:text>1</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$values" />

  </xsl:function>
  
  <xsl:function as="xs:string" name="au:toRoman">
    <xsl:param as="xs:double" name="value" />
    <xsl:number format="I" value="$value" />
  </xsl:function>
    
  <xsl:template name="getPatchPage">
    <xsl:param name="recursive"/>
    <xsl:param name="create_element"/>
  </xsl:template>
    
  <!-- 
    *******************
    SWITCH: WHICH MODE?
    *******************
  -->
  <!-- Selects between modes:
     - related: alpha's parent is beta's descendant
     - unrelated: alpha's parent is not beta's descendant
     - lastPage: beta does not exist
  -->
  <!-- Make sure to copy teiHeader in the right position. Priority overrides the previous template -->
  <xsl:template name="wrap">
    
    <xsl:param name="manuscriptname"/>
    
    <xsl:param name="splitEl" select="'pb'"/>
    
    <xsl:param name="pgNum" select="'1'" />
    
    <xsl:param name="pgRange" select="'1'"/>
    
    <!-- Variables -->
    
    <xsl:variable name="pageNum" select="translate($pgNum, '_', ' ')"/>
    
    <!-- List of milestones in order of appereance -->
    <!-- v1.1: separated in front and body to identify positions in perfatory material. Get VERY first front. -->
    <!-- v1.1: Treat differently if booklets -->
    
    <xsl:variable name="milPos">
      <xsl:choose>
        <xsl:when test="//au:fb">
          <!-- assuming the first front is always in the first booklet/fascicle -->
          <tei:front>
            <xsl:choose>
              <xsl:when test="//front[not(ancestor::group)]">
                <xsl:for-each select="//front[not(ancestor::group)][1]//*[name()=$splitEl]">
                  <xsl:sequence select="." />
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="//group//text[1]//front[1]//*[name()=$splitEl]">
                  <xsl:sequence select="." />
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </tei:front>
          <tei:body>
            <!-- If there are first pages not in booklets -->
            <xsl:if test="//*[name()=$splitEl][not(preceding::au:fb)]">
              <xsl:for-each select="//*[name()=$splitEl][not(preceding::au:fb)][not(@rend) or @rend != 'overstrike'][not(ancestor::front[not(ancestor::group)])]">
                <xsl:sequence select="." />
              </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="//au:fb[not(ancestor::front[parent::text[1]])]">
              <xsl:variable name="this_fb" select="generate-id(.)"/>
              <au:fb>
                <xsl:sequence select="@*"/>
                <xsl:for-each select="//*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::au:fb[1][generate-id()=$this_fb]]">
                  <xsl:sequence select="." />
                </xsl:for-each>
              </au:fb>
            </xsl:for-each>
          </tei:body>
        </xsl:when>
        <xsl:otherwise>
          <tei:front>
            <xsl:choose>
              <xsl:when test="//front[not(ancestor::group)]">
                <xsl:for-each select="//front[not(ancestor::group)][1]//*[name()=$splitEl]">
                  <xsl:sequence select="." />
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="//group//text[1]//front[1]//*[name()=$splitEl]">
                  <xsl:sequence select="." />
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </tei:front>
          <tei:body>
            <xsl:for-each select="//*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][not(ancestor::front[not(ancestor::group)])]">
              <xsl:sequence select="." />
            </xsl:for-each>
          </tei:body>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- First milestone (the required one) is called 'alpha', the following milestone is called 'beta' -->
    <!-- v1.1: changed XPath for Beta in order to exclude milestones with @rend='overstrike' -->
    <!-- v1.1: takes position relative to booklets/fascicles if present-->
    
    <!--ALPHA-xpath: *[name()=$splitEl][@xml:id = $pageId]
  BETA-xpath: *[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]-->
    <xsl:variable name="pageId">
      <xsl:choose>
        <xsl:when test="//au:fb">
          <xsl:choose>
            <xsl:when test="string(number($pageNum))!='NaN'">
              <xsl:choose>
                <!-- only a number (not in a booklet/fascicle) -->
                <xsl:when test="$milPos//body//*[name()=$splitEl][not(parent::au:fb)][position()=number($pageNum)][@n = $pageNum]
                  or $milPos//body//*[name()=$splitEl][not(parent::au:fb)][position()=number($pageNum)][not(@n)]">
                  <xsl:value-of select="$milPos//body//*[name()=$splitEl][not(parent::au:fb)][position()=number($pageNum)]/@xml:id" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][not(parent::au:fb)][@n=$pageNum]/@xml:id" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- not a number (in a booklet/fascicle or not but non-numeric pagination)-->
            <xsl:otherwise>
              <xsl:choose>
                <!--If in this format: ^b\d+-\d+$ is in a numbered booklet/fascicle with a numbered page (only inferred. Add specified ( not(@type) and @n ) if necessary).-->
                <xsl:when test="matches($pageNum, '^b\d+-\d+$')">
                  
                  <xsl:choose>
                    <xsl:when test="$milPos//body//au:fb[@n=substring-before(substring-after($pageNum, 'b'), '-')]
                      //*[name()=$splitEl][@n=substring-after($pageNum, '-')]">
                      <xsl:value-of select="$milPos//body//au:fb[@n=substring-before(substring-after($pageNum, 'b'), '-')]
                        //*[name()=$splitEl][@n=substring-after($pageNum, '-')]/@xml:id" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$milPos//body//au:fb[@n=substring-before(substring-after($pageNum, 'b'), '-')]
                        //*[name()=$splitEl][position()=number(substring-after($pageNum, '-'))]/@xml:id" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <!--If in this format: ^b\d+-.*?$ is in a numbered booklet/fascicle with a non-numeric page (either editorial or specified).-->
                <xsl:when test="matches($pageNum, '^b\d+-.+?$')">
                  <xsl:value-of select="$milPos//body//au:fb[@n=substring-before(substring-after($pageNum, 'b'), '-')]
                    //*[name()=$splitEl][@n=substring-after($pageNum, '-')]/@xml:id" />
                </xsl:when>
                <!-- not in booklet/fascicle -->
                <xsl:otherwise>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@n=$pageNum]/@xml:id" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$manuscriptname='lady_susan' and ($pageNum='6' or $pageNum='7')">
              <xsl:value-of select="$milPos//*[name()=$splitEl][@n=concat($pageNum, '.')]/@xml:id" />
            </xsl:when>
            <xsl:when test="string(number($pageNum))!='NaN'">
              <xsl:choose>
                <xsl:when test="$milPos//body//*[name()=$splitEl][position()=number($pageNum)][@n = $pageNum]
                  or $milPos//body//*[name()=$splitEl][position()=number($pageNum)][not(@n)]">
                  <xsl:value-of select="$milPos//body//*[name()=$splitEl][position()=number($pageNum)]/@xml:id" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@n=$pageNum]/@xml:id" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$milPos//*[name()=$splitEl][@n=$pageNum]/@xml:id" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- v1.1: Determine prev and next pages to correctly switch from roman to integer and vice versa -->
    
    <xsl:variable name="prevPageNum">
      <xsl:choose>
        <xsl:when test="$manuscriptname='lady_susan' and $pageNum='7'">
          <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/@n, '.', '')"/>
        </xsl:when>
        <xsl:when test="string(number($pageNum))!='NaN'">
          <xsl:choose>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][not(preceding::*[name()=$splitEl][1])]"/>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][preceding::*[name()=$splitEl][1][@n]]">
              <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/@n, ' ', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="number($pageNum)-1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][preceding::*[name()=$splitEl][1][parent::au:fb]]">
          <xsl:choose>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][preceding::*[name()=$splitEl][1][@n]]">
              <xsl:text>b</xsl:text>
              <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/parent::au:fb/@n"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/@n, ' ', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>b</xsl:text>
              <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/parent::au:fb/@n"/>
              <xsl:text>-</xsl:text>
              <xsl:number select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][preceding::*[name()=$splitEl][1][@n]]">
              <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]/@n, ' ', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]">
                <xsl:number select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/preceding::*[name()=$splitEl][1]"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]" />
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:variable>
    
    <xsl:variable name="nextPageNum">
      <xsl:choose>
        <xsl:when test="$manuscriptname='lady_susan' and $pageNum='6'">
          <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/@n, '.', '')"/>
        </xsl:when>
        <xsl:when test="string(number($pageNum))!='NaN'">
          <xsl:choose>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][parent::au:fb]]">
              <xsl:choose>
                <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][@n]]">
                  <xsl:text>b</xsl:text>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/parent::au:fb/@n"/>
                  <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/@n, ' ', '_')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>b</xsl:text>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/parent::au:fb/@n"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][not(following::*[name()=$splitEl][1])]"/>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][@n]]">
              <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/@n, ' ', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="number($pageNum)+1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][parent::au:fb]]">
              <xsl:choose>
                <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][@n]]">
                  <xsl:text>b</xsl:text>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/parent::au:fb/@n"/>
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/@n, ' ', '_')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>b</xsl:text>
                  <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/parent::au:fb/@n"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]"/>
                </xsl:otherwise>
              </xsl:choose>
              
            </xsl:when>
            <xsl:when test="$milPos//*[name()=$splitEl][@xml:id=$pageId][following::*[name()=$splitEl][1][@n]]">
              <xsl:value-of select="translate($milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]/@n, ' ', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]">
                <xsl:number select="$milPos//*[name()=$splitEl][@xml:id=$pageId]/following::*[name()=$splitEl][1]"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:value-of select="$milPos//*[name()=$splitEl][@xml:id=$pageId]" />
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:variable>
    
    <xsl:for-each select="//TEI">     
      
      <xsl:element inherit-namespaces="yes" name="TEI" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="prev_page">
          <xsl:value-of select="$prevPageNum" />
        </xsl:attribute>
        <xsl:attribute name="next_page">
          <xsl:value-of select="$nextPageNum" />
        </xsl:attribute>
        
        <xsl:sequence select="@*"/>
        <!--        <xsl:sequence select="$pageId"/>-->
        <!--        <xsl:sequence select="$milPos"/>-->
        
        <!--<xsl:sequence select="//teiHeader" />-->
        <xsl:choose>
          <xsl:when
            test="descendant::*[name()=$splitEl][@xml:id = $pageId]/parent::*/descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
            <xsl:if test="$debug"><xsl:comment>RELATED mode is running</xsl:comment></xsl:if>
            <xsl:apply-templates mode="related">
              <xsl:with-param name="manuscriptname" select="$manuscriptname" tunnel="yes"/>
              <xsl:with-param name="splitEl" select="$splitEl" tunnel="yes"/>
              <xsl:with-param name="pgNum" select="$pgNum" tunnel="yes"/>
              <xsl:with-param name="pgRange" select="$pgRange" tunnel="yes"/>
              <xsl:with-param name="pageNum" select="$pageNum" tunnel="yes"/>
              <xsl:with-param name="milPos" select="$milPos" tunnel="yes"/>
              <xsl:with-param name="pageId" select="$pageId" tunnel="yes"/>
              <xsl:with-param name="prevPageNum" select="$prevPageNum" tunnel="yes"/>
              <xsl:with-param name="nextPageNum" select="$nextPageNum" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="descendant::*[name()=$splitEl][@xml:id = $pageId]/not(following::*[name()=$splitEl])">
            <xsl:if test="$debug"><xsl:comment>LASTPAGE mode is running</xsl:comment></xsl:if>
            <xsl:apply-templates mode="lastPage">
              <xsl:with-param name="manuscriptname" select="$manuscriptname" tunnel="yes"/>
              <xsl:with-param name="splitEl" select="$splitEl" tunnel="yes"/>
              <xsl:with-param name="pgNum" select="$pgNum" tunnel="yes"/>
              <xsl:with-param name="pgRange" select="$pgRange" tunnel="yes"/>
              <xsl:with-param name="pageNum" select="$pageNum" tunnel="yes"/>
              <xsl:with-param name="milPos" select="$milPos" tunnel="yes"/>
              <xsl:with-param name="pageId" select="$pageId" tunnel="yes"/>
              <xsl:with-param name="prevPageNum" select="$prevPageNum" tunnel="yes"/>
              <xsl:with-param name="nextPageNum" select="$nextPageNum" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$debug"><xsl:comment>UNRELATED mode is running</xsl:comment></xsl:if>
            <xsl:apply-templates mode="unrelated">
              <xsl:with-param name="manuscriptname" select="$manuscriptname" tunnel="yes"/>
              <xsl:with-param name="splitEl" select="$splitEl" tunnel="yes"/>
              <xsl:with-param name="pgNum" select="$pgNum" tunnel="yes"/>
              <xsl:with-param name="pgRange" select="$pgRange" tunnel="yes"/>
              <xsl:with-param name="pageNum" select="$pageNum" tunnel="yes"/>
              <xsl:with-param name="milPos" select="$milPos" tunnel="yes"/>
              <xsl:with-param name="pageId" select="$pageId" tunnel="yes"/>
              <xsl:with-param name="prevPageNum" select="$prevPageNum" tunnel="yes"/>
              <xsl:with-param name="nextPageNum" select="$nextPageNum" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="text()" mode="#all" />

  <xsl:template
    match="*"
    mode="related">
    
    <xsl:param name="manuscriptname" tunnel="yes"/>
    <xsl:param name="splitEl" tunnel="yes"/>
    <xsl:param name="pgNum" tunnel="yes"/>
    <xsl:param name="pgRange" tunnel="yes"/>
    <xsl:param name="pageNum" tunnel="yes"/>
    <xsl:param name="milPos" tunnel="yes"/>
    <xsl:param name="pageId" tunnel="yes"/>
    <xsl:param name="prevPageNum" tunnel="yes"/>
    <xsl:param name="nextPageNum" tunnel="yes"/>
    
    <xsl:if test="self::*[name()=$splitEl][@xml:id = $pageId]">
      <xsl:call-template name="processMilestone"/>
    </xsl:if>
    
    <xsl:if test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId] and descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
      <xsl:if test="$debug">
        <xsl:comment>
        CREATED
        mode="related" 
        section="common ancestors" 
        template="Creates all ancestor elements common to alpha and beta" 
        id="REL1"
      </xsl:comment>
      </xsl:if>
      
      <xsl:element inherit-namespaces="yes" name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
        <!-- do not sequence rend indent if p does not originate in this page -->
        <xsl:choose>
          <xsl:when test="self::q[@type='c']">
            <xsl:sequence select="@* except @type"/>
            <xsl:attribute name="type">
              <xsl:text>skip</xsl:text>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
            <xsl:sequence select="@* except @rend"/>
            <xsl:choose>
              <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent', 'rule_after')"/>
              <xsl:otherwise>
                <xsl:sequence select="@rend"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="@*" />
          </xsl:otherwise>
        </xsl:choose>
        <!-- Q and QUOTE -->
        <!-- if alpha is child -->
        
        <xsl:if test="(self::q[not(@type)] or self::quote[not(@type)]) and *[name()=$splitEl][@xml:id = $pageId]">
          <xsl:attribute name="type">
            <xsl:text>IGNORE</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when
            test="descendant::*[name()=$splitEl][@xml:id = $pageId]/parent::*/descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
            <xsl:apply-templates mode="related" select="*" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="unrelated" select="*" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="*"
    mode="unrelated">
    
    <xsl:param name="manuscriptname" tunnel="yes"/>
    <xsl:param name="splitEl" tunnel="yes"/>
    <xsl:param name="pgNum" tunnel="yes"/>
    <xsl:param name="pgRange" tunnel="yes"/>
    <xsl:param name="pageNum" tunnel="yes"/>
    <xsl:param name="milPos" tunnel="yes"/>
    <xsl:param name="pageId" tunnel="yes"/>
    <xsl:param name="prevPageNum" tunnel="yes"/>
    <xsl:param name="nextPageNum" tunnel="yes"/>
    
    <xsl:if test="self::*[name()=$splitEl][@xml:id = $pageId]">
      <xsl:call-template name="processMilestone"/>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId] and descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
        <xsl:if test="$debug">
          <xsl:comment>
        CREATED 
        mode="unrelated" 
        section="common 
        ancestors" 
        template="Creates all ancestor elements common to alpha and beta" 
        id="UNRL1"
      </xsl:comment>
        </xsl:if>
        
        <xsl:element inherit-namespaces="yes" name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
          <!-- do not sequence rend indent if p does not originate in this page -->
          <xsl:choose>
            <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
              <xsl:sequence select="@* except @rend"/>
              <xsl:choose>
                <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent', 'rule_after')"/>
                <xsl:otherwise>
                  <xsl:sequence select="@rend"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="self::floatingText[descendant::*[name()=$splitEl][@xml:id = $pageId]]"/>
            <xsl:otherwise>
              <xsl:sequence select="@*" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when
              test="descendant::*[name()=$splitEl][@xml:id = $pageId]/parent::*/descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
              <xsl:apply-templates select="*" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="unrelated" select="node()" />
              
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId] and descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]
        /text()[preceding::*[name()=$splitEl][@xml:id = $pageId] and following::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
        <xsl:if test="$debug">
          <xsl:comment>
        SEQUENCED 
        mode="unrelated" 
        section="common ancestors" 
        template="Creates all ancestor elements common to alpha and beta " 
        id="UNRL-SEQ1"
      </xsl:comment>
        </xsl:if>
        <xsl:sequence select="." />
      </xsl:when>
      <!-- Create alpha's ancestors not yet created -->
      <xsl:when test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId] and not(descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]])]">
        <xsl:if test="$debug">
          <xsl:comment>
          CREATED 
          mode="unrelated" 
          section="alpha" 
          template="Create alpha's ancestors not yet created" 
          id="UNRL2"
        </xsl:comment>
        </xsl:if>
        
        <xsl:element inherit-namespaces="yes" name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
          
          <!-- Amendments to attributes to help next xsl to process correctly -->
          <!-- do not sequence rend indent if p does not originate in this page -->
          <xsl:choose>
            <xsl:when test="self::q[not(@type)] and $manuscriptname='blvolsecond' and $pageNum='215'">
              <xsl:attribute name="type">
                <xsl:text>c</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="self::q[@type='o']">
              <xsl:attribute name="type">
                <xsl:text>skip</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
              <xsl:sequence select="@* except @rend"/>
              <xsl:choose>
                <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent')"/>
                <xsl:otherwise>
                  <xsl:sequence select="@rend"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="self::floatingText[descendant::*[name()=$splitEl][@xml:id = $pageId]]"/>
            <xsl:otherwise>
              <xsl:sequence select="@*" />
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- Q and QUOTE -->
          <!-- if alpha is child -->
          
          <xsl:if test="(self::q[not(@type)] or self::quote[not(@type)]) and *[name()=$splitEl][@xml:id = $pageId]">
            <xsl:attribute name="type">
              <xsl:text>c</xsl:text>
            </xsl:attribute>
          </xsl:if>
          
          <xsl:apply-templates mode="unrelated" select="node()" />
          
        </xsl:element>
      </xsl:when>
      <!-- Copy elements in alphas's ancestors after alpha when unrelated-->
      <xsl:when test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId]]
        [not(descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]])]
        [not(*[name()=$splitEl][@xml:id = $pageId])]
        /node()[preceding::*[name()=$splitEl][@xml:id = $pageId]]">
        <xsl:for-each select=".">          
          <xsl:choose>
            <xsl:when test="descendant-or-self::ptr[@type='displacement']">
              <xsl:call-template name="getPatchPage">
                <xsl:with-param name="recursive" select="true()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="descendant-or-self::ptr[@type='insertion']">
              <xsl:call-template name="getPatchPage">
                <xsl:with-param name="recursive" select="true()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="descendant-or-self::floatingText">
              <xsl:call-template name="getPatchPage">
                <xsl:with-param name="recursive" select="true()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$debug">
                <xsl:comment>
              SEQUENCED 
              mode="unrelated" 
              section="unnamed" 
              template="Copy elements in alphas's ancestors after alpha when unrelated" 
              id="UNRL-SEQ2"
            </xsl:comment>
              </xsl:if>
              <xsl:sequence select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <!-- OTHER SAME-LEVEL ELEMENTS IN BETWEEN ALPHA AND BETA -->
      <xsl:when test="self::*
        [descendant::*[name()=$splitEl][@xml:id = $pageId][1]]
        [descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]][1]]
        /*
        [preceding::*[*[name()=$splitEl][@xml:id = $pageId]]]
        [following::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]
        ">
        <xsl:choose>
          <xsl:when test="descendant-or-self::ptr[@type='displacement']">
            <xsl:call-template name="getPatchPage">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="descendant-or-self::ptr[@type='insertion']">
            <xsl:call-template name="getPatchPage">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="descendant-or-self::floatingText">
            <xsl:call-template name="getPatchPage">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$debug">
              <xsl:comment>
            SEQUENCED 
            mode="unrelated" 
            section="OTHER SAME-LEVEL ELEMENTS IN BETWEEN ALPHA AND BETA" 
            template="unnamed" 
            id="UNRL-SEQ3"
          </xsl:comment>
            </xsl:if>
            <xsl:sequence select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- Create beta's ancestors not yet created with their content up to beta's parent -->
      <xsl:when test="self::*[not(descendant::*[name()=$splitEl][@xml:id = $pageId]) and descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
        <xsl:if test="$debug">
          <xsl:comment>
        CREATED 
        mode="unrelated" 
        section="beta" 
        template="Create beta's ancestors not yet created with their content up to beta's parent" 
        id="UNRL3"/>
      </xsl:comment>
        </xsl:if>
        
        
        <xsl:element inherit-namespaces="yes" name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
          
          <!-- do not sequence rend indent if p does not originate in this page -->
          <xsl:choose>
            <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
              <xsl:sequence select="@* except @rend"/>
              <xsl:choose>
                <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent')"/>
                <xsl:otherwise>
                  <xsl:sequence select="@rend"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@*" />
            </xsl:otherwise>
          </xsl:choose>
          <!-- Amendments to attributes to help next xsl to process correctly -->
          
          <!-- Q and QUOTE -->
          <!-- if beta is child -->
          
          <xsl:choose>
            <xsl:when
              test="(self::q[not(@type)] or self::quote[not(@type)]) and *[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
              <xsl:attribute name="type">
                <xsl:text>o</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="self::q[@type='c']">
              <xsl:attribute name="type">
                <xsl:text>skip</xsl:text>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates mode="unrelated" select="node()" />
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::*[not(descendant::*[name()=$splitEl][@xml:id = $pageId]) and descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]] and not(*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]])]
        /text()[following::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
        <xsl:if test="$debug">
          <xsl:comment>
        SEQUENCED 
        mode="unrelated" 
        section="BETA" 
        template="Create beta's ancestors not yet created with their content up to beta's parent" 
        id="UNRL-SEQ4"
      </xsl:comment>
        </xsl:if>
        <xsl:sequence select="." />
      </xsl:when>
      <!-- Copy elements in beta's descendants before beta-->
      <xsl:when test="self::*[not(descendant::*[name()=$splitEl][@xml:id = $pageId])]
        [descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]
        [not(*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]])]
        /*[following::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]">
        <xsl:if test="$debug">
          <xsl:comment>
        SEQUENCED 
        mode="unrelated" 
        section="BETA" 
        template="Copy elements in beta's descendants before beta" 
        id="UNRL-SEQ5"
      </xsl:comment>
        </xsl:if>
        <xsl:sequence select="." />
      </xsl:when>
      <xsl:when test="self::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
        <xsl:choose>
          
          <!--If it also contains alpha-->
          
          <xsl:when test="parent::*/descendant::*[name()=$splitEl][@xml:id = $pageId]" />
          
          <!--otherwise copy beta's preceding-siblings-->
          <xsl:otherwise>
            <xsl:for-each select="preceding-sibling::node()">
              <xsl:if test="$debug">
                <xsl:comment>
              SEQUENCED 
              mode="unrelated" 
              section="BETA" 
              template="unnamed" 
              id="UNRL-SEQ6"
            </xsl:comment>
              </xsl:if>
              <xsl:sequence select="." />
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <xsl:otherwise/>
      
    </xsl:choose>   
    
  </xsl:template>  

  <xsl:template
    match="*"
    mode="lastPage">
    
    <xsl:param name="manuscriptname" tunnel="yes"/>
    <xsl:param name="splitEl" tunnel="yes"/>
    <xsl:param name="pgNum" tunnel="yes"/>
    <xsl:param name="pgRange" tunnel="yes"/>
    <xsl:param name="pageNum" tunnel="yes"/>
    <xsl:param name="milPos" tunnel="yes"/>
    <xsl:param name="pageId" tunnel="yes"/>
    <xsl:param name="prevPageNum" tunnel="yes"/>
    <xsl:param name="nextPageNum" tunnel="yes"/>
    
    <xsl:if test="self::*[name()=$splitEl][@xml:id = $pageId]">
      <xsl:call-template name="processMilestone"/>
    </xsl:if>
    
    <xsl:if test="self::*[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
      <xsl:if test="$debug">
        <xsl:comment>
        CREATED 
        mode="unrelated" 
        section="last page templates" 
        template="If contains text and parent contains text" 
        id="LP1"
        notes="CONTAINS text, CONTAINS text"
      </xsl:comment>
      </xsl:if>
      
      <xsl:element inherit-namespaces="yes" name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
        
        <!-- Amendments to attributes to help next xsl to process correctly -->
        <!-- do not sequence rend indent if p does not originate in this page -->
        <xsl:choose>
          <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
            <xsl:sequence select="@* except @rend"/>
            <xsl:choose>
              <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent')"/>
              <xsl:otherwise>
                <xsl:sequence select="@rend"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="@*" />
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- Q and QUOTE -->
        <!-- if alpha is child -->
        
        <xsl:if test="(self::q[not(@type)] or self::quote[not(@type)]) and *[name()=$splitEl][@xml:id = $pageId]">
          <xsl:attribute name="type">
            <xsl:text>c</xsl:text>
          </xsl:attribute>
        </xsl:if>
        
        <xsl:apply-templates select="*[name()=$splitEl][@xml:id = $pageId]">
          <xsl:with-param name="lastpage" select="'y'"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates mode="lastPage" select="*[descendant::*[name()=$splitEl][@xml:id = $pageId]]" />
        
        <xsl:if test="$debug">
          <xsl:comment>
          SEQUENCED 
          mode="lastPage" 
          section="last page templates" 
          template="If contains text and parent contains text" 
          id="LP-SEQ1"
        </xsl:comment>
        </xsl:if>
        
        <xsl:sequence select="node()[preceding::*[name()=$splitEl][@xml:id = $pageId]]"/>
        
      </xsl:element>
    </xsl:if>
        
  </xsl:template>

  <xsl:template name="processMilestone">
    <xsl:param name="manuscriptname" tunnel="yes"/>
    <xsl:param name="splitEl" tunnel="yes"/>
    <xsl:param name="pgNum" tunnel="yes"/>
    <xsl:param name="pgRange" tunnel="yes"/>
    <xsl:param name="pageNum" tunnel="yes"/>
    <xsl:param name="milPos" tunnel="yes"/>
    <xsl:param name="pageId" tunnel="yes"/>
    <xsl:param name="prevPageNum" tunnel="yes"/>
    <xsl:param name="nextPageNum" tunnel="yes"/>
    
    <xsl:param name="lastpage" select="'n'"/>
    
      <!-- If immediately preceeded by an lb, include it as well (for line break rendition) -->
      <xsl:if test="preceding-sibling::node()[1][not(normalize-space(.)=' ')][self::lb[@rend]]">
        <xsl:sequence select="preceding-sibling::node()[1][not(normalize-space(.)=' ')][self::lb[@rend]]" />
      </xsl:if>
      <!-- If immediately preceeded by au:fb, include it as well. TBA -->
      
      <!-- Copy alpha and the preciding handShift if it exists -->
      <xsl:if test="$debug">
        <xsl:comment>
        CREATED 
        mode="ALL" 
        section="alpha" 
        template="Copy alpha and the preciding handShift if it exists" 
        id="ALL1"
      </xsl:comment>
      </xsl:if>
      <xsl:element inherit-namespaces="yes" name="{$splitEl}" namespace="http://www.tei-c.org/ns/1.0">
        <!-- do not sequence rend indent if p does not originate in this page -->
        <xsl:choose>
          <xsl:when test="self::p[descendant::*[name()=$splitEl][@xml:id = $pageId]]">
            <xsl:sequence select="@* except @rend"/>
            <xsl:choose>
              <xsl:when test="@rend=('indent', 'indent1', 'indent2', 'short-indent')"/>
              <xsl:otherwise>
                <xsl:sequence select="@rend"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="@*" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(@n)">
          <xsl:attribute name="n_added">
            <xsl:value-of select="$pageNum" />
          </xsl:attribute>
        </xsl:if>
        <!--<xsl:sequence select="@*" />-->
        
        <!-- v1.1: Determine prev fascicule if present -->
        
        <xsl:if test="preceding::au:fb[1]">
          <au:prev_fb position="{count(preceding::au:fb)}">
            <xsl:sequence select="preceding::au:fb[1]" />
          </au:prev_fb>
        </xsl:if>
        
      </xsl:element>
      <xsl:if test="preceding::handShift[1]">
        <xsl:sequence select="preceding::handShift[1]" />
      </xsl:if>
      <xsl:if test="preceding-sibling::node()[1][name()='au:fb']">
        <xsl:sequence select="preceding::au:fb[1]" />
      </xsl:if>
      
      <xsl:choose>
        
        <!-- If parent also has beta descendant -->
        
        <xsl:when
          test="parent::*/descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
          <xsl:for-each select="parent::*">
            <xsl:call-template name="copy2beta_ancestor" />
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$lastpage='y'"/>
        <!-- otherwise copy alpha's following-siblings -->
        <!-- 1.2 and call getPatchPage template if prt or floatingText are the current elements -->
        <xsl:otherwise>
          <xsl:for-each select="following-sibling::node()">
            <xsl:choose>
              <xsl:when test="descendant-or-self::ptr[@type='displacement']">
                <xsl:call-template name="getPatchPage">
                  <xsl:with-param name="recursive" select="true()"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="descendant-or-self::ptr[@type='insertion']">
                <xsl:call-template name="getPatchPage">
                  <xsl:with-param name="recursive" select="true()"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="descendant-or-self::floatingText">
                <xsl:call-template name="getPatchPage">
                  <xsl:with-param name="recursive" select="true()"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$debug">
                  <xsl:comment>
                  SEQUENCED 
                  mode="ALL" 
                  section="alpha" 
                  template="Copy alpha and the preciding handShift if it exists" 
                  id="ALL2"
                </xsl:comment>
                </xsl:if>
                <xsl:sequence select="." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
        
  </xsl:template>

  <xsl:template name="copy2beta_ancestor">

    <xsl:param name="manuscriptname" tunnel="yes"/>
    <xsl:param name="splitEl" tunnel="yes"/>
    <xsl:param name="pgNum" tunnel="yes"/>
    <xsl:param name="pgRange" tunnel="yes"/>
    <xsl:param name="pageNum" tunnel="yes"/>
    <xsl:param name="milPos" tunnel="yes"/>
    <xsl:param name="pageId" tunnel="yes"/>
    <xsl:param name="prevPageNum" tunnel="yes"/>
    <xsl:param name="nextPageNum" tunnel="yes"/>

    <!-- Copy all the siblings until the one that has beta as descendant -->

    <xsl:for-each-group
      group-starting-with="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1] | *[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]"
      select="node()">

      <xsl:choose>
        <xsl:when
          test="current-group()[descendant-or-self::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]]" />
        <xsl:otherwise>
          <xsl:for-each select="current-group()">
            <xsl:choose>
              <xsl:when test="self::floatingText[@type='displaced']">
                  <xsl:call-template name="getPatchPage">
                    <xsl:with-param name="create_element" select="true()"/>
                  </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$debug">
                  <xsl:comment>
                    SEQUENCED 
                    mode="related" 
                    section="unknown" 
                    template="copy2beta_ancestor" 
                    id="CTOB-SEQ1"
                  </xsl:comment>
                </xsl:if>
                <xsl:sequence select=".[preceding::*[name()=$splitEl][@xml:id = $pageId]]" />
              </xsl:otherwise>
            </xsl:choose>
            
          </xsl:for-each>   
         <!-- <xsl:choose>
            <xsl:when test="current-group()[descendant-or-self::floatingText[@type='displaced']]">
                         
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="current-group()[preceding::*[name()=$splitEl][@xml:id = $pageId]]" />
            </xsl:otherwise>
          </xsl:choose>-->
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each-group>

    <!-- Create the node with descendant beta and repeat 1. -->

    <xsl:choose>
      <xsl:when
        test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]">
        
        <xsl:if test="$debug">
          <xsl:comment>
            CREATED 
            mode="related" 
            section="unknown" 
            template="copy2beta_ancestor" 
            id="CTOB1"
          </xsl:comment>
        </xsl:if>
        
        <xsl:choose>
          <xsl:when test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][namespace-uri()='http://www.cch.kcl.ac.uk/xmlns/austen']">
            <xsl:element 
              name="{node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/name()}"
              namespace="http://www.cch.kcl.ac.uk/xmlns/austen">
              <xsl:sequence
                select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/@*" />
              <!-- Q and QUOTE -->
              <!-- if beta is child -->
              <!-- start only for standard quote -->
              <xsl:if
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::q[not(@type)]] and node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
                <xsl:attribute name="type">
                  <xsl:text>o</xsl:text>
                </xsl:attribute>
              </xsl:if>
              <!-- ingore if "close only" (@type='c') quote -->
              <xsl:if
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::q[@type='c']] and node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
                <xsl:attribute name="type">
                  <xsl:text>IGNORE</xsl:text>
                </xsl:attribute>
              </xsl:if>
              
             
              <!-- 1.2 change floatingText corresp and ignore floatingText insertion-->
              
              <xsl:if 
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][@type='displaced']">
                <xsl:for-each select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][@type='displaced']">
                  <xsl:call-template name="getPatchPage">
                    <xsl:with-param name="create_element" select="false()"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:if>
              
              <xsl:if 
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][substring-after(@corresp, '#')=//ptr[@type='insertion']/@xml:id]">
                
              </xsl:if>
              
              <xsl:for-each
                select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]">
                <xsl:call-template name="copy2beta_ancestor" />
              </xsl:for-each>
              
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            
            <xsl:if test="$debug">
              <xsl:comment>
                CREATED 
                mode="related" 
                section="unknown" 
                template="copy2beta_ancestor" 
                id="CTOB1-otherwise"
              </xsl:comment>
            </xsl:if>
            
            <xsl:element inherit-namespaces="yes"
              name="{node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/name()}"
              namespace="http://www.tei-c.org/ns/1.0">
              <xsl:sequence
                select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/@*" />
              <!-- Q and QUOTE -->
              <!-- if beta is child -->
              <!-- start only for standard quote -->
              <xsl:if
                test="(node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::q[not(@type)]] and node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]])
                or ($manuscriptname='blvolsecond' and $pageNum='214')
                ">
                <xsl:attribute name="type">
                  <xsl:text>o</xsl:text>
                </xsl:attribute>
              </xsl:if>
              <!-- ingore if "close only" (@type='c') quote -->
              <xsl:if
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::q[@type='c']] and node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]/*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]">
                <xsl:attribute name="type">
                  <xsl:text>IGNORE</xsl:text>
                </xsl:attribute>
              </xsl:if>
              <!-- ignore @rend if 'indent', 'indent1', 'indent2', 'short-indent', 'rule_after' -->
              <xsl:if
                test="( ($manuscriptname='blvolsecond' and ($pageNum='188' or $pageNum='189')) or ($manuscriptname='qmwats' and $pageNum='b7-1') )
                and node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::p][@rend=('indent', 'indent1', 'indent2', 'short-indent', 'rule_after')]">
                <xsl:attribute name="rend">IGNORE</xsl:attribute>
              </xsl:if>
              
              <!-- 1.2 change floatingText corresp and ignore floatingText insertion-->
              
              <xsl:if 
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][@type='displaced']">
                <xsl:for-each select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][@type='displaced']">
                  <xsl:call-template name="getPatchPage">
                    <xsl:with-param name="create_element" select="false()"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:if>
              
              <xsl:if 
                test="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1][self::floatingText][substring-after(@corresp, '#')=//ptr[@type='insertion']/@xml:id]">
                
              </xsl:if>
              
              <xsl:for-each
                select="node()[descendant::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][preceding::*[name()=$splitEl][not(@rend) or @rend != 'overstrike'][number($pgRange)][@xml:id = $pageId]]][1]">
                <xsl:call-template name="copy2beta_ancestor" />
              </xsl:for-each>
              
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
