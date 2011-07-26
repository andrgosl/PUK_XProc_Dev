<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:cs="http://www.corbas.net/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:input port="source"/>
    <p:output port="result"/>

    <!-- name of the output EPUB -->
    <p:option name='epub-file' required="true"/>
    
    <!-- name that the package file is to be stored under. -->
    <p:option name="package-file-name" select="'package.opf'"/>
    
    <!-- name of the directory in which the package file (and other contents) should be stored -->
    <p:option name="content-dir" select="'OPS'"/>
    
    <p:import href="../libs/ng-library.xpl"/>
    

    <!-- create a temporary file we can use to store the mimetype file -->
    <cxf:tempfile href="./" prefix='mimetype' suffix='.tmp' name="temp-mimetype-file"/>

    <!-- use an identity here because the output from cfx:tempfile is not primary and 
        we want the context for the next step to use it so we can extract info from
        it with xpath -->
    <p:identity>
        <p:input port="source"><p:pipe port="result" step="temp-mimetype-file"/></p:input>
    </p:identity>
    
    
    
    <!-- get the file name and store the mimetype string to it -->
    <p:store method="text" >
        <p:with-option name="href" select="//c:result"/>
        <p:input port="source">
            <p:inline><doc>application/epub+zip</doc></p:inline>
        </p:input>
    </p:store>    
    
    <!-- Another one for the container.xml -->
    <cxf:tempfile href="./" prefix="container" suffix=".xml" name="temp-container-file"/>
    <p:identity name="temp-container">
        <p:input port="source"><p:pipe port="result" step="temp-container-file"/></p:input>
    </p:identity>
    
    <p:in-scope-names name="var-params"/>
    
    
    
    <!-- create the zip manifest -->
    <p:xslt version="2.0" name='create-initial-zip-manifest'>
        
        <p:input port="source">
            <p:pipe port="result" step="temp-mimetype"/>
        </p:input>
        
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">
                    
                    <xsl:param name='package-file'/>
                    
                    <xsl:template match="/">
                        <c:zip-manifest xml:base="/epub-root/">
                            <xsl:apply-templates/>
                        </c:zip-manifest>
                    </xsl:template>
                    
                    <xsl:template match="c:result">
                        <c:entry href="{.}" name="mimetype" compression-method="stored"/>
                    </xsl:template>
                    
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        
    </p:xslt>
    
    <cx:zip name="add-manifest">
        
        <p:input port="manifest">
            <p:pipe port="result" step="create-initial-zip-manifest"/>
        </p:input>
        
        <p:with-option name="command" select="'create'"/>
        <p:with-option name="href" select="$epub-file"/>
        
    </cx:zip>
    
    <p:sink/>
        
    <p:template name="construct-container">        
        <p:input port="source">
            <p:pipe step="var-params" port="result"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="template">
            <p:inline>
                <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
                    <rootfiles>
                        <rootfile full-path="{/c:param-set/c:param[@name='content-dir']/@value}/{/c:param-set/c:param[@name='package-file-name']/@value}" media-type="application/oebps-package+xml"/>
                    </rootfiles>
                </container>                      
            </p:inline>
        </p:input>        
    </p:template>
    
    <cx:zip name="add-container">
        
        <p:input port="source">
            <p:pipe port="result" step="construct-container"/>
        </p:input>
        
        <p:input port="manifest">
            <p:inline>
                <c:zip-manifest xml:base="/epub-root/">
                    <c:entry href="container.xml" name="META-INF/container.xml"/> 
                </c:zip-manifest>
            </p:inline>
        </p:input>
        
        <p:with-option name="command" select="'update'"/>
        <p:with-option name="href" select="$epub-file"/>
        
    </cx:zip>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="add-container"/>
        </p:input>
    </p:identity>
    
</p:declare-step>
