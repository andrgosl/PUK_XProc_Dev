<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    version="2.0">

    <xsl:include href="identity.xsl"/>
    
    <!-- wrap up A Head sections -->
    <xsl:template match="*[title[@cword:hint='A-Head']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="title[@cword:hint='A-Head']">
                <xsl:choose>
                    <xsl:when test="@cword:hint = 'A-Head'">
                        <section xml:id="{generate-id()}">
                            <xsl:apply-templates select="current-group()"/>
                        </section>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <!-- wrap up B Head sections -->
    <xsl:template match="*[title[@cword:hint='B-Head']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="title[@cword:hint='B-Head']">
                <xsl:choose>
                    <xsl:when test="@cword:hint = 'B-Head'">
                        <section xml:id="{generate-id()}">
                            <xsl:apply-templates select="current-group()"/>
                        </section>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <!-- wrap up A Head sections -->
    <xsl:template match="*[title[@cword:hint='C-Head']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="title[@cword:hint='C-Head']">
                <xsl:choose>
                    <xsl:when test="@cword:hint = 'C-Head'">
                        <section xml:id="{generate-id()}">
                            <xsl:apply-templates select="current-group()"/>
                        </section>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
