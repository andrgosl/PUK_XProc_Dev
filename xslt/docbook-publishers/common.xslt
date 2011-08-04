<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xd"
    version="1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 10, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Templates that are to be shared between poetry and drama.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- Override the built-in anchor template to do nothing -->
    <xsl:template name="anchor"/>
    
    <!-- Override the built-in common.html.attributes element to generate an id attribute -->
    <xsl:template name="common.html.attributes">
        
        <xsl:param name="inherit" select="0"/>
        <xsl:param name="class" select="local-name(.)"/>
        
        <xsl:apply-templates select="." mode="common.html.attributes">
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="inherit" select="$inherit"/>
        </xsl:apply-templates>
        
        <xsl:call-template name="generate.id.attribute"/>
        
    </xsl:template>
    
    <!-- generate an id attribute -->
    <xsl:template name='generate.id.attribute'>
        <xsl:choose>
            <xsl:when test='@xml:id'>
                <xsl:attribute name='id'><xsl:value-of select='@xml:id'/></xsl:attribute>
            </xsl:when>
            <xsl:when test='@id'>
                <xsl:attribute name='id'><xsl:value-of select='@id'/></xsl:attribute>
            </xsl:when>
        </xsl:choose>    
    </xsl:template>
    
    
</xsl:stylesheet>