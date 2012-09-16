<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd"
	xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cword="http://www.corbas.co.uk/ns/word"
	version="2.0">
	
	<xsl:include href="identity.xsl"/>
	
	<xsl:template match="*[dedication]">
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select="node()[not(self::dedication)]"/>
		</xsl:copy>
		<xsl:copy-of select="dedication"/>
	</xsl:template>

</xsl:stylesheet>
