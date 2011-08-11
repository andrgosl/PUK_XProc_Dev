<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name='copy-images-test'>
    <p:output port="result"/>
    
    <p:option name="css-source"/>
    <p:option name="css-target"/>
    
    <p:import href="../libs/create-epub-library.xpl"/>    
    
    <epub:copy-css>
        <p:with-option name="css-path" select="$css-source"/>
        <p:with-option name="href" select="$css-target"/>        
    </epub:copy-css>
    
</p:declare-step>