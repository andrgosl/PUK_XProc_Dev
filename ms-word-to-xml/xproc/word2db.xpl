<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:cword="http://www.corbas.co.uk/ns/word"
    name="wordToDocBook" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:db="http://docbook.org/ns/docbook" version="1.0"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:wprop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps">

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
                    <revision>
                        <revnumber>3</revnumber>
                        <date>2012-08-06</date>
                        <revremark>Added block quote refactoring code.</revremark>
                    </revision>
                    <revision>
                        <revnumber>5</revnumber>
                        <date>2012-08-23</date>
                        <revremark>Added code to handle dedications</revremark>
                    </revision>
                    <revision>
                        <revnumber>4</revnumber>
                        <date>2012-08-27</date>
                        <revremark>Updated to use ccproc:store-identity and added options to make it
                        simpler to use. Removed refactoring code to separate file for ease of maintenance.
                        Improved documentation.
                        </revremark>
                    </revision>
                </revhistory>
            </info>
            <para>XProc script to unzip a word docx document, extract metadata and convert to
                DocBook xml</para>
        </section>
    </p:documentation>

    <p:option name="package-url" required="true"/>
 
    <p:option name="log-step-output" select="'true'">
        <p:documentation>
            <p xmlns="http://www.w3.org/1999/xhtml">Controls whether or not the output of the each transformation
            stage is logged.</p>
        </p:documentation>
    </p:option>

    <p:option name="href-root" select="'/tmp/'">
        <p:documentation>
            <p xmlns="http://wwww.w3.org/1999/xhtml">Optional prefix for the stage logging path. Defaults to 
            <code>/tmp/</code>.</p>
        </p:documentation>
    </p:option>

    <p:import href="library-1.0.xpl"/>
    <p:import href="docx2xml.xpl"/>
    <p:import href="store-identity.xpl"/>
	<p:import href="stylesheet-runner.xpl"/>
    <p:import href="insert-db-structures.xpl"/>
    <p:import href="refactor-document.xpl"/>

    <!-- Extract docx file to a wrapped xml file -->
    <corbas:docx2xml name="extract-document">
        <p:with-option name="package-url" select="$package-url"/>
    </corbas:docx2xml>
    
    <!-- rewrite the numbering for lists to something more useable later -->   
	<ccproc:stylesheet-runner href="extracted.xml" name="store-extracted" stylesheet-href="../xsl/word-to-docbook/word-numbering.xsl">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:stylesheet-runner>
     
    <!-- convert word markup to docbook elements -->
	<ccproc:stylesheet-runner href="converted.xml" name="store-converted" stylesheet-href="../xsl/word-to-docbook/word-components.xsl">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>        
    </ccproc:stylesheet-runner>
    
    <!-- Refactor converted xml into something more like DocBook-->
    <corbas:refactor-document name="refactor">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="log-step-output" select="$log-step-output"/>        
    </corbas:refactor-document>
        
    <ccproc:store-identity href="refactored.xml" name="store-refactored">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>        
    </ccproc:store-identity>
    

    <!-- This step inserts DocBook structure -->
    <corbas:insert-db-structures name="build-db-structures">
    	<p:with-option name="href-root" select='$href-root'/>
    	<p:with-option name="log-step-output" select="$log-step-output"/>        
    </corbas:insert-db-structures>

    <ccproc:store-identity href="structured.xml" name="store-structured">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>        
    </ccproc:store-identity>
 
    <!-- remove everything non docbook; done in xslt because it's a hassle
    to handle the sequence result otherwise -->
	<ccproc:stylesheet-runner href="filtered.xml" name="insert-filtered" stylesheet-href="../xsl/word-to-docbook/strip-non-db.xsl">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>        
    </ccproc:stylesheet-runner>
	
   
    <!-- insert identifiers on any node which should have one and doesn't -->
   <p:xslt name="insert-identifiers" version="2.0">
    	<p:input port="source">
    		<p:pipe port="result" step="insert-filtered"/>
    	</p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-identifiers.xsl"/>
        </p:input>        
    </p:xslt>
	
	<p:identity>
		<p:input port="source">
			<p:pipe port="result" step="insert-identifiers"/>
		</p:input>
	</p:identity>

</p:pipeline>
