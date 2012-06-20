<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns="http://docbook.org/ns/docbook"
     xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Paragraph style rewrites -->
    <xsl:include href='paragraph-styles.xsl'/>
    
    
    
</xsl:stylesheet>