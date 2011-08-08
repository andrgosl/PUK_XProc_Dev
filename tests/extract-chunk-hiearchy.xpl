<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name='extract-chunk-hierarchy'>
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:import href="../libs/create-epub-library.xpl"/>

    <epub:get-chunk-hierarchy>
        <p:input port="source">
            <p:pipe port="source" step="extract-chunk-hierarchy"/>
        </p:input>
    </epub:get-chunk-hierarchy>
    
</p:declare-step>