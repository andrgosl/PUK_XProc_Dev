<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <xsl:include href="identity.xsl"/>
    
    
    <xsl:template match="*[not(ancestor::para)][not(@xml:id)]">
        <xsl:copy>
            <xsl:apply-templates select='@*'/>
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
