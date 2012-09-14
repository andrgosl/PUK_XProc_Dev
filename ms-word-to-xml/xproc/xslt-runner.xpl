<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/extensions"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0" name="xslt-runner"
	type="ccproc:xslt-runner">
	
	<p:documentation>
		<p xmlns="http:/wwww.w3.org/1999/xhtml">Wrapper around an xslt pipeline. The xslt
		is provided by name and loaded. The output can be logged if desired (using store-identity.xpl).
		Any xslt parameters required should be provided on the parameter input. The input document 
		is the primary input to the step.</p>
	</p:documentation>
	
	
	<p:input port="source" primary="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The primary input must provide the document to
				be processed (and returned).</p>
		</p:documentation>
	</p:input>
	
	<p:input kind="parameter" primary="true" port="parameters">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The parameter port contains the parameters to be
			passed to the xslt script.</p>
		</p:documentation>
	</p:input>
	
	<p:output port="result" primary="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The primary output is the result of the
				xslt process.</p>
		</p:documentation>
		<p:pipe port="result" step="store-result"/>
	</p:output>
	
	<p:output port="href-written">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The url for the logged output copy is provided on the
				<code>href-written</code> port within a single <code>c:result</code>
				element.</p>
		</p:documentation>
		<p:pipe port="result" step="store-result"/>
	</p:output>
	
	<p:option name="execute-store" select="'true'">
		<p:documentation>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">If set to true the store step will not be
				executed. This is intended to allow debugging to be enabled and disabled easily.</p>
		</p:documentation>
	</p:option>
	
	<p:option name="href" required="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The URL to which the file should be written. If
				the href-root option is provided, the href is appended to it.</p>
		</p:documentation>
	</p:option>
	
	<p:option name="href-root" select="''">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">An optional root portion for the href. If
				provided is used as a prefix.</p>
		</p:documentation>
	</p:option>
	
	<p:option name="xslt-href" required="true" >
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The XSLT file to be loaded.</p>
		</p:documentation>
	</p:option>

	
	<p:import href="store-identity.xpl"/>
	
	<p:load name="load-xslt" href="$xslt-href"/>
	
	<p:xslt name="xslt-processing">
		<p:input port="stylesheet">
			<p:pipe port="result" step="load-xslt"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe port="parameters" step="xslt-runner"/>
		</p:input>
		<p:input port="source">
			<p:pipe port="source" step="xslt-runner"/>
		</p:input>
	</p:xslt>
		
	<ccproc:store-identity>
		<p:with-option name="href-root" select="$href-root"/>
		<p:with-option name="href" select="$href"/>
		<p:with-option name="execute-store" select="$execute-store"/>		
	</ccproc:store-identity>
	
	
</p:declare-step>
