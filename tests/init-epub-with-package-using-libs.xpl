<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:cs="http://www.corbas.net/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:input port="source"/>
    <p:output port="result"/>

    <!-- name of the output EPUB -->
    <p:option name='epub-file' required="true"/>
       
    <p:import href="../libs/ng-library.xpl"/>
    <p:import href="../libs/epub-library.xpl"/>
    
    <epub:init-epub>
        <p:with-option name="uri" select="$epub-file"/>
    </epub:init-epub>
   
   
    
</p:declare-step>
