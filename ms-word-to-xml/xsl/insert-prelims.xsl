<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" version="2.0">

    <xsl:include href="identity.xsl"/>
    
    <xsl:template match="cword:word-doc">
        <xsl:variable name="insert-prefaces">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$insert-prefaces" mode="fix-up"/>
    </xsl:template>

    <!-- wrap up text content occurring between the info and first chapter or part -->
    <xsl:template match="cword:word-doc/*[part or chapter]">
        <xsl:variable name="first-body" select="if (part) then part[1] else chapter[1]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*[. &lt;&lt; $first-body]"
                group-starting-with="title|epigraph|dedication|info">
                <xsl:choose>
                    <xsl:when test="self::title">
                        <preface>
                            <xsl:apply-templates select="current-group()"/>
                        </preface>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="prelims"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
            <xsl:apply-templates select="$first-body | *[. >> $first-body]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="epigraph" mode="prelims">
        <preface xml:id="{generate-id()}">
            <title/>
            <xsl:apply-templates select="." mode="#default"/>
        </preface>
    </xsl:template>

    <!-- move elements that are between prefaces into them -->
    <xsl:template match="preface[following-sibling::preface]" mode="fix-up">
        <xsl:variable name="next-preface" select="following-sibling::preface[1]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="fixup"/>
            <xsl:apply-templates select="following-sibling::*[. >> current()][. &lt;&lt; $next-preface]"/>               
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[preceding-sibling::preface][following-sibling::preface][not(self::preface)]" mode="fix-up"/>


</xsl:stylesheet>
