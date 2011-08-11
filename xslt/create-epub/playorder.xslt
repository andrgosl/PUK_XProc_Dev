<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.daisy.org/z3986/2005/ncx/"
     xpath-default-namespace="http://www.daisy.org/z3986/2005/ncx/"
    version="2.0">
    
    <!-- process an existing navMap to add playOrder -->
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="navPoint">
        <xsl:variable name='offset' select="if (ancestor::navPoint[@id = 'book'] or preceding::navPoint[@id='book']) then 0 else 1"/>
        <xsl:variable name="order" select="
            count(preceding::navPoint) + count(ancestor::navPoint) + $offset"/>
        <xsl:copy>
            <xsl:copy-of select='@*'/>
            <xsl:attribute name="playOrder" select='$order'/>
            <xsl:apply-templates select='node()'/>
        </xsl:copy>
        
    </xsl:template>
    
</xsl:stylesheet>