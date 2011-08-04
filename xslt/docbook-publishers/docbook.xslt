<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:exsl="http://exslt.org/common"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ng="http://docbook.org/docbook-ng"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:stext="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.TextFactory"
  xmlns:str="http://exslt.org/strings"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xtext="xalan://com.nwalsh.xalan.Text"
  xmlns:p="http://www.penguingroup.com/ns/standard"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  extension-element-prefixes="stext xtext"
  exclude-result-prefixes="exsl db dc h ncx ng opf stext str xtext p xd" version="1.0">

  <xsl:import href="param.xslt"/>
  <xsl:import href="/usr/local/share/docbook-xsl/html/docbook.xsl" /> 
  <xsl:import href="line-based.xslt" />
  
  <xsl:output media-type="html" encoding="UTF-8"/>
  
  <xsl:param name="chapter.autolabel">0</xsl:param>
  
  <xsl:strip-space elements="p:linegroup p:poem p:stanza p:canto"/>

</xsl:stylesheet>
