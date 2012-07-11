<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.daisy.org/z3986/2005/ncx/"
    xpath-default-namespace="http://www.daisy.org/z3986/2005/ncx/" version="2.0">

    <!-- process an existing navMap to add playOrder -->

    <xsl:variable name="paths" select="distinct-values(//content/normalize-space(@src))"/>

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="navPoint">
        <xsl:copy>
        <xsl:attribute name="playOrder" select="index-of($paths, content/@src)"/>
        <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
