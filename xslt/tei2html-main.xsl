<?xml version="1.0" encoding="UTF-8"?>
<!-- checked. jawalsh. $Id$ -->
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc" exclude-result-prefixes="#all"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml">
    

    


    
        <xdoc:author>John A. Walsh</xdoc:author>
        <xdoc:copyright>Copyright 2006 John A. Walsh</xdoc:copyright>
        <xdoc:short>XSLT stylesheet to transform TEI P5 documents to XHTML.</xdoc:short>

    <!-- naming conventions:
        
         named templates:
         parameters that indicate option material in output use "include...", e.g., "includeDocumentInformation"
        
    -->
    

    <xsl:template match="/" priority="1">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- debugging template -->
    <xsl:template match="*">
        <xsl:message>
            <xsl:value-of select="concat(name(),': ')"/> ELEMENT UNACCOUNTED FOR BY STYLESHEET:
        </xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Check for single or double quotation mark format -->
    
    <xsl:param name="quotation_format" as="xs:string">
        <xsl:value-of select="TEI/teiHeader/encodingDesc/editorialDecl/quotation//*[@xml:id='quotation_format']"/>
    </xsl:param>
    
    <!-- TEI|teiCorpus -->
    <xdoc:doc>
        <xdoc:short>Matches root (TEI|teiCorpus) and starts things off.</xdoc:short>
        <xdoc:detail>By default, outputs full XHTML document. If $outputAsDiv is set to true, then
            an HTML div is output.</xdoc:detail>
    </xdoc:doc>
    <xsl:template match="TEI|teiCorpus">
        <xsl:choose>
            <xsl:when test="$outputAsDiv = true()">
                <div id="output-content">
                    <xsl:call-template name="id"/>
                    <xsl:if test="$includeDocumentInformation = true()">
                        <xsl:call-template name="docinfo"/>
                    </xsl:if>
                    <div>
                        <xsl:apply-templates/>
                        <xsl:call-template name="endnotes"/>
                        <xsl:if test="$displayThematicKeywords = true()">
                            <xsl:call-template name="thematicKeywords"/>
                        </xsl:if>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <!-- no id attribute on <html>.  Need to stick id in a <meta> tag somewhere -->
                    <xsl:call-template name="htmlHead"/>
                    <body onload="init();">
                        <div id="output-content">
                            <xsl:if test="contains(/TEI/text/body/@rendition,'#wide')">
                                <xsl:attribute name="style" select="'width:100%;'"/>
                            </xsl:if>
                        <xsl:if test="$includeDocumentInformation = true()">
                            <xsl:call-template name="docinfo"/>
                        </xsl:if>
                        <xsl:if test="$includeDocHeader = true()">
                            <xsl:call-template name="docHeader"/>
                        </xsl:if>
                        <!-- div included to validate poetry line groups which are spans and must have a parent div. -->
                        <div>
                            <xsl:apply-templates/>
                            <xsl:call-template name="endnotes"/>
                            <xsl:if test="$displayThematicKeywords = true()">
                                <xsl:call-template name="thematicKeywords"/>
                            </xsl:if>
                        </div>
                        </div>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="body">
        <div>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    

    <xdoc:short>Creates a "header" for the HTML page with title, author, and other information.</xdoc:short>
    
    <xsl:template name="docHeader">
        <div id="docHeader">
            <div id="docTitle">
                <xsl:apply-templates select="/TEI/teiHeader/fileDesc/titleStmt/title"/>
            </div>
            <div id="docAuthor">
                <xsl:apply-templates select="/TEI/teiHeader/fileDesc/titleStmt/author"/>
            </div>
            <xsl:if test="/TEI/teiHeader/fileDesc/titleStmt/editor[not(persName[@key = 'jawalsh'])]">
                <div id="docEditor">
                    <xsl:text>Edited by </xsl:text><xsl:apply-templates select="/TEI/teiHeader/fileDesc/titleStmt/editor"/>
                </div>
            </xsl:if>
            
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc//ptr[@type='source']">
                <div id="docSource"> TEI/XML source: <xsl:apply-templates
                        select="/TEI/teiHeader/fileDesc/sourceDesc//ptr[@type='source']"/>
                </div>
            </xsl:if>
            <hr/>
        </div>
    </xsl:template>



    <xsl:template match="teiCorpous/TEI">
        <div>
            <xsl:call-template name="id"/>
            <xsl:if test="$includeDocumentInformation = true()">
                <xsl:call-template name="docinfo"/>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xdoc:doc>divisions</xdoc:doc>
    <xsl:template match="div|div0|div1|div2|div3|div4|div5|div6">
        <xsl:variable name="depth">
            <xsl:apply-templates select="." mode="depth"/>
        </xsl:variable>
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="concat('teidiv',$depth)"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xdoc:doc>division heads</xdoc:doc>
    <xsl:template
        match="div/head|div0/head|div1/head|div2/head|div3/head|div4/head|div5/head|div6/head|div7/head">
        <xsl:variable name="depth">
            <xsl:apply-templates select="parent::*" mode="depth"/>
        </xsl:variable>
        <xsl:choose>
            <!-- need first when/@test to avoid duplicate heads in slides -->
            <xsl:when test="($depth = 0) and ($makingSlides = true())"/>
            <xsl:when test="($depth + 1) &gt; 6">
                <xsl:element name="h6">
                    <xsl:call-template name="rendition"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="h{$depth + 1}">
                    <xsl:call-template name="rendition"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xdoc:doc>divisions mode="depth". Returns the hierarchical level of the division, starting from
        0.</xdoc:doc>
    <xsl:template match="div|div0|div1|div2|div3|div4|div5|div6" mode="depth">
        <xsl:choose>
            <xsl:when test="name(.) = 'div'">
                <xsl:value-of select="count(ancestor::div)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::div0">
                        <xsl:value-of select="substring-after(name(.),'div')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="number(substring-after(name(.),'div')) - 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="head" mode="plain">
        <xsl:apply-templates/>        
    </xsl:template>


    <xsl:template match="head">
        <div>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'genericHeading'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="ab">
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'ab'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="p">
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'p'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>




    <!-- named templates -->

    <xdoc:doc>
        <xdoc:short>Outputs XHTML head and child elements.</xdoc:short>
    </xdoc:doc>

    <xsl:template name="htmlHead">
        <head>
            <xsl:variable name="headTitle">
                <xsl:call-template name="generateTitle"/>
            </xsl:variable>
            <title>
                <xsl:value-of select="$headTitle"/>
            </title>
            <xsl:if test="$cssFile != ''">
                <xsl:choose>
                    <xsl:when test="$standalone = true()">
                        <style type="text/css">
                            <xsl:value-of select="unparsed-text($cssFile)"/>
                        </style>
                    </xsl:when>
                    <xsl:otherwise>
                        <link rel="stylesheet" type="text/css">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$cssFile"/>
                            </xsl:attribute>
                        </link>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="$jsFile != ''">
                <xsl:choose>
                    <xsl:when test="$standalone = true()">
                        <!-- embedding js isn't working -->
                        <script type="text/javascript" src="{$jsFile}">
                            <xsl:comment> //IE doesn't like empty script tag. </xsl:comment>
                        </script>
                        <!--
                        <script type="text/javascript">
                            <xsl:comment>
                                <xsl:text>
                                </xsl:text>
                            <xsl:value-of select="unparsed-text($jsFile)"/>
                            </xsl:comment>
                        </script>
                        -->
                    </xsl:when>
                    <xsl:otherwise>
                        <script type="text/javascript" src="{$jsFile}">
                            <xsl:comment> //IE doesn't like empty script tag. </xsl:comment>
                        </script>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </head>
    </xsl:template>

    <xdoc:doc>
        <xdoc:short>Transfers TEI @rendition values to XHTML @class values.</xdoc:short>
        <xdoc:detail>This template assumes a specific encoding practice whereby TEI @rendition values are analagous to XHTML classes, a whitespace separated list of styles. The template accepts a "defaultRend" parameter passed in from the calling template. The default rendition values will be concatenated with the content of @rendition. So, for instance, the title template may have a defaultRend of "i" (for italics), which could then be combined with additional styles listed in @rendition, e.g., "u" (for underlined) or "b" (for bold).</xdoc:detail>
    </xdoc:doc>
    
    <xsl:template name="rendition">
        <xsl:param name="defaultRend"/>
        <xsl:choose>
            <xsl:when test="@rendition and @rendition != ''">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$defaultRend != ''">
                            <xsl:value-of select="concat($defaultRend,' ',translate(normalize-space(@rendition), '#', ''))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="translate(normalize-space(@rendition), '#', '')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:if test="$defaultRend !=''">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$defaultRend"/>
                    </xsl:attribute>
                    
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template name="rend">
        <xsl:if test="@rend and @rend != ''">
        <xsl:attribute name="style">
            <xsl:value-of select="@rend"/>
        </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="atts">
        <xsl:call-template name="id"/>
        <xsl:call-template name="rendition"/>
        <xsl:call-template name="rend"/>
    </xsl:template>
    
   
<!-- 
    <xsl:template name="rendition">
        <xsl:param name="defaultRend"/>
        <xsl:choose>
            <xsl:when test="@rend and @rend != ''">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$defaultRend != ''">
                            <xsl:value-of select="concat($defaultRend,' ',@rend)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@rend"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>

                <xsl:if test="$defaultRend !=''">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$defaultRend"/>
                    </xsl:attribute>

                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->

    <xdoc:doc>Passes xml:id from TEI element to corresponding XHTML element.</xdoc:doc>
    <xsl:template name="id">
        <xsl:if test="@xml:id">
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xdoc:doc>Outputs unclear readings with tool tip that provides certainty and responsibility
        information.</xdoc:doc>
    <xsl:template match="unclear">
        <xsl:choose>
            <xsl:when test="@cert|@reason">
                <span class="tooltip" onmouseout="hideTip()">
                    <xsl:attribute name="onmouseover">
                        <xsl:text>doTooltip(event,'&lt;b&gt;unclear reading&lt;/b&gt;&lt;br /&gt;</xsl:text>
                        <xsl:if test="@cert">
                            <xsl:text>&lt;b&gt;certainty:&lt;/b&gt; </xsl:text>
                            <xsl:value-of select="@cert"/>
                        </xsl:if>
                        <xsl:if test="@resp">
                            <xsl:if test="@cert">
                                <xsl:text>&lt;br/&gt;</xsl:text>
                            </xsl:if>
                            <xsl:text>&lt;b&gt;read by:&lt;/b&gt; </xsl:text>
                            <xsl:choose>
                                <xsl:when test="@resp = 'jawalsh'">
                                    <xsl:text>John A. Walsh</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@resp"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:text>')</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$preEditorialIntervention"/>
                    <i>
                        <xsl:apply-templates/>
                    </i>
                    <xsl:value-of select="$postEditorialIntervention"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="tooltip" onmouseover="doTooltip(event,'reason: unknown')"
                    onmouseout="hideTip()">
                    <xsl:value-of select="$preEditorialIntervention"/>
                    <i>illeg.</i>
                    <xsl:value-of select="$postEditorialIntervention"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xdoc:doc>Outputs supplied tag within "editorial intervention" strings.</xdoc:doc>
    <xsl:template match="supplied">
        <xsl:value-of select="$preEditorialIntervention"/>
        <xsl:apply-templates/>
        <xsl:value-of select="$postEditorialIntervention"/>
    </xsl:template>

    <xdoc:doc>Handles choice between abbr and expan. Assumes one child abbr and one child expan.</xdoc:doc>
    <xsl:template match="choice[abbr]">
        <xsl:choose>
            <xsl:when test="expan and ($expandAbbr = true())">
                <xsl:apply-templates select="expan"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="abbr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xdoc:doc>Handles choice between orig and reg. Assumes one child orig and one child reg.</xdoc:doc>
    <xsl:template match="choice[orig]">
        <xsl:choose>
            <xsl:when test="reg and ($regularizeOrig = true())">
                <xsl:apply-templates select="reg"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="orig"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xdoc:doc>Handles choice between orig and reg. Assumes one child orig and one child reg. Special mode for end-of-line hyphenation. See also: template for "lb[n='eol']".</xdoc:doc>
    
    <!-- choice things -->
    
    <xsl:template match="choice[@n='eol']" priority="10">
        <xsl:choose>
            <xsl:when test="eol=true()">
                <xsl:apply-templates select="orig"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="reg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    


    <xdoc:doc>Handles choice between sic and corr. Assumes one child sic and one child corr.</xdoc:doc>
    <xsl:template match="choice[sic]">
        <xsl:choose>
            <xsl:when test="corr and ($correctSic = true())">
                <xsl:apply-templates select="corr"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="sic"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="del">
        <span>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'strike'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xdoc:doc>Tests @place attribute to superscript or subscript output.</xdoc:doc>
    <xsl:template match="add">
        <xsl:choose>
            <xsl:when test="@place = 'supralinear' or @place = 'above'">
                <span>
                    <xsl:call-template name="rendition">
                        <xsl:with-param name="defaultRend">
                            <xsl:value-of select="'super'"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@place = 'infralinear' or @place = 'below'">
                <span>
                    <xsl:call-template name="rendition">
                        <xsl:with-param name="defaultRend">
                            <xsl:value-of select="'sub'"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xdoc:doc>Placeholder for inline elements that are not handled in any special way.</xdoc:doc>
    <xsl:template match="activity">
        <xsl:apply-templates/>
    </xsl:template>


    <xdoc:doc>general template for title</xdoc:doc>
    <xsl:template match="title">
        <span>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:if test="not(@rendition) or @rendition=''">
                        <xsl:value-of select="'i'"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xdoc:doc>special mode to add a space between multiple title elements. E.g. in teiHeader one
        might have title[@type='main'] followed by title[@type='sub'], and one wants at least a
        space between these two title elements.</xdoc:doc>
    <xsl:template match="title" mode="multi-title">
        <xsl:if test="preceding-sibling::title">
            <xsl:text>  </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="generateTitle">
        <xsl:choose>
            <xsl:when test="/teiCorpus">
                <xsl:apply-templates
                    select="ancestor-or-self::teiCorpus/teiHeader/fileDesc/titleStmt/title"
                    mode="multi-title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates
                    select="ancestor-or-self::TEI/teiHeader/fileDesc/titleStmt/title"
                    mode="multi-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xdoc:doc>Do nothing by default with teiHeader, so elements can be accessed explicitly
        elsewhere.</xdoc:doc>
    <xsl:template match="teiHeader"/>



    <xsl:template match="salute">
        <div>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'salute'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:template
        match="div[@type='frontispiece']|div[@type='epistle']|div[@type='illustration']|byline">
        <div>
            <xsl:call-template name="rendition"/>
            <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xdoc:doc>Handling of poetic stanzas. Special case for lg[@rend='sublg'], which represents a
        "line group" within a stanza, that is not separated by white space from the recent of the
        stanza, e.g., the octect and sestet within a Petrarchan sonnet or the four quatrains and
        couplet in a Shakesperian sonnet.</xdoc:doc>

    <xsl:template match="lg">
        <span>
            <xsl:choose>
                <xsl:when test="contains(@rendition,'sublg')">
                    <xsl:call-template name="rendition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="rendition">
                        <xsl:with-param name="defaultRend">lg</xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates select="head" mode="lgHead"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="head" mode="lgHead">
        <span>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'genericHeading'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="lg/head"/>

    <xdoc:doc>
        <xdoc:short>Handling of poetic lines</xdoc:short>
        <xdoc:detail>Wraps poetic lines in a series of divs that, when combined with the proper CSS,
            displays formated poetic lines with proper indentation (derived from l/@rend attributes)
            and line numbering (derived from l/@n attributes.</xdoc:detail>
    </xdoc:doc>

    <xsl:template match="l">
        <span class="lineWrapper">
            <span>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="label">
                            <xsl:text>lineWithLabel</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <span>
                    <xsl:call-template name="id"/>
                    <xsl:call-template name="rend"/>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="not(contains(@rendition,'ti-'))">
                                <xsl:call-template name="rendition">
                                    <xsl:with-param name="defaultRend">
                                        <xsl:value-of select="'ti-0'"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="rendition"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </span>
            <xsl:if test="label">
                <span class="lineLabel">
                    <xsl:apply-templates select="./label" mode="lineLabel"/>
                </span>
            </xsl:if>
            <span class="number">
                <xsl:choose>
                    <xsl:when test="@n mod $lineNumberFrequency = 0">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment>don't want empty div</xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </span>
    </xsl:template>


    <xsl:template match="l/label"/>
    <xsl:template match="l/label" mode="lineLabel">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="note">
        <span>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="note" mode="hide">
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'note suppress'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:template match="note[@type= 'gloss']" priority="1">
        <xsl:apply-templates select="." mode="generated-reference"/>
    </xsl:template>

<!--
   
-->
    <xsl:template match="note[@type = 'gloss']/term">
        <span class="glossTerm">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template match="note[@type = 'gloss']/gloss">
        <span class="gloss">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="note[@type = 'dev']|note[@type = 'metadocument']"/>

   <!-- jsInit not needed if use window.onload in .js file -->
    <xsl:template name="jsInit">
        <xsl:attribute name="onload">
            <xsl:value-of select="'Tooltip.init();'"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="persName|placeName|geogName|orgName|name|rs">
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition"/>
            <xsl:apply-templates/>
            <xsl:if test="contains(@corresp,'#unfamiliar')">
                <xsl:call-template name="nameGloss">
                    <xsl:with-param name="target">
                        <xsl:value-of select="@key"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </span>
    </xsl:template>


    <xsl:template match="listBibl">
        <div>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- need similar for biblStruct and biblFull -->
    <xsl:template match="listBibl/bibl">
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'bibl'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="listBibl/biblStruct">
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'bibl'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="get-author"/>
            <xsl:call-template name="get-editor-analytic"/>
            <xsl:if test="analytic/title">
                <xsl:call-template name="get-title-analytic"/>
            </xsl:if>
            <xsl:call-template name="get-title-monogr"/>
            <xsl:if test="analytic and not(analytic/author)">
                <xsl:call-template name="get-author-monogr"/>
            </xsl:if>
            
            <xsl:call-template name="get-editor-monogr"/>
            <xsl:call-template name="get-extent"/>
            <xsl:call-template name="get-pubPlace"/>
            <xsl:call-template name="get-publisher"/>
            <xsl:call-template name="get-date"/>
            <xsl:call-template name="get-biblScope"/>
            <xsl:call-template name="get-origPubInfo"/>
        </div>
    </xsl:template>
    
    <xsl:template name="get-author">
        <xsl:param name="author">
            <xsl:choose>
                <xsl:when test="analytic">
                    <xsl:choose>
                <xsl:when test="analytic/author/persName/@key">
                    <xsl:call-template name="getXtmName">
                        <xsl:with-param name="target" select="analytic/author/persName/@key"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="analytic/author">
                    <xsl:value-of select="analytic/author"/>
                </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                <xsl:when test="monogr/author/persName/@key">
                    <xsl:call-template name="getXtmName">
                        <xsl:with-param name="target" select="monogr/author/persName/@key"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="monogr/author">
                    <xsl:value-of select="monogr/author"/>
                </xsl:when>
                <xsl:when test="analytic/editor"/>
                <xsl:when test="monogr/editor"/>
                <xsl:otherwise>
                    <xsl:value-of select="'unknown'"/>
                </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:if test="$author != ''">
            <xsl:choose>
                <xsl:when test="not(ends-with(normalize-space($author),'.'))">
                    <xsl:value-of select="concat(normalize-space($author),'. ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(normalize-space($author),' ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get-author-monogr">
        <xsl:param name="author">
            <xsl:choose>
                        <xsl:when test="monogr/author/persName/@key">
                            <xsl:call-template name="getXtmName">
                                <xsl:with-param name="target" select="monogr/author/persName/@key"/>
                                <xsl:with-param name="scope" select="'display'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="mongr/author/persName">
                            <xsl:value-of select="mongr/author/persName"/>
                        </xsl:when>
                        <xsl:when test="monogr/author">
                            <xsl:value-of select="monogr/author"/>
                        </xsl:when>
                        <xsl:when test="analytic/editor"/>
                        <xsl:when test="monogr/editor"/>
                        <xsl:otherwise>
                            <xsl:value-of select="'unknown'"/>
                        </xsl:otherwise>
                    </xsl:choose>
        </xsl:param>
        <xsl:if test="$author != ''">
            <xsl:choose>
                <xsl:when test="not(ends-with(normalize-space($author),'.'))">
                    <xsl:value-of select="concat('By ', normalize-space($author),'. ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('By ', normalize-space($author),' ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get-editor-analytic">
        
        <xsl:param name="editor">
            <xsl:choose>
                <xsl:when test="analytic/editor/persName/@key">
                    <xsl:call-template name="getXtmName">
                        <xsl:with-param name="target" select="analytic/editor/persName/@key"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="analytic/editor">
                    <xsl:value-of select="analytic/editor"/>
                </xsl:when>
                <!--
                    <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/editor/persName/@key">
                    <xsl:call-template name="getXtmName">
                    <xsl:with-param name="target" select="/TEI/teiHeader/fileDesc/editor/author/persName/@key"/>
                    </xsl:call-template>
                    </xsl:when>
                -->
            </xsl:choose>
        </xsl:param>
        <xsl:if test="$editor != ''">
            <xsl:value-of select="concat(normalize-space($editor),', ed. ')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get-editor-monogr">
        
        <xsl:param name="editor">
            <xsl:choose>
                <xsl:when test="monogr/editor/persName/@key">
                    <xsl:call-template name="getXtmName">
                        <xsl:with-param name="target" select="monogr/editor/persName/@key"/>
                        <xsl:with-param name='scope' select="'display'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="monogr/editor">
                    <xsl:value-of select="monogr/editor"/>
                </xsl:when>
                <!--
                    <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/editor/persName/@key">
                    <xsl:call-template name="getXtmName">
                    <xsl:with-param name="target" select="/TEI/teiHeader/fileDesc/editor/author/persName/@key"/>
                    </xsl:call-template>
                    </xsl:when>
                -->
            </xsl:choose>
        </xsl:param>
        <xsl:if test="$editor != ''">
            <xsl:value-of select="concat('Ed. ',normalize-space($editor),'. ')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get-title-analytic">
        <xsl:variable name="title">
            <xsl:apply-templates select="analytic/title" mode="bibl"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="analytic/title/@level = 'm'">
                <cite><xsl:value-of select="$title"/>.</cite><xsl:value-of select="' '"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'“'"/><xsl:copy-of select="$title"/><xsl:value-of select="'.” '"/>
                <!--
                <xsl:value-of select="concat('“',normalize-space($title),'.” ')"/>
                -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="analytic/title" mode="bibl">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    
    <xsl:template name="get-title-monogr">
        <xsl:choose>
            <xsl:when test="monogr/title/choice/reg">
                <cite><xsl:value-of select="concat(normalize-space(monogr/title/choice/reg),'. ')"/></cite>
            </xsl:when>
            <xsl:when test="monogr/title">
                <xsl:for-each select="monogr/title">
                    <!-- this doesn't work with more than one title, e.g.,:
                        <monogr>
                        <author>Adams, Antoníeta</author>
                        <title>El Proyecto Crack</title>
                        <title type="sub">Cuentos Grises</title>
                        <imprint>
                        <pubPlace>Concepción, Chile</pubPlace>
                        <publisher>Ediciones Letra Nueva</publisher>
                        <date when="2005">2005</date>
                        </imprint>
                        </monogr>
                    -->
                    
                    <cite><xsl:value-of select="concat(normalize-space(.),'. ')"/></cite>
                </xsl:for-each>
                
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="get-extent">
        <xsl:param name="extent" select="normalize-space(monogr/extent)"/>
        <xsl:if test="$extent != ''">
            <xsl:choose>
                <xsl:when test="ends-with($extent,'.')">
                    <xsl:value-of select="concat($extent,' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($extent,'. ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="get-pubPlace">
        <xsl:if test="monogr/imprint/pubPlace">
            <xsl:value-of select="concat(normalize-space(monogr/imprint/pubPlace),': ')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template name="get-publisher">
        <xsl:if test="monogr/imprint/publisher">
            <xsl:value-of select="concat(normalize-space(monogr/imprint/publisher),', ')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template name="get-date">
        <xsl:choose>
            <xsl:when test="monogr/imprint/date/@from and monogr/imprint/date/@to">
                <xsl:value-of select="concat(normalize-space(monogr/imprint/date/@from),'-',normalize-space(monogr/imprint/date/@to),'. ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="monogr/imprint/date/@when">
                    <xsl:value-of select="concat(normalize-space(monogr/imprint/date/@when),'. ')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="get-biblScope">
        <xsl:if test="monogr/imprint/biblScope[@type = 'vol']">
            <xsl:choose>
                <xsl:when test="monogr/imprint/biblScope[@type = 'pp']">
                    <xsl:value-of select="concat(normalize-space(monogr/imprint/biblScope[@type = 'vol']),': ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(normalize-space(monogr/imprint/biblScope[@type = 'vol']),'. ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="monogr/imprint/biblScope[@type = 'pp']">
            <xsl:value-of select="concat(normalize-space(monogr/imprint/biblScope[@type = 'pp']),'. ')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get-origPubInfo">
        <xsl:param name="pubPlace" select="normalize-space(relatedItem[@type = 'original_collection']/biblStruct/monogr/imprint/pubPlace)"/>
        <xsl:param name="publisher" select="normalize-space(relatedItem[@type = 'original_collection']/biblStruct/monogr/imprint/publisher)"/>
        <xsl:param name="date" select="normalize-space(relatedItem[@type = 'original_collection']/biblStruct/monogr/imprint/date/@when)"/>
        <xsl:if test="$pubPlace != '' and $publisher != '' and $date != ''">
            <xsl:value-of select="concat($pubPlace,': ',$publisher,', ',$date,'.')"/>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="biblStruct">
        <span>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    <xsl:template match="lb">
        <br>
        <xsl:call-template name="rendition"/>
        <xsl:call-template name="id"/>
        </br>
    </xsl:template>
    
    <xsl:template match="lb[n='eol']">
        <xsl:if test="$eol = true()">
            <xsl:call-template name="rendition"/>
            <xsl:call-template name="id"/>
            <br/>
        </xsl:if>
    </xsl:template>

    <xdoc:doc>A generic template for (usually) inline elements.</xdoc:doc>
    <!-- Will, eventually, need special case for castList/castItem, when they are in "list" format. -->
    <!-- Long quote predicate to avoide matching quotes with @prev and @next, which typically would appear in verse and are handled as a special case. -->
    <xsl:template match="s|seg|resp|emph|label|foreign|term|hi|quote[(contains(@rendition,'#sq') or contains(@rendition,'#dq')) and not(@prev) and not(@next)]|q[(contains(@rendition,'#sq') or contains(@rendition,'#dq')) and not(@prev) and not(@next)]"> <!-- |quote[parent::cit[contains(@rendition, '#block')]]-->
        <xsl:choose>
            <xsl:when test="((@rendition and @rendition != '') or (@rend and @rend != '') )">
                <span><xsl:call-template name="atts"/><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="class">
                        <xsl:value-of select="name()"/>
                    </xsl:attribute>
                    <xsl:call-template name="id"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="author|speaker|bibl|cit|w|c|publisher|titlePart|catDesc|castItem|title[@level = 'a' and contains(@rendition,'#nq')]">
            <span>
                <xsl:call-template name="atts"/>
                <xsl:apply-templates/>
            </span>
    </xsl:template>
    

  
    <xdoc:doc>A generic template for (usually) block elements.</xdoc:doc>
    <xsl:template match="sp|stage|address|dateline|text|castList|docImprint|docTitle|epigraph|signed|sound|titlePage|addrLine|quote[contains(@rendition,'#block')]|opener|closer|imprimatur|floatingText|milestone|docDate">
        <div>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="note[@type = 'chronoLetter']" priority="200">
        <!--
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend" select="'chronoLetter'"/>
            </xsl:call-template>
            <h1 style="font-style:italic;font-weight:500;letter-spacing:3px;font-size:120%;">From a letter:</h1>
            <xsl:apply-templates/>
        </div>
        -->
        <ul><li>
            <xsl:value-of select="concat('From a letter: ',cit/bibl/title[@level = 'a'])"/>
            <span>
                <xsl:attribute name="class" select="concat('showTip ',@xml:id)"/>
                <span class="ref"><xsl:value-of select="$refSymbol"/></span>
            </span></li>
        </ul>
        <span style="display:none;">
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend" select="'chronoLetter'"/>
            </xsl:call-template>
           
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    
    
    <xsl:template match="castItem[parent::castList[contains(@rendition,'#list')]]">
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'castItem'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
                      
    <!-- cit w/ block quote and block bibl, as commonly found in epigraphs. -->
<!--
    <xsl:template match="cit/quote[contains(@rendition, '#block') and following-sibling::bibl]|cit/quote[contains(@rendition, '#block') and following-sibling::bibl]/lg">
        <div>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'epiblock'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
-->
    
    
    <!--
    
    <xsl:template match="cit[contains(@rendition,'#block')]">
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend">
                    <xsl:value-of select="'blockquote'"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    -->
    
    <!-- assumes epigraphs are block elements by default -->
    <!-- Template below was throwing ambiguous rule error, and the template itself doesn't appear to be necessary.  Not sure why I 
    wrote it in the first place.-->
    <!--
    <xsl:template match="cit[contains(@rendition,'#block')]/quote|epigraph/cit/quote">
        <span>
           <xsl:call-template name="rendition"/>
           <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    -->
 
    
        
    <xsl:template match="/TEI/teiHeader/fileDesc/titleStmt/title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="figure">
        <div>
            <xsl:call-template name="atts"/>
           <!-- <xsl:apply-templates/> -->
            <xsl:apply-templates select="graphic"/>
            <xsl:apply-templates select="head" mode="caption"/>
        </div>
    </xsl:template>
    <xsl:template match="graphic">
        <a href="{@url}" style="border-bottom:none;">
        <img>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend" select="'figure'"/>
            </xsl:call-template>
            <xsl:attribute name="src">
                <xsl:value-of select="@url"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="../figDesc">
                        <!--
                        <xsl:value-of select="normalize-space(../figDesc/text())"/>
                        -->
                        <xsl:apply-templates mode="alt" select="../figDesc"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'graphic'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </img>
        </a>
    </xsl:template>
    
    <xsl:template match="figDesc//*" mode="alt">
        <xsl:value-of select="."/>
    </xsl:template>
    
    
    <xsl:template match="graphic[@mimeType = 'application/x-shockwave-flash']">
        <xsl:param name="width">
            <xsl:value-of select="substring-before(@width,'px')"/>
        </xsl:param>
        <xsl:param name="height">
            <xsl:value-of select="substring-before(@height,'px')"/>
        </xsl:param>
        <object>
            <xsl:if test="@width and @width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="$width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@height and @height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="$height"/>
                </xsl:attribute>
            </xsl:if>
            <param name="movie" value="{@url}"/>
            <embed src="{@url}">
                <xsl:if test="@width and @width != ''">
                    <xsl:attribute name="width">
                        <xsl:value-of select="$width"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@height and @height != ''">
                    <xsl:attribute name="height">
                        <xsl:value-of select="$height"/>
                    </xsl:attribute>
                </xsl:if>
            </embed>
        </object>
    </xsl:template>

    <xsl:template match="figDesc"/>

    
    <xsl:template match="ptr[@type = 'figure']" priority="10">
        <xsl:value-of select="'Figure '"/>
        <xsl:number select="id(substring-after(@target,'#'))" level="any" count="figure[head]"/>
    </xsl:template>
    
    <xsl:template match="ptr[@type = 'eg']" priority="10">
        <xsl:value-of select="'Example '"/>
        <xsl:number select="id(substring-after(@target,'#'))" level="any" count="eg[following-sibling::note[@type = 'caption']]|eg:egXML[following-sibling::note[@type = 'caption']]"/>
    </xsl:template>
    
    

    
    

    <xsl:template match="head" mode="caption">
        
        <div class="caption">
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend" select="'caption'"/>
            </xsl:call-template>
            <xsl:if test="$numberFigures = true()">
                <b>
                    <xsl:value-of select="'Figure '"/>
                    <xsl:number level="any" count="figure[head]"/>
                    <xsl:text>.</xsl:text>
                </b>
                <xsl:text>
					</xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:apply-templates select="following-sibling::p"/>
        </div>
        <!--
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:call-template name="rendition">
                <xsl:with-param name="defaultRend" select="'caption'"/>
            </xsl:call-template>
            
            <xsl:apply-templates/>
        </span>-->
    </xsl:template>

    <xsl:template match="figure/head"/>

    
    
    

    

    <xsl:template match="q|soCalled|title[contains(@rendition,'#quotes')]|title[@level='a' and not(contains(@rendition,'#dq')) and not(contains(@rendition,'#sq')) and not(contains(@rendition,'#nq'))]|analytic/title[not(contains(@rendition,'#dq'))]|quote[not(parent::cit[contains(@rendition,'#block')]) and not(contains(@rendition,'#block'))]">
        <span>
            <xsl:call-template name="atts"/>
        <xsl:call-template name="quotes">
            <xsl:with-param name="contents">
                <xsl:apply-templates/>
            </xsl:with-param>
        </xsl:call-template>
        </span>
    </xsl:template>
    
    <!-- below for quotes that are not marked with quotation marks. -->
    <xsl:template match="q[contains(@rendition,'#nq')]|quote[contains(@rendition,'#nq')]">
        <span>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
   
    
        
    
        

    <xsl:template name="quotes">
        <xsl:param name="contents">
            <xsl:apply-templates/>
        </xsl:param>
        <xsl:variable name="level">
            <xsl:value-of
                select="count(ancestor::quote[contains(@rendition,'#inline')] |
                ancestor::soCalled |
                ancestor::q |
                ancestor::title[contains(@rendition,'#quotes')] |
                ancestor::title[@level='a' and not(contains(@rendition,'#nq'))] |
                ancestor::analytic/title[not(contains(@rendition,'#nq'))] |
                ancestor::quote[not(parent::cit[contains(@rendition,'#block')])])"
            />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$quotation_format = 'single'">
                <xsl:choose>
                    <xsl:when test="$level mod 2">
                        <xsl:text>“</xsl:text>
                        <!--<xsl:copy-of select="$contents"/>--><xsl:apply-templates/>
                        <xsl:text>”</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>‘</xsl:text>
                        <!--<xsl:copy-of select="$contents"/>--><xsl:apply-templates/>
                        <xsl:text>’</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="$level mod 2">
                <xsl:text>‘</xsl:text>
                <!--<xsl:copy-of select="$contents"/>--><xsl:apply-templates/>
                <xsl:text>’</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>“</xsl:text>
                <!--<xsl:copy-of select="$contents"/>--><xsl:apply-templates/>
                <xsl:text>”</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- special quotes -->
    
    <xdoc:doc>
        <xdoc:short>Special quotation</xdoc:short>
        <xdoc:detail>This template matches part of an extended quotation, the first line of a new stanza.  In Swinburne, 
            these lines have an initial double quotation mark.</xdoc:detail>
    </xdoc:doc>
    <xsl:template match="lg/l[position() = 1]//q[@next and @prev]" priority="10">
        <xsl:param name="rendition">
            <xsl:value-of select="translate(translate(normalize-space(@rendition), '#sq', ''), '#dq', '')"/>
        </xsl:param>
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <!-- insteading of calling "rendition" template, need to remove #sq -->
            <xsl:if test="$rendition != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="translate(normalize-space($rendition), '#', '')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="contains(@rendition,'#sq')">
                    <xsl:text>‘</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@rendition,'#dq')">
                    <xsl:text>“</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$quotation_format = 'single'">
                            <xsl:text>‘</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>“</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="lg/l[position() = 1]//q[@prev and not(cdext)]" priority="10">
        <xsl:param name="rendition">
            <xsl:value-of select="translate(translate(normalize-space(@rendition), '#sq', ''), '#dq', '')"/>
        </xsl:param>
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <!-- insteading of calling "rendition" template, need to remove #sq -->
            <xsl:if test="$rendition != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="translate(normalize-space($rendition), '#', '')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="contains(@rendition,'#sq')">
                    <xsl:text>‘</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@rendition,'#dq')">
                    <xsl:text>“</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$quotation_format = 'single'">
                            <xsl:text>‘</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>“</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="contains(@rendition,'#sq')">
                    <xsl:text>’</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@rendition,'#dq')">
                    <xsl:text>”</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$quotation_format = 'single'">
                            <xsl:text>’</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>”</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <xsl:template match="q[@next and @prev]">
        <xsl:param name="rendition">
            <xsl:value-of select="translate(translate(normalize-space(@rendition), '#sq', ''), '#dq', '')"/>
        </xsl:param>
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <!-- insteading of calling "rendition" template, need to remove #sq -->
            <xsl:if test="$rendition != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="translate(normalize-space($rendition), '#', '')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- first part of multi-part quote gets opening quotation mark -->
    <xsl:template match="q[@next and not(@prev)]">
        <xsl:param name="rendition">
            <xsl:value-of select="translate(translate(normalize-space(@rendition), '#sq', ''), '#dq', '')"/>
        </xsl:param>
        <span>

            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <!-- insteading of calling "rendition" template, need to remove #sq -->
            <xsl:if test="$rendition != ''">
            <xsl:attribute name="class">
                <xsl:value-of select="translate(normalize-space(@rendition), '#', '')"/>
            </xsl:attribute>
            </xsl:if>
            
        <xsl:choose>
            <xsl:when test="contains(@rendition,'#sq')">
                <xsl:text>‘</xsl:text>
            </xsl:when>
            <xsl:when test="contains(@rendition,'#dq')">
                <xsl:text>“</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$quotation_format = 'single'">
                        <xsl:text>‘</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>“</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- final part of multi-part quote gets closing quotation mark -->
    <xsl:template match="q[@prev and not(@next)]">
        <xsl:param name="rendition">
            <xsl:value-of select="translate(translate(normalize-space(@rendition), '#sq', ''), '#dq', '')"/>
        </xsl:param>
        <span>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <!-- insteading of calling "rendition" template, need to remove #sq -->
            <xsl:if test="$rendition != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="translate(normalize-space(@rendition), '#', '')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="contains(@rendition,'#sq')">
                    <xsl:text>’</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@rendition,'#dq')">
                    <xsl:text>”</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$quotation_format = 'single'">
                            <xsl:text>’</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>”</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    


    <!-- pb -->
    
    <xsl:template match="pb[@facs = 'dummy']"/>
    
    <xsl:template name="pb-handler">
        <xsl:param name="pn"/>
        <xsl:param name="page-id"/>
        
        <span class="page-num">
            <xsl:call-template name="atts"/>
            <span class="pbNote">page: </span>
            <xsl:value-of select="@n"/>
            <xsl:text> </xsl:text>
        </span>
    </xsl:template>
   
    <xsl:template match="pb">
        
        <xsl:param name="pn">
            <xsl:number count="//pb" level="any"/>    
        </xsl:param>
        

        
        
        <xsl:if test="$displayPageBreaks = true()">
        <xsl:choose>
            <xsl:when test="parent::table">
                <tr>
                    <td class="pb">
                        <xsl:call-template name="pb-handler">
                            <xsl:with-param name="pn" select="$pn"/>
                            <xsl:with-param name="page-id" select="@facs"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <span class="pb">
                    <xsl:call-template name="pb-handler">
                        <xsl:with-param name="pn" select="$pn"/>
                        <xsl:with-param name="page-id" select="@facs"/>
                    </xsl:call-template>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:if>
    </xsl:template>
    


    <xsl:template match="fw">
        <span>
            <xsl:call-template name="rendition"/>
            <xsl:call-template name="id"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="space[@dim='vertical']">
        <xsl:call-template name="verticalSpace">
            <xsl:with-param name="quantity">
                <xsl:value-of select="number(@quantity)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="verticalSpace">
        <xsl:param name="quantity"/>
        <xsl:choose>
            <xsl:when test="@quantity and $quantity > 0">
                <br/>
                <xsl:call-template name="verticalSpace">
                    <xsl:with-param name="quantity">
                        <xsl:value-of select="$quantity - 1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- so prose page breaks aren't rendered -->
    <!--
    <xsl:template match="p//lb"/>
    -->
    
    <xsl:template name="pagePanel">
        <!-- work in progress -->
        <xsl:param name="id"/>
        <xsl:param name="n"/>
        <!-- following page -->
        <xsl:param name="fid"/>
        <xsl:param name="fn"/>
        <!-- previous page -->
        <xsl:param name="pid"/>
        <xsl:param name="pn"/>
        <div style="visibility: hidden;" class="pMedRoot">
            <xsl:attribute name="id">
                <xsl:value-of select="concat($id,'_screen')"/>
            </xsl:attribute>
            <span class="pHandleLt">
                <xsl:value-of select="concat($n,'&#x00a0;&#x00a0;')"/>
            </span>
            <xsl:if test="$fid != ''">
            <a class="pHandleLink" >   
                <!-- onclick="showImgPanel(event, '1v_screen','img/ALCH00109-1v-screen.jpg');" -->
            <xsl:attribute name="title">
                <xsl:value-of select="concat('View page ', $fn)"/>
            </xsl:attribute>
                
            <xsl:attribute name="onclick">
                <xsl:value-of select="concat('showImgPanel(event, ',$apos,$fn, $apos,$pn,'_screen',$apos,',img/',$fid,'-screen.jpg',$apos)"/>
            </xsl:attribute>
            
            </a>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="*[@copyOf]" priority="1">
        <xsl:apply-templates select="id(substring-after(@copyOf,'#'))"/>
    </xsl:template>

    
          
            

<xsl:template match="milestone[@type='hr']">
<hr>
    <xsl:call-template name="atts"/>
</hr>
</xsl:template>
    
<xsl:template match="milestone[contains(@rendition,'#hr')]">
    <hr>
        <xsl:call-template name="atts"/>
    </hr>
</xsl:template>
    

    
    
    <!-- using parse date in old TEI version when format was YYYYMMDD, without hyphens -->
    <!--
<xsl:template name="parse-date">
    <xsl:param name="date"/>
    <xsl:value-of select="concat(substring($date,1,4),'-',substring($date,5,2),'-',substring(@when,6,2))"/>
</xsl:template>
-->
    
<!-- date just copied from P4, need to clean up -->
    <xsl:template match="date">
        <xsl:choose>
            <xsl:when test="$tooltipDates = true()">
                <xsl:choose>
                    <!-- test for attribute and that attribute containts more that
                        a four-digit year -->
                    <xsl:when test="(@when | @from | @to)">
                        <xsl:choose>
                            <xsl:when test="name() = 'date'">
                                <span class="tooltip" onmouseout="hideTip()">
                                    <xsl:call-template name="atts"/>
                                    <xsl:attribute name="onmouseover">
                                        <xsl:text>doTooltip(event,'</xsl:text><xsl:value-of select="@when"/><xsl:text>')</xsl:text>
                                    </xsl:attribute>
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <!-- dateRange -->
                            <xsl:otherwise>
                                <span class="tooltip" onmouseout="hideTip()">
                                    <xsl:call-template name="atts"/>
                                    <xsl:attribute name="onmouseover">
                                        <xsl:text>doTooltip(event,'&lt;div></xsl:text>
                                        <xsl:value-of select="$headerFrom"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@from"/>
                                        <xsl:text>&lt;br/></xsl:text>
                                        <xsl:value-of select="$headerTo"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@to"/>
                                        <xsl:text>')</xsl:text>
                                    </xsl:attribute>
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:call-template name="atts"/>
                        <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:call-template name="atts"/>
                <xsl:choose>
                    <!-- if date or dateRange is empty, then display @value or @from and @to -->
                    <xsl:when test="not(child::*) and not(text())">
                        <xsl:choose>
                            <xsl:when test="name() = 'date'">
                                <xsl:value-of select="@when"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@from"/><xsl:text> &#x2014; </xsl:text><xsl:value-of select="@to"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<xsl:template match="ab[@type = 'exam-answer']">
<span class="exam-answer"/>
</xsl:template>
    
    <xsl:template match="gap">
        <xsl:choose>
            <xsl:when test="contains(@reason,'cancelled')">
                <span class="tooltip" onmouseover="doTooltip(event,'&lt;b>reason&lt;/b>: cancelled and illegible')" onmouseout="hideTip()">
                    <xsl:value-of select="$preEditorialIntervention"/>
                    <i>illeg.</i>
                    <xsl:value-of select="$postEditorialIntervention"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="tooltip" onmouseover="doTooltip(event,'reason: unknown')" onmouseout="hideTip()">
                    <xsl:value-of select="$preEditorialIntervention"/>
                    <i>illeg.</i>
                    <xsl:value-of select="$postEditorialIntervention"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    
    <xsl:template match="date[@type='today']">
        <xsl:variable name="dt">
            <xsl:value-of select="current-dateTime()"/>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:value-of  select="year-from-dateTime($dt)"/>
        </xsl:variable>
        <xsl:variable name="month">
            <xsl:value-of  select="month-from-dateTime($dt)"/>
        </xsl:variable>
        <xsl:variable name="month-word">
            <xsl:choose>
                <xsl:when test="$month = '01' or $month = '1'">
                    <xsl:value-of select="'January'"/>
                </xsl:when>
                <xsl:when test="$month = '02' or $month = '2'">
                    <xsl:value-of select="'February'"/>
                </xsl:when>
                <xsl:when test="$month = '03' or $month = '3'">
                    <xsl:value-of select="'March'"/>
                </xsl:when>
                <xsl:when test="$month = '04'or $month = '4'">
                    <xsl:value-of select="'April'"/>
                </xsl:when>
                <xsl:when test="$month = '05' or $month = '5'">
                    <xsl:value-of select="'May'"/>
                </xsl:when>
                <xsl:when test="$month = '06' or $month = '6'">
                    <xsl:value-of select="'June'"/>
                </xsl:when>
                <xsl:when test="$month = '07' or $month = '7'">
                    <xsl:value-of select="'July'"/>
                </xsl:when>
                <xsl:when test="$month = '08' or $month = '8'">
                    <xsl:value-of select="'August'"/>
                </xsl:when>
                <xsl:when test="$month = '09' or $month = '9'">
                    <xsl:value-of select="'September'"/>
                </xsl:when>
                <xsl:when test="$month = '10'">
                    <xsl:value-of select="'October'"/>
                </xsl:when>
                <xsl:when test="$month = '11'">
                    <xsl:value-of select="'November'"/>
                </xsl:when>
                <xsl:when test="$month = '12'">
                    <xsl:value-of select="'December'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:value-of  select="day-from-dateTime($dt)"/>
        </xsl:variable>
        <xsl:variable name="day-num">
            <xsl:choose>
                <xsl:when test="substring($day,1,1) = '0'">
                    <xsl:value-of select="substring($day,2,1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$day"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($day-num,' ',$month-word,' ',$year)"/>
    </xsl:template>
    
    
    
    <xsl:template match="*[@sameAs]" priority="10">
        <xsl:param name="id" select="substring-after(@sameAs,'#')"/>
        <xsl:apply-templates select="//*[@xml:id = $id]"/>
    </xsl:template>
    
    <xsl:template match="note[@type = 'metadata']"/>

    <!-- utterance -->
    <xsl:template match="u">
        <div>
            <strong>
                <xsl:apply-templates select="id(substring-after(@who,'#'))"/>
            </strong>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- suppressed elements -->
    <xsl:template match="fw[@type = 'header']"/>

</xsl:stylesheet>
