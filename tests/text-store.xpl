<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:cs="http://www.corbas.net/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name='epub-file' required="true"/>
    
    <p:import href="../libs/ng-library.xpl"/>
    
    <!-- create a temporary file we can use to store the mimetype file -->
    <cxf:tempfile href="./" prefix='mimetype' suffix='.tmp' name="temp-mimetype"/>


    <!-- use an identity here because the oiutput from cfx:tempfile is not primary and 
        we want the context for the next step to use it so we can extract info from
        it with xpath -->
    <p:identity>
        <p:input port="source"><p:pipe port="result" step="temp-mimetype"/></p:input>
    </p:identity>
    
    <!-- get the file name and store the mimetype string to it -->
    <p:store method="text">
        <p:with-option name="href" select="//c:result"/>
        <p:input port="source">
            <p:inline><doc>application/epub+zip</doc></p:inline>
        </p:input>
    </p:store>
    
    <!-- create the zip manifest -->
    <p:xslt version="2.0" name='create-zip-manifest'>
        
        <p:input port="source">
            <p:pipe port="result" step="temp-mimetype"/>
        </p:input>
        
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">
                    
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

    <cx:zip>
        
        <p:input port="manifest">
            <p:pipe port="result" step="create-zip-manifest"/>
        </p:input>
        
        <p:with-option name="command" select="'create'"/>
        <p:with-option name="href" select="$epub-file"/>
        
    </cx:zip>
    

    
</p:declare-step>
