<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 29, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Write content to an xhtml file. This is basically a dummy because we serialize in XProc</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="debug.page.generation" select="'yes'"/>
    
    <xsl:template name="html-doc">
        
        <xsl:param name="page-id">
            <xsl:call-template name="page.id"/>
        </xsl:param>
        
        
        <xsl:param name="filename">
            <xsl:call-template name="page.href">
                <xsl:with-param name="page-id" select="$page-id"/>
            </xsl:call-template>
        </xsl:param>
        
        
        <xsl:param name="contents">
            <xsl:apply-templates mode="#current"/>
        </xsl:param>
        
        <xsl:param name="title"/>
        
        <xsl:if test="$debug.page.generation = 'yes'">
            <xsl:message>
                Generating page for the "<xsl:value-of select='local-name()'/>" element with id "<xsl:value-of select='@xml:id'/>".
                File name will be: "<xsl:value-of select='$filename'/>" and page-id will be "<xsl:value-of select="$page-id"/>".
            </xsl:message>
        </xsl:if>
        
        <xsl:variable name="class" select="if (@role) then @role else local-name()"/>
        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml" 
            href="{$filename}">
            <html xml:id="{$page-id}">
                <head>
                    <xsl:copy-of select="$title"/>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                </head>
                <body class="{$class}">
                    <xsl:call-template name="create-body-id"/>
                    <xsl:copy-of select='$contents'/>
                </body>
            </html>
        </xsl:result-document>
        
        <xsl:if test="$debug.page.generation = 'yes'">
            <xsl:message>
                Generated Page
            </xsl:message>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>