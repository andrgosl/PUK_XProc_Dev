<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <!-- 
        Steps for epub creation (unpackaged) 
        Create on-disk structures
        Copy the CSS to css directory (keep a list of CSS files to add to HTML)
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

    <p:declare-step name="copy-css" type="epub:copy-css">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Given a directory or a single file, copies the CSS to the EPUB styles directory
                    and returns a list of CSS files in a c:result-set element. The bare file names
                    are returned not the paths. </p>
                <h3>Options</h3>
                <dl>
                    <dt>css-source</dt>
                    <dd>Either a directory containing CSS files or a single CSS file.</dd>
                </dl>
                <dl>
                    <dt>css-target</dt>
                    <dd>The path to which the CSS files should be written.</dd>
                </dl>
                <h3>Results</h3>
                <p>A singe c:result-set element containing a c:result for each file copied.</p>
            </div>
        </p:documentation>

        <p:output port="result">
            <p:pipe step="wrap-files" port="css-files"/>
        </p:output>

        <p:option name="css-source" required="true"/>
        <p:option name="css-target" required="true"/>

        <!-- work out if we have a file or a directory -->
        <cxf:info name="check-type">
            <p:with-option name="href" select="$css-source"/>
        </cxf:info>

        <!-- problem cause by not knowing if there are any files -->
        <p:choose name="wrap-files">

            <p:xpath-context>
                <p:pipe port="result" step="check-type"/>
            </p:xpath-context>

            <p:when test="/c:directory">

                <p:output port="css-files" primary="true">
                    <p:pipe port="result" step="copy-multiple-css-files"/>
                </p:output>

                <epub:copy-multiple-css name="copy-multiple-css-files">
                    <p:with-option name="source-dir" select="$css-source"/>
                    <p:with-option name="target-dir" select="$css-target"/>
                </epub:copy-multiple-css>


            </p:when>

            <p:otherwise>

                <p:output port="css-files" primary="true">
                    <p:pipe port="result" step="copy-single-css-file"/>
                </p:output>

                <epub:copy-single-css name="copy-single-css-file">
                    <p:with-option name="source-file" select="$css-source"/>
                    <p:with-option name="target-dir" select="$css-target"/>
                </epub:copy-single-css>

            </p:otherwise>
        </p:choose>

    </p:declare-step>

    <p:declare-step name="copy-single-css" type="epub:copy-single-css">

        <p:option name="source-file"/>
        <p:option name="target-dir"/>

        <p:output port="result" primary="true">
            <p:pipe port="result" step="transform-css-file"/>
        </p:output>

        <cx:message name="source-file">
            <p:with-option name="message" select="$source-file"/>
            <p:input port="source">
                <p:empty/>
            </p:input>
        </cx:message>

        <cxf:copy name="copier">
            <p:with-option name="href" select="$source-file"/>
            <p:with-option name="target" select="$target-dir"/>
        </cxf:copy>

        <p:xslt version="2.0" name="transform-css-file">

            <p:with-param name="path" select="$source-file"/>

            <p:input port="parameters">
                <p:empty/>
            </p:input>

            <p:input port="source">
                <p:inline>
                    <dummy/>
                </p:inline>
            </p:input>

            <p:input port="stylesheet">

                <p:inline>

                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

                        <xsl:param name="path"/>

                        <xsl:template match="/">
                            <c:result-set>

                                <xsl:choose>
                                    <xsl:when test="matches($path, '/[^/]+\.css$')">
                                        <xsl:analyze-string select="$path" regex="/([^/]+\.css)$">
                                            <xsl:matching-substring>
                                                <c:result><xsl:value-of select="regex-group(1)"/></c:result>
                                            </xsl:matching-substring>                                    
                                        </xsl:analyze-string>                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <c:result><xsl:value-of select="$path"/></c:result>
                                    </xsl:otherwise>                                    
                                </xsl:choose>

                            </c:result-set>
                        </xsl:template>

                    </xsl:stylesheet>

                </p:inline>

            </p:input>

        </p:xslt>

    </p:declare-step>

    <p:declare-step name="copy-multiple-css" type="epub:copy-multiple-css">

        <p:option name="source-dir" required="true"/>
        <p:option name="target-dir" required="true"/>

        <p:output port="result" primary="true">
            <p:pipe port="result" step="transform-css-list"/>
        </p:output>

        <cx:message name="source-dir">
            <p:input port="source">
                <p:empty/>
            </p:input>
            <p:with-option name="message" select="$source-dir"/>
        </cx:message>

        <p:directory-list name="list-css-files">
            <p:with-option name="path" select="$source-dir"/>
        </p:directory-list>

        <p:store href="/tmp/test.xml" method="xml">
            <p:input port="source">
                <p:pipe step="list-css-files" port="result"> </p:pipe>
            </p:input>

        </p:store>
        

        <p:for-each name="process-css-files">

            <p:iteration-source select="//c:file">
                <p:pipe port="result" step="list-css-files"/>
            </p:iteration-source>
            
            <p:variable name="filename" select="/c:file/@name"/>
            
            <cx:message>
                <p:input port="source">
                    <p:empty/>
                </p:input>
                <p:with-option name="message" select="$filename"/>
            </cx:message>

            <cxf:copy name="copy-css-file">
                <p:with-option name="href" select="p:resolve-uri($filename, $source-dir)"/>
                <p:with-option name="target" select="$target-dir"/>
            </cxf:copy>

        </p:for-each>

        <p:xslt version="2.0" name="transform-css-list">
            <p:input port="source">
                <p:pipe port="result" step="list-css-files"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

                        <xsl:template match="/">
                            <c:result-set>
                                <xsl:apply-templates/>
                            </c:result-set>
                        </xsl:template>

                        <xsl:template match="c:directory">
                            <xsl:apply-templates/>
                        </xsl:template>

                        <xsl:template match="c:file">
                            <c:result><xsl:apply-templates select="@name"/></c:result>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>


    </p:declare-step>

    <p:declare-step name="copy-images" type="epub:copy-images">

        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Searches for all imagedata elements with fileref attributes and copies the files
                    to the images directory (given by the 'image-target' option). If any errors
                    occur, fails with a fatal error.</p>
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
                <dd>Directory to which image files should be copied. Bear in mind that there may be
                    a path as part of the fileref attribute on input.</dd>
            </dl>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="combine-results"/>
        </p:output>

        <p:option name="image-source" required="true"/>
        <p:option name="image-target" required="true"/>

        <p:for-each name="process-images">

            <p:iteration-source select="//db:imagedata[@fileref]">
                <p:pipe port="source" step="copy-images"/>
            </p:iteration-source>

            <p:output port="image-result">
                <p:pipe port="result" step="copy-image"/>
            </p:output>


            <cxf:copy name="copy-image">
                <p:with-option name="href"
                    select="p:resolve-uri(/db:imagedata/@fileref, $image-source)"/>
                <p:with-option name="target" select="$image-target"/>
            </cxf:copy>


        </p:for-each>

        <p:wrap-sequence name="combine-results" wrapper="c:result-set">
            <p:input port="source">
                <p:pipe port="image-result" step="process-images"/>
            </p:input>
        </p:wrap-sequence>


    </p:declare-step>

    <p:declare-step name="create-paths" type="epub:create-paths">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Creates the basic directory structure. Not strictly necessary but useful because
                some extension steps seem to create paths if non-existant and others don't.</p>
                <p><strong>Warning</strong> - this may not be totally reliable - XProc slightly
                immature here.</p>
            </div>
        </p:documentation>
        
        <p:option name='base-path' required="true"/>
        <p:option name="content-dir-name" required="true"/>
        <p:option name="xhtml-dir-name" required="true"/>
        <p:option name="styles-dir-name" required="true"/>
        <p:option name="images-dir-name" required="true"/>
        
        <p:variable name="xhtml-path" select="concat($base-path, '/', $content-dir-name, '/', $xhtml-dir-name)"/>
        <p:variable name="css-path" select="concat($base-path, '/', $content-dir-name, '/', $styles-dir-name)"/>
        <p:variable name="img-path" select="concat($base-path, '/', $content-dir-name, '/', $images-dir-name)"/>
 
        <cx:message name="source-file">
            <p:with-option name="message" select="$xhtml-path"/>
            <p:input port="source">
                <p:empty/>
            </p:input>
        </cx:message>
        <cxf:mkdir>
            <p:with-option name="href" select="$xhtml-path"/>
        </cxf:mkdir> 
            
        <cxf:mkdir>
            <p:with-option name="href" select="concat($base-path, '/', $content-dir-name, '/', $styles-dir-name)"/>
        </cxf:mkdir>         
    
        <cxf:mkdir>
            <p:with-option name="href" select="concat($base-path, '/', $content-dir-name, '/', $images-dir-name)"/>
        </cxf:mkdir>       
          
    </p:declare-step>

    <p:declare-step name="create-ncx" type="epub:create-ncx">

        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>The create-ncx step generates the NCX file from the XML and stores it, returning
                    the URI of the stored file.</p>
                <h3>Inputs</h3>
                <dl>
                    <dt>href</dt>
                    <dd>URI to which the NCX file is to be written.</dd>
                </dl>
                <h3>Parameters</h3>
                <p>See create-ncx.xslt</p>
                <h3>Outputs</h3>
                <p>The result port (not primary) returns a c:result containing the URI to which the
                    file was written</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result">
            <p:pipe step="store-toc" port="result"/>
        </p:output>
        
        <p:option name="href" required="true"/>
        <p:option name="xhtml-dir-name" required="true"/>

        <!-- generate the NCX file -->
        <p:xslt name="convert-ncx">

            <p:input port="parameters">
                <p:empty/>
            </p:input>

            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/create-ncx.xslt"/>
            </p:input>

        </p:xslt>

        <!-- add the play order to it -->
        <p:xslt name="sequence-ncx">
            
            <p:with-param name="xhtml-dir" select="$xhtml-dir-name"/>

            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/playorder.xslt"/>
            </p:input>
        </p:xslt>

        <p:store name="store-toc">
            <p:with-option name="href" select="$href"/>
            <p:input port="source">
                <p:pipe port="result" step="sequence-ncx"/>
            </p:input>
        </p:store>

    </p:declare-step>
    
    <p:declare-step name="create-opf" type="epub:create-opf">
        
        <p:input port="source" primary="true"/>
        <p:option name="href" required="true"/>
        
        <p:xslt name="convert-opf">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/create-opf.xslt"/>
            </p:input>
        </p:xslt>
                
        <p:store name="store-opf" encoding="UTF-8" omit-xml-declaration="false" indent="true">
            <p:with-option name="href" select="$href"/>
            <p:input port="source">
                <p:pipe port="result" step="convert-opf"/>
            </p:input>
        </p:store>
        
    </p:declare-step>

</p:library>
