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
    
    <!-- Prelims -->
    
    <xsl:template match="para[@role='01FMTPTitle']">
        <title cword:hint="doc-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <xsl:template match="para[@role='01FMTPSubtitle']">
        <subtitle cword:hint="doc-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></subtitle>
    </xsl:template>
    
    <xsl:template match="para[@role='01FMTPAuthor']">
        <author cword:hint="doc-author" role="{@role}"><xsl:apply-templates select="@*|node()"/></author>
    </xsl:template>

    <xsl:template match="para[@role='01FMDediBody']">
        <dedication role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></dedication>
    </xsl:template>
    
    <xsl:template match="para[@role='01FMEpigraph']">
        <epigraph role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></epigraph>
    </xsl:template>

    <xsl:template match="para[@role='01FMEpigraphSource']">
        <epigraph role="{@role}"><attribution><xsl:apply-templates select="@*|node()"/></attribution></epigraph>
    </xsl:template>      
    
    <!-- skip the TOC -->
    <xsl:template match="para[starts-with(@role, '01FMContent')]"/>
    
    
    <!-- Chapter Openers -->
    <xsl:template match="para[@role='03ChapterEpigraph']">
        <epigraph role="{@role}"><para><xsl:apply-templates select="@*|node()"/></para></epigraph>
    </xsl:template>    
    
    <xsl:template match="para[@role='03ChapterEpigraphSource']">
        <epigraph role="{@role}"><attribution><xsl:apply-templates select="@*|node()"/></attribution></epigraph>
    </xsl:template>
    
    <xsl:template match="para[@role='03ChapterNumberandTitle']">
        <title cword:hint="chapter-title" role="{@role}"><xsl:apply-templates select="@*|node()"/></title>
    </xsl:template>
    
    <!-- Images/Art -->
    <xsl:template match="para[@role='12caption']">
        <caption role="{@role}"><xsl:apply-templates select="@*|node()"/></caption>
    </xsl:template>
    
    
    
</xsl:stylesheet>
