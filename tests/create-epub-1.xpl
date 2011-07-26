<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
    name="opf-create-test-1">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    
    <p:option name="epub-path" required="true"/>
    
    
    <p:import href="../libs/epub-library.xpl"/>
    
    <epub:create-epub>
        
        <p:with-option name="epub-path" select="$epub-path"/>
        <p:input port="source">
            <p:pipe port="source" step="opf-create-test-1"/>
        </p:input>        
    </epub:create-epub>
    
    
</p:declare-step>