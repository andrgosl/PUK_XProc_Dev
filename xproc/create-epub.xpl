<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:cstep="http://www.corbas.net/ns/xproc" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:corbas="http://www.corbas.net/ns/tempns" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" name="create-epub">


    <p:input port="source"/>
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
    <p:option name="image-dir-name" select="'images'"/>
    <p:option name="xhtml-dir-name" select="'xhtml'"/>
    <p:option name="css-dir-name" select="'styles'"/>
    <p:option name="font-dir-name" select="'fonts'"/>
    <p:option name="media-dir-name" select="'media'"/>

    <p:import href="../libs/ng-library.xpl"/>
    <p:import href="../libs/pstd-library.xpl"/>
    <p:import href="../libs/create-epub-library.xpl"/>

    <!-- set up some paths -->
    <p:variable name="opf-path" select="concat($root, '/',  $content-dir-name, '/', $package-file)"/>
    <p:variable name="ncx-path" select="concat($root, '/', $content-dir-name, '/', $daisy-file)"/>
    <p:variable name="xhtml-path" select="concat($root, '/', $content-dir-name,'/', $xhtml-dir-name)"/>
    <p:variable name="css-path" select="concat($root, '/', $content-dir-name,'/', $css-dir-name)"/>
    
    <!-- set up base URLs for relative access to images and css from HTML -->
    <p:variable name="css-uri-base" select="concat('../', $css-dir-name)"/>
    <p:variable name="image-uri-base" select="concat('../', $image-dir-name)"/>
    
    
    <!-- start by creating the paths -->
    <epub:create-paths>
        <p:with-option name="base-path" select="$root"/>
        <p:with-option name="content-dir-name" select="$content-dir-name"/>
        <p:with-option name="xhtml-dir-name" select="$xhtml-dir-nane"/>
        <p:with-option name="styles-dir-name" select="$styles-dir-name"/>
        <p:with-option name="images-dir-name" select="$images-dir-name"/>
    </epub:create-paths>
    
    
   

    <!-- metadata files -->
    <epub:create-opf name="create-opf">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="href" select="$opf-path"/>
    </epub:create-opf>


    <epub:create-ncx name="create-ncx">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="href" select="$ncx-path"/>
        <p:with-option name="xhtml-dir-name" select='$xhtml-dir-name'/>
    </epub:create-ncx>

<!--
    <epub:generate-html name="generate-final-html">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
    </epub:generate-html>


    <p:identity name="final">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </p:identity>
-->
</p:declare-step>
