<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns="http://docbook.org/ns/docbook"
     xpath-default-namespace="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs cword xd w">
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 6/6/12</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Reformatting based on penguin styles.</xd:p>
            <xd:p>Interprets penguin styles to get improved docbook elememt conversion</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- sets of styles -->
    <xsl:variable name="chapter-titles" select="('03ChapterTitle', '03ChapterNumberandTitle', '03ChapterNumber')"/>
    <xsl:variable name="epigraphs" select="('01FMEpigraph', '01FMEpigraphFL', '01EpigraphVerse', '02PartEpigraph', '02PartEpigraphVerse', '03ChapterEpigraph', '03ChapterEpigraphVerse')"/>
    <xsl:variable name="epigraph-sources" select="('01FMEpigraphSource', '02PartEpigraphSource', '03ChapterEpigraphSource')"/>
        
    <!-- Prelims -->
    
    <xsl:template match="para[@role='01FMTPTitle']">
        <title cword:hint="doc-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <xsl:template match="para[@role='01FMTPSubtitle']">
        <subtitle cword:hint="doc-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></subtitle>
    </xsl:template>
    
    <xsl:template match="para[@role='01FMHead']">
        <title cword:hint="prelims-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>        
    </xsl:template>
    
    <xsl:template match="para[@role='01FMTPAuthor']">
        <author cword:hint="doc-author" role="{@role}"><personname><xsl:apply-templates select="@*|node()"/></personname></author>
    </xsl:template>

    <xsl:template match="para[@role='01FMDediBody']">
        <dedication role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></dedication>
    </xsl:template>
       
    <!-- skip the TOC -->
    <xsl:template match="para[starts-with(@role, '01FMContent')]"/>
    
    <!-- Part Openers -->

    
    <!-- match a title that isn't paired with a number or other title -->
    <xsl:template match="para[@role=('02PartTitle', '02PartNumber')][not(following-sibling::*[1][para[@role =('02PartTitle', '02PartNumber')]]) 
        and not(preceding-sibling::*[1][para[@role = ('02PartTitle', '02PartNumber')]])]">
        <title cword:hint="part-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <!-- match a title immediately preceded by a number -->
    <xsl:template match="para[@role='02PartTitle'][preceding-sibling::*[1][para[@role = '02PartNumber']]]">
        <title cword:hint="part-title" role="{@role}" cword:chapter-number="{following-sibling::*[1][para[@role = '02PartNumber']]}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <xsl:template match="para[@role='02PartTitleSubtitle']">
        <subtitle cword:hint="part-title"><xsl:apply-templates select="@*|node()"/></subtitle>
    </xsl:template>    
    
    
    <!-- Chapter Openers -->
    
   <!-- match a title that isn't paired with a number or other title -->
    <xsl:template match="para[@role=$chapter-titles][not(following-sibling::*[1][para[@role = $chapter-titles]]) 
        and not(preceding-sibling::*[1][para[@role = $chapter-titles]])]">
        <title cword:hint="chapter-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <!-- match a title immediately preceded by a number -->
    <xsl:template match="para[@role='03ChapterTitle'][preceding-sibling::*[1][para[@role = '03ChapterNumber']]]">
        <title cword:hint="chapter-title" role="{@role}" cword:chapter-number="{following-sibling::*[1][para[@role = '03ChapterNumber']]}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <xsl:template match="para[@role='03ChapterTitleSubtitle']">
        <subtitle cword:hint="chapter-title"><xsl:apply-templates select="@*|node()"/></subtitle>
    </xsl:template>
    
    <!-- Headers-->
    <xsl:template match="para[@role=('05HeadA', '05HeadB', '05HeadC')]">
        <xsl:variable name='hint' select="concat(substring-after(@role, 'Head'), '-Head')"/>
        <title cword:hint="{$hint}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <!-- B-Head that immediately follows an A-Head -->
    <xsl:template match="para[@role='05HeadB'][preceding-sibling::*[1][self::para[@role='05HeadA']]]"  priority="1">
        <subtitle cword:hint='B-Head'><xsl:apply-templates select='@*|node()'/></subtitle>
    </xsl:template>
    
    <!-- Images/Art -->
    <xsl:template match="para[@role='12Caption']">
        <caption role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></caption>
    </xsl:template>
    
    <!-- epipgraphs -->
    <xsl:template match="para[@role=$epigraphs]" priority="1">
        <epigraph role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></epigraph>
    </xsl:template>
    
    <xsl:template match="para[@role=$epigraphs][matches(@role, 'Verse')]" priority="2">
        <epigraph><para cword:hint="poetry"><xsl:apply-templates select="@*|node()"/></para></epigraph>
    </xsl:template>
    
    
    <xsl:template match="para[@role=$epigraph-sources]">
        <epigraph role="{@role}"><attribution><xsl:apply-templates select="@*|node()"/></attribution></epigraph>
    </xsl:template>      
    
    <!-- para with normal style -->
    <xsl:template match="para/@role[. = 'normal']">
        <xsl:attribute name='role' select="'04BodyText'"/>
    </xsl:template>
    
</xsl:stylesheet>
