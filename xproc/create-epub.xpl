<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cstep="http://www.corbas.net/ns/xproc" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:corbas="http://www.corbas.net/ns/tempns" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" name="create-epub">


    <p:input port="source"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="final"/>
    </p:output>


    <p:option name="root" select="'.'"/>

    <p:option name="package-file" select="'package.opf'"/>
    <p:option name="daisy-file" select="'toc.ncx'"/>

    <p:option name="content-dir-name" select="'OPS'"/>
    <p:option name="image-dir-name" select="'images'"/>
    <p:option name="xhtml-dir-name" select="'xhtml'"/>
    <p:option name="styles-dir-name" select="'styles'"/>


    <p:import href="../libs/ng-library.xpl"/>
    <p:import href="../libs/pstd-library.xpl"/>
    <p:import href="../libs/create-epub-library.xpl"/>

    <p:declare-step name="s_create-ncx" type="cstep:create-ncx">

        <p:input port="source" primary="true"/>

        <p:option name="href" required="true"/>
        <p:option name="xhtml-dir-name" required="true"/>

        <!-- generate the NCX file -->
        <p:xslt name="convert-ncx">

            <p:with-param name="xhtml-dir" select="$xhtml-dir-name"/>

            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/create-ncx.xslt"/>
            </p:input>
        </p:xslt>
        
        <!-- add the play order to it -->
        <p:xslt name="sequence-ncx">
            
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="playorder.xslt"/>
            </p:input>
        </p:xslt>
               
        <p:store name="store-toc">
            <p:with-option name="href" select="$href"/>
            <p:input port="source">
                <p:pipe port="result" step="sequence-ncx"/>
            </p:input>
        </p:store>

    </p:declare-step>


    <!-- generate the OPF file -->
    <p:declare-step name="s_create-opf" type="cstep:create-opf">

        <p:input port="source" primary="true"/>
        <p:option name="href" required="true"/>

        <p:xslt name="convert-opf">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/create-opf.xslt"/>
            </p:input>
        </p:xslt>

        <cx:message>
            <p:with-option name="message" select="concat('STORE OPF: ', $href)"/>
        </cx:message>
        

        <p:store name="store-opf" encoding="UTF-8" omit-xml-declaration="false" indent="true">
            <p:with-option name="href" select="$href"/>
            <p:input port="source">
                <p:pipe port="result" step="convert-opf"/>
            </p:input>
        </p:store>

    </p:declare-step>




    <!-- set up some paths -->
    <p:variable name="opf-path" select="concat($root, '/',  $content-dir-name, '/', $package-file)"/>
    <p:variable name="ncx-path" select="concat($root, '/', $content-dir-name, '/', $daisy-file)"/>
    <p:variable name="xhtml-path" select="concat($root, '/', $content-dir-name,'/', $xhtml-dir-name)"/>


    <!-- metadata files -->
    <cstep:create-opf name="create-opf">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="href" select="$opf-path"/>
    </cstep:create-opf>


    <cstep:create-ncx name="create-ncx">
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:with-option name="href" select="$ncx-path"/>
        <p:with-option name="xhtml-dir-name" select='$xhtml-dir-name'/>
    </cstep:create-ncx>

    <p:xslt name="render-pages">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="create-epub"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/create-epub/xml-to-html.xslt"/>
        </p:input>
    </p:xslt>
    
    <p:sink/>

    <p:for-each name="save-pages">

        <p:iteration-source>
            <p:pipe port="secondary" step="render-pages"/>            
        </p:iteration-source>
        
        <p:variable name='page-id' select="/xhtml:html/xhtml:head/xhtml:meta[@name='page-id']/@content"/>
        <p:variable name="href" select="concat($xhtml-path, '/', $page-id, '.html')"/>
        
        <cx:message>
            <p:with-option name="message" select="concat('STORE: CHAPTER ', $href)"/>
        </cx:message>

        <p:store encoding="UTF-8" include-content-type="true" method="xhtml" indent="true" omit-xml-declaration="false">
            <p:with-option name="href" select="$href"/>
        </p:store>

    </p:for-each>


    <p:identity name="final">
        <p:input port="source">
            <p:empty/>
        </p:input>
    </p:identity>

</p:declare-step>
