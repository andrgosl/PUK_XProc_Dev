<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc><p>Templates for handling notes generation.</p></desc>
    </doc>

    


    <xsl:param name="notes.file.name" select="'notes'"/>
    
    <!-- Default node for (normal) footnotes. Insert a link to the chapter notes file. -->
    <xsl:template match="footnote[not(@role='endnote')]">
        <!-- what do we use as a label. Going to insert sequential number from our chapter type ancestor-->
        <xsl:variable name="container" select="ancestor::chapter|ancestor::preface|ancestor::glossary|ancestor::bibliography"/>
        <xsl:variable name='chapter-pos' select="count($container//footnote[. &lt;&lt; current()]) + 1"/>
        <xsl:variable name="notes-file">
            <xsl:call-template name="page.href">
                <xsl:with-param name="prefix" select="concat($notes.file.name, '-')"/>
                <xsl:with-param name="with.fragment" select="concat('note-', @xml:id)"/>
            </xsl:call-template>
        </xsl:variable>
        <span class='noteref' id="{@xml:id}"><sup>
            <a href="{$notes-file}">
                <xsl:apply-templates select='.' mode='marker'/>
            </a></sup>
        </span>
    </xsl:template>   
    
    <!-- Default mode for footnotes (as endnotes)- we insert a link to the notes file. Because we want to
    link back we also need to create an anchor. -->
    <xsl:template match="footnote[@role='endnote']">
        <!-- what do we use as a label. Going to insert sequential number from our chapter type ancestor-->
        <xsl:variable name='container' select="if (ancestor::part) then ancestor::*[parent::*[part]] else ancestor::*[parent::book]"/>
        <xsl:variable name='chapter-pos' select="count($container//footnote[. &lt;&lt; current()]) + 1"/>
        <xsl:variable name="notes-file">
            <xsl:call-template name="page.href">
                <xsl:with-param name="page-id" select="$notes.file.name"/>
                <xsl:with-param name="with.fragment" select="concat('note-', @xml:id)"/>
            </xsl:call-template>            
        </xsl:variable>
        <span class='noteref' id="{@xml:id}"><sup>
            <a href="{$notes-file}">
                <xsl:apply-templates select='.' mode='marker'/>
            </a></sup>
        </span>
    </xsl:template>
    
    <xsl:template match="chapter/title|preface/title|bibliography/title|appendix/title" mode="notes">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/> Notes
        </h5>
    </xsl:template>
    
    
    <xsl:template match="title" mode="notes">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>
    

    

    
    
    <xsl:template match="footnote/para[position() = 1]" mode="notes">
        <xsl:variable name="marker">
            <xsl:apply-templates select='..' mode='marker'/>
        </xsl:variable>
        
        <xsl:variable name="marker.padding" select="if (string-length($marker) lt 4) 
            then substring('&#xA0;&#xA0;&#xA0;&#xA0;', 1, 4 - string-length($marker))
            else ' '"/>
        
        <xsl:variable name='anchor'>
            <xsl:call-template name="page.href">
                <xsl:with-param name="node" select=".."/>
                <xsl:with-param name="with.fragment" select="@xml:id"/>
            </xsl:call-template>
        </xsl:variable>        
        
        <p class='EB26SmallTextHangingIndent' id="{concat('note-', ../@xml:id)}">
            <a href="{$anchor}"><xsl:value-of select='$marker'/></a>
            <xsl:value-of select='$marker.padding'/>
            <xsl:apply-templates/>
        </p>
        
    </xsl:template>
    
    
    <xsl:template match="footnote/para[position() gt 1]" mode="notes">
        <p class='EB26SmallTextHangingIndent'>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="footnote" mode="notes">
        <xsl:apply-templates mode="notes"/>
    </xsl:template>
    
    
    
    <xsl:template match="footnote"  mode="marker">
        <xsl:variable name='container' select="if (ancestor::part) then ancestor::*[parent::*[part]] else ancestor::*[parent::book]"/>
        <xsl:variable name='chapter-pos' select="count($container//footnote[. &lt;&lt; current()]) + 1"/>        
        <xsl:value-of select='$chapter-pos'/>
    </xsl:template>
    
    
    <!-- Templates to generate the notes pages. -->
    
    <!-- Suppress notes generation by default -->
    <xsl:template match="book" mode="notes"/>
    
    <xsl:template match="book[descendant::footnote[@role='endnote']]" mode="notes">
        
        <xsl:variable name="notes-file">
            <xsl:call-template name="page.href">
                <xsl:with-param name="page-id" select="$notes.file.name"/>
            </xsl:call-template>
        </xsl:variable>
                
        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <title>Notes</title>
            </xsl:with-param>
            <xsl:with-param name="page-id" select="$notes.file.name"/>
            <xsl:with-param name="filename" select="$notes-file"/>
            <xsl:with-param name="contents">
                <xsl:apply-templates select="descendant::footnote[@role='endnote']"  mode="notes"/>
            </xsl:with-param>            
        </xsl:call-template>     
        
    </xsl:template>
    
    <xsl:template match="part" mode="notes">
        <xsl:apply-templates mode='notes'/>
    </xsl:template>
    
    <xsl:template match="preface[footnote[not(@role = 'endnote')]]|
            appendix[footnote[not(@role = 'endnote')]]|
            glossary[footnote[not(@role = 'endnote')]]|
            bibliography[footnote[not(@role = 'endnote')]]|
            chapter[footnote[not(@role = 'endnote')]]" mode="notes">
        
        <xsl:variable name="notes-file">
            <xsl:call-template name="page.href">
                <xsl:with-param name="prefix" select="concat($notes.file.name, '-')"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="page-id">
            <xsl:call-template name="page.id">
                <xsl:with-param name="prefix" select="concat($notes.file.name, '-')"/>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <title>Notes</title>
            </xsl:with-param>
            <xsl:with-param name="page-id" select="$page-id"/>
            <xsl:with-param name="filename" select="$notes-file"/>
            <xsl:with-param name="contents">
                <xsl:apply-templates select='title|info/title' mode='notes'/>
                <xsl:apply-templates select="descendant::footnote[not(@role='endnote')]"  mode="notes"/>
            </xsl:with-param>            
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="preface|appendix|glossary|bibliography|chapter" mode="notes"/>
     
    
</xsl:stylesheet>