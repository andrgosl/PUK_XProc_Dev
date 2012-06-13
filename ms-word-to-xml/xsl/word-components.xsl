<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:rp="http://schemas.openxmlformats.org/package/2006/relationships"
    
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"    
    exclude-result-prefixes="xs cword xd db w r rp a">
    <xsl:import href="word-functions.xsl"/>
    <xsl:import href="word-tables.xsl"/>
    <xsl:import href="word-templates.xsl"/>

    <xsl:output encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="image-uri-base" select="'images'"/> <!-- override to change the assumed dir for images -->
    
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="w:t"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 28, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Default templates for major word components such as document and paragraph.</xd:p>
            <xd:p><xd:b>Update 2010-03-19</xd:b></xd:p>
            <xd:p>Added support for images contained within w:drawing elements. Currently, only
            handles images referenced via the <xd:b>blip</xd:b> element. We render these as DocBook
            imageobject elements within a section (the next stage processing may move this).</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- most nodes just copy to output -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- word body can be skipped -->
    <xsl:template match="w:body">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Section, para and run properties must be dropped -->
    <xsl:template match="w:sectPr|w:p/w:pPr|w:r/w:rPr"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Matches the document, processing titles and all para, table and
                graphical content.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:document">
        
        <db:article>
            <db:info>
                <xsl:call-template name="cword:documentTitle"/>
            </db:info>
            <xsl:apply-templates/>
        </db:article>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Matches paragraphs. Ignores empty paragraphs and fetches any
            style data to copy into the role attribute of the element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p">
        <xsl:if test='normalize-space(.) != ""'>
            <xsl:apply-templates select='.' mode='basic'/>
        </xsl:if>    
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Default processing for paragraphs. Created with
            a mode so it can be called from other paragraph
            handling templates.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p" mode='basic'>
            <db:para>
                <xsl:call-template name='cword:getStyleAsRole'>
                    <xsl:with-param name='properties' select="w:pPr"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </db:para>            
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Matches paragraphs that contain images.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[descendant::w:drawing]">
        <xsl:apply-templates select='.//a:blip'/>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Process paragraphs which represent list items.
        Right now we just convert them to listitem elements
        and store information in the role about the sort of
        list and indent level.</xd:desc>
    </xd:doc> 
    <xsl:template match="w:p[w:pPr/w:numPr]">
        <db:listitem cword:list-level='{w:pPr/w:numPr/w:ilvl/@w:val}' cword:list-mark='{w:pPr/w:numPr/w:numId/@w:val}'>
            <xsl:apply-templates select='.' mode='basic'/>
        </db:listitem>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Template to ignore paragraphs with no runs and
            just section or page breaks</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[not(w:tbl|w:r|w:hlink) and w:pPr/w:sectPr]"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Ignore paragraphs that contain just a single run and
            that run just contains a break.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[count(w:r) = 1 and w:r/w:br]"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Ignore paragraphs containing just a singe run
            which contains only a tab.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[count(w:r) = 1 and w:r/w:tab]"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Default processing for runs - execute supply mode default.
            This is intended to allow additional modes as required.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='w:r'>
        <xsl:apply-templates select='.' mode='default'/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Primary processing for runs of text. If the run has any
            styling we generated a phrase element so that we can capture
            the character style name.</xd:p>
        </xd:desc>
    </xd:doc>
     <xsl:template match='w:r' mode='default'>
        <xsl:choose>
            <xsl:when test='w:rPr/w:rStyle'>
                <db:phrase>
                    <xsl:call-template name='cword:getStyleAsRole'>
                        <xsl:with-param name='properties' select="w:rPr"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </db:phrase>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of bold text by wrapping the text in
            a db:emphasis element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='w:r[w:rPr/w:b]'>
        <db:emphasis role='bold'><xsl:apply-templates select='.' mode='default'/></db:emphasis>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of italicised text by wrapping that text
            in a db:emphasis element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='w:r[w:rPr/w:i]'>
        <db:emphasis role='italic'><xsl:apply-templates select='.' mode='default'/></db:emphasis>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of bold and italicised text by wrapping the text in
                two db:emphasis elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='w:r[w:rPr/w:i and w:rPr/w:b]'>
        <db:emphasis role='italic'><db:emphasis role='bold'><xsl:apply-templates select='.' mode='default'/></db:emphasis></db:emphasis>
    </xsl:template>
    
    
    <!-- Include any custom runs required -->
    <xsl:include href='custom-runs.xsl'/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Process text elements by outputting them as long as they aren't
            empty text.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='w:t'>
        <xsl:if test='normalize-space(.) != ""'>
            <xsl:value-of select='.'/>    
        </xsl:if>
        
    </xsl:template>
  
 
    

    
    <xd:doc>
        <xd:desc>
            <xd:p>Handle <xd:b>a:blip</xd:b> elements. Convert them to a DocBook
                imageobject element. The fileRef attribute is filled with the relation ID.
            Later processing can replace that with the actual URL from document.rels.xml</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match='a:blip'>
        <db:imageobject>
            <xsl:apply-templates select="@r:link"/>
         </db:imageobject>
    </xsl:template>
    
    <xsl:template match="a:blip/@r:link">
        <!-- generate a docbook imdagedata element based on this. -->
        <xsl:variable name="id" select='.'/>
        <xsl:variable name="image-uri" select="//rp:Relationships/rp:Relationship[@Id = $id]/Target"/>
        <xsl:variable name="filename" select="if (matches($image-uri, '/')) then reverse(substring-before(reverse($image-uri), '/')) else $image-uri"/>
        <xsl:variable name="new-uri" select="concat($image-uri-base, '/', $filename)"/>
        <db:imagedata fileref="{$new-uri}"/>
    </xsl:template>
    
    
</xsl:stylesheet>
