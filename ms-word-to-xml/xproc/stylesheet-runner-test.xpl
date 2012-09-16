<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/extensions"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name='test-script'>

	<p:input port="source">
        <p:inline>
            <doc>Hello world!</doc>
        </p:inline>
    </p:input>
	
	<p:input port="params" kind="parameter"/>
	
	<p:output port="result"/>
	
	<p:import href="stylesheet-runner.xpl"/>

	<ccproc:stylesheet-runner name="move-dedication" 
		xslt-href="file:/Users/nicg/Projects/penguin/PUK_XProc_Dev/ms-word-to-xml/xsl/word-to-docbook/identity.xsl" 
		href-root='file:/tmp/' 
		href='test.xml' 
		execute-store='true'>
		<p:input port="source">
			<p:pipe port="source" step="test-script"></p:pipe>
		</p:input>
	</ccproc:stylesheet-runner>
	
    
</p:declare-step>