<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="1.0" exclude-result-prefixes="xd">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 5, 2011</xd:p>
            <xd:p><xd:b>Updatad on:</xd:b> July 27, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Originally written for the Penguin Standard schema. Modified for use with the
                actual DocBook Publishers schema.</xd:p>
        </xd:desc>
    </xd:doc>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Basic output generator for the block based components of DocBook Publishers. Uses
                a more complex method of generating the class attribute than the normal stylesheets
                as poetry needs much more styling than 'normal' text. </xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="db:poetry|db:linegroup|db:dialogue|db:drama|db:speaker">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="class">
                <xsl:call-template name="line-based.choose.class"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="db:line">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Drama
        Need to support two common models of rendering the speaker and the speech.
        Firstly, we need to be able to handle the speaker as inline and secondly
        as a block. 
        
        There's a warning in this template because there is no sensible way to
        insert the speaker into an arbitrary block. Therefore, if the linegroup
        contains 
            
    -->
    <xsl:template match="db:linegroup[db:speaker]">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="content">
                <xsl:choose>
                    <xsl:when test="not($drama.speaker.block-formatted = 0)">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="*[not(self::db:speaker)][not(self::db:line)]">
                                <xsl:message terminate="no">Not converting db:speaker to inline as
                                    the linegroup contains non line elements</xsl:message>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="*[not(self::db:speaker)][1]" mode="insert-speaker"/>
                                <xsl:apply-templates select="*[not(self::db:speaker)][position() &gt; 1]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Inserts a speaker element as the first child content of the first line
            of a drama. Inserts it as a span.</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="db:speaker" mode="insert-speaker">
        <span>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class">
                    <xsl:call-template name="line-based.choose.class"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:value-of select="$drama.speaker.separator"/>
        </span>
    </xsl:template>
    

    <!-- Insert any speakers as spans into this para. -->
    <xsl:template match="db:line" mode="insert-speaker">
        <xsl:call-template name="line-based.block">
            <xsl:with-param name="element" select="'p'"/>
            <xsl:with-param name="class" select="@role"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="ancestor::db:speech/db:speaker"/>
                <xsl:apply-templates/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- This should never happen - code in the linegroup element template should stop it -->
    <xsl:template match="*" mode="insert-speaker">
        <xsl:message terminate="yes">Attempt to insert a speaker into an arbitrary block. Not allowed.</xsl:message>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Handles shared processing of block content. Defaults to generating divs but can be
                overriden.</xd:p>
        </xd:desc>
        <xd:param><xd:b>class</xd:b> Name of css class to create on output.</xd:param>
        <xd:param><xd:b>element</xd:b> Name of element to output. Defaults to <b>div</b>.</xd:param>
        <xd:param><xd:b>content</xd:b> Content to output. Optional. If not provided uses
                <b>xsl:apply-templates</b></xd:param>
    </xd:doc>


    <xsl:template name="line-based.block">

        <xsl:param name="class" select="local-name()"/>
        <xsl:param name="element" select="'div'"/>
        <xsl:param name="content"/>

        <xsl:apply-templates select="." mode="line-based.block">
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="element" select="$element"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="line-based.block">

        <xsl:param name="class" select="local-name()"/>
        <xsl:param name="element" select="'div'"/>
        <xsl:param name="content"/>

        <xsl:element name="{$element}">
            
            <xsl:call-template name="anchor"/>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="class" select="$class"/>
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

    <xsl:template name="line-based.choose.class">
        <xsl:apply-templates select="." mode="line-based.choose.class"/>
    </xsl:template>

    <!-- Allow the class attribute value to be overridden -->
    <xsl:template match="*" mode="line-based.choose.class">
        <xsl:choose>
            <xsl:when test="$para.propagates.style != 0">
                <xsl:choose>
                    <xsl:when test="$line-based.merge.classes != 0">
                        <xsl:value-of
                            select="normalize-space(concat(local-name(), $line-based.class.separator, @role))"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@role"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="local-name()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <p>Works out the class attribute to be applied to the paragraph created for a line of
                poetry. This will not work terribly well at times because the Docbook Publishers
                model for poetry has issues - the model allows far too much content.</p>
            <p>Uses the following parameters: </p>
            <xd:ul>
                <xd:li>poetry.generate.line.classes</xd:li>
                <xd:li>poetry.even.line.class</xd:li>
                <xd:li>poetry.odd.line.class</xd:li>
                <xd:li>poetry.generate.first.line.class</xd:li>
                <xd:li>poetry.first.line.class</xd:li>
                <xd:li>poetry.generate.last.line.class</xd:li>
                <xd:li>poetry.last.line.class</xd:li>
                <xd:li>line-based.class.separator</xd:li>
            </xd:ul>

        </xd:desc>
    </xd:doc>
    <xsl:template match="db:poetry//db:line" mode="line-based.choose.class">

        <xsl:variable name="posn" select="position()"/>
        <xsl:variable name="total"
            select="count(preceding-sibling::db:line) + count(following-sibling::db:line) + 1"/>
        <xsl:variable name="even" select="$posn mod 2"/>

        <xsl:variable name="base-class">
            <xsl:call-template name="line-based.choose.class"/>
        </xsl:variable>

        <xsl:choose>

            <!-- generating line based classes -->
            <xsl:when test="number(normalize-space($poetry.generate.line.classes)) != 0">

                <!-- odd or even numbered line -->
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
                                <xsl:when
                                    test="number(normalize-space($poetry.generate.first.line.class)) != 0">
                                    <xsl:value-of
                                        select="concat($poetry.first.line.class, $line-based.class.separator, $poetry.odd.line.class)"
                                    />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:choose>

                            <!-- single line stanza/linegroup! -->
                            <xsl:when test="$posn=$total">
                                <xsl:choose>
                                    <xsl:when
                                        test="number(normalize-space($poetry.generate.last.line.class)) != 0">
                                        <xsl:value-of
                                            select="concat($first-line-class, $line-based.class.separator, $poetry.last.line.class)"
                                        />
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
                            <xsl:when
                                test="number(normalize-space($poetry.generate.last.line.class)) != 0">
                                <xsl:value-of
                                    select="concat($line-base-class, $line-based.class.separator, $poetry.last.line.class)"
                                />
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


</xsl:stylesheet>
