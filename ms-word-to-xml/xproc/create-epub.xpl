<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="create-epub">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="final"/>
    </p:output>
    
    <!-- CSS source location -->
    <p:option name="css-source" required="true"/>
    
    <!-- root of image storage -->
    <p:option name="image-root" required="true"/>        
    
    <!-- final epub file -->
    <p:option name="epub-path" required="true"/>
    
    <!-- name of the directory in which the content directory should be created -->
    <p:option name="root" select="'.'"/>
    
    <!-- path separator. should be able to get this via cxo:info but I can't see
    a useful way to use it -->
    <p:option name="path-sep" select="'/'"/>
    
    <!-- metadata filenames --> 
    <p:option name="epub.opf.filename" select="'package.opf'"/>
    <p:option name="epub.ncx.filename" select="'toc.ncx'"/>
    
    <!-- main content directory -->
    <p:option name="content-dir-name" select="'OPS'"/>
    
    <!-- names of various content locations -->
    <p:option name="images-dir-name" select="'images'"/>
    <p:option name="xhtml-dir-name" select="'xhtml'"/>
    <p:option name="styles-dir-name" select="'styles'"/>
    <p:option name="fonts-dir-name" select="'fonts'"/>
    <p:option name="media-dir-name" select="'media'"/>
    
   
    <p:import href="create-epub-library.xpl"/>
    <p:import href="pstd-library.xpl"/>
    <p:import href="package-epub-library.xpl"/>
    
    <!-- set up some paths -->
    <p:variable name="content-path" select="concat($root, $path-sep, $content-dir-name)"/>
    <p:variable name="opf-path" select="concat($content-path, $path-sep, $epub.opf.filename)"/>
    <p:variable name="ncx-path" select="concat($content-path, $path-sep, $epub.ncx.filename)"/>    
    <p:variable name="xhtml-path" select="concat($content-path, $path-sep, $xhtml-dir-name)"/>
    
    <!-- set up base URLs for relative access to images and css from HTML -->
    <p:variable name="css-uri-base" select="concat('..', $path-sep, styles-dir-name)"/>
    <p:variable name="image-uri-base" select="concat('..', $path-sep, $images-dir-name)"/>
    

    <!-- create the paths -->
    <epub:create-paths name="create-epub-paths">
        <p:with-option name="base-path" select="$root"/>
        <p:with-option name="content-dir-name" select="$content-dir-name"/>
        <p:with-option name="xhtml-dir-name" select="$xhtml-dir-name"/>
        <p:with-option name="styles-dir-name" select="$styles-dir-name"/>
        <p:with-option name="images-dir-name" select="$images-dir-name"/>
    </epub:create-paths>
    
    <epub:copy-images name="copy-image-files">  
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="image-source" select='$image-root'/>
        <p:with-option name="image-target" select="concat($root, $path-sep, $content-dir-name, $path-sep, $images-dir-name)"/> 
    </epub:copy-images>
    
    
    <epub:copy-css name="copy-css-files">
        <!-- need explicit sources because the preceding step results in a sequence that we don't use -->
        <p:with-option name="css-source" select='$css-source'>
            <p:pipe port="source" step="create-epub"/>
        </p:with-option>
        <p:with-option name="css-target" select="concat($root, $path-sep, $content-dir-name, $path-sep, $styles-dir-name)">
            <p:pipe port="source" step="create-epub"/>
        </p:with-option> 
    </epub:copy-css>    
    
    
   
    <!-- build the c:result that will contain all the c:results from the output steps -->
    <p:insert name="insert-css-results" match="/c:result" position="last-child">
        <p:input port="source">
            <p:inline>
                <c:result></c:result>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="copy-css-files"/>
        </p:input>
    </p:insert>
    
    <p:insert name="insert-image-results" match="/c:result" position="last-child">
        <p:input port="source">
            <p:pipe port="result" step="insert-css-results"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="copy-image-files"/>
        </p:input>
    </p:insert>
    
    <epub:generate-html name="generate-html-data">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>            
        </p:input>
        <p:input port="css-files">
            <p:pipe port="result" step="copy-css-files"/>
        </p:input>
        <p:with-option name="image-uri-base" select="$image-uri-base"/>
        <p:with-option name="css-uri-base" select="$css-uri-base"/>
        <p:with-option name="xhtml-path" select="$xhtml-path"/>        
    </epub:generate-html>
    
    <p:insert name="insert-html-results" match="/c:result" position="last-child">
        <p:input port="source">
            <p:pipe port="result" step="insert-image-results"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="generate-html-data"/>
        </p:input>
    </p:insert>
    
    <!-- metadata files -->
    <epub:create-ncx name="create-ncx-file">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="content-path" select="$content-path"/>
        <p:with-option name="filename" select="$epub.ncx.filename"/>
        <p:with-option name="xhtml-dir-name" select='$xhtml-dir-name'/>
    </epub:create-ncx>
    
    <p:insert name="insert-ncx-results" match="/c:result" position="last-child">
        <p:input port="source">
            <p:pipe port="result" step="insert-html-results"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="create-ncx-file"/>
        </p:input>
    </p:insert>
    
    <epub:create-opf name="create-opf">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>           
        </p:input>
        <p:input port="manifest-files">
            <p:pipe port="result" step="insert-ncx-results"/>
        </p:input>
        <p:with-option name="href" select="$opf-path"/>
    </epub:create-opf>
    
    <p:load  dtd-validate="false" name="reload-opf">
        <p:with-option name="href" select="$opf-path"/>
    </p:load>  
    
    <epub:package-epub name="make-zip">
        <p:input port="source">
            <p:pipe port="result" step="reload-opf"/>
        </p:input>
        <p:with-option name="content-dir" select="$content-dir-name"/>
        <p:with-option name="epub-path" select="$epub-path"/>
    </epub:package-epub>
    
    <p:sink/>
    
    <p:identity name="final">
        <p:input port="source">
            <p:pipe port="result" step="create-opf"/>
        </p:input>
    </p:identity>
    
</p:declare-step>