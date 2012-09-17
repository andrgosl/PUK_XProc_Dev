<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	exclude-result-prefixes="xs xd"
	xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
	version="2.0">

	<xsl:import href="identity.xsl"/>

	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Sep 16, 2012</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>If a document has parts, ensure that the last part does not have anything after the last chapter by moving it to after that part</xd:p>
		</xd:desc>
	</xd:doc>
	
	
	<xsl:template match="part[position() = last()]">
		<xsl:variable name="last-chapter" select="chapter[position() = last()]"/>
		<xsl:copy>
			<xsl:copy-of select="@*|node()[. &lt;&lt; $last-chapter]|$last-chapter"/>
		</xsl:copy>
		<xsl:copy-of select="node()[. >> $last-chapter]"/>
	</xsl:template>
	
</xsl:stylesheet>