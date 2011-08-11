<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:documentation>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <p>Module to wrap up scripts used when converting Penguin Standard XML to EPUB.</p>
        </div>
    </p:documentation>

    <p:declare-step name="generate-html" type="epub:generate-html">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Wrapper for content converstion to html. Generates the HTML and stores it to the
                    appropriate location. Before rendering, converts Penguion Standard to DocBook
                    Publishers.</p>
                <p>The primary input is the XML document to be rendered, the output is a sequence of
                    c:result elements, one for each output file, containing the name of the file (no
                    path information). File names are generated using the xml:id of the root element
                    of the output as the base name. </p>
                <p>The list of CSS files to be included in each HTML file must be passed as a
                    sequence on the css-files port.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:input port="css-files" sequence="true"/>
        <p:output port="result" sequence="true" primary="true">
            <p:pipe port="result" step="render-to-html-files"/>
        </p:output>
        
        <p:option required="true" name="image-uri-base"/>
        <p:option required="true" name="css-uri-base"/>
        <p:option required="true" name="xhtml-path"/>

        <epub:penguin-standard-to-db-p/>

        <epub:insert-penguin-styles/>

        <epub:render-to-html name="render-to-html-files">
            <p:input port="css-files">
                <p:pipe port="css-files" step="generate-html"/>
            </p:input>
            <p:with-option name="image-uri-base" select="$image-uri-base"/>
            <p:with-option name="css-uri-base" select="$css-uri-base"/>
            <p:with-option name="xhtml-path" select="$xhtml-path"/>
        </epub:render-to-html>
        
        
                
    </p:declare-step>





    <p:declare-step name="penguin-standard-to-db-p" type="epub:penguin-standard-to-db-p">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Convert a Penguin Standard title to DocBook publishers.</p>
                <p>This step is likely to become more complex as common problems are found and
                    fixed.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="pstd-to-db-final"/>
        </p:output>

        <epub:penguin-standard-link-fixup/>
        <epub:penguin-standard-image-fixup/>
        <epub:penguin-standard-convert-poetry/>

        <!-- just to keep the result from the whole pipeline simple -->
        <p:identity name="pstd-to-db-final"/>

    </p:declare-step>

    <p:declare-step name="penguin-standard-link-fixup" type="epub:penguin-standard-link-fixup">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Remove URLs from link text.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="xslt-fix-links"/>
        </p:output>

        <p:xslt name="xslt-fix-links">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="penguin-standard-link-fixup"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>

                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        xmlns="http://docbook.org/ns/docbook"
                        xpath-default-namespace="http://docbook.org/ns/docbook"
                        xmlns:xlink="http://www.w3.org/1999/xlink">

                        <xsl:strip-space elements="*"/>
                        <xsl:preserve-space elements="para"/>

                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>

                        <xsl:template match="xref/@linkend|link/@linkend">
                            <xsl:variable name="target" select="//*[@xml:id = current()]"/>
                            <xsl:choose>
                                <xsl:when test="local-name($target) = 'info'">
                                    <xsl:attribute name="linkend" select="$target/parent::*/@xml:id"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:template>

                        <!-- if there is a case difference it's probably a deliberate thing and we want to keep the
                            link correct -->
                        <xsl:template
                            match="link[ends-with(@xlink:href, .) and upper-case(.) = lower-case(.)]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                            </xsl:copy>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>

        </p:xslt>
    </p:declare-step>


    <p:declare-step name="penguin-standard-image-fixup" type="epub:penguin-standard-image-fixup">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Remove paths from images - making the HTML conversion simpler.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="xslt-fix-images"/>
        </p:output>

        <p:xslt name="xslt-fix-images">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="penguin-standard-image-fixup"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>

                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        xmlns="http://docbook.org/ns/docbook"
                        xpath-default-namespace="http://docbook.org/ns/docbook"
                        xmlns:xlink="http://www.w3.org/1999/xlink">

                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>

                        <xsl:template match="imagedata/@fileref">
                            <xsl:attribute name="fileref">
                                <xsl:choose>
                                    <xsl:when test="matches(., '/')">
                                        <xsl:analyze-string select="." regex="/([^/]+)$">
                                            <xsl:matching-substring>
                                                <xsl:value-of select="regex-group(1)"/>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>

        </p:xslt>
    </p:declare-step>

    <p:declare-step name="penguin-standard-convert-poetry"
        type="epub:penguin-standard-convert-poetry">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Convert penguin's poetry to that used by DocBook Publishers.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="xslt-convert-poetry"/>
        </p:output>

        <p:xslt name="xslt-convert-poetry">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="penguin-standard-convert-poetry"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>

                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        xmlns="http://docbook.org/ns/docbook"
                        xpath-default-namespace="http://docbook.org/ns/docbook"
                        xmlns:pbl="http://www.penguingroup.com/ns/standard"
                        xmlns:xlink="http://www.w3.org/1999/xlink">

                        <xsl:strip-space elements="*"/>
                        <xsl:preserve-space elements="para"/>

                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>

                        <!-- convert penguin poetry mark-up to docbook publishers -->
                        <xsl:template match="pbl:poem">
                            <poetry>
                                <xsl:apply-templates select="@*|node()"/>
                            </poetry>
                        </xsl:template>

                        <xsl:template match="pbl:stanza">
                            <linegroup>
                                <xsl:if test="not(@role)">
                                    <xsl:attribute name="role" select="stanza"/>
                                </xsl:if>
                                <xsl:apply-templates select="@*|node()"/>
                            </linegroup>
                        </xsl:template>

                        <xsl:template match="pbl:canto">
                            <linegroup>
                                <xsl:if test="not(@role)">
                                    <xsl:attribute name="role" select="canto"/>
                                </xsl:if>
                                <xsl:apply-templates select="@*|node()"/>
                            </linegroup>
                        </xsl:template>

                        <xsl:template match="pbl:line">
                            <line>
                                <xsl:apply-templates select="@*|node()"/>
                            </line>
                        </xsl:template>

                    </xsl:stylesheet>
                </p:inline>
            </p:input>

        </p:xslt>
    </p:declare-step>

    <p:declare-step name="insert-penguin-styles" type="epub:insert-penguin-styles">

        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Insert Penguin standard styles into epub:style attributes on the xml.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true"/>

        <p:xslt version="2.0">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="insert-penguin-styles"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/insert-penguin-styles.xslt"/>
            </p:input>
        </p:xslt>

    </p:declare-step>

    <p:declare-step name="insert-css-into-html" type="epub:insert-css-into-html">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Given an HTML document and a sequence of c:result elements, constructs a sequence
                    of HTML link elements for the CSS and inserts it into the HTML file.</p>
            </div>
        </p:documentation>

        <p:input port="source" primary="true"/>
        <p:input port="css-files" sequence="true"/>
        
        <p:output port="result" primary="true">
            <p:pipe port="result" step="insert-css-links"/>
        </p:output>
        
        <p:option required="true" name="css-uri-base"/>
        
        <p:for-each name="iterate-css">

            <p:iteration-source>
                <p:pipe port="css-files" step="insert-css-into-html"/>
            </p:iteration-source>

            <p:output port="css-links" primary="true"/>

            <p:xslt name="create-css-link">

                <p:input port="parameters">
                    <p:empty/>
                </p:input>

                <p:input port="source">
                    <p:pipe port="current" step="iterate-css"/>
                </p:input>

                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns="http://www.w3.org/1999/xhtml"
                            xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">
                            <xsl:param name="css-uri-base" select="'../styles/'"/>
                            <xsl:template match="c:result">
                                <link rel="stylsheet" type="text/css"
                                    href="{concat($css-uri-base), '/', .)}"/>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>

                <p:with-param name="css-uri-base" select="$css-uri-base"/>

            </p:xslt>

        </p:for-each>
        
        <p:insert name="insert-css-links" match="/h:html/h:head" position="last-child">
            <p:input port="source">
                <p:pipe port="source" step="insert-css-into-html"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe port="css-links" step="iterate-css"/>
            </p:input>
        </p:insert>
        

    </p:declare-step>

    <p:declare-step name="render-to-html" type="epub:render-to-html">
        
        <p:documentation>
            
        </p:documentation>
        
        <p:input port="source" primary="true"/>
        <p:input port="css-files"/>
        
        <p:output port="result" primary="true" sequence="true">
            <p:pipe port="html-files" step="store-pages"/>
        </p:output>
        
        <p:option required="true" name="image-uri-base"/>
        <p:option required="true" name="css-uri-base"/>
        <p:option required="true" name="xhtml-path"/>
        
    
        <p:xslt name="render-pages">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="render-to-html"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-epub/xml-to-html.xslt"/>
            </p:input>
            <p:with-param name="image-uri-base" select="$image-uri-base"/>
            
        </p:xslt>

        <!-- ignore the primary output -->
        <p:sink/>
        
        <p:for-each name="store-pages">
            
            <p:iteration-source>
                <p:pipe port="secondary" step="render-pages"/>            
            </p:iteration-source>
            
            <p:output port="html-files" primary="true" sequence="true">
                <p:pipe port="result" step="create-result"/>
            </p:output>
            
            <p:variable name='page-id' select="/h:html/@xml:id"/>
            <p:variable name="filename" select="concat($page-id, '.html')"/>
            <p:variable name="href" select="concat($xhtml-path, '/', $filename)"/>
            
            <!-- no ID on root element of XHTML! -->
            <p:delete name="delete-root-id" match="/h:html/@xml:id"/>
            <p:store encoding="UTF-8" include-content-type="true" method="xhtml" indent="true" omit-xml-declaration="false">
                <p:with-option name="href" select="$href"/>
            </p:store>

            <p:xslt name="create-result">
                <p:input port="parameters"><p:empty/></p:input>
                <p:input port="source">
                    <p:inline><c:result><c:dummy/></c:result></p:inline>
                </p:input>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                            xmlns:c="http://www.w3.org/ns/xproc-step">
                            <xsl:param name="filename"/>
                            <xsl:template match="@*|node()">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:template>
                            <xsl:template match="c:dummy">
                                <xsl:value-of select="$filename"/>
                            </xsl:template>                            
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
                <p:with-param name="filename" select="$filename"/>
            </p:xslt>
            
        </p:for-each>
    
    </p:declare-step>

</p:library>
