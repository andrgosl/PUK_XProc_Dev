<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="final"/>
    </p:output>

    <p:option name="href"/>    
    
    <p:import href="../libs/pstd-library.xpl"/>
    
    <epub:penguin-standard-image-fixup name="final"/>

</p:declare-step>

