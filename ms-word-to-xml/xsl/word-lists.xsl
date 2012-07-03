<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" version="2.0">
    
    <xsl:include href="identity.xsl"/>
    
    <!-- suppress the list definitions on output -->
    <xsl:template match="cword:list-formats"/>

    <!-- match elements that contain list items -->
    <xsl:template match="*[child::listitem]" mode="#all" priority="1">
        
        <xsl:copy>

            <xsl:apply-templates select="@*"/>

            <xsl:for-each-group select="*" group-adjacent="if (element()) then local-name(.) else 'other-node'">
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
        
        <xsl:variable name="word-types" select="('decimal', 'lowerLetter', 'lowerRoman', 'upperLetter', 'upperRoman')"/>
        <xsl:variable name="docbook-types" select="('arabic', 'loweralpha', 'lowerroman', 'upperalpha', 'upperroman')"/>
        
        <xsl:variable name="level" select="number($list-items[1]/@cword:list-level)"/>
        <xsl:variable name="list-mark-number" select="number($list-items[1]/@cword:list-mark)"/>
        
        <xsl:variable name="list-format" select="//cword:list-formats/cword:list-format[@number = $list-mark-number]"/>
        
        
        <xsl:variable name="list-mark" select="$list-format/cword:level[position() = $level + 1]/@format"/>
        <xsl:variable name="list-type" select="if ($list-mark = 'bullet') then 'itemizedlist' else 'orderedlist'"/>
                
        <xsl:element name="{$list-type}" namespace="http://docbook.org/ns/docbook">
            
            <xsl:if test="not($list-type = 'itemizedlist')">
                <xsl:attribute name="numeration" select="$docbook-types[index-of($word-types, $list-type)]"/>
            </xsl:if>

             <xsl:for-each-group select="$list-items" group-adjacent="@cword:list-level = $level">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = false()">
                        <listitem>
                            <xsl:call-template name="list-handler">
                                <xsl:with-param name="list-items" select="current-group()"/>
                            </xsl:call-template>
                        </listitem>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:element>


    </xsl:template>

</xsl:stylesheet>
