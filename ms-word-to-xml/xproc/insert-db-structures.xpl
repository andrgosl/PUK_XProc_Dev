<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" name="insert-db-structures"
     type="corbas:insert-db-structures"
    version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="structure-done"/>
    </p:output>
    <p:input kind="parameter" port="params"/>
    
    
    <!-- continue refactoring - insert parts -->
    <p:xslt name="insert-parts" version="2.0">
        <p:input port="source">
            <p:pipe port="source" step="insert-db-structures"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-parts.xsl"/>
        </p:input>        
    </p:xslt>
    
    <!-- continue refactoring - insert chapters -->
    <p:xslt name="insert-chapters" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="insert-parts"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-chapters.xsl"/>
        </p:input>        
    </p:xslt>
    
    <!-- continue refactoring - insert prelims -->
<!--    <p:xslt name="insert-prelims" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="insert-chapters"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-prelims.xsl"/>
        </p:input>        
    </p:xslt> -->
    
    <p:store href="/tmp/insert-chapters.xml">
        <p:input port="source">
            <p:pipe port="result" step="insert-chapters"/>
        </p:input>
    </p:store>
    
    <!-- continue refactoring - insert sections -->
    <p:xslt name="insert-sections" version="2.0">
        <p:input port="source">
            <p:pipe port="result" step="insert-chapters"/>
        </p:input>
        <p:input port="parameters"/>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-sections.xsl"/>
        </p:input>        
    </p:xslt>
    
    
    <p:store href="/tmp/insert-sections.xml">
        <p:input port="source">
            <p:pipe port="result" step="insert-sections"/>
        </p:input>
    </p:store>
    
    <p:identity name="structure-done">
        <p:input port="source">
            <p:pipe port="result" step="insert-sections"/>            
        </p:input>
    </p:identity>
    
</p:declare-step>