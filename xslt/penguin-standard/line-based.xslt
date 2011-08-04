<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:p="http://www.penguingroup.com/ns/standard" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="1.0"
    exclude-result-prefixes="p xd">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 5, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>This stylesheet should work with both the namespaced and non-namespaced DocBook stylsheets. The
                namespace stripping component will leave these elements unchanged bar the conversion of @xml:id to @id.
                The id processing template below takes this into account.</xd:p>
        </xd:desc>
    </xd:doc>


    <xsl:template match="p:poem|p:linegroup|p:stanza|p:canto|p:speech|p:speechgroup|p:dialog|p:cast">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="class">
                <xsl:value-of select="@role"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="p:poem//p:line">

        <xsl:variable name="class">
            <xsl:call-template name="poem.line.style"/>
        </xsl:variable>

        <p>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class" select="$class"/>
            </xsl:call-template>

            <xsl:apply-templates/>

        </p>
    </xsl:template>



    <xsl:template match="p:poem/title|p:poem/info/title">
        <h4>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <!-- Drama -->
    <xsl:template match="p:speech">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="class">
                <xsl:if test="@role and $para.propagates.style != 0">
                    <xsl:value-of select="@role"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="content">
                <xsl:choose>
                    <xsl:when test="not($drama.speaker.block-formatted = 0)">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*[not(self::p:speaker)][1]" mode="insert-speaker"/>
                        <xsl:apply-templates select="*[not(self::p:speaker)][position() &gt; 1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>


    <xsl:template match="p:speaker">
        <span>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class">
                    <xsl:choose>
                        <xsl:when test="$para.propagates.style != 0">
                            <xsl:value-of select="normalize-space(concat(@role, $linebased.class.separator, local-name(.)))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:apply-templates/>

        </span>
    </xsl:template>
        

    <xsl:template match="p:inlinedirection">
        <span>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class">
                    <xsl:choose>
                        <xsl:when test="$para.propagates.style != 0">
                            <xsl:value-of select="normalize-space(concat(@role, $linebased.class.separator, local-name(.)))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:value-of select='$drama.inline.direction.start.marker'/><xsl:apply-templates/><xsl:value-of select='$drama.inline.direction.end.marker'/>
            
        </span>
    </xsl:template>
    

    <xsl:template match="p:direction" mode="insert-speaker">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="../p:speaker"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select='$drama.direction.start.marker'/><xsl:apply-templates/><xsl:value-of select='$drama.direction.end.marker'/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="p:poem|p:linegroup" mode="insert-speaker">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="class" select="@role"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="*[1]" mode="insert-speaker"/>
                <xsl:apply-templates select="*[position() &gt; 1]"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="para" mode="insert-speaker">
        <xsl:call-template name="paragraph">
            <xsl:with-param name="class">
                <xsl:if test="@role and $para.propagates.style != 0">
                    <xsl:value-of select="@role"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="content">

                <xsl:call-template name="anchor"/>
                <xsl:apply-templates select="ancestor::p:speech/p:speaker"/>
                <xsl:apply-templates/>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="p:line" mode="insert-speaker">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="ancestor::p:speech/p:speaker"/>
                <xsl:apply-templates/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="p:direction">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
            <xsl:with-param name="content">
                <xsl:value-of select='$drama.direction.start.marker'/><xsl:apply-templates/><xsl:value-of select='$drama.direction.end.marker'/>                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    

    <xsl:template match="p:line|p:castmember">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="p:speaker/p:role">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="p:roleref">
        <xsl:apply-templates select='//p:role[@id = current()/@linkend or @xml:id = current()/@linkend]'/>
    </xsl:template>
    
    
     
    <xd:doc scope="component">
        <xd:desc>
            <p>Works out the class attribute to be applied to the paragraph created for a line of poetry. </p>
            <p>Uses the following parameters: </p>
            <xd:ul>
                <xd:li></xd:li>
            </xd:ul>

        </xd:desc>
    </xd:doc>
    <xsl:template name="poem.line.style">

        <xsl:variable name="posn" select="position()"/>
        <xsl:variable name="total" select="count(preceding-sibling::p:line) + count(following-sibling::p:line) + 1"/>
        <xsl:variable name="even" select="$posn mod 2"/>
        <xsl:variable name="base-class">
            <xsl:choose>
                <xsl:when test="@role">
                    <xsl:value-of select="concat(@role, $linebased.class.separator, local-name(.))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="local-name(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:choose>
            <xsl:when test="number(normalize-space($poetry.generate.line.classes)) != 0">

                <xsl:variable name="line-base-class">
                    <xsl:choose>
                        <xsl:when test="$even=0">
                            <xsl:value-of select="$poetry.even.line.class"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$poetry.odd.line.class"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>


                <xsl:choose>

                    <!-- first line of stanza/linegroup -->
                    <xsl:when test="$posn = 1">

                        <xsl:variable name="first-line-class">
                            <xsl:choose>
                                <xsl:when test="number(normalize-space($poetry.generate.first.line.class)) != 0">
                                    <xsl:value-of select="concat($poetry.first.line.class, $linebased.class.separator, $poetry.odd.line.class)"
                                    />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:choose>

                            <!-- single line stanza/linegroup! -->
                            <xsl:when test="$posn=$total">
                                <xsl:choose>
                                    <xsl:when test="number(normalize-space($poetry.generate.last.line.class)) != 0">
                                        <xsl:value-of select="concat($first-line-class, $linebased.class.separator, $poetry.last.line.class)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$first-line-class"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:value-of select="$first-line-class"/>
                            </xsl:otherwise>

                        </xsl:choose>

                    </xsl:when>

                    <!-- last line of stanza/linegroup with more than one line -->
                    <xsl:when test="$posn = $total">

                        <xsl:choose>
                            <xsl:when test="number(normalize-space($poetry.generate.last.line.class)) != 0">
                                <xsl:value-of select="concat($line-base-class, $linebased.class.separator, $poetry.last.line.class)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$line-base-class"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>

                    <!-- any other line -->
                    <xsl:otherwise>
                        <xsl:value-of select="$line-base-class"/>
                    </xsl:otherwise>

                </xsl:choose>

            </xsl:when>

            <!-- no line based classes -->
            <xsl:otherwise>
                <xsl:value-of select="$base-class"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Handles shared processing of block content. Defaults to generating divs but can be overriden. Differs
                from the main DocBook XSL code in that it merges the role attribute and the local name if
                para.propagates.style is set rather than replacing the local name with the role attribute. </xd:p>
        </xd:desc>
        <xd:param><xd:b>class</xd:b> Name of css class to create on output.</xd:param>
        <xd:param><xd:b>element</xd:b> Name of element to output. Defaults to <b>div</b>.</xd:param>
        <xd:param><xd:b>content</xd:b> Content to output. Optional. If not provided uses
            <b>xsl:apply-templates</b></xd:param>
    </xd:doc>


    <xsl:template name="line-based.block">
        <xsl:param name="class" select="''"/>
        <xsl:param name="element" select="'div'"/>
        <xsl:param name="content"/>

        <xsl:element name="{$element}">
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class">
                    <xsl:choose>
                        <xsl:when test="$para.propagates.style != 0">
                            <xsl:value-of select="normalize-space(concat($class, $linebased.class.separator, local-name(.)))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="$content">
                    <xsl:copy-of select="$content"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:element>
    </xsl:template>


</xsl:stylesheet>
