<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="create-and-copy-test">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="final"/>
    </p:output>
    
    
    <!-- name of the directory in which the content directory should be created -->
    <p:option name="root" select="'.'"/>
    
    <!-- path separator. should be able to get this via cxo:info but I can't see
    a useful way to use it -->
    <p:option name="path-sep" select="'/'"/>
    
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
    
    <!-- CSS source location -->
    <p:option name="css-source" required="true"/>
    
    <!-- root of image storage -->
    <p:option name="image-root" required="true"/>
    
    
    
    <p:import href="../libs/create-epub-library.xpl"/>

    <!-- create the paths -->
    <epub:create-paths>
        <p:with-option name="base-path" select="$root"/>
        <p:with-option name="content-dir-name" select="$content-dir-name"/>
        <p:with-option name="xhtml-dir-name" select="$xhtml-dir-name"/>
        <p:with-option name="styles-dir-name" select="$styles-dir-name"/>
        <p:with-option name="images-dir-name" select="$images-dir-name"/>
        
    </epub:create-paths>
    
    <epub:copy-images>
        <p:input port="source">
            <p:pipe port="source" step="create-and-copy-test"/>
        </p:input>
        <p:with-option name="image-source" select='$image-root'/>
        <p:with-option name="image-target" select="concat($root, $path-sep, $content-dir-name, $path-sep, $images-dir-name)"/> 
    </epub:copy-images>

    <epub:copy-css>
         <p:with-option name="css-source" select='$css-source'/>
        <p:with-option name="css-target" select="concat($root, $path-sep, $content-dir-name, $path-sep, $styles-dir-name)"/> 
    </epub:copy-css>
    
    <p:sink/>
        
    <p:identity name="final">
        <p:input port="source">
            <p:inline><dummy/></p:inline>
        </p:input>
    </p:identity>
    
    
</p:declare-step>