<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
    version="1.0">

    <xsl:import href="../xhtml-1_1/chunkfast.xsl"/>
   
    <xsl:param name='chunk.section.depth'>0</xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select="/*" mode="find.chunks"/>
    </xsl:template>

    <xsl:template match="*" mode="class.attribute">
        <xsl:param name="class" select="local-name(.)"/>
        <xsl:apply-imports>
            <xsl:with-param name="class" select="$class"/>
        </xsl:apply-imports>
        <xsl:attribute name="source-id">
            <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="chunk">
        <xsl:param name="node" select="."/>

        <!-- returns 1 if $node is a chunk -->

        <!-- adds some additional Penguin chunks 
                                   book/acknowledgements
                                   book/dedication
                                   part/acknowledgements
                                   part/dedication
                                   book/info/mediaobject[@role='cover']
                                   mediaobject[@role='full-page']
                                   figure[@role='full-page']
                            -->

        <!-- ==================================================================== -->
        <!-- What's a chunk?
                                
                                The root element
                                appendix
                                article
                                bibliography  in article or part or book
                                book
                                chapter
                                colophon
                                glossary      in article or part or book
                                index         in article or part or book
                                part
                                preface
                                refentry
                                reference
                                sect{1,2,3,4,5}  if position()>1 && depth < chunk.section.depth
                                section          if position()>1 && depth < chunk.section.depth
                                set
                                setindex
                            -->
        <!-- ==================================================================== -->

        <!--
                                <xsl:message>
                                <xsl:text>chunk: </xsl:text>
                                <xsl:value-of select="name($node)"/>
                                <xsl:text>(</xsl:text>
                                <xsl:value-of select="$node/@id"/>
                                <xsl:text>)</xsl:text>
                                <xsl:text> csd: </xsl:text>
                                <xsl:value-of select="$chunk.section.depth"/>
                                <xsl:text> cfs: </xsl:text>
                                <xsl:value-of select="$chunk.first.sections"/>
                                <xsl:text> ps: </xsl:text>
                                <xsl:value-of select="count($node/parent::section)"/>
                                <xsl:text> prs: </xsl:text>
                                <xsl:value-of select="count($node/preceding-sibling::section)"/>
                                </xsl:message>
                            -->


        <xsl:choose>
            <xsl:when
                test="$node/parent::*/processing-instruction('dbhtml')[normalize-space(.) = 'stop-chunking']"
                >0</xsl:when>
            <xsl:when test="not($node/parent::*)">1</xsl:when>

            <xsl:when
                test="local-name($node) = 'sect1'                     and $chunk.section.depth &gt;= 1                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::sect1) &gt; 0)">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:when
                test="local-name($node) = 'sect2'                     and $chunk.section.depth &gt;= 2                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::sect2) &gt; 0)">
                <xsl:call-template name="chunk">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="local-name($node) = 'sect3'                     and $chunk.section.depth &gt;= 3                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::sect3) &gt; 0)">
                <xsl:call-template name="chunk">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="local-name($node) = 'sect4'                     and $chunk.section.depth &gt;= 4                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::sect4) &gt; 0)">
                <xsl:call-template name="chunk">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="local-name($node) = 'sect5'                     and $chunk.section.depth &gt;= 5                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::sect5) &gt; 0)">
                <xsl:call-template name="chunk">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="local-name($node) = 'section'                     and $chunk.section.depth &gt;= count($node/ancestor::section|$node/ancestor::db:section)+1                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::section|$node/preceding-sibling::db:section) &gt; 0)">
                <xsl:call-template name="chunk">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="local-name($node)='preface'">1</xsl:when>
            <xsl:when test="local-name($node)='chapter'">1</xsl:when>
            <xsl:when test="local-name($node)='appendix'">1</xsl:when>
            <xsl:when test="local-name($node)='article'">1</xsl:when>
            <xsl:when test="local-name($node)='part'">1</xsl:when>
            <xsl:when test="local-name($node)='reference'">1</xsl:when>
            <xsl:when test="local-name($node)='refentry'">1</xsl:when>
            <xsl:when
                test="local-name($node)='index' and ($generate.index != 0 or count($node/*) &gt; 0)                     and (local-name($node/parent::*) = 'article'                     or local-name($node/parent::*) = 'book'                     or local-name($node/parent::*) = 'part'                     )"
                >1</xsl:when>
            <xsl:when
                test="local-name($node)='bibliography'                     and (local-name($node/parent::*) = 'article'                     or local-name($node/parent::*) = 'book'                     or local-name($node/parent::*) = 'part'                     )"
                >1</xsl:when>
            <xsl:when
                test="local-name($node)='glossary'                     and (local-name($node/parent::*) = 'article'                     or local-name($node/parent::*) = 'book'                     or local-name($node/parent::*) = 'part'                     )"
                >1</xsl:when>
            <xsl:when test="local-name($node)='colophon'">1</xsl:when>
            <xsl:when test="local-name($node)='book'">1</xsl:when>
            <xsl:when test="local-name($node)='set'">1</xsl:when>
            <xsl:when test="local-name($node)='setindex'">1</xsl:when>
            <xsl:when
                test="local-name($node)='legalnotice'                     and $generate.legalnotice.link != 0"
                >1</xsl:when>


            <!-- Penguin Additions -->
            <xsl:when
                test="local-name($node)='dedication'
                                        and (local-name($node/parent::*) = 'book' or local-name($node/parent::*) = 'part')"
                >1</xsl:when>
            <xsl:when
                test="local-name($node)='acknowledgements'
                                    and (local-name($node/parent::*) = 'book' or local-name($node/parent::*) = 'part')"
                >1</xsl:when>
            <xsl:when
                test="local-name($node) = 'mediaobject'
                                    and $node/@role = 'cover' and local-name($node/parent::*) = 'info'
                                    and local-name($node/parent::*/parent::*) = 'book'"
                >1</xsl:when>
            <xsl:when
                test="local-name($node) = 'mediaobject' 
                                    and $node/@role='full-page' and not(local-name($node/parent::*) = 'figure')"
                >1</xsl:when>
            <xsl:when test="local-name($node) = 'figure' and $node/@role='full-page' ">1</xsl:when>

            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
