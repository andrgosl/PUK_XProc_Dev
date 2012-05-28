<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ixwd="http://www.ixxus.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:rp="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    exclude-result-prefixes="xs ixwd xd db w r rp a">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 22, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Simple stylesheet to be executed following the word normaliser in the conversion
                pipeline. This stylesheet simply moves sections representing graphics to before the
                preceding section if it is marked as being a right floated image.</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output encoding="UTF-8" indent="yes"/>

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="w:t"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="db:article">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="db:section[@role != 'graphic:container']">
        
        <xsl:if test="following-sibling::db:section[1][@role = 'graphic:container']">
            <xsl:if test="following-sibling::*[1]//db:section[@role = 'graphic:alignment']/db:para='Right'">
                <xsl:apply-templates select="following-sibling::db:section[1]" mode="normal"/>
            </xsl:if>
        </xsl:if>

        <xsl:apply-templates select="." mode="normal"/>

    </xsl:template>

    <xsl:template
        match="db:section[@role = 'graphic:container' and not(.//db:section[@role = 'graphic:alignment']/db:para='Right')]">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:template
        match="db:section[@role = 'graphic:container' and .//db:section[@role = 'graphic:alignment']/db:para='Right']">
    </xsl:template>    

    <xsl:template match="db:section" mode="normal">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
