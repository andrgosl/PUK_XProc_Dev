<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="opf-manifest-test">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    

    <p:option name="content-dir" required="true"/>
    

    <p:import href="../libs/epub-library.xpl"/>
    
    <epub:convert-opf-to-zip-manifest>
       
        <p:with-option name="content-dir" select="$content-dir"/>
        <p:input port="source">
            <p:pipe port="source" step="opf-manifest-test"/>
        </p:input>        
    </epub:convert-opf-to-zip-manifest>
    
    
</p:declare-step>