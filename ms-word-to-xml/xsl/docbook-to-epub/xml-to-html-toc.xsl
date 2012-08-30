<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc><p>Templates for handling TOC generation.</p></desc>
    </doc>
    
    
    <xsl:template match="title|info/title" mode="toc">
        <xsl:apply-templates select="node()" mode="as-title"/>
    </xsl:template>
    
    <xsl:template match="book" mode="toc">
        
        
        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml"
            href="{concat('toc.', $xhtml.suffix)}">
            <html xml:id="toc">
                <head>
                    <title>Contents</title>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                    <meta name="page-id" content="toc"/>
                </head>
                <body class="toc">
                    <h2 class="EB04MainHead">Contents</h2>
                    <xsl:apply-templates select="/book/info/cover[@role='cover']" mode="toc"/>
                    <xsl:apply-templates select="dedication" mode="toc"/>
                    <xsl:apply-templates select="/book/info/cover[@role='title']" mode="toc"/>
                    <xsl:apply-templates
                        select="preface[not(@role) or not(@role = ('author', 'books-by'))]"
                        mode="toc"/>
                    <xsl:apply-templates select="part|acknowledgements|chapter|preface|personblurb|dedication|bibliography|appendix" mode="toc"/> 
                    <xsl:apply-templates select="author//personblurb" mode="toc"/>
                    <xsl:apply-templates select="preface[@role = ('author', 'books-by')]" mode="toc"
                    />
                </body>
            </html>
        </xsl:result-document>
        
        
    </xsl:template>
    
    <xsl:template match="cover" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>        
        <xsl:variable name="title"
            select="concat(upper-case(substring(@role, 1, 1)), lower-case(substring(@role, 2)))"/>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:value-of select="$title"/>
            </a>
        </p>
    </xsl:template>
    
    <xsl:template match="dedication" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">Dedication</a>
        </p>
    </xsl:template>
    
    <xsl:template match="acknowledgements" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">Acknowledgements</a>
        </p>
    </xsl:template>
    
    <xsl:template match="personblurb" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">About the author</a>
        </p>
    </xsl:template>
    
    <xsl:template match="chapter|appendix|preface|glossary|bibliography" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:apply-templates select="info/title|title" mode="toc"/>
            </a>
        </p>
        
    </xsl:template>

    <xsl:template match="toc[partintro]" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:apply-templates select="info/title|title" mode="toc"/>
            </a>
        </p>
        <xsl:apply-templates select="acknowledgements|chapter|preface|personblurb|dedication|bibliography|appendix" mode="toc"/>
    </xsl:template>
    
    
    <xsl:template match="part" mode="toc">
        <xsl:apply-templates select="acknowledgements|chapter|preface|personblurb|dedication|bibliography|appendix" mode="toc"/>
    </xsl:template>
    
    
    
</xsl:stylesheet>