<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:temp="http://wwww.corbas.co.uk/ns/temp"
    name="wordToDocBook" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:db="http://docbook.org/ns/docbook" version='1.0'
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:wprop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties">

    <p:documentation>
        <section xmlns="http://docbook.org/ns/docbook">
            <info>
                <title>word2db.xp</title>
                <author><personname>Nic Gibson</personname></author> <revhistory
                    xmlns="http://docbook.org/ns/docbook">
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
                </revhistory> </info>
            <para>XProc script to unzip a word docx document, extract metadata and convert to
                DocBook xml</para>
        </section>
    </p:documentation>

    <p:option name="package-url" required="true"/>

    <p:import href="library-1.0.xpl"/>
    <p:import href="docx2xml.xpl"/>
    
    <corbas:docx2xml>
        <p:with-option name="package-url" select="$package-url"/>
    </corbas:docx2xml>
    
 
    <p:xslt name="normalise-doc" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="get-doc"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-components.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="move-graphics" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="normalise-doc"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-graphics.xsl"/>
        </p:input>
    </p:xslt>


    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="get-meta"/>            
            <p:pipe port="result" step="get-rels"/>
            <p:pipe port="result" step="get-app"/>
            <p:pipe port="result" step="get-numbering"/>
            <p:pipe port="result" step="move-graphics"/>
        </p:input>
    </p:identity>

    <p:wrap-sequence wrapper="docfiles"/>

 


</p:pipeline>
