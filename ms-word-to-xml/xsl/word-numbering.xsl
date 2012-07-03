<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.corbas.co.uk/ns/word"
    exclude-result-prefixes="xs"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xpath-default-namespace="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    version="2.0">
    
    <!-- cleans up the word numbering file so that we can easily extract information from it -->
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:numbering">
        <list-formats xmlns="http://www.corbas.co.uk/ns/word">
            <xsl:apply-templates select="w:num"/>
        </list-formats>
    </xsl:template>
    
    <xsl:template match="w:num">
        <xsl:variable name="abstract" select="w:abstractNumId/@w:val"/>
        <list-format number="{@w:numId}">
            <xsl:apply-templates select="../w:abstractNum[@w:abstractNumId = $abstract]/w:lvl"/>
        </list-format>
    </xsl:template>   
    
    <xsl:template match="w:lvl">
        <level>
            <xsl:apply-templates select="w:numFmt|w:start|w:lvlText"/>
        </level>        
        
    </xsl:template>
    
    <xsl:template match="w:numFmt">
        <xsl:attribute name="format" select="@w:val"/>
    </xsl:template>
    
    <xsl:template match="w:start">
        <xsl:attribute name="start" select="@w:val"/>
    </xsl:template>
    
    <xsl:template match="w:lvlText">
        <xsl:attribute name="text" select="@w:val"/>
    </xsl:template>
    

</xsl:stylesheet>