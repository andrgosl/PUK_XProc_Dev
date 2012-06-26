<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2"
    xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns="http://docbook.org/ns/docbook"
     
    xpath-default-namespace="http://docbook.org/ns/docbook">
    
    <xsl:output  indent="yes"/>
    
    <xsl:template match="cword:word-doc">
        <xsl:apply-templates select="book"/>
    </xsl:template>
    
    <xsl:template match="@cword:hint"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>