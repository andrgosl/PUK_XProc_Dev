<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE schema [

<!ENTITY dbblocks01 "db:abstract|db:acknowledgements|db:address|db:appendix|db:article|db:bibliodiv|db:biblioentry">
<!ENTITY dbblocks02 "db:bibliography|db:bibliolist|db:bibliomixed|db:bibliomset|db:biblioset|db:blockquote|db:book">
<!ENTITY dbblocks03 "db:callout|db:calloutlist|db:informaltable|db:table|db:caption|db:caution|db:chapter|db:colophon">
<!ENTITY dbblocks04 "db:cover|db:dedication|db:epigraph|db:equation|db:example|db:figure|db:formalpara|db:glossary|db:glossdef">
<!ENTITY dbblocks05 "db:glossdiv|db:glossentry|db:glosslist|db:glosssee|db:glossseealso|db:imageobjectco|db:important|db:index">
<!ENTITY dbblocks06 "db:indexdiv|db:indexentry|db:informalequation|db:informalexample|db:informalfigure|db:itemizedlist">
<!ENTITY dbblocks07 "db:legalnotice|db:listitem|db:mediaobject|db:note|db:orderedlist|db:para|db:part|db:partintro">
<!ENTITY dbblocks08 "db:personblurb|db:preface|db:primaryie|db:printhistory|db:qandadiv|db:qandaentry|db:qandaset|db:screenco">
<!ENTITY dbblocks09 "db:screenshot|db:secondaryie|db:section|db:seealsoie|db:seeie|db:set|db:setindex|db:sidebar|db:simpara">
<!ENTITY dbblocks10 "db:simplesect|db:subtitle|db:synopfragment|db:synopfragmentref|db:term|db:tertiaryie|db:tip|db:title|db:toc">
<!ENTITY dbblocks11 "db:tocdiv|db:tocentry|db:warning">

<!ENTITY dbblocks  "&dbblocks01;|&dbblocks02;|&dbblocks03;|&dbblocks04;|&dbblocks05;|&dbblocks06;|&dbblocks07;|
	&dbblocks08;|&dbblocks09;|&dbblocks10;|&dbblocks11;">
	
<!ENTITY other_db_id_elements "db:anchor|db:info">
<!ENTITY penguin_line_elements "pbl:line|pbl:linegroup|pbl:stanza|pbl:poem|pbl:direction|pbl:speech|pbl:dialog|pbl:role|pbl:cast">
<!ENTITY penguin_cookery_elements "pbc:ingredients|pbc:recipe">
<!ENTITY penguin_id_elements  "&penguin_line_elements;|&penguin_cookery_elements;">

]>

<schema xmlns="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- 
		Version 1.1/05 March 2008
		Version 1.2/09 July 2008
			Fixed error with missing namespace on author/authorgroup tests.
	-->
	
	<!-- schematron lets us declare namespaces. this is good because xpath is fiddly otherwise -->
    <ns uri="http://docbook.org/ns/docbook" prefix='db' />
    <ns uri="http://www.penguingroup.com/ns/standard" prefix="pbl"/>
    <ns uri="http://www.penguingroup.com/ns/cookbook" prefix="pbc"/>
	<ns uri='http://www.w3.org/XML/1998/namespace' prefix='xml'/>
	
	<!-- used for duplicated ids later on -->
	<xsl:key name="xmlid" match="*[@xml:id]" use="@xml:id"/> 
    
    <!-- check that all the elements which need ids have them -->
    <pattern id='id_required'>
        <rule context="&dbblocks;">
        	<assert test="@xml:id">The "<name/>"  elements contained in the "<value-of select='name(ancestor::*[@xml:id][1])'/>" element with id "<value-of select='ancestor::*[@xml:id][1]/@xml:id'/>" must have an  "id" attribute.</assert>
        </rule>
    	<rule context="&penguin_id_elements;">
    		<assert test="@xml:id">The "<name/>"  element contained in the "<value-of select='name(ancestor::*[@xml:id][1])'/>" element with id "<value-of select='ancestor::*[@xml:id][1]/@xml:id'/>" must have an  "id" attribute.</assert>
    	</rule>
    	<rule context="&penguin_id_elements;">
    		<assert test="@xml:id">The "<name/>"  element contained in the "<value-of select='name(ancestor::*[@xml:id][1])'/>" element with id "<value-of select='ancestor::*[@xml:id][1]/@xml:id'/>" must have an  "id" attribute.</assert>
    	</rule>
    </pattern>
	
	<!-- check for duplicated ids -->
	<pattern id="duplicated_id"> 
		<rule context="*[@xml:id]"> 
			<assert test="count(key('xmlid', @xml:id)) = 1">Duplicated id in element "<name/>" - "<value-of select='@xml:id'/>".</assert> 
		</rule> 
	</pattern> 
	

	<!-- 
		This rule checks that book,part,chapter and sections elements which have titles have
		them inside info elements 
	-->
	<pattern id='info_checker'>
		<rule context='db:book|db:part|db:chapter|db:section'>
			<report test='title'>The "<name/>" element with id "<value-of select='@xml:id'/>" should have an "info" element to contain the title</report>
		</rule>
	</pattern>
	
	
	<!-- Check that we have require metadata in the book element -->
	<pattern id='book_metadata'>
		
		<rule context='db:book'>
			<assert test='db:info'>Book elements must have  an "info" elements.</assert>
		</rule>
		
		<rule context='db:book/db:info'>
			<assert test='db:title'>Book information must contain a "title" element.</assert>
			<assert test='descendant::db:biblioid[@class="isbn"]'>Book information must contain at least one "biblioid" element with a "class" attribute set to "isbn".</assert>
			<assert test='db:publisher'>Book information must contain at least one "publisher" element.</assert>
			<assert test="db:authorgroup|db:author">Book information must contain at least on "author" or "authorgroup" element.</assert>
		</rule>
		
	</pattern>
	
	<!-- These elements are often empty to make the document validate. So... let's check -->
	<pattern id='should_not_be_empty'>
		<rule context='db:title|db:para'>
			<assert test='string-length(normalize-space(.)) != 0'>The "<name/>" element with id "<value-of select='@xml:id'/>" should have some content.</assert>
		</rule>
	</pattern>
	
	<!-- Basic checks on images
	<pattern id='image_checks'>
		<rule context='db:mediaobject|db:inlinemediaobject'>
			<assert test='imageobject'></assert>
		</rule>
	</pattern> -->
	
	<!-- Check that paragraphs don't *directly* contain block elements. This is not necessarily an error but we want to know about it. -->
	<pattern id='para_block_checks'>
		<rule context='&dbblocks;'>
			<report test="local-name(..) = 'para'">The block "<name/>" element with id "<value-of select='@xml:id'/>"" is a direct child of a paragraph.</report>
		</rule>
		<rule context='&penguin_id_elements;'>
			<report test="local-name(..) = 'para'">The block "<name/>" element with id "<value-of select='@xml:id'/>"" is a direct child of a paragraph.</report>
		</rule>
	</pattern>
	
</schema>