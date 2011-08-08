<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
    
    <!-- 
        Steps for epub creation (unpackaged) 
        Create on-disk structures
        Copy the CSSS to css directory (keep a list of CSS files to add to HTML)
        Copy the images to images directory
        Generate the XSLT driven content
        Generate any other content
            title page
            cover page
            imprint page
        Copy any boilerplate files provided        
        Create the OPF file
        Create the NCX file  
    -->
    
    
    <p:import href="ng-library.xpl"/>

    <p:declare-step name="get-chunk-hierarchy" type="epub:get-chunk-hierarchy">

        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Uses the fast chunk stylesheet from the DocBook XSLT to generate the list of
                    chunks. This stylesheet overrides the default class.attribute method in order to
                    add a new attribute to the output that contains the original ID of the chunk
                    element. We need to do this because we are not running in a single
                    transformation so generate-id() is not guaranteed to give us the same id
                    attributes next time the script runs.</p>
                <p>Bob Stayton pointed out that this is the best method.</p>
                <h2>Input</h2>
                <p>The input is the source XML file</p>
                <h2>Output</h2>
                <p>The output is a cf:div element containing the chunk elements.</p>
            </div>
        </p:documentation>

        <p:input port="source"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="docbook-hierarchy"/>
        </p:output>

        <p:xslt version="1.0" name="docbook-hierarchy">
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/docbook-chunk-hierarchy.xslt"/>
            </p:input>

            <p:input port="parameters">
                <p:empty/>
            </p:input>

            <p:input port="source">
                <p:pipe port="source" step="get-chunk-hierarchy"/>
            </p:input>

        </p:xslt>

    </p:declare-step>

    <p:declare-step name='copy-images' type="epub:copy-images">

        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Searches for all imagedata elements with fileref attributes and copies
                the files to the images directory (given by the 'image-target' option).
                If any errors occur, fails with a fatal error.</p>
            </div>
            <h2>Input</h2>
            <p>XML source file</p>
            <h2>Outputs</h2>
            <p>A c:result-set document containing the resulting paths</p>
            <h2>Options</h2>            
            <dl>
                <dt>image-source</dt>
                <dd>Directory in which the source images are to be found.</dd>
                <dt>image-target</dt>
                <dd>Directory to which image files should be copied. Bear in mind
                that there may be a path as part of the fileref attribute on input.</dd>
            </dl>
        </p:documentation>
        
        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="combine-results"/>
        </p:output>
        
        <p:option name='image-source' required="true"/>
        <p:option name="image-target" required="true"/>
        
        <p:for-each name="process-images">
            
            <p:iteration-source select="//db:imagedata[@fileref]">
                <p:pipe  port="source" step="copy-images"/>
            </p:iteration-source>
            
            <p:output port="image-result">
                <p:pipe port="result" step="copy-image"/>
            </p:output>
            
            
            <cxf:copy name="copy-image">
                <p:with-option name="href" select="p:resolve-uri(/db:imagedata/@fileref, $image-source)"/>
                <p:with-option name="target" select="$image-target"/>
            </cxf:copy>
                        
            
        </p:for-each>
        
        <p:wrap-sequence name="combine-results" wrapper="c:result-set">
            <p:input port="source">
                <p:pipe port="image-result" step="process-images"/>
            </p:input>
        </p:wrap-sequence>
        
        
    </p:declare-step>
        
    <p:declare-step name="create-ncx" type="epub:create-ncx">
        
        <p:input port="source" primary="true"/>
        
        <p:option name="href" required="true"/>
        <p:option name="xhtml-dir-name" required="true"/>
        
        <!-- generate the NCX file -->
        <p:xslt name="convert-ncx">
            
            <p:with-param name="xhtml-dir" select="$xhtml-dir-name"/>
            
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/create-ncx.xslt"/>
            </p:input>
        </p:xslt>
        
        <!-- add the play order to it -->
        <p:xslt name="sequence-ncx">
            
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="playorder.xslt"/>
            </p:input>
        </p:xslt>
        
        <p:store name="store-toc">
            <p:with-option name="href" select="$href"/>
            <p:input port="source">
                <p:pipe port="result" step="sequence-ncx"/>
            </p:input>
        </p:store>
        
    </p:declare-step>

</p:library>
