<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/extensions"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" name="refactor-document"
    type="corbas:refactor-document"
    version="1.0">
    
    <!-- step to insert semantic structure into converted documents -->

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:input kind="parameter" primary="true" port="parameters"/>
    
    <p:option name="log-step-output" select="'false'">
        <p:documentation>
            <p xmlns="http://www.w3.org/1999/xhtml">Controls whether or not the output of the each transformation
                stage is logged.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="href-root" select="'/tmp/'">
        <p:documentation>
            <p xmlns="http://wwww.w3.org/1999/xhtml">Optional prefix for the stage logging path. Defaults to 
                <code>/tmp/</code>.</p>
        </p:documentation>
    </p:option>
    
    <p:import  href="store-identity.xpl"/>
    
    <!-- rewrite paragraphs to appropriate elements -->
    <p:xslt name="refactor-paragraphs" version="2.0">
        <p:input port="source">
            <p:pipe port="source" step="refactor-document"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-paragraphs.xsl"/>
        </p:input>
    </p:xslt>
    
    <ccproc:store-identity href="paragraphs.xml" name="store-paragraphs">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    
    <!-- make sure we have the right db root element -->
    <p:xslt name="refactor-root" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-root.xsl"/>
        </p:input>
    </p:xslt>
    
    <ccproc:store-identity href="root.xml" name="store-root">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix up epigraphs -->
    <p:xslt name="refactor-epigraphs" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-epigraphs.xsl"/>
        </p:input>
    </p:xslt>
    
    <ccproc:store-identity href="epigraphs.xml" name="store-epigraphs">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix up blockquotes -->
    <p:xslt name="refactor-blockquotes" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-blockquotes.xsl"/>
        </p:input>
    </p:xslt> 
    
    <ccproc:store-identity href="blockquotes.xml" name="store-blockquotes">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix up dedication -->
    <p:xslt name="refactor-dedication" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-dedication.xsl"/>
        </p:input>
    </p:xslt> 
    
    <ccproc:store-identity href="dedication.xml" name="store-dedication">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix up lists -->
    <p:xslt name="refactor-lists" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/word-lists.xsl"/>
        </p:input>
    </p:xslt>
    
    <ccproc:store-identity href="lists.xml" name="store-lists">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix up figures -->
    <p:xslt name="refactor-figures" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-figures.xsl"/>
        </p:input>
    </p:xslt>

    <ccproc:store-identity href="figures.xml" name="store-figures">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    <!-- fix poetry -->
    <p:xslt name="refactor-poetry" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/refactor-poetry.xsl"/>
        </p:input>        
    </p:xslt>   
    
    <ccproc:store-identity href="poetry.xml" name="store-poetry">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    
    <!-- build book info -->
    <p:xslt name="insert-book-info" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-book-info.xsl"/>
        </p:input>        
    </p:xslt>

    <ccproc:store-identity href="book-info.xml" name="store-info">
        <p:with-option name="href-root" select='$href-root'/>
        <p:with-option name="execute-store" select="$log-step-output"/>
    </ccproc:store-identity>
    
    
    
</p:declare-step>