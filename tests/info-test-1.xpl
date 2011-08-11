<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
    
    <p:output port="result" primary="true">
        <p:pipe port="result" step="check-type"/>
    </p:output>

    <p:option name="href"/>    
    
    <p:import href="../libs/ng-library.xpl"/>

    <!-- work out if we have a file or a directory -->
    <cxf:info name="check-type" fail-on-error='true'>
        <p:with-option name="href" select="$href"/>
    </cxf:info>

</p:declare-step>

