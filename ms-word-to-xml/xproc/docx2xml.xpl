<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" name="docx2xml"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:prop="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
    xmlns:rels="http://schemas.openxmlformats.org/package/2006/relationships" version="1.0"
     type="corbas:docx2xml"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc" xmlns:cword="http://www.corbas.co.uk/ns/cword">

    <p:documentation>
        <section xmlns="http://docbook.org/ns/docbook">
            <info>
                
                <title>docx2xml.xpl</title>
                <author><personname>Nic Gibson</personname></author>
                <revhistory>
                    <revision>
                        <revnumber>1</revnumber>
                        <date>2010-02-08</date>
                        <revremark>Initial Version</revremark>
                    </revision>
                    <revision>
                        <revnumber>2</revnumber>
                        <date>2010-03-19</date>
                        <revremark>Added support for loading and merging the document.xml.rels file
                            in order to access URLs for linked images.</revremark>
                    </revision>
                    <revision>
                        <revnumber>2</revnumber>
                        <date>2010-03-29</date>
                        <revremark>Added support for loading app.xml for document properties and
                            numbering.xml for list handling.</revremark>
                    </revision>
                    <revision>
                        <revnumber>3</revnumber>
                        <date>2010-04-11</date>
                        <revremark> Added support for footnote, endnote and styles files.
                        </revremark>
                    </revision>
                    <revision>
                        <revnumber>4</revnumber>
                        <date>2010-04-12</date>
                        <revremark> Added wrappers around all loaders to handle missing xml files.
                        </revremark>
                    </revision>
                    <revision>
                        <revnumber>5</revnumber>
                        <date>2012-05-12</date>
                        <revremark>Added core and app properties</revremark>
                    </revision>
                    <revision>
                        <revnumber>6</revnumber>
                        <date>2012-07-02</date>
                        <revremark>Added omitted relationships doc</revremark>
                    </revision>
                </revhistory>
            </info>
            <para>XProc script to unzip a word docx document, extract metadata and convert to
            DocBook xml</para>
            <para>Input is the url for the docx file supplied as an option named 'package-url'.</para>
        </section>
    </p:documentation>

    <p:output port="result" primary="true">
        <p:pipe port="result" step="the-end"/>
    </p:output>

    <p:option name="package-url" required="true"/>

    <p:import href="library-1.0.xpl"/>



    <p:declare-step name="get-doc-from-archive" type="corbas:get-doc-from-archive">

        <p:documentation>
            <section xmlns="http://docbook.org/ns/docbook">
                <title>corbas:get-doc-from-archive</title>
                <para>Step to extract a file from an archive and fall back to a default if not
                    found.</para>
            </section>
        </p:documentation>

        <p:input port="fallback" primary="false"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="extract-doc"/>
        </p:output>
        <p:option name="archive" required="true"/>
        <p:option name="doc" required="true"/>

        <p:try name="extract-doc">
            <p:group>
                <p:output port="result" primary="true">
                    <p:pipe port="result" step="use-output"/>
                </p:output>
                <cx:unzip name="get-zip-file">
                    <p:with-option name="href" select="$archive"/>
                    <p:with-option name="file" select="$doc"/>
                </cx:unzip>
                <p:identity name="use-output">
                    <p:input port="source">
                        <p:pipe port="result" step="get-zip-file"/>
                    </p:input>
                </p:identity>
            </p:group>
            <p:catch name="catch-error">
                <p:output port="result" primary="true">
                    <p:pipe port="result" step="use-fallback"/>
                </p:output>
            
             
                <p:identity name="use-fallback">
                    <p:input port="source">
                        <p:pipe port="fallback" step="get-doc-from-archive"/>
                    </p:input>
                </p:identity>
            </p:catch>
        </p:try>

    </p:declare-step>



    <corbas:get-doc-from-archive name="get-styles">
        <p:input port="fallback">
            <p:inline>
                <w:styles/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/styles.xml'"/>
    </corbas:get-doc-from-archive>
    
    <corbas:get-doc-from-archive name="get-endnotes">
        <p:input port="fallback">
            <p:inline>
                <w:endnotes/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/endnotes.xml'"/>
    </corbas:get-doc-from-archive>
    
    <corbas:get-doc-from-archive name="get-numbering">
        <p:input port="fallback">
            <p:inline>
                <w:numbering/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/numbering.xml'"/>
    </corbas:get-doc-from-archive>
    
    <corbas:get-doc-from-archive name="get-footnotes">
        <p:input port="fallback">
            <p:inline>
                <w:footnotes/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/footnotes.xml'"/>
    </corbas:get-doc-from-archive>
    
    <corbas:get-doc-from-archive name="get-doc">
        <p:input port="fallback">
            <p:inline>
                <w:document/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/document.xml'"/>
    </corbas:get-doc-from-archive>
    
    <corbas:get-doc-from-archive name="get-core-properties">
        <p:input port="fallback">
            <p:inline>
                <cp:coreProperties/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'docProps/core.xml'"/>
    </corbas:get-doc-from-archive>


    <corbas:get-doc-from-archive name="get-app-properties">
        <p:input port="fallback">
            <p:inline>
                <prop:Properties/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'docProps/app.xml'"/>
    </corbas:get-doc-from-archive>
    
    
    <corbas:get-doc-from-archive name="get-relationships">
        <p:input port="fallback">
            <p:inline>
                <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>
            </p:inline>
        </p:input>
        <p:with-option name="archive" select="$package-url"/>
        <p:with-option name="doc" select="'word/_rels/document.xml.rels'"/>
    </corbas:get-doc-from-archive>
    
    <p:identity name="create-sequence">
        <p:input port="source">
            <p:pipe port="result" step="get-doc"/>
            <p:pipe port="result" step="get-styles"/>
            <p:pipe port="result" step="get-numbering"/>
            <p:pipe port="result" step="get-footnotes"/>
            <p:pipe port="result" step="get-endnotes"/>
            <p:pipe port="result" step="get-app-properties"/>
            <p:pipe port="result" step="get-core-properties"/>
            <p:pipe port="result" step="get-relationships"/>
        </p:input>
    </p:identity>

    <p:wrap-sequence name="wrap-up" wrapper="word-doc"
        wrapper-namespace="http://www.corbas.co.uk/ns/word"/>

    <p:add-attribute name="insert-url" xmlns:cword="http://www.corbas.co.uk/ns/word"
        attribute-name="package-url" 
         match="/cword:word-doc">
        <p:with-option name="attribute-value" select="$package-url"/>
    </p:add-attribute>
    
    
    <p:identity name="the-end"/>


</p:declare-step>
