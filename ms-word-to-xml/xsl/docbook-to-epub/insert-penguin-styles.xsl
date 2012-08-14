<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:db="http://docbook.org/ns/docbook"
    version="2.0">
    
    <!-- Insert penguin standard styles into attributes on the xml. Insert them
    into epub:style attributes -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- Modify a title for about the author to all upper case -->
    <xsl:template match="title[lower-case(.) = 'about the author']/text()">
        <xsl:text>ABOUT THE AUTHOR</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>