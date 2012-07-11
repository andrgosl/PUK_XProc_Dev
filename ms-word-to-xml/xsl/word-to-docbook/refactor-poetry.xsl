<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    xmlns:cword="http://www.corbas.co.uk/ns/word"
    xpath-default-namespace="http://docbook.org/ns/docbook" exclude-result-prefixes="xs"
    version="2.0">

    <xsl:include href="identity.xsl"/>

    <xsl:template match="*[para[@cword:hint = 'poetry']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*"
                group-adjacent="if (@cword:hint) then @cword:hint else 'other'">
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'poetry'">
                        <poem xml:id="{generate-id()}"
                            xmlns="http://www.penguingroup.com/ns/standard">
                            <stanza>
                                <xsl:apply-templates select="current-group()"/>
                            </stanza>
                        </poem>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="para[@cword:hint = 'poetry']">
        <line xmlns="http://www.penguingroup.com/ns/standard">
            <xsl:apply-templates select="@*|node()"/>
        </line>
    </xsl:template>
    
    <!-- Workaround for what's probably a bug in the Penguin schema - role attribute is in Penguin namespace -->
    <xsl:template match="para[@cword:hint = 'poetry']/@role">
        <xsl:attribute name="role" namespace="http://www.penguingroup.com/ns/standard" select='.'/>
    </xsl:template>

</xsl:stylesheet>
