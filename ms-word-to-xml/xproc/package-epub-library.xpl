<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:documentation>
            <h:p>This module can be used to generate an EPUB zip file from the ouput of an XSLT
            transformation. It works on the files generated from transforming XML to HTMl and the
            various manifest files for EPUB. There is an assumption that no further transformation
            is required and that the files on disk fully represent the final EPUB.</h:p>
            <h:h2>External options used by steps in this module.</h:h2>
            <h:h3>epub-path</h:h3>
            <h:p>This is the full file URL for the epub file. .</h:p>
            <h:h3>content-dir</h:h3>
            <h:p>This is the directory to which all content (including the OPF file) is written in the
                EPUB zip file.</h:p>
            <h:h2>xml:base</h:h2>
            <h:p>It is important to ensure a meaningful xml:base for the package file that allows the
                content files referred to be located. If the package file is generated by an earlier
                step it might be necessary to set one manually on the root element of the package.
                In order to keep EPUB processing sane any xml:base attribute on the root of the
                package file is stripped off before it is written to the EPUB file.</h:p>
    </p:documentation>


    <p:import href="ng-library.xpl"/>
    

    <p:declare-step name="write-mimetype" type="epub:write-mimetype">

        <p:documentation>
                <h:p>Writes the mimetype file to disk. The only information required is the directory
                    to which it should be written. Returns a <code>c:result</code> element that
                    gives the full url for the file. </h:p>
            <h:p>The file is written to a temp file that is removed on script exit.</h:p>
            <h:p>The step has no inputs.</h:p>
        </p:documentation>

        <p:output port="result" primary="true">
            <p:documentation>
                <h:p>The output for the write-mimetype step is a c:result
                    element containing the URL pointing to the temporary file to 
                    written. It doesn't try to write it to the directory containing
                    the package file as this may not be possible.</h:p>
            </p:documentation>
            <p:pipe port="result" step="store-mimetype"/>
        </p:output>

        <cxf:tempfile href="./" prefix="mimetype" suffix=".tmp" name="temp-mimetype-file"
            delete-on-exit="true">
            <p:documentation><h:p>Create a temporary file we can use to store the mimetype file</h:p></p:documentation>
        </cxf:tempfile>

        <p:identity name="make-tempfile-primary">
            
            <p:documentation>
                    <h:p>Use an identity here because the output from cfx:tempfile is not primary and 
                        we want the context for the next step to use it so we can extract info from
                        it with xpath</h:p>
            </p:documentation>
            
            <p:input port="source">
                <p:pipe port="result" step="temp-mimetype-file"/>
            </p:input>
            
        </p:identity>

        <!-- get the file name and store the mimetype string to it -->
        <p:store method="text" name="store-mimetype">
            <p:documentation>
                    <h:p>Write out the mimetype file to disk. The value of the
                    c:result from the temporary file creation is used as the
                    URL. Result of this is a c:result containing the URL which
                    becomes the step output.</h:p>
            </p:documentation>
            <p:with-option name="href" select="//c:result"/>
            <p:input port="source">
                <p:inline><doc>application/epub+zip</doc></p:inline>
            </p:input>
        </p:store>

    </p:declare-step>

    <p:declare-step name="write-container" type="epub:write-container">

        <p:output port="result" primary="true">
            <p:documentation>
                <h:p>The result of the step is a c:result element containing the
                URL pointing to the temporary file containing the container file.</h:p> 
            </p:documentation>
            <p:pipe port="result" step="store-container"/>
        </p:output>

        <p:documentation>
                <h:p>Writes the container.xml file to disk.</h:p>
                <h:p>The file is written to a temp file that is removed on script exit. Returns a
                        <h:code>c:result</h:code> element containing the URL pointing to the file.</h:p>
        </p:documentation>

        <p:option name="opf-uri" select="'OPS/package.opf'">
            <p:documentation>
                <h:p>The relative URI from the root of the zip file to the package file. This is
                    stored in the <code>container.xml</code> file. This defaults to
                    <h:code>OPS/package.opf</h:code>.</h:p>
            </p:documentation>
        </p:option>
        
        
        <p:in-scope-names name="vars"/>
        
        <p:template name="container-xml">
            <p:documentation>
                    <h:p>The template step inserts the name of the
                    OPF file into the full-path attribute of </h:p>
            </p:documentation>
            <p:input port="source"><p:empty/></p:input>
            <p:input port='template'>
<p:inline>                <container version="1.0"
                    xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
                    <rootfiles>
                        <rootfile full-path="{$opf-uri}"
                            media-type="application/oebps-package+xml"/>
                    </rootfiles>
                </container>
</p:inline>            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        
        <cxf:tempfile href="./" prefix="container" suffix=".xml" name="temp-container-file"
            delete-on-exit="true">
            <p:documentation>
                <h:p>Creates a temporary file we can use to store the container file.</h:p>
            </p:documentation>
        </cxf:tempfile>


        <p:identity name="container-identity">
            <p:documentation>
                <h:p>Use an identity here because the output from cfx:tempfile is not primary and 
                    we want the context for the next step to use it so we can extract info from
                    it with xpath</h:p>
            </p:documentation>
            <p:input port="source">
                <p:pipe port="result" step="temp-container-file"/>
            </p:input>
        </p:identity>


        <!-- get the file name and store the mimetype string to it -->
        <p:store method="xml" name="store-container">
            <p:documentation>
                <h:p>Write out the container file to disk. The value of the
                    c:result from the temporary file creation is used as the
                    URL. Result of this is a c:result containing the URL which
                    becomes the step output.</h:p>
            </p:documentation>            
            <p:with-option name="href" select="//c:result"/>
            <p:input port="source">
                <p:pipe port="result" step="container-xml"/>
            </p:input>
        </p:store>

    </p:declare-step>

    <p:declare-step name="init-epub" type="epub:init-epub">
        <p:documentation>
                <h:p>Initialises the initial the EPUB structure. Writes the 
                        <h:code>mimetype</h:code> file and <h:code>META-INF/container.xml</h:code> file
                    only and returns a sequence containing them.</h:p>
        </p:documentation>

        <p:output port="result" primary="true" sequence="true">
            <p:pipe port="result" step="gather-results"/>
        </p:output>

        <p:option name="opf-uri" select="'OPS/package.opf'">
            <p:documentation><h:p>Relative url for the OPF file, defaults to <h:code>OPS/package.opf</h:code></h:p></p:documentation>
        </p:option>
        
        <epub:write-mimetype name="temp-mimetype"/>
        <epub:write-container name="temp-container">
            <p:with-option name="opf-uri" select="$opf-uri"/>
        </epub:write-container>

        <p:identity name="gather-results">
            <p:input port="source">
                <p:pipe port="result" step="temp-mimetype"/>
                <p:pipe port="result" step="temp-container"/>
            </p:input>
        </p:identity>
 
    </p:declare-step>

    <p:declare-step name="convert-opf-to-zip-manifest" type="epub:convert-opf-to-zip-manifest">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Given an OPF document, takes the manifest section of the file and converts it to
                    a zip file manifest. The file name is resolved to an absolute url for the
                        <code>href</code> attribute of the manifest and the prefix is prepended to
                    create the <code>name</code> attribute.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true">
            <p:documentation>
                <h:p>The OPF file to be converted to a manifest.</h:p>
            </p:documentation>
        </p:input>
        
        <p:output port="result" primary="true">
            <p:documentation>
                <h:p>The result of the step is a c:zip-manifest element.</h:p>
            </p:documentation>
            <p:pipe port="result" step="transform-manifest"/>
        </p:output>

        <p:option name="content-dir" required="true">
            <p:documentation><h:p>The prefix to prepend to the manifest href to create the name attribute. OPF
                manifests are relative to the OPF file whils the zip manifest must be
                relative to EPUB root.</h:p></p:documentation>
        </p:option>
        <p:option name="opf-uri" required="true">
            <p:documentation><h:p>The URI for the package file itself is required in order to
            add it to the zipe file as the package file is not self-referential.</h:p></p:documentation>
        </p:option>

        <p:xslt version="2.0" name="transform-manifest">
            
            <p:documentation>
                <h:p>Convert the epub manifest to a zip manifest, setting the xml:base so that files are
                    found in the right locations. In order to have a meaningful xml:base it must have
                either been set explicitly at some point or the OPF file must actually exist 
                on disk.</h:p>
            </p:documentation>

            <p:with-param name="content-dir" select="$content-dir"/>
            <p:with-param name="opf-uri" select="$opf-uri"/>

            <p:input port="source">
                <p:pipe port="source" step="convert-opf-to-zip-manifest"/>
            </p:input>

            <p:input port="parameters">
                <p:empty/>
            </p:input>

            <p:input port="stylesheet">

                <p:inline>
                    <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:opf="http://www.idpf.org/2007/opf"
                        xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

                        <xsl:param name="content-dir"/>
                        <xsl:param name="opf-uri"/>

                        <xsl:template match="/">
                            <xsl:apply-templates select="/opf:package/opf:manifest"/>
                        </xsl:template>

                        <xsl:template match="opf:manifest">
                            <c:zip-manifest xml:base="{base-uri(.)}">
                                <c:entry href="{base-uri(.)}" name="{$opf-uri}"/>                                
                                <xsl:apply-templates/>
                            </c:zip-manifest>
                        </xsl:template>

                        <xsl:template match="opf:item">
                            <xsl:variable name="path" select="concat($content-dir, '/', @href)"/>
                            <c:entry href="{@href}" name="{$path}"/>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>

    </p:declare-step>

    <p:declare-step name="convert-result-to-entry" type="epub:convert-result-to-entry">
        
        <p:documentation>
            <h:p>Given a c:result entry as source, creates a c:entry element suitable for 
            adding to a zip manifest. </h:p>
        </p:documentation>
        
        <p:input port="source" primary="true">
            <p:documentation>
                <h:p>The input should hold a single c:result element</h:p>
            </p:documentation>
        </p:input>
        
        <p:output port="result" primary="true">
            <p:documentation>
                <h:p>The output will be a single c:entry element.</h:p>
            </p:documentation>
            <p:pipe port="result" step="create-result"/>
        </p:output>
        
        <p:option name="compression" select="'deflated'">
            <p:documentation>
                <h:p>Set the compression level to be used. Defaults to <h:code>deflated</h:code></h:p>
            </p:documentation>
        </p:option>
        
        <p:option name="name" required="true">
            <p:documentation>
                <h:p>Defines the path under which the file should be stored in the zip file.</h:p>
            </p:documentation>
        </p:option>
        
        <p:in-scope-names name="vars"/>
        
        <p:template name="create-result">
            <p:input port="source">
                <p:pipe port="source" step="convert-result-to-entry"/>
            </p:input>
            <p:input port='template'>
                <p:inline><c:entry name="{$name}" compression-method="{$compression}" href="{//c:result}" /></p:inline>                 
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        
        
    </p:declare-step>

    <p:declare-step name="package-epub" type="epub:package-epub">
        <p:documentation>
                <h:p>Given an input of an OPF file, creates an EPUB file. The caller must
                provide the path to the EPUB file and the name of the directory into which
                content must be stored.</h:p>
        </p:documentation>
        
        <p:input port="source" primary="true">
            <p:documentation>
                <h:p>The source for the step must be an OPF file</h:p>
            </p:documentation>
        </p:input>
        <p:output port="result" primary="true">
            <p:documentation>
                <h:p>The result of the step is a cx:zip-result element describing
                the zipe file created.</h:p>
            </p:documentation>
            <p:pipe port="result" step="package-epub-result"/>
        </p:output>
        
        <p:option name="content-dir" select="'OPS'">
            <p:documentation>
                <h:p>Name of the directory into which all content (including the OPF file)
                    will be stored in the zip file. Defaults to <h:code>OPS</h:code>.</h:p>
            </p:documentation>
        </p:option>
        
        <p:option name="package-file" select="'package.opf'">
           <p:documentation><h:p> The file name for the package file. Defaults to <h:code>package.opf</h:code></h:p></p:documentation>
        </p:option>
        
        <p:option name="epub-path"  required="true">
            <p:documentation><h:p>The full path to the epub-file to be created.</h:p>></p:documentation>
        </p:option>
    
        <p:variable name="opf-uri" select="concat($content-dir, '/', $package-file)"/>
        <p:variable name="opf-base" select="p:base-uri()"/>
    
        <epub:write-mimetype name="temp-mimetype"/>
        <epub:write-container name="temp-container">
            <p:with-option name="opf-uri" select="$opf-uri"/>
        </epub:write-container>
        
        <epub:convert-opf-to-zip-manifest name='create-content-manifest'>
            <p:input port="source">
                <p:pipe port="source" step="package-epub"/>
            </p:input>
            <p:with-option name="content-dir" select="$content-dir"/>
            <p:with-option name="opf-uri" select="$opf-uri"/>
        </epub:convert-opf-to-zip-manifest>
        
        <epub:convert-result-to-entry name="convert-container">
            <p:input port="source">
                <p:pipe port="result" step="temp-container"/>
             </p:input>            
            <p:with-option name="name" select="'META-INF/container.xml'"/>
        </epub:convert-result-to-entry>

        <p:insert name="insert-container" position="first-child" match="/c:zip-manifest">
            <p:documentation>
                <h:p>Insert the mimetype file into the zip manifest.</h:p>
            </p:documentation>
            <p:input port="source">
                <p:pipe port="result" step="create-content-manifest"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe  step="convert-container" port="result"/>
            </p:input>
        </p:insert>
        
        <epub:convert-result-to-entry name="convert-mimetype">
            <p:input port="source">
                <p:pipe port="result" step="temp-mimetype"/>
            </p:input>            
            <p:with-option name="compression" select="'stored'"/>
            <p:with-option name="name" select="'mimetype'"/>
        </epub:convert-result-to-entry>
        
        <p:insert name="insert-mimetype" position="first-child" match="/c:zip-manifest">
            <p:documentation>
                <h:p>Insert the mimetype file into the zip manifest.</h:p>
            </p:documentation>
            <p:input port="source">
                <p:pipe port="result" step="insert-container"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe  step="convert-mimetype" port="result"/>
            </p:input>
        </p:insert>
        

        
        <!-- now add all the other content to the zip file -->
        <cx:zip name="insert-content">            
            <p:input port="source">
               <p:pipe port="source" step="package-epub"/>
            </p:input>
            <p:input port="manifest">
                <p:pipe port="result" step="insert-mimetype"/>
            </p:input>
            <p:with-option name="href" select="$epub-path"/>
            <p:with-option name="command" select="'create'"/>
            </cx:zip>
        
        <p:sink/>
        
        <p:identity name='package-epub-result'>
            <p:input port="source">
                <p:pipe port="result" step="insert-mimetype"/>
            </p:input>
        </p:identity>
        
        
    </p:declare-step>


</p:library>
