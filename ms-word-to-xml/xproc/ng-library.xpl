<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:cxu="http://xmlcalabash.com/ns/extensions/xmlunit"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <div class='library-doc'>
            <h1>Library Definitions Module</h1>
            <p>This module simply contains definitions for all the calabash extensions we might need to use rather than the whole lot</p>
        </div>
    </p:documentation>
    
        
    <p:declare-step type="cx:unzip">
        
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <div class='step-doc'>
                <h1>cx:unzip</h1>
                <p>Unzip, extracting listings or contents from a module.</p>
            </div>
        </p:documentation>
        
        <p:output port="result"/>
        <p:option name="href" required="true" cx:type="xsd:anyURI"/>
        <p:option name="file"/>
        <p:option name="content-type"/>
    </p:declare-step>
    
    <p:declare-step type="cx:zip">
        
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <div class='step-doc'>
                <h1>cx:zip</h1>
                <p>Create or update a zip file and its contents.</p>
            </div>
        </p:documentation>
        
        <p:input port="source" sequence="true" primary="true"/>
        
        <p:input port="manifest"/>
        <p:output port="result"/>
        <p:option name="href" required="true" cx:type="xsd:anyURI"/>
        <p:option name="compression-method" cx:type="stored|deflated"/>
        <p:option name="compression-level"
            cx:type="smallest|fastest|default|huffman|none"/>
        <p:option name="command" select="'update'" cx:type="update|freshen|create|delete"/>
        
        <p:option name="byte-order-mark" cx:type="xsd:boolean"/>
        <p:option name="cdata-section-elements" select="''" cx:type="ListOfQNames"/>
        
        <p:option name="doctype-public" cx:type="xsd:string"/>
        <p:option name="doctype-system" cx:type="xsd:anyURI"/>
        <p:option name="encoding" cx:type="xsd:string"/>
        <p:option name="escape-uri-attributes" select="'false'" cx:type="xsd:boolean"/>
        <p:option name="include-content-type" select="'true'" cx:type="xsd:boolean"/>
        <p:option name="indent" select="'false'" cx:type="xsd:boolean"/>
        <p:option name="media-type" cx:type="xsd:string"/>
        <p:option name="method" select="'xml'" cx:type="xsd:QName"/>
        <p:option name="normalization-form" select="'none'" cx:type="NormalizationForm"/>
        
        <p:option name="omit-xml-declaration" select="'true'" cx:type="xsd:boolean"/>
        <p:option name="standalone" select="'omit'" cx:type="true|false|omit"/>
        <p:option name="undeclare-prefixes" cx:type="xsd:boolean"/>
        <p:option name="version" select="'1.0'" cx:type="xsd:string"/>
    </p:declare-step>


    <p:declare-step type="cx:message">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:option name="message" required="true"/>
    </p:declare-step>
    
    <p:declare-step type="cxf:tempfile">
        <p:output port="result" primary="false"/>
        <p:option name="href" required="true"/>                       <!-- anyURI -->
        <p:option name="prefix"/>                                     <!-- string -->
        <p:option name="suffix"/>                                     <!-- string -->
        <p:option name="delete-on-exit"/>                             <!-- boolean -->
        <p:option name="fail-on-error" select="'true'"/>              <!-- boolean -->
    </p:declare-step>
    
    <p:declare-step type="cxf:copy">
        <p:output port="result" primary="false"/>
        <p:option name="href" required="true"/>                       <!-- anyURI -->
        <p:option name="target" required="true"/>                     <!-- boolean -->
        <p:option name="fail-on-error" select="'true'"/>              <!-- boolean -->
    </p:declare-step>

    <p:declare-step type="cxf:mkdir">
        <p:output port="result" primary="false"/>
        <p:option name="href" required="true"/>                       <!-- anyURI -->
        <p:option name="fail-on-error" select="'true'"/>              <!-- boolean -->
    </p:declare-step>
    
    <p:declare-step type="cxf:info">
        <p:output port="result" sequence="true"/>
        <p:option name="href" required="true"/>                       <!-- anyURI -->
        <p:option name="fail-on-error" select="'true'"/>              <!-- boolean -->
    </p:declare-step>    
    
    <p:declare-step type="cxo:info">
        <p:output port="result"/>
    </p:declare-step>

</p:library>

