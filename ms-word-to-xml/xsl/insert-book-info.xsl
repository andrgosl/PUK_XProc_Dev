<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
    xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    version="2.0">
    
    <xsl:template match="@*|node()" mode='#all'>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- we may have two titles. Override the one we pulled from properties if we have another -->
    <xsl:template match="/*/info/title[exists(//title[@cword:hint='book-title'])]"/>
    
    <!-- suppress front material under normal circumstances -->
    <xsl:template match="*[starts-with(@role, '01')]" mode='#default'/>
    
    <!-- match an info element that is a grandchild of the root element so we don't have to care about the DB root. -->
    <xsl:template match="/cword:word-doc/*/info">
        <info>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:apply-templates select="../*[starts-with(@role, '01')]" mode='info'/> <!-- just need a non default mode -->
        </info>
    </xsl:template>
    
    
</xsl:stylesheet>