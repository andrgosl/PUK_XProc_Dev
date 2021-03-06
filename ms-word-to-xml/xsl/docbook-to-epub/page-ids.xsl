<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:cfn="https://www.corbas.co.uk/ns/xsl/functions"
    xmlns="http://docbook.org/ns/docbook" 
     xpath-default-namespace="http://docbook.org/ns/docbook" version="2.0">

    <xsl:param name="debug.page-ids" select="'no'"/>
    <xsl:param name="xhtml.suffix" select="'xhtml'"/>
    
    <xsl:variable name="page-elements" select="('preface', 'chapter', 'appendix', 'acknowledgements', 'dedication', 'bibliography', 'glossary', 'part')"/> 
    <xsl:variable name="page-nodes" select="//*[local-name() = $page-elements]"/>
   
    <!-- page IDs -->
    <xsl:template name="page.id">
        <xsl:param name="node" select="."/>
        <xsl:param name="prefix" select="''"/>

        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generating page id for a <xsl:value-of select="name()"/> element.
            </xsl:message>
        </xsl:if>

        <xsl:variable name="page-ancestor"
            select="$node/ancestor-or-self::*[local-name() = ('chapter', 'preface', 'appendix', 'bibliography')]"/>

        <xsl:variable name="page-id">
            <xsl:choose>

                <xsl:when
                    test="local-name($node) = ('part', 'index', 'cover', 'acknowledgements', 'personblurb', 'dedication')">
                    <xsl:if test="$debug.page-ids = 'yes'">
                        <xsl:message>Using element id for page id.</xsl:message>
                    </xsl:if>
                    <xsl:apply-templates select="$node" mode="page-id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$debug.page-ids = 'yes'">
                        <xsl:message>Using ancestor id for page id.</xsl:message>
                    </xsl:if>
                    <xsl:apply-templates select="$page-ancestor" mode="page-id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generated id is <xsl:value-of select="concat($prefix, $page-id)"/></xsl:message>
        </xsl:if>

        <xsl:value-of select="concat($prefix, $page-id)"/>

    </xsl:template>

    <xsl:template match="*" mode="page-id">

        <xsl:variable name="name" select="local-name()"/>
        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generating generic page id for a <xsl:value-of select="$name"/> element.</xsl:message>
        </xsl:if>
        <xsl:variable name="generic-id">
            <xsl:choose>
                <xsl:when test="count($page-nodes[local-name() = $name]) lt 2">
                    <xsl:value-of select="local-name()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="counted.page.id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$generic-id"/>

    </xsl:template>

    <xsl:template match="author/personblurb" mode="page-id">
        <xsl:value-of select="'author'"/>
    </xsl:template>

    <xsl:template match="appendix|part|index|chapter|bibliography" mode="page-id">
        <xsl:call-template name="counted.page.id"/>
    </xsl:template>


    <!--- countes the preceding elements of the same type to get a count for the id of an element -->
    <xsl:template name="counted.page.id" as="text()">
        <xsl:variable name="type" select="local-name(.)"/>

        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generating a counted page id for a <xsl:value-of select="$type"/>
                element.</xsl:message>
        </xsl:if>

        <xsl:variable name="of-my-type" select="$page-nodes[local-name() = $type]"/>
                
        <xsl:choose>
                <xsl:when test="count($of-my-type) = 0">1</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="my-index" select="index-of($of-my-type, .)"/>
                <xsl:variable name="num" select="count($page-nodes[position() = 1 to $my-index])"/>
                <xsl:value-of select="concat($type ,'-' , format-number($num, '000'))"/>
            </xsl:otherwise>
        </xsl:choose>
   
    </xsl:template>

    <!-- page hrefs -->
    <xsl:template name="page.href">
        <xsl:param name="node" select="."/>
        <xsl:param name="page-id" select="''"/>
        <xsl:param name="prefix" select="''"/>
        
        <xsl:param name="with.fragment" select="''"/>

        <xsl:variable name="calculated-page-id">
            <xsl:choose>
                <xsl:when test="$page-id"><xsl:value-of select="$page-id"/></xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="page.id">
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="prefix" select="$prefix"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name='href' select="concat($calculated-page-id, '.', $xhtml.suffix)"/>
        
        <xsl:choose>
            <xsl:when test="$with.fragment">
                <xsl:value-of select="concat($href, '#', $with.fragment)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
