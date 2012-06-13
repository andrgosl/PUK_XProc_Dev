<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" version="2.0">

    <xsl:template match="@*|node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[child::listitem]" mode="#all" priority="1">

        <xsl:copy>

            <xsl:apply-templates select="@*"/>

            <xsl:for-each-group select="node()" group-adjacent="if (element()) then local-name(.) else 'other-node'">
                <xsl:choose>

                    <!-- process lists specially -->
                    <xsl:when test="current-grouping-key() = 'listitem'">
                        <xsl:call-template name="list-handler">
                            <xsl:with-param name="list-items" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:when>

                    <!-- output anything else in the normal way -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:for-each-group>

        </xsl:copy>

    </xsl:template>

    <xd:doc>
        <xd:desc>Template to localise processing of lists. Given a parameter containing a sequence
            of listitem elements, converts it to at least one list.</xd:desc>
        <xd:param name="list-items">Sequence containing the list items to be processed.</xd:param>
    </xd:doc>
    <xsl:template name="list-handler">

        <xsl:param name="list-items"/>

        <!-- type of the outer most list is defined by the bullet on the first
        element. -->
        <xsl:variable name="list-mark-number" select="number($list-items[1]/@cword:list-mark)"/>
        <xsl:variable name="list-mark"
            select="cword:getListMark(//cword:list-formats, number($list-items[1]/@cword:list-level), $list-mark-number)"/>

        <xsl:variable name="list-type" select="cword:getListType($list-mark)"/>
        <xsl:variable name="level" select="number($list-items[1]/@cword:list-level)"/>

        <xsl:element name="{$list-type}">

            <xsl:if test="$list-type = 'orderedlist'">
                <xsl:attribute name="numeration">
                    <xsl:choose>
                        <xsl:when test="lower-case($list-mark) = &quot;decimal&quot;">
                            <xsl:value-of select="&quot;arabic&quot;"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="lower-case($list-mark)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>

            <xsl:for-each-group select="$list-items" group-adjacent="./@cword:list-level = $level">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = false()">
                        <listitem>
                            <xsl:call-template name="list-handler">
                                <xsl:with-param name="list-items" select="current-group()"/>
                            </xsl:call-template>
                        </listitem>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="write-list-item">
                            <xsl:with-param name="list-mark-number" select="$list-mark-number"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:element>


    </xsl:template>


    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Uses the processed numbering to extract list format information.</xd:p>
        </xd:desc>
        <xd:param name="numbering">Tree fragment containing the processed numbering nodes</xd:param>
        <xd:param name="level">Indicates the nesting level of the list.</xd:param>
        <xd:param name="list-id">Indicates which numbering definition should be used.</xd:param>
        <xd:return>String containing the bullet name or numbering style.</xd:return>
    </xd:doc>
    <xsl:function name="cword:getListMark">
        <xsl:param name="numbering"/>
        <xsl:param name="level"/>
        <xsl:param name="list-id"/>
        
        <xsl:variable name="list-format" select="$numbering//cword:list-format[@number= $list-id]"/>
        <xsl:variable name="level-format" select="$list-format/cword:level[position() = $level - 1]"/>
        <xsl:value-of select="$level-format/@format"/>
        
    </xsl:function>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Converts a bullet type into a list type and returns it.</xd:p>
        </xd:desc>
        <xd:param name="list-marker">Name of a marker element.</xd:param>
        <xd:return>String containing either orderedlist or itemizedlist</xd:return>
    </xd:doc>
    <xsl:function name="cword:getListType">
        <xsl:param name="list-marker"/>
        <xsl:choose>
            <xsl:when test="$list-marker = 'bullet'">
                <xsl:value-of select="'itemizedlist'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'orderedlist'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
