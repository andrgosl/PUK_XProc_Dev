<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cword="http://wwww.corbas.co.uk/ns/word"
    name="wordToDocBook" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:db="http://docbook.org/ns/docbook" version="1.0"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:wprop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties">

    <p:documentation>
        <section xmlns="http://docbook.org/ns/docbook">
            <info>
                <title>word2db.xp</title>
                <author><personname>Nic Gibson</personname></author>
                <revhistory xmlns="http://docbook.org/ns/docbook">
                    <revision>
                        <revnumber>1</revnumber>
                        <date>2010-02-08</date>
                        <revremark>Initial Version</revremark>
                    </revision>
                    <revision>
                        <revnumber>2</revnumber>
                        <date>2010-03-19</date>
                        <revremark>Added support for loading and merging the document.xml.rels file
                            in order to access URLs for linked images. Added move-graphics step to
                            allow images to be placed correctly.</revremark>
                    </revision>
                    <revision>
                        <revnumber>2</revnumber>
                        <date>2010-03-29</date>
                        <revremark>Added support for loading app.xml for document properties and
                            numbering.xml for list handling.</revremark>
                    </revision>
                    <revision>
                        <revnumber>3</revnumber>
                        <date>2012-05-28</date>
                        <revremark>Removed load code to replace with standalone module.</revremark>
                    </revision>
                </revhistory>
            </info>
            <para>XProc script to unzip a word docx document, extract metadata and convert to
                DocBook xml</para>
        </section>
    </p:documentation>

    <p:option name="package-url" required="true"/>
    <p:option name="show-steps" select="'false'" required="false"/>

    <p:import href="library-1.0.xpl"/>
    <p:import href="docx2xml.xpl"/>


    <!-- Extract docx file to a wrapped xml file -->
    <corbas:docx2xml name="extract-document">
        <p:with-option name="package-url" select="$package-url"/>
    </corbas:docx2xml>
    
    <!-- rewrite the numbering for lists to something more useable later -->   
    <p:xslt name="refactor-numbering">
        <p:input port="source">
            <p:pipe port="result" step="extract-document"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-numbering.xsl"/>
        </p:input>        
    </p:xslt>

    <p:store href="/tmp/extracted.xml">
        <p:input port="source">
            <p:pipe port="result" step="refactor-numbering"/>
        </p:input>
    </p:store>

    <!-- convert word markup to docbook elements -->
    <p:xslt name="initial-conversion" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="refactor-numbering"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-components.xsl"/>
        </p:input>
    </p:xslt>

    <p:store href="/tmp/converted-1.xml">
        <p:input port="source">
            <p:pipe port="result" step="initial-conversion"/>
        </p:input>
    </p:store>
    
    <!-- rewrite paragraphs to appropriate elements -->
    <p:xslt name="refactor-paragraphs" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="initial-conversion"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/refactor-paragraphs.xsl"/>
        </p:input>
    </p:xslt>
    
    
    <p:store href="/tmp/converted-2.xml">
        <p:input port="source">
            <p:pipe port="result" step="refactor-paragraphs"/>
        </p:input>
    </p:store>
    
    
    <!-- start refactoring - fix up epipgraphs -->
    <p:xslt name="refactor-epigraphs" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="refactor-paragraphs"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/refactor-epigraphs.xsl"/>
        </p:input>
       
    </p:xslt>

    <p:store href="/tmp/converted-3.xml">
        <p:input port="source">
            <p:pipe port="result" step="refactor-epigraphs"/>
        </p:input>
    </p:store>
    
    
        <!-- continue refactoring - fix up lists -->
        <p:xslt name="refactor-lists" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="refactor-epigraphs"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-lists.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:store href="/tmp/converted-4.xml">
        <p:input port="source">
            <p:pipe port="result" step="refactor-lists"/>
        </p:input>
    </p:store>
    
    <!-- continue refactoring - build book info -->
    <p:xslt name="insert-book-info" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="refactor-lists"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/insert-chapters.xsl"/>
        </p:input>        
    </p:xslt>
    
    <p:store href="/tmp/converted-5.xml">
        <p:input port="source">
            <p:pipe port="result" step="insert-book-info"/>
        </p:input>
    </p:store>
   
    <!-- continue refactoring - insert chapters -->
    <p:xslt name="insert-chapters" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="insert-book-info"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/insert-chapters.xsl"/>
        </p:input>        
    </p:xslt>
    
    <p:store href="/tmp/converted-6.xml">
        <p:input port="source">
            <p:pipe port="result" step="insert-chapters"/>
        </p:input>
    </p:store>
    
    <!-- remove everything non docbook; done in xslt because it's a hassle
    to handle the sequence result otherwise -->
    <p:xslt name="filter-non-db" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="insert-chapters"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2"
                    xmlns:cword="http://www.corbas.co.uk/ns/word"
                    xmlns="http://docbook.org/ns/docbook"
                    xpath-default-namespace="http://docbook.org/ns/docbook"
                    exclude-result-prefixes="cword">
                    
                    <xsl:template match="cword:word-doc">
                        <xsl:apply-templates select="book"/>
                    </xsl:template>
                    
                    <xsl:template match="@cword:*"/>
                    
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    
                </xsl:stylesheet>
            </p:inline>
        </p:input>        
    </p:xslt>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="filter-non-db"/>
        </p:input>
    </p:identity>

</p:pipeline>
