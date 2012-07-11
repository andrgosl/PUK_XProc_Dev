<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:corbas="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
     exclude-result-prefixes="xs corbas w"
    >
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 28, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Functions module. Contains re-usable xslt functions for 
            extracting content from OOXML.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Returns true if the content has been marked as bold and
            false if not.</xd:p>
        </xd:desc>
        <xd:param name="properties">
            <xd:p>The properties parameter must be provided and must
                contain the properties element of the element being processed</xd:p>
        </xd:param>    </xd:doc>
    <xsl:function name="corbas:isBold">
        <xsl:param name="properties"/>
        <xsl:choose>
            <xsl:when test='$properties/w:b'>
                <xsl:value-of select='true()'/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select='false()'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
 
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Returns true if the content has been marked as italic and
                false if not.</xd:p>
        </xd:desc>
        <xd:param name="properties">
            <xd:p>The properties parameter must be provided and must
                contain the properties element of the element being processed</xd:p>
        </xd:param>    </xd:doc>
    <xsl:function name="corbas:isItalic">
        <xsl:param name="properties"/>
        <xsl:choose>
            <xsl:when test='$properties/w:i'>
                <xsl:value-of select='true()'/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select='false()'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Mechanism for mapping oaragraph styles to xml roles</xd:p>
        </xd:desc>
        <xd:param name="style">Contains the style element of the element to be mapped</xd:param>
    </xd:doc>
    <xsl:function name="corbas:mapParagraphStyle">
        <xsl:param name='style'/>
        <xsl:choose>
            <xsl:when test='starts-with($style, "Normal")'/>
            <xsl:otherwise>
                <xsl:value-of select='$style'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Mechanism for mapping run styles to xml roles</xd:p>
        </xd:desc>
        <xd:param name="style">Contains the style element of the element to be mapped</xd:param>
        <xd:return>String containing the style name or nothing.</xd:return>
    </xd:doc>
    <xsl:function name="corbas:mapRunStyle">
        <xsl:param name='style'/>
        <xsl:choose>
            <xsl:when test='starts-with($style, "Normal")'/>
            <xsl:otherwise>
                <xsl:value-of select='$style'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Follows the trail through w:Num and w:AbstractNum to
            work out the 'mark' text for a list.</xd:p>
        </xd:desc>
        <xd:param name='numbering'>Tree fragment containing the numbering nodes</xd:param>
        <xd:param name='level'>Indicates the nesting level of the list.</xd:param>
        <xd:param name='list-id'>Indicates which numbering definition should be used.</xd:param>
        <xd:return>String containing the bullet name or numbering style.</xd:return>
    </xd:doc>
    <xsl:function name="corbas:getListMark">
        <xsl:param name='numbering'/>        
        <xsl:param name='level'/>
        <xsl:param name='list-id'/>
        <xsl:variable name='abstract-number' select="number($numbering/w:num[@w:numId = $list-id]/w:abstractNumId/@w:val)"/>     
        <xsl:variable name='abstract-node' select="$numbering/w:abstractNum[@w:abstractNumId = $abstract-number]"/>
        <xsl:variable name='mark' select="$abstract-node/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val"/>
        <xsl:value-of select='$mark'/>
    </xsl:function>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Converts a bullet type into a list type and returns it.</xd:p>
        </xd:desc>
        <xd:param name='list-marker'>Name of a marker element.</xd:param>
        <xd:return>String containing either orderedlist or itemizedlist</xd:return>
    </xd:doc>
    <xsl:function name='corbas:getListType'>
        <xsl:param name='list-marker'/>
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
