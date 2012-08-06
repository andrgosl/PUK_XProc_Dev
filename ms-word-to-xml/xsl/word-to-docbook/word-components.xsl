<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://docbook.org/ns/docbook"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:rp="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" 
    xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs w cp r rp dc a">
    <xsl:import href="word-functions.xsl"/>
    <xsl:import href="word-tables.xsl"/>
    


    <xsl:output encoding="UTF-8" indent="yes"/>

    <xsl:param name="image-uri-base" select="'images'"/>
    <!-- override to change the assumed dir for images -->

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="w:t"/>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 28, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Default templates for major word components such as document and paragraph.</xd:p>
            <xd:p>
                <xd:b>Update 2010-03-19</xd:b>
            </xd:p>
            <xd:p>Added support for images contained within w:drawing elements. Currently, only
                handles images referenced via the <xd:b>blip</xd:b> element. We render these as
                DocBook imageobject elements within a section (the next stage processing may move
                this).</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="identity.xsl"/>

    <!-- word body can be skipped -->
    <xsl:template match="w:body">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Section, para and run properties must be dropped -->
    <xsl:template match="w:sectPr|w:p/w:pPr|w:r/w:rPr"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Matches the document, processing titles and all para, table and graphical
                content.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:document">

        <book version="PBL1.0">
            <info>
                <xsl:apply-templates select="//cp:coreProperties/*"/>
                <xsl:if test="not(normalize-space(//cp:coreProperties/dc:title))">
                    <title><xsl:comment> INSERT TITLE HERE </xsl:comment></title>
                </xsl:if>
                <author>
                   <personname><xsl:comment> INSERT AUTHOR NAME HERE </xsl:comment></personname>
                </author>
                <biblioid class="isbn"><xsl:comment>INSERT ISBN HERE</xsl:comment></biblioid>
                <publisher><publishername>Penguin Group</publishername></publisher>
                <cover>
                    <mediaobject role='cover'><imageobject><imagedata fileref='cover.jpg'/></imageobject></mediaobject>
                </cover>
            </info>
            <xsl:apply-templates/>
        </book>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Matches paragraphs. Ignores empty paragraphs and fetches any style data to copy
                into the role attribute of the element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[not(normalize-space(.) = '')]">
        <xsl:apply-templates select="." mode="basic"/>
    </xsl:template>

    <xsl:template match="w:p[normalize-space(.) = '']" priority="2"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Default processing for paragraphs. Created with a mode so it can be called from
                other paragraph handling templates.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p" mode="basic">
        <para>
            <xsl:call-template name="cword:getStyleAsRole">
                <xsl:with-param name="properties" select="w:pPr"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </para>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Matches paragraphs that contain images.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[descendant::w:drawing]" priority="3">
        <xsl:apply-templates select=".//a:blip"/>
    </xsl:template>


    <xd:doc>
        <xd:desc>Process paragraphs which represent list items. Right now we just convert them to
            listitem elements and store information in the role about the sort of list and indent
            level.</xd:desc>
    </xd:doc>
    <xsl:template match="w:p[w:pPr/w:numPr]">
        <listitem cword:list-level="{w:pPr/w:numPr/w:ilvl/@w:val}"
            cword:list-mark="{w:pPr/w:numPr/w:numId/@w:val}">
            <xsl:apply-templates select="." mode="basic"/>
        </listitem>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Template to ignore paragraphs with no runs and just section or page breaks</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[not(w:tbl|w:r|w:hlink) and w:pPr/w:sectPr]"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Ignore paragraphs that contain just a single run and that run just contains a
                break. </xd:p>
        </xd:desc>
    </xd:doc>
    
   
    <xsl:template match="w:p[count(w:r) = 1][w:r/w:br][not(w:r/w:t)]"/>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Ignore paragraphs containing just a singe run which contains only a tab.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p[count(w:r) = 1][w:r/w:tab][not(w:r/w:t)]"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Default processing for runs - execute and supply mode base. This is intended to
                allow additional modes as required.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r">
        <xsl:apply-templates select="." mode="base"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Primary processing for runs of text. If the run has any styling we generated a
                phrase element so that we can capture the character style name.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:rPr/w:rStyle]" mode="base">
                <phrase>
                    <xsl:call-template name="cword:getStyleAsRole">
                        <xsl:with-param name="properties" select="w:rPr"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </phrase>
    </xsl:template>
    
    <xsl:template match="w:r" mode="base">
        <xsl:apply-templates/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of bold text by wrapping the text in a db:emphasis element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:rPr/w:b]">
        <emphasis role="bold">
            <xsl:apply-templates select="." mode="base"/>
        </emphasis>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of text with foot note references into docbook footnotes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:endnoteReference]">
        <xsl:apply-templates select="w:endnoteReference"/>
    </xsl:template>

    <xsl:template match="w:endnoteReference">
        <xsl:apply-templates select="//w:endnotes/w:endnote[@w:id = current()/@w:id]"/>
    </xsl:template>

    <xsl:template match="w:endnote[w:r[not(w:continuationSeparator)]]">
        <footnote role="endnote">
            <xsl:apply-templates/>
        </footnote>
    </xsl:template>

    <xsl:template match="w:endnote[normalize-space(.) = '']"/>
    

    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of italicised text by wrapping that text in a emphasis
                element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:rPr/w:i]">
        <emphasis role="italic">
            <xsl:apply-templates select="." mode="base"/>
        </emphasis>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Process runs of bold and italicised text by wrapping the text in two emphasis
                elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:rPr/w:i and w:rPr/w:b]">
        <emphasis role="italic">
            <emphasis role="bold">
                <xsl:apply-templates select="." mode="base"/>
            </emphasis>
        </emphasis>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Process text elements by outputting them as long as they aren't empty text.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:t">
        <xsl:apply-templates/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Handle <xd:b>a:blip</xd:b> elements. Convert them to a DocBook imageobject
                element. The fileRef attribute is filled with the relation ID. Later processing can
                replace that with the actual URL from document.rels.xml</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="a:blip">
        <mediaobject xml:id="{generate-id()}">
            <imageobject>
                <xsl:apply-templates select="@r:link|@r:embed"/>
            </imageobject>
        </mediaobject>
    </xsl:template>

    <xsl:template match="a:blip/@r:embed|a:blip/@r:link">
        <!-- generate a docbook imdagedata element based on this. -->
        <xsl:variable name="id" select="."/>

        <imagedata>
            <xsl:variable name="doc-image-uri" select="//rp:Relationships/rp:Relationship[@Id = $id]/@Target"/>
            <xsl:analyze-string select="$doc-image-uri" regex=".+/([^/]+)$/">
                <xsl:matching-substring>
                    <xsl:attribute name="fileref"
                        select="concat($image-uri-base, '/', regex-group(1))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:attribute name="fileref" select="$doc-image-uri"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </imagedata>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Handle comment references by processing the referenced comment
            and including it as an XML comment in the same location.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="w:r[descendant::w:commentReference]" priority="1">
        <xsl:apply-templates select="descendant::w:commentReference"/>
    </xsl:template>
    
    <xsl:template match="w:commentReference">
        <xsl:variable name="comment-id" select='@w:id'/>
        <xsl:apply-templates select="//w:comments/w:comment[@w:id = $comment-id]"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Convert a word comment to an XML comment. Output the name
            of the user who made the comment too.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="w:comment">
        <remark>
            <xsl:apply-templates select="@w:author"/>: <xsl:apply-templates/>
        </remark>
    </xsl:template>
    
    <xsl:template match="@w:author">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="w:comment/*" priority="1">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts the style given in an elements properties to a role attribute containing
                the style's value.</xd:p>
            <xd:p>Currently handles run and paragraph styles.</xd:p>
        </xd:desc>
        <xd:param name="properties">
            <xd:p>The properties parameter must be provided and must contain the properties element
                of the document being processed</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="cword:getStyleAsRole">
        <xsl:param name="properties"/>
        <xsl:variable name="style" select="$properties/w:rStyle|$properties/w:pStyle"/>
        <xsl:variable name="mapped-style">
            <xsl:choose>
                <xsl:when test="$properties/w:pStyle">
                    <xsl:value-of select="cword:mapParagraphStyle($style/@w:val)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$properties/w:rStyle">
                    <xsl:value-of select="cword:mapRunStyle($style/@w:val)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$style/@w:val = &quot;attributes&quot;"/>
            <xsl:when test="$style/@w:val = &quot;CommentReference&quot;"/>
            <xsl:when test="$style">
                <xsl:attribute name="role">
                    <xsl:value-of select="$mapped-style"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Skip core properties</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="cp:coreProperties"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Copy children of core properties unless specified.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="cp:coreProperties/*">
        <bibliomisc role="{name()}">
            <xsl:apply-templates/>
        </bibliomisc>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Returns the document title from properties.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="cp:coreProperties/dc:title" priority="1">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Convert dcterms:created and modified into date metadata</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="cp:coreProperties/dcterms:created|cp:coreProperties/dcterms:modified"
        priority="1">
        <date role="{name()}">
            <xsl:apply-templates/>
        </date>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Convert the word revision number</xd:p>
        </xd:desc>
    </xd:doc>


    <xd:doc>
        <xd:desc>
            <xd:p>Handle word bookmarks by converting them to either anchors (when empty) or phrases
                (when not)</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="w:bookmarkStart[following-sibling::node()[1][self::w:bookmarkEnd]]">
        <!-- <anchor xml:id="{@w:name}"/> causing problems in xml to html for some reason -->
    </xsl:template>

    <xsl:template match="w:bookmarkStart[not(following-sibling::node()[1][self::w:bookmarkEnd])]">
        <xsl:variable name="end-marker" select="(following-sibling::*[self::bookmarkEnd])[1]"/>
        <phrase xml:id="{@w:name}">
            <xsl:apply-templates select="following-sibling::*[ . &lt;&lt; $end-marker]"/>
        </phrase>
    </xsl:template>

    <xsl:template match="w:bookmarkEnd"/>


    <!-- Handle hyperlinks -->
    <xsl:template match="w:r[descendant::w:rStyle[@w:val='Hyperlink']]">
        <xsl:apply-templates select="descendant::w:hyperlink"/>
    </xsl:template>
    
    <xsl:template match="w:hyperlink[@w:anchor]">
        <link linkend="{@w:anchor}"><xsl:apply-templates/></link>
    </xsl:template>
    
    <xsl:template match="w:hyperlink[@r:id]">
        <xsl:variable name="id" select="@r:id"/>
        <link xlink:href="{//rp:Relationships/rp:Relationship[@Id = $id]/@Target}"><xsl:apply-templates/></link>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Suppress the following:</xd:p>
            <xd:ul>
                <xd:li>Breaks</xd:li>
                <xd:li>Tabs</xd:li>
                <xd:li>Hard Carriage Returns</xd:li>
                <xd:li>Annotation Refs</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>

    <xsl:template match="w:br"/>
    <xsl:template match="w:lastRenderedPageBreak"/>
    <xsl:template match="w:tab"/>
    <xsl:template match="w:cr"/>
    <xsl:template match="w:annotationRef"/>
    
    
</xsl:stylesheet>
