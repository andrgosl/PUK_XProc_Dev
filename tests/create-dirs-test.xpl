<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="opf-create-test-1">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="final"/>
    </p:output>
    
    
    <!-- name of the directory in which the content directory should be created -->
    <p:option name="root" select="'.'"/>
    
    <!-- metadata filenames --> 
    <p:option name="package-file" select="'package.opf'"/>
    <p:option name="daisy-file" select="'toc.ncx'"/>
    
    <!-- main content directory -->
    <p:option name="content-dir-name" select="'OPS'"/>
    
    <!-- names of various content locations -->
    <p:option name="images-dir-name" select="'images'"/>
    <p:option name="xhtml-dir-name" select="'xhtml'"/>
    <p:option name="styles-dir-name" select="'styles'"/>
    <p:option name="fonts-dir-name" select="'fonts'"/>
    <p:option name="media-dir-name" select="'media'"/>
    
    <p:import href="../libs/create-epub-library.xpl"/>
    
    <!-- create the paths -->
    <epub:create-paths>
        <p:with-option name="base-path" select="$root"/>
        <p:with-option name="content-dir-name" select="$content-dir-name"/>
        <p:with-option name="xhtml-dir-name" select="$xhtml-dir-name"/>
        <p:with-option name="styles-dir-name" select="$styles-dir-name"/>
        <p:with-option name="images-dir-name" select="$images-dir-name"/>
    </epub:create-paths>
    
    <p:identity name="final">
        <p:input port="source">
            <p:inline><dummy/></p:inline>
        </p:input>
    </p:identity>
    
    
</p:declare-step>