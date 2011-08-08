<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns:pbl="http://www.penguingroup.com/ns/standard"
    xmlns:xlink="http://www.w3.org/1999/xlink"
     exclude-result-prefixes="pbl">
    
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="para"/>
     
    <xsl:template match="book/@version">
        <xsl:attribute name="version" select="'5.0'"/>
    </xsl:template>
    
    <xsl:template match='book/@xml:lang'>
        <xsl:attribute name="xml:lang" select="'EN-us'"/>
    </xsl:template>
    
    <xsl:template match="@version|@revision|@xml:lang"/>
    
    <xsl:template match='@*|node()'>
        <xsl:copy>
            <xsl:apply-templates select='@*|node()'/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="itermset|indexterm"/>
    
    <xsl:template match="bibliomixed/citetitle/emphasis">
        <xsl:apply-templates/>
    </xsl:template>
        
    <xsl:template match="book/info/publisher"/>
    <xsl:template match="book/info/bibliomisc"/>
    <xsl:template match="book/info/legalnotice"/>
    <xsl:template match="book/info/biblioset"/>
    
    <xsl:template match="epigraph/text()"/>
    
    <xsl:template match="para/@role[. = 'noindent']"/>

    <xsl:template  match="para[@role='spacebreak']/emphasis[@role='smallcaps'][position() = 1]">
        <phrase role='leadin'><xsl:apply-templates/></phrase>
    </xsl:template>
    
    <xsl:template  match="para[@role='spacebreak']/emphasis[@role='smallcaps'][position() = 1]/emphasis[@role='bold']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="toc"/>
    
    <xsl:template match="footnote/@role">
        <xsl:attribute name='role' select="'book-end'"/>
    </xsl:template>
    
    <!-- convert penguin poetry mark-up to docbook publishers -->
    <xsl:template match="pbl:poem">
        <poetry>
            <xsl:apply-templates select='@*|node()'/>
        </poetry>
    </xsl:template>
    
    <xsl:template match="pbl:stanza">
        <linegroup>
            <xsl:apply-templates select='@*|node()'/>
        </linegroup>
    </xsl:template>

    <xsl:template match="pbl:line">
        <line><xsl:apply-templates select='@*|node()'/></line>
    </xsl:template>
    
    <xsl:template match="emphasis[@role='dropcap']">
        <phrase role='firstChar'><xsl:apply-templates/></phrase>
    </xsl:template>
    
    <!-- fix up links - handle links to the info element and links that should be empty -->
    <xsl:template match='xref/@linkend|link/@linkend'>
        <xsl:variable name='target' select='//*[@xml:id = current()]'/>
        <xsl:choose>
            <xsl:when test="local-name($target) = 'info'">
                <xsl:attribute name='linkend' select="$target/parent::*/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>            
        </xsl:choose>
    </xsl:template>

    <xsl:template match="link[ends-with(@xlink:href, .)]">
        <xsl:copy>
            <xsl:apply-templates select='@*'/>
        </xsl:copy>    
    </xsl:template>
    
</xsl:stylesheet>