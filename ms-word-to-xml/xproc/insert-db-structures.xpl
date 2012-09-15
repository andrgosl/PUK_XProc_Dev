<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/extensions"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" name="insert-db-structures"
     type="corbas:insert-db-structures"
    version="1.0">
    
    <!-- step to insert DocBook structure into processed word documents -->
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="structure-done"/>
    </p:output>
    <p:input kind="parameter" port="params"/>
	
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
	
	<p:import href="store-identity.xpl"/>
	<p:import  href="xslt-runner.xpl"/>
	
    
    <!-- continue refactoring - insert parts -->
    <p:xslt name="insert-parts" version="2.0">
        <p:input port="source">
            <p:pipe port="source" step="insert-db-structures"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-parts.xsl"/>
        </p:input>        
    </p:xslt>
    
	<ccproc:store-identity href="parts.xml" name="store-parts">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:store-identity>
	
    
    <!-- continue refactoring - insert chapters -->
    <p:xslt name="insert-chapters" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-chapters.xsl"/>
        </p:input>        
    </p:xslt>
    
	<ccproc:store-identity href="chapters.xml" name="store-chapters">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:store-identity>
	
	
    <!-- continue refactoring - insert sections -->
    <p:xslt name="insert-sections" version="2.0">
        <p:input port="stylesheet">
            <p:document href="../xsl/word-to-docbook/insert-sections.xsl"/>
        </p:input>        
    </p:xslt>
    
	<ccproc:store-identity href="sections.xml" name="store-sections">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:store-identity>
	
	<!-- process the dedication into the right location -->
	<ccproc:xslt-runner href='dedications-2.xml' name="move-dedication" xslt-href="../xsl/word-to-docbook/move-dedication.xsl">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:xslt-runner>
	
    <p:identity name="structure-done"/>
    
</p:declare-step>