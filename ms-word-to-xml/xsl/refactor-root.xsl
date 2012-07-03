<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cword="http://www.corbas.co.uk/ns/word"
    exclude-result-prefixes="xs"
    xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    version="2.0">
    
    <xsl:include href="identity.xsl"/>
    
    <!-- choose which root element we should have (book or article) depending on the
    presence of chapter or part content  -->
    
    <xsl:template match="book[not(.//title[@cword:hint='chapter-title'] or .//title[@cword:hint='part-title'])]">
        <article>
            <xsl:apply-templates select="@*|node()"/>
        </article>
    </xsl:template>
    
</xsl:stylesheet>