<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns="http://docbook.org/ns/docbook"
     xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <!-- Update epigraph content to create groups and insert sources -->
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[epigraph]" mode="refactor-body">
        <xsl:for-each-group select="*" group-adjacent="local-name()">
            <xsl:choose>
                <xsl:when test="current-grouping-key() = 'epigraph'">
                    <epigraph><xsl:apply-templates select="@* | current-group()"/></epigraph>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="epigraph">
        <xsl:apply-templates/>
    </xsl:template>    
   
    
</xsl:stylesheet>