<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/z3986/2005/ncx/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:corbas="http://www.corbas.net/ns/tempns"
    version="2.0" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:daisy="http://www.daisy.org/z3986/2005/ncx/" exclude-result-prefixes="#all">

    <xsl:import href="page-ids.xslt"/>

    <!-- Unique identifier for book. Should be the same value as that used in the OPF metadata. If none is
        not provided, synthesises one from from the first ISBN found. -->
    <xsl:param name="book-id" select="concat('book-', /book/info/biblioid[@class='isbn'][1])"/>

    <!-- relative path from the NCX file to content. Defaults to 'xhtml' -->
    <xsl:param name="xhtml-dir" select="&quot;xhtml&quot;"/>

    <xsl:output method="xml" doctype-public="-//NISO//DTD ncx 2005-1//EN"
        doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"/>

    <xsl:strip-space elements="*"/>

    <!-- create an ncx file from DocBook -->
    <xsl:template match="/">
        <ncx version="2005-1" xml:lang="en">
            <xsl:apply-templates select="/book/info"/>
            <xsl:apply-templates select="/book" mode="navMap"/>
        </ncx>
    </xsl:template>

    <xsl:template match="/book/info">
        <head>
            <meta name="dtb:uid" content="{$book-id}"/>
        </head>
        <docTitle>
            <text>
                <xsl:value-of select="title/text()"/>
            </text>
        </docTitle>
        <docAuthor>
            <text>
                <xsl:apply-templates select="author|authorgroup"/>
            </text>
        </docAuthor>
    </xsl:template>

    <xsl:template match="book" mode="navMap">

        <navMap>
            <xsl:apply-templates select="info/cover[@role='cover']"/>
            <xsl:apply-templates select="dedication"/>
            <xsl:apply-templates select="info/cover[@role='title']"/>

            <navPoint id="toc">
                <navLabel>
                    <text>Contents</text>
                </navLabel>
                <content src="{concat($xhtml-dir, '/toc.html')}"/>
            </navPoint>

            <navPoint id="book">
                <navLabel>
                    <text>
                        <xsl:apply-templates select="/book/info/title"/>
                    </text>
                </navLabel>
                <xsl:apply-templates
                    select="(preface[not(@role) or not(@role = ('reviews', 'author', 'books-by'))]|part|chapter|bibliography|appendix)[1]"
                    mode="book-content"/>                
                <xsl:apply-templates
                    select="preface[not(@role) or not(@role = ('reviews', 'author', 'books-by'))]"/>
                <xsl:apply-templates select="part|chapter|appendix"/>
            </navPoint>

            <navPoint id="copyright">
                <navLabel>
                    <text>Copyright</text>
                </navLabel>
                <content src="{concat($xhtml-dir, '/copyright.html')}"/>
            </navPoint>

            <xsl:apply-templates select="author//personblurb"/>
            <xsl:apply-templates select="preface[@role = ('author', 'books-by')]"/>

        </navMap>

    </xsl:template>


    <xsl:template match="cover">
        <xsl:variable name="file-name">
            <xsl:call-template name="page.href"/>
        </xsl:variable>
        <xsl:variable name="title"
            select="concat(upper-case(substring(@role, 1, 1)), lower-case(substring(@role, 2)))"/>

        <navPoint id="{@role}">
            <navLabel>
                <text>
                    <xsl:value-of select="$title"/>
                </text>
            </navLabel>
            <content src="{concat($xhtml-dir, '/', $file-name)}"/>
        </navPoint>

    </xsl:template>

    <xsl:template match="dedication">
        <navPoint id="dedication">
            <navLabel>
                <text>Dedication</text>
            </navLabel>
            <xsl:apply-templates select="." mode="book-content"/>
        </navPoint>

    </xsl:template>




    <xsl:template match="chapter|bibliography|appendix">

        <xsl:variable name="page-id">
            <xsl:call-template name="page.id"/>
        </xsl:variable>

        <xsl:variable name="title-node" select="(title, info/title)[1]"/>
        <navPoint id="{$page-id}">
            <navLabel>
                <text>
                    <xsl:value-of select="normalize-space($title-node)"/>
                </text>
            </navLabel>
            <xsl:apply-templates select="." mode="book-content"/>
        </navPoint>

    </xsl:template>




    <xsl:template match="part">

        <xsl:variable name="page-id">
            <xsl:call-template name="page.id"/>
        </xsl:variable>

        <navPoint id="{$page-id}">
            <navLabel>
                <text>
                    <xsl:apply-templates select="title|info/title"/>
                </text>
            </navLabel>
            <xsl:apply-templates select="." mode="book-content"/>
            <xsl:apply-templates select="preface|chapter"/>

        </navPoint>

    </xsl:template>

    <xsl:template match="part|part|dedication|chapter|preface|bibliography|appendix"
        mode="book-content">

        <xsl:variable name="page-id">
            <xsl:call-template name="page.id"/>
        </xsl:variable>
        <xsl:variable name="file-name">
            <xsl:call-template name="page.href"/>
        </xsl:variable>

        <content src="{concat($xhtml-dir, '/', $file-name)}"/>

    </xsl:template>

    <xsl:template match="preface">

        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <navPoint id="{$basis}">
            <navLabel>
                <text>
                    <xsl:apply-templates select="title|info/title"/>
                </text>
            </navLabel>
            <xsl:apply-templates select="." mode="book-content"/>
        </navPoint>

    </xsl:template>


    <xsl:template match="personblurb">

        <xsl:variable name="file-name">
            <xsl:call-template name="page.href"/>
        </xsl:variable>

        <navPoint id="author">
            <navLabel>
                <text> About the author </text>
            </navLabel>
            <content src="{concat($xhtml-dir, '/', $file-name)}"/>
        </navPoint>

    </xsl:template>

    <xsl:template match="authorgroup">
        <xsl:choose>
            <xsl:when test="count(*) gt 1">
                <xsl:for-each select="*[position() lt last()]">
                    <xsl:if test="position() gt 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="author|editor|othercredit">
        <xsl:apply-templates select="personname"/>
    </xsl:template>

    <!-- very basic -->
    <xsl:template match="personname">
        <xsl:value-of select="honorific|firstname|givenname|surname"/>
    </xsl:template>




</xsl:stylesheet>
