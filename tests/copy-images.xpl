<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name='copy-images-test'>
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name="image-source"/>
    <p:option name="image-target"/>
    
    <p:import href="../libs/create-epub-library.xpl"/>    
    
    <epub:copy-images>
        <p:input port="source">
            <p:pipe port="source" step="copy-images-test"/>
        </p:input>
        <p:with-option name="image-source" select="$image-source"/>
        <p:with-option name="image-target" select="$image-target"/>        
    </epub:copy-images>
    
</p:declare-step>