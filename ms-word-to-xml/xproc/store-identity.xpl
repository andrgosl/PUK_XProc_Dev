<?xml version="1.0" encoding="UTF-8"?>
    
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0" name="store-identity"
	type="ccproc:store-identity">

	<p:documentation>
		<p xmlns="http:/wwww.w3.org/1999/xhtml">Very simple wrapper around a store operation to give
			us a step which stores in passing - makes the primary input the same as the primary
			output in order to simplify processing. Has an additional parameter which can be used to
			suppress the store stage of the process, allowing additional control over the
			output.Finally, the path and the file name may be passed as separate arguments in order
			to make multiple operating system operation simpler.</p>
	</p:documentation>


	<p:input port="source" primary="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The primary input must provide the document to
				be stored (and returned).</p>
		</p:documentation>
	</p:input>

	<p:output port="result" primary="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The primary output is simply a copy of the
				primary input.</p>
		</p:documentation>
		<p:pipe port="result" step="store-complete"/>
	</p:output>

	<p:output port="href-written">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The url for the written file is provided on the
					<code>href-written</code> port within a single <code>c:result</code>
				element.</p>
		</p:documentation>
		<p:pipe port="result" step="href-written"/>
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

	<!-- Concatenate to form a URL if the href-root option is set, putting a '/' between them if href-root doesn't end with one -->
	<p:variable name="final-href"
		select="if ($href-root) then concat($href-root, if (ends-with($href-root, '/')) then '' else '/', $href)  else $href"/>

	<!-- Work around the fact that if statements with no else don't make sense in a pipeline by creating the same dummy output 
        for each option. p:store has no primary output but the choose does so we use identities. -->
	<p:choose name="do-store">
		<p:when test="$execute-store = 'true'">
			<p:store>
				<p:with-option name="href" select="$final-href"/>
			</p:store>
			<p:identity name="choose-result">
				<p:input port="source">
					<p:inline>
						<c:result/>
					</p:inline>
				</p:input>
			</p:identity>
		</p:when>
		<p:otherwise>
			<p:identity name="choose-result">
				<p:input port="source">
					<p:inline>
						<c:result/>
					</p:inline>
				</p:input>
			</p:identity>
		</p:otherwise>
	</p:choose>

	<!-- Discard the result of choose after all that -->
	<p:sink/>

	<!-- The primary output is the primary input -->
	<p:identity name="store-complete">
		<p:input port="source">
			<p:pipe port="source" step="store-identity"/>
		</p:input>
	</p:identity>
	
	<!-- copy the vars to a parameter set -->
	<p:in-scope-names name="template-params"/>

	<!-- Secondary output - the href written to (if a write occurs) -->
	<p:template name="href-written">
		<p:input port="source">
			<p:empty/>
		</p:input>
		<p:input port="template">
			<p:inline>
				<c:result>{$final-href}</c:result>
			</p:inline>
		</p:input>
		<p:input port="parameters">
			<p:pipe port="result" step="template-params"/>
		</p:input>
	</p:template>

</p:declare-step>
