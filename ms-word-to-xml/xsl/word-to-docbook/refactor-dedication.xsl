<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://docbook.org/ns/docbook" version="2.0">

    <!-- Update dedication content to extract from body and place into the top level of the document -->

    <xsl:include href="identity.xsl"/>

	<xsl:template match="*[dedication]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()[not(self::dedication)]|dedication[1]"/>
		</xsl:copy>
	</xsl:template>
		

    <xsl:template match="dedication[1]">
    	<xsl:copy>
    		<xsl:apply-templates select="@*|node()"/>
    		<xsl:apply-templates select="following-sibling::dedication" mode="copy-content"/>
    	</xsl:copy>
    </xsl:template>
	
	<xsl:template match="dedication" mode="copy-content">
		<xsl:apply-templates/>
	</xsl:template>

</xsl:stylesheet>
