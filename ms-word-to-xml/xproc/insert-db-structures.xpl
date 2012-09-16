<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:corbas="http://www.corbas.co.uk/ns/xproc"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
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
	
	<p:import  href="stylesheet-runner.xpl"/>
    
    <!-- continue refactoring - insert parts -->
	<ccproc:stylesheet-runner href="parts.xml" name="store-parts" stylesheet-href="../xsl/word-to-docbook/insert-parts.xsl">
		<p:input port="source">
			<p:pipe port="source" step="insert-db-structures"/>
		</p:input>
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:stylesheet-runner>
	    
    <!-- continue refactoring - insert chapters -->
	<ccproc:stylesheet-runner href="chapters.xml" name="insert-chapters" stylesheet-href="../xsl/word-to-docbook/insert-chapters.xsl">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:stylesheet-runner>
	
    <!-- continue refactoring - insert sections -->
	<ccproc:stylesheet-runner href="sections.xml" name="insert-sections"  stylesheet-href="../xsl/word-to-docbook/insert-sections.xsl">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:stylesheet-runner>
	
	<!-- process the dedication into the right location -->
	<ccproc:stylesheet-runner href='dedications2.xml' name="move-dedication" stylesheet-href="../xsl/word-to-docbook/move-dedication.xsl">
		<p:with-option name="href-root" select='$href-root'/>
		<p:with-option name="execute-store" select="$log-step-output"/>
	</ccproc:stylesheet-runner>
	
    <p:identity name="structure-done"/>
    
</p:declare-step>