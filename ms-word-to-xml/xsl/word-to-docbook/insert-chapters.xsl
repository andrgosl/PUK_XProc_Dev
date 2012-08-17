<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    version="2.0">

    <xsl:include href="identity.xsl"/>
    
    <xsl:variable name="hints" select="('chapter-title', 'endmatter-title', 'prelims-title', 'ack-title')"></xsl:variable>

    <!-- wrap up chapters and similar constructs -->
    <xsl:template match="*[title[@cword:hint=$hints]]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="title[@cword:hint=$hints]">
                <xsl:choose>
                    <xsl:when test="@cword:hint = $hints">
                        <xsl:apply-templates select="." mode='insert-structure'/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="title[@cword:hint='chapter-title']" mode="insert-structure">
        <chapter>
            <xsl:apply-templates select="current-group()"/>
        </chapter>
    </xsl:template>
    
    <xsl:template match="title[@cword:hint='endmatter-title']" mode="insert-structure">
        <appendix>
            <xsl:apply-templates select="current-group()"/>
        </appendix>
    </xsl:template>
    
    <xsl:template match="title[@cword:hint='prelims-title']" mode="insert-structure">
        <preface>
            <xsl:apply-templates select="current-group()"/>
        </preface>
    </xsl:template>
    
    <xsl:template match="title[@cword:hint='ack-title']" mode="insert-structure">
        <acknowledgements>
            <xsl:apply-templates select="current-group()"/>
        </acknowledgements>
    </xsl:template>
    
    <!-- this is to handle situations where front matter marked content is *after* the chapters -->
    <xsl:template match="title[@cword:hint='prelims-title'][preceding-sibling::title[@cword:hint='chapter-title']]"  mode="insert-structure" priority="1">
        <appendix>
            <xsl:apply-templates select="current-group()"/>
        </appendix>
    </xsl:template>

</xsl:stylesheet>
