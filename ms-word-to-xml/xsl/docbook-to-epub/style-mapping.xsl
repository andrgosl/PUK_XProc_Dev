<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:data="http://www.corbas.co.uk/ns/penguin/data"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="debug.style.mapping" select="'no'"/>
    
    
    <map xmlns="http://www.corbas.co.uk/ns/penguin/data">
        <mapping role="01FMAboutAuthorTitle" style="EB07SmallCapsMediumHead" element="h5"/>
        <mapping role="01FMBiographyFL" style="EB02BodyTextFullOut" element="p"/>
        <mapping role="01FMDediBody" style="EB02BodyTextFullOut" element="p"/>
        <mapping role="01FMEpigraph" style="EB17Epigraph" element="p"/>
        <mapping role="01FMEpigraphSource" style="EB18EpigraphSource" element="p"/>
        <mapping role="01FMTPAuthor " style="EB09SmallCapsLargeHead" element="h2"/>
        <mapping role="01FMTPSubtitle" style="EB11SmallItalicHeadSpaced" element="p"/>
        <mapping role="01FMTPTitle" style="EB04MainHead" element="h2"/>
        <mapping role="03ChapterEpigraphSource" style="EB18EpigraphSource" element="p"/>
        <!-- NB need a way to map number and title separately at a later point -->
        <mapping role="03ChapterNumberandTitle" style="EB04MainHeadClosedTitle"
            element="h2"/>
        <mapping role="03ChapterTitle" style="EB04MainHead" element="h2"/>
        <mapping role="04BodyText" style="EB03BodyTextIndented" element="p"/>
        <mapping role="04BodyTextFL" style="EB02BodyTextFullOut" element="p"/>
        <mapping role="05HeadA" style="EB04MainHead2" element="h2"/>
        <mapping role="05HeadB" style="EB10SmallHead" element="h4"/>
        <mapping role="05HeadC" style="EB11SmallItalicHead" element="p"/>
        <mapping role="06ProseExtractFirst" style="EB19ExtraFeatureFullOut" element="p"/>
        <mapping role="06Verse" style="poem" element="p"/>
        <mapping role="11RecipeIngredients" style="EB22ExtraFeatureFirst" element="p"/>
        <mapping role="11RecipeMethodSubhead" style="EB10SmallHead" element="h4"/>
        <mapping role="11RecipeServes" style="EB14CopyrightText" element="p"/>
        <mapping role="12Caption" style="EB28InlineCaption" element="p"/>
        <mapping role="14FootnoteText" style="EB19ExtraFeatureFullOut" element="p"/>
        <mapping role="13EMBiblioFL" style="EB26SmallTextHangingIndent" element="p"/>
        <mapping role="15Italic" style="EB12SmallItalic"/>
        <mapping role="15Subscript" style="EBsub" element="sub"/>
        <mapping role="bold" style="" element="strong"/>
        <mapping role="italic" style="" element="em"/>
        <mapping role="normal" style="EB03BodyTextIndented" element="p"/>
        <mapping role="14FootnoteText" style="EB19ExtraFeatureFullOut" element="p"/>
    	<mapping role="01FMbythesameauthorHead" style="EB04MainHead" element="h2"/>
    	<mapping role="01FMbythesameauthorlist" style="EB02BodyTextFullOut" element="p"/>
        <mapping role="02PartTitle" style="EB04MainHead" element="h2"/>
    	<mapping role="13EMHead" style="EB13CopyrightHead" element="h5"/>
    	<mapping role="13EMEndNotesFL" style="EB14CopyrightText" element="p"/>
    </map>
    
    
    <xsl:template match="@*|comment()|processing-instruction()|text()|html|body" mode='#all'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="head">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
   
    <xsl:template match="*">
        <xsl:variable name="current-name" select="local-name()"/>
        <xsl:variable name="current-class" select="@class"/>
        <xsl:variable name="mapping" select="document('')//data:map/data:mapping[@role = $current-class][1]"/>
        <xsl:variable name="new-name" select="if ($mapping and $mapping/@element) then $mapping/@element else $current-name"/>
       <xsl:variable name="new-class" select="if ($mapping and $mapping/@style) then $mapping/@style else $current-class"/>
        
        <xsl:if test="$debug.style.mapping = 'yes'">
            <xsl:message select="concat(
                    ' Processing ', @xml:id, '. ',
                    ' Match found: ', if ($mapping) then 'yes' else 'no', '. ', 
                    'Current element = ', $current-name, 
                    ', current class = ', $current-class, 
                    '. New name = ', $new-name, 
                    ', new class = ', $new-class)"/>
        </xsl:if>
        
        <xsl:element name="{$new-name}">
            <xsl:if test="$new-class">
                <xsl:attribute name="class" select="$new-class"/>
            </xsl:if>
            <xsl:apply-templates select="@*|node() "/>
        </xsl:element>
        
    </xsl:template>
    
    <xsl:template match="@class"/>
    
    
</xsl:stylesheet>