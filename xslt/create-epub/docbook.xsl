<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:dc="http://purl.org/dc/elements/1.1/"  
  xmlns:exsl="http://exslt.org/common" 
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ng="http://docbook.org/docbook-ng"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:stext="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.TextFactory"
  xmlns:str="http://exslt.org/strings"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
xmlns:xtext="xalan://com.nwalsh.xalan.Text"

  extension-element-prefixes="stext xtext"
  exclude-result-prefixes="exsl db dc h ncx ng opf stext str xtext d"

  version="1.0">

  <xsl:import href="../xhtml-1_1/docbook.xsl" />
  <xsl:import href="../xhtml-1_1/chunk-common.xsl" />
  <xsl:include href="../xhtml-1_1/chunk-code.xsl" />


  <!-- We want a separate TOC file, please -->
  <xsl:param name="chunk.tocs.and.lots">1</xsl:param>
  <xsl:param name="toc.section.depth">2</xsl:param>
  <xsl:param name="generate.toc">
  book   toc,title
  </xsl:param>

  <xsl:param name="ade.extensions" select="0"/>
  <xsl:param name="epub.autolabel" select="'1'"/> 
 

 
  
  <xsl:param name="epub.cover.id" select="'cover'"/> 
  <xsl:param name="epub.cover.html" select="'cover.html'" />
  <xsl:param name="epub.cover.image.id" select="'cover-image'"/> 
  <xsl:param name="epub.cover.linear" select="0" />
  <xsl:param name="epub.ncx.toc.id">ncxtoc</xsl:param>
  <xsl:param name="epub.html.toc.id">htmltoc</xsl:param>
  <xsl:param name="epub.metainf.dir" select="'META-INF/'"/> 

  <xsl:param name="epub.embedded.fonts"></xsl:param>

  <!-- Turning this on crashes ADE, which is unbelievably awesome -->
  <xsl:param name="formal.object.break.after">0</xsl:param>


  <!-- Per Bob Stayton:
       """Process your documents with the css.decoration parameter set to zero. 
          That will avoid the use of style attributes in XHTML elements where they are not permitted."""
       http://www.sagehill.net/docbookxsl/OtherOutputForms.html#StrictXhtmlValid -->
  <xsl:param name="css.decoration" select="0"/>
  <xsl:param name="custom.css.source"></xsl:param> <!-- FIXME: Align with current CSS parameter design -->

  <xsl:param name="callout.graphics" select="1"/>
  <xsl:param name="callout.graphics.extension">.png</xsl:param>
  <xsl:param name="callout.graphics.number.limit" select="15"/>
  <xsl:param name="callout.graphics.path" select="'images/callouts/'"/>

  <!-- no navigation in .epub -->
  <xsl:param name="suppress.navigation" select="'1'"/> 

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="node" select="/*"/>
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="root.is.a.chunk">
    <xsl:choose>
      <xsl:when test="/*[not(self::d:book)][not(d:sect1) or not(d:section)]">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="/d:book[*[last()][self::d:bookinfo]]|d:book[d:bookinfo]">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="/d:book[*[last()][self::d:info]]|d:book[d:info]">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="/d:bibliography">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:key name="image-filerefs" match="d:graphic|d:inlinegraphic|d:imagedata" use="@fileref"/>

  <xsl:template match="/">
    <!-- * Get a title for current doc so that we let the user -->
    <!-- * know what document we are processing at this point. -->
    <xsl:variable name="doc.title">
      <xsl:call-template name="get.doc.title" />
    </xsl:variable>
    <xsl:choose>
      
      <!-- include extra test for Xalan quirk -->
      <xsl:when test="namespace-uri(*[1]) != 'http://docbook.org/ns/docbook'">
 <xsl:call-template name="log.message">
 <xsl:with-param name="level">Note</xsl:with-param>
 <xsl:with-param name="source" select="$doc.title"/>
 <xsl:with-param name="context-desc">
 <xsl:text>namesp. add</xsl:text>
 </xsl:with-param>
 <xsl:with-param name="message">
 <xsl:text>added namespace before processing</xsl:text>
 </xsl:with-param>
 </xsl:call-template>
 <xsl:variable name="addns">
    <xsl:apply-templates mode="addNS"/>
  </xsl:variable>
  <xsl:apply-templates select="exsl:node-set($addns)"/>
</xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$rootid != ''">
            <xsl:choose>
              <xsl:when
                test="count(key('id',$rootid)) = 0">
                <xsl:message terminate="yes">
                  <xsl:text>ID '</xsl:text>
                  <xsl:value-of select="$rootid" />
                  <xsl:text>' not found in document.</xsl:text>
                </xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if
                  test="$collect.xref.targets = 'yes' or
                                $collect.xref.targets = 'only'">
                  <xsl:apply-templates
                    select="key('id', $rootid)" mode="collect.targets" />
                </xsl:if>
                <xsl:if
                  test="$collect.xref.targets != 'only'">
                  <xsl:message>
                    Formatting from
                    <xsl:value-of select="$rootid" />
                  </xsl:message>
                  <xsl:apply-templates
                    select="key('id',$rootid)" mode="process.root" />
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if
              test="$collect.xref.targets = 'yes' or
                    $collect.xref.targets = 'only'">
              <xsl:apply-templates select="/"
                mode="collect.targets" />
            </xsl:if>
            <xsl:if
              test="$collect.xref.targets != 'only'">
              <xsl:apply-templates select="/"
                mode="process.root" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="html.head">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:variable name="this" select="."/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>

    <head xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="system.head.content"/>
      <xsl:call-template name="head.content"/>

      <xsl:call-template name="user.head.content"/>
    </head>
  </xsl:template>

  <!-- OVERRIDES xhtml-1_1/graphics.xsl -->
  <!-- we can't deal with no img/@alt, because it's required. Try grabbing a title before it instead (hopefully meaningful) -->
  <xsl:template name="process.image.attributes">
    <xsl:param name="alt"/>
    <xsl:param name="html.width"/>
    <xsl:param name="html.depth"/>
    <xsl:param name="longdesc"/>
    <xsl:param name="scale"/>
    <xsl:param name="scalefit"/>
    <xsl:param name="scaled.contentdepth"/>
    <xsl:param name="scaled.contentwidth"/>
    <xsl:param name="viewport"/>

    <xsl:choose>
      <xsl:when test="@contentwidth or @contentdepth">
        <!-- ignore @width/@depth, @scale, and @scalefit if specified -->
        <xsl:if test="@contentwidth and $scaled.contentwidth != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="$scaled.contentwidth"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@contentdepth and $scaled.contentdepth != ''">
          <xsl:attribute name="height">
            <xsl:value-of select="$scaled.contentdepth"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>

      <xsl:when test="number($scale) != 1.0">
        <!-- scaling is always uniform, so we only have to specify one dimension -->
        <!-- ignore @scalefit if specified -->
        <xsl:attribute name="width">
          <xsl:value-of select="$scaled.contentwidth"/>
        </xsl:attribute>
      </xsl:when>

      <xsl:when test="$scalefit != 0">
        <xsl:choose>
          <xsl:when test="contains($html.width, '%')">
            <xsl:choose>
              <xsl:when test="$viewport != 0">
                <!-- The *viewport* will be scaled, so use 100% here! -->
                <xsl:attribute name="width">
                  <xsl:value-of select="'100%'"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="width">
                  <xsl:value-of select="$html.width"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:when test="contains($html.depth, '%')">
            <!-- HTML doesn't deal with this case very well...do nothing -->
          </xsl:when>

          <xsl:when test="$scaled.contentwidth != '' and $html.width != ''                         and $scaled.contentdepth != '' and $html.depth != ''">
            <!-- scalefit should not be anamorphic; figure out which direction -->
            <!-- has the limiting scale factor and scale in that direction -->
            <xsl:choose>
              <xsl:when test="$html.width div $scaled.contentwidth &gt;                             $html.depth div $scaled.contentdepth">
                <xsl:attribute name="height">
                  <xsl:value-of select="$html.depth"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="width">
                  <xsl:value-of select="$html.width"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:when test="$scaled.contentwidth != '' and $html.width != ''">
            <xsl:attribute name="width">
              <xsl:value-of select="$html.width"/>
            </xsl:attribute>
          </xsl:when>

          <xsl:when test="$scaled.contentdepth != '' and $html.depth != ''">
            <xsl:attribute name="height">
              <xsl:value-of select="$html.depth"/>
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>

    <!-- AN OVERRIDE -->
    <xsl:if test="not(@format ='SVG')">
      <xsl:attribute name="alt">
        <xsl:choose>
          <xsl:when test="$alt != ''">
            <xsl:value-of select="normalize-space($alt)"/>
          </xsl:when>
          <xsl:when test="preceding::d:title[1]">
            <xsl:value-of select="normalize-space(preceding::d:title[1])"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>(missing alt)</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <!-- END OF OVERRIDE -->

    <xsl:if test="$longdesc != ''">
      <xsl:attribute name="longdesc">
        <xsl:value-of select="$longdesc"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="@align and $viewport = 0">
      <xsl:attribute name="style"><xsl:text>text-align: </xsl:text>
        <xsl:choose>
          <xsl:when test="@align = 'center'">middle</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@align"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <!-- OVERRIDES xhtml-1_1/chunk-common.xsl   -->
  <!-- make a bibliography always a chunk -->
  <xsl:template name="chunk"
                priority="1">       
    <xsl:param name="node" select="."/>
    <!-- returns 1 if $node is a chunk -->

    <!-- ==================================================================== -->
    <!-- What's a chunk?

        The root element
        appendix
        article
        bibliography  ### NO LONGER TRUE in article or part or book
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
      <xsl:value-of select="count($node/parent::d:section)"/>
      <xsl:text> prs: </xsl:text>
      <xsl:value-of select="count($node/preceding-sibling::d:section)"/>
    </xsl:message>
  -->

    <xsl:choose>
      <xsl:when test="not($node/parent::*)">1</xsl:when>

      <xsl:when test="local-name($node) = 'sect1'                     and $chunk.section.depth &gt;= 1                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:sect1) &gt; 0)">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect2'                     and $chunk.section.depth &gt;= 2                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:sect2) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect3'                     and $chunk.section.depth &gt;= 3                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:sect3) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect4'                     and $chunk.section.depth &gt;= 4                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:sect4) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect5'                     and $chunk.section.depth &gt;= 5                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:sect5) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'section'                     and $chunk.section.depth &gt;= count($node/ancestor::d:section)+1                     and ($chunk.first.sections != 0                          or count($node/preceding-sibling::d:section) &gt; 0)">
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
      <xsl:when test="local-name($node)='index' and ($generate.index != 0 or count($node/*) &gt; 0)                     and (local-name($node/parent::*) = 'article'                     or local-name($node/parent::*) = 'book'                     or local-name($node/parent::*) = 'part'                     )">1</xsl:when>
      <!-- AN OVERRIDE -->
      <xsl:when test="local-name($node)='bibliography'">1</xsl:when>
      <!-- END OF OVERRIDE -->
      <xsl:when test="local-name($node)='glossary'                     and (local-name($node/parent::*) = 'article'                     or local-name($node/parent::*) = 'book'                     or local-name($node/parent::*) = 'part'                     )">1</xsl:when>
      <xsl:when test="local-name($node)='colophon'">1</xsl:when>
      <xsl:when test="local-name($node)='book'">1</xsl:when>
      <xsl:when test="local-name($node)='set'">1</xsl:when>
      <xsl:when test="local-name($node)='setindex'">1</xsl:when>
      <xsl:when test="local-name($node)='legalnotice'                     and $generate.legalnotice.link != 0">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- OVERRIDES xhtml-1_1/chunk-code.xsl   -->
  <!-- Add chunking for bibliography as root element -->
  <!-- AN OVERRIDE --> 
  <xsl:template match="d:set|
                       d:book|
                       d:part|
                       d:preface|
                       d:chapter|
                       d:appendix|
                       d:article|
                       d:reference|
                       d:refentry|
                       d:book/d:glossary|
                       d:article/d:glossary|
                       d:part/d:glossary|
                       d:bibliography|
                       d:colophon"
                priority="1">       
  <!-- END OF OVERRIDE --> 
    <xsl:choose>
      <xsl:when test="$onechunk != 0 and parent::*">
        <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process-chunk-element"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- OVERRIDES xhtml-1_1/graphics.xsl   -->
  <!-- Do _NOT_ output any xlink garbage, so if you don't have 
       processor with extensions, you're screwed and we're terminating -->
  <xsl:template match="d:inlinegraphic">
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="@entityref">
          <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@fileref"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="anchor"/>

    <xsl:choose>
      <xsl:when test="@format='linespecific'">
        <xsl:choose>
          <xsl:when test="$use.extensions != '0'                         and $textinsert.extension != '0'">
            <xsl:choose>
              <xsl:when test="element-available('stext:insertfile')">
                <stext:insertfile href="{$filename}" encoding="{$textdata.default.encoding}"/>
              </xsl:when>
              <xsl:when test="element-available('xtext:insertfile')">
                <xtext:insertfile href="{$filename}"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">
                  <xsl:text>No insertfile extension available.</xsl:text>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <!-- AN OVERRIDE --> 
            <xsl:message terminate="yes">
              <xsl:text>No insertfile extension available. Use a different processor (with extensions) or turn on $use.extensions and $textinsert.extension (see docs for more).  </xsl:text>
            </xsl:message>
            <!-- END OF OVERRIDE --> 
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process.image"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  

  <xsl:template name="cover">
    <xsl:apply-templates select="/*/*[contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"/>
  </xsl:template>  

  <xsl:template match="/*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]">
    <xsl:call-template name="write.chunk">
      <xsl:with-param name="filename">
        <xsl:value-of select="$epub.cover.filename" />
      </xsl:with-param>
      <xsl:with-param name="method" select="'xml'" />
      <xsl:with-param name="encoding" select="'utf-8'" />
      <xsl:with-param name="indent" select="'no'" />
      <xsl:with-param name="quiet" select="$chunk.quietly" />
      <xsl:with-param name="content">
        <xsl:element namespace="http://www.w3.org/1999/xhtml" name="html">
          <xsl:element namespace="http://www.w3.org/1999/xhtml" name="head">
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="title">Cover</xsl:element>
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="style">
              <xsl:attribute name="type">text/css</xsl:attribute>
              <!-- Help the cover image scale nicely in the CSS then apply a max-width to look better in Adobe Digital Editions -->
              <xsl:text> img { max-width: 100%; }</xsl:text>
            </xsl:element>
          </xsl:element>
          <xsl:element namespace="http://www.w3.org/1999/xhtml" name="body">
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="div">
              <xsl:attribute name="id">
                <xsl:value-of select="$epub.cover.image.id"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="d:imageobject[@role='front-large']">
                  <xsl:apply-templates select="d:imageobject[@role='front-large']"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="d:imageobject[1]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
            <!-- If this is defined as an explicit cover page, then process
            any remaining text -->
            <xsl:if test="ancestor::d:cover">
              <xsl:apply-templates select="ancestor::d:cover/d:para"/>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:with-param>  
    </xsl:call-template>  
  </xsl:template>

  <xsl:template name="cover-svg">
    <xsl:param name="node"/>
  </xsl:template>

  <xsl:template name="toc-href">
    <xsl:param name="node" select="."/>
    <xsl:apply-templates select="$node" mode="recursive-chunk-filename">
      <xsl:with-param name="recursive" select="true()"/>
    </xsl:apply-templates>
    <xsl:text>-toc</xsl:text>
    <xsl:value-of select="$html.ext"/>
  </xsl:template>

  <xsl:template match="d:bibliodiv[d:title]" mode="label.markup">
  </xsl:template>

  <xsl:template match="d:token" mode="opf.manifest.font">
    <xsl:call-template name="embedded-font-item">
      <xsl:with-param name="font.file" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="embedded-font-item">
    <xsl:param name="font.file"/>
    <xsl:param name="font.order" select="1"/>

    <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('epub.embedded.font.', $font.order)"/>
      </xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="$font.file"/></xsl:attribute>
      <xsl:choose>
        <xsl:when test="contains($font.file, 'otf')">
          <xsl:attribute name="media-type">font/opentype</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING: OpenType fonts should be supplied! (</xsl:text>
            <xsl:value-of select="$font.file"/>
            <xsl:text>)</xsl:text>
          </xsl:message>
        </xsl:otherwise>  
      </xsl:choose>
    </xsl:element>
  </xsl:template>

<!-- Change section.heading to improve SEO on generated HTML by doing heading levels 
     "correctly". SEO rules are sometimes silly silly, but this does actually create 
     a semantic improvement.
     Note: This template needs to be manually maintained outside of the html/sections.xsl 
     code, so make sure important changes get reintegrated. -->
<xsl:template name="section.heading">
  <xsl:param name="section" select="."/>
  <xsl:param name="level" select="1"/>
  <xsl:param name="allow-anchors" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="class" select="'title'"/>

  <xsl:variable name="id">
    <xsl:choose>
      <!-- Make sure the subtitle doesn't get the same id as the title -->
      <xsl:when test="self::d:subtitle">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <!-- if title is in an *info wrapper, get the grandparent -->
      <xsl:when test="contains(local-name(..), 'info')">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="../.."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- For SEO, we try to actually ensure we *always* output one and only one h1,
       so unlike the regular stylesheets, we don't add one to the section level and
       we get the right behavior because of chunking. -->
  <xsl:variable name="hlevel">
    <xsl:choose>
      <!-- highest valid HTML H level is H6; so anything nested deeper
           than 7 levels down just becomes H6 -->
      <xsl:when test="$level &gt; 6">6</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:element name="h{$hlevel}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
    <xsl:if test="$css.decoration != '0'">
      <xsl:if test="$hlevel&lt;3">
        <xsl:attribute name="style">clear: both</xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$allow-anchors != 0 and $generate.id.attributes = 0">
      <xsl:call-template name="anchor">
        <xsl:with-param name="node" select="$section"/>
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$generate.id.attributes != 0 and not(local-name(.) = 'appendix')">
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$title"/>
  </xsl:element>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:bridgehead">
  <xsl:variable name="container" select="(ancestor::d:appendix                         |ancestor::d:article                         |ancestor::d:bibliography                         |ancestor::d:chapter                         |ancestor::d:glossary                         |ancestor::d:glossdiv                         |ancestor::d:index                         |ancestor::d:partintro                         |ancestor::d:preface                         |ancestor::d:refsect1                         |ancestor::d:refsect2                         |ancestor::d:refsect3                         |ancestor::d:sect1                         |ancestor::d:sect2                         |ancestor::d:sect3                         |ancestor::d:sect4                         |ancestor::d:sect5                         |ancestor::d:section                         |ancestor::d:setindex                         |ancestor::d:simplesect)[last()]"/>

  <xsl:variable name="clevel">
    <xsl:choose>
      <xsl:when test="local-name($container) = 'appendix'                       or local-name($container) = 'chapter'                       or local-name($container) = 'article'                       or local-name($container) = 'bibliography'                       or local-name($container) = 'glossary'                       or local-name($container) = 'index'                       or local-name($container) = 'partintro'                       or local-name($container) = 'preface'                       or local-name($container) = 'setindex'">1</xsl:when>
      <xsl:when test="local-name($container) = 'glossdiv'">
        <xsl:value-of select="count(ancestor::d:glossdiv)+1"/>
      </xsl:when>
      <xsl:when test="local-name($container) = 'sect1'                       or local-name($container) = 'sect2'                       or local-name($container) = 'sect3'                       or local-name($container) = 'sect4'                       or local-name($container) = 'sect5'                       or local-name($container) = 'refsect1'                       or local-name($container) = 'refsect2'                       or local-name($container) = 'refsect3'                       or local-name($container) = 'section'                       or local-name($container) = 'simplesect'">
        <xsl:variable name="slevel">
          <xsl:call-template name="section.level">
            <xsl:with-param name="node" select="$container"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$slevel + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- HTML H level is one higher than section level -->
  <xsl:variable name="hlevel">
    <xsl:choose>
      <xsl:when test="@renderas = 'sect1'">1</xsl:when>
      <xsl:when test="@renderas = 'sect2'">2</xsl:when>
      <xsl:when test="@renderas = 'sect3'">3</xsl:when>
      <xsl:when test="@renderas = 'sect4'">4</xsl:when>
      <xsl:when test="@renderas = 'sect5'">5</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$clevel + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$hlevel}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- SEO customization #2 -->
<xsl:template name="component.title">
  <xsl:param name="node" select="."/>

  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="ancestor::d:section">
        <xsl:value-of select="count(ancestor::d:section)+1"/>
      </xsl:when>
      <xsl:when test="ancestor::d:sect5">6</xsl:when>
      <xsl:when test="ancestor::d:sect4">5</xsl:when>
      <xsl:when test="ancestor::d:sect3">4</xsl:when>
      <xsl:when test="ancestor::d:sect2">3</xsl:when>
      <xsl:when test="ancestor::d:sect1">2</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$level}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:if test="$generate.id.attributes = 0">
      <xsl:call-template name="anchor">
	<xsl:with-param name="node" select="$node"/>
	<xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
    </xsl:if>
      <xsl:apply-templates select="$node" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
