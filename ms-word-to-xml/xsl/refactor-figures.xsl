<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <!-- find mediaobject elements immediately followed by caption elements
        and turn them into figure elements -->
    
    <xsl:include href="identity.xsl"/>
    
    <xsl:template match="mediaobject[following-sibling::*[1][self::caption]]">
        <figure xml:id="{generate-id()}">
            <title/>
            <xsl:copy-of select=".|following-sibling::*[1]"/>
        </figure>
    </xsl:template>
    
    <xsl:template match="caption[preceding-sibling::*[1][self::mediaobject]]"/>
    
    
</xsl:stylesheet>