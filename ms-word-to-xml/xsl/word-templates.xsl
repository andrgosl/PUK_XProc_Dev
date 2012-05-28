<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:db='http://docbook.org/ns/docbook'
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"

    exclude-result-prefixes="xs cword xd w r "
    >
    <xsl:import href="word-functions.xsl"/>
    
    <xd:doc  scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 28, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Generic templates module. Contains named templates for
                repurposing content from OOXML
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts the style given in an elements properties
            to a role attribute containing the style's value.</xd:p>
            <xd:p>Currently handles run and paragraph styles.</xd:p>
        </xd:desc>
        <xd:param name="properties">
            <xd:p>The properties parameter must be provided and must
            contain the properties element of the element being processed</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="cword:getStyleAsRole">
        <xsl:param name='properties'/>
        <xsl:variable name='style' select='$properties/w:rStyle|$properties/w:pStyle'/>
        <xsl:variable name='mapped-style'>
            <xsl:choose>
                <xsl:when test='$properties/w:pStyle'><xsl:value-of select='cword:mapParagraphStyle($style/@w:val)'/></xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test='$properties/w:rStyle'><xsl:value-of select='cword:mapRunStyle($style/@w:val)'/></xsl:when>
            </xsl:choose>
        </xsl:variable>
         
        <xsl:choose>
            <xsl:when test='$style/@w:val = "attributes"'/>
            <xsl:when test='$style/@w:val = "CommentReference"'/>
            <xsl:when test='$style'>
                <xsl:attribute name='role'><xsl:value-of select='$mapped-style'/></xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Title for the document as a whole. The default
            generates a blank title. Override it.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name='cword:documentTitle'>
        <db:title/>
    </xsl:template>
    

    
</xsl:stylesheet>
