<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:epub="http://www.corbas.net/ns/epub"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:documentation>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <p>Module to wrap up scripts used when converting Penguin Standard XML to DocBook
                Publishers.</p>
        </div>
    </p:documentation>

    <p:declare-step name="penguin-standard-to-db-p" type="epub:penguin-standard-to-db-p">
        <p:documentation>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <p>Convert a Penguin Standard title to DocBook publishers.</p>
                <p>This step is likely to become more complex as common problems
                are found and fixed.</p>
            </div>
        </p:documentation>
        
        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true">
            <p:pipe port="result" step="pstd-to-db-final"/>
        </p:output>     
        
        <epub:penguin-standard-link-fixup/>  
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
            <p:input port="parameters"><p:empty/></p:input>
            <p:input port="source"><p:pipe port="source" step="penguin-standard-link-fixup"/></p:input>
            <p:input port="stylesheet">
                <p:inline>
                    
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        version="2.0" xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
                        xmlns:xlink="http://www.w3.org/1999/xlink">
                        
                        <xsl:strip-space elements="*"/>
                        <xsl:preserve-space elements="para"/>
                                                
                        <xsl:template match='@*|node()'>
                            <xsl:copy>
                                <xsl:apply-templates select='@*|node()'/>
                            </xsl:copy>
                        </xsl:template>
                                                
                        <xsl:template match='xref/@linkend|link/@linkend'>
                            <xsl:variable name='target' select='//*[@xml:id = current()]'/>
                            <xsl:choose>
                                <xsl:when test="local-name($target) = 'info'">
                                    <xsl:attribute name='linkend' select="$target/parent::*/@xml:id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy/>
                                </xsl:otherwise>            
                            </xsl:choose>
                        </xsl:template>
                        
                        <xsl:template match="link[ends-with(@xlink:href, .)]">
                            <xsl:copy>
                                <xsl:apply-templates select='@*'/>
                            </xsl:copy>    
                        </xsl:template>
                        
                    </xsl:stylesheet>                    
                </p:inline>
            </p:input>
            
        </p:xslt>
    </p:declare-step>
    
    <p:declare-step name="penguin-standard-convert-poetry" type="epub:penguin-standard-convert-poetry">
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
        <p:input port="parameters"><p:empty/></p:input>
        <p:input port="source"><p:pipe port="source" step="penguin-standard-convert-poetry"/></p:input>
        <p:input port="stylesheet">
            <p:inline>
                
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    version="2.0" xmlns="http://docbook.org/ns/docbook" xpath-default-namespace="http://docbook.org/ns/docbook"
                    xmlns:pbl="http://www.penguingroup.com/ns/standard"
                    xmlns:xlink="http://www.w3.org/1999/xlink">
                    
                    <xsl:strip-space elements="*"/>
                    <xsl:preserve-space elements="para"/>
                    
                    <xsl:template match='@*|node()'>
                        <xsl:copy>
                            <xsl:apply-templates select='@*|node()'/>
                        </xsl:copy>
                    </xsl:template>
                    
                    <!-- convert penguin poetry mark-up to docbook publishers -->
                    <xsl:template match="pbl:poem">
                        <poetry>
                            <xsl:apply-templates select='@*|node()'/>
                        </poetry>
                    </xsl:template>
                    
                    <xsl:template match="pbl:stanza">
                        <linegroup>
                            <xsl:if test="not(@role)">
                                <xsl:attribute name='role' select="stanza"/>
                            </xsl:if>
                            <xsl:apply-templates select='@*|node()'/>
                        </linegroup>
                    </xsl:template>
                    
                    <xsl:template match="pbl:canto">
                        <linegroup>
                            <xsl:if test="not(@role)">
                                <xsl:attribute name='role' select="canto"/>
                            </xsl:if>
                            <xsl:apply-templates select='@*|node()'/>
                        </linegroup>
                    </xsl:template>                    
                    
                    <xsl:template match="pbl:line">
                        <line><xsl:apply-templates select='@*|node()'/></line>
                    </xsl:template>                    
                    
                </xsl:stylesheet>                    
            </p:inline>
        </p:input>
        
    </p:xslt>
    </p:declare-step>    

</p:library>
