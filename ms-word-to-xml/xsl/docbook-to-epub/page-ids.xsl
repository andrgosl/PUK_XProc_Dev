<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:param name="debug.page-ids" select="'no'"/>

    <!-- page IDs -->
    <xsl:template name="page.id">
        <xsl:param name="node" select="."/>

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
            <xsl:message>Generated id is <xsl:value-of select="$page-id"/></xsl:message>
        </xsl:if>

        <xsl:value-of select="$page-id"/>

    </xsl:template>

    <xsl:template match="*" mode="page-id">

        <xsl:variable name="name" select="local-name()"/>
        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generating generic page id for a <xsl:value-of select="$name"/> element.</xsl:message>
        </xsl:if>
        <xsl:variable name="generic-id">
            <xsl:choose>
                <xsl:when test="count(//*[local-name() = $name]) = 1">
                    <xsl:value-of select="(@role, local-name())[1]"/>
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

    <xsl:template name="counted.page.id">
        <xsl:variable name="type" select="local-name(.)"/>

        <xsl:if test="$debug.page-ids = 'yes'">
            <xsl:message>Generating a counted page id for a <xsl:value-of select="$type"/>
                element.</xsl:message>
        </xsl:if>


        <xsl:variable name="num" select="count(preceding::*[local-name(.) = $type]) + 1"/>
        <xsl:value-of select="concat($type, format-number($num, '000'))"/>
    </xsl:template>

    <!-- page hrefs -->
    <xsl:template name="page.href">
        <xsl:param name="node" select="."/>
        <xsl:param name="create.fragment" select="false()"/>        
        <xsl:variable name="page-id">
            <xsl:call-template name="page.id">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name='href' select="concat($page-id, '.html')"/>
        <xsl:choose>
            <xsl:when test="$create.fragment">
                <xsl:value-of select="concat($href, '#', $node/@xml:id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
