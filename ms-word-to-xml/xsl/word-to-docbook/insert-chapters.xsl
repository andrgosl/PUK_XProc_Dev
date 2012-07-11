<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    version="2.0">

    <xsl:include href="identity.xsl"/>

    <!-- wrap up chapters -->
    <xsl:template match="*[title[@cword:hint='chapter-title']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="title[@cword:hint='chapter-title']">
                <xsl:choose>
                    <xsl:when test="@cword:hint = 'chapter-title'">
                        <chapter xml:id="{generate-id()}">
                            <xsl:copy-of select="current-group()"/>
                        </chapter>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
