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
  <xsl:param name="epub.ncx.depth">4</xsl:param> <!-- Not functional until http://code.google.com/p/epubcheck/issues/detail?id=70 is resolved -->


  <xsl:param name="manifest.in.base.dir" select="'1'"/> 
  <xsl:param name="base.dir" select="$epub.oebps.dir"/>

  <xsl:param name="epub.oebps.dir" select="'OEBPS/'"/> 
  <xsl:param name="epub.ncx.filename" select="'toc.ncx'"/> 
  <xsl:param name="epub.container.filename" select="'container.xml'"/> 
  <xsl:param name="epub.opf.filename" select="concat($epub.oebps.dir, 'content.opf')"/> 
  <xsl:param name="epub.cover.filename" select="concat($epub.oebps.dir, 'cover', $html.ext)"/> 
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
                  <xsl:call-template name="ncx" />
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
              <xsl:call-template name="ncx" />
              <xsl:call-template name="opf" />
              <xsl:call-template name="cover" />
              <!--          
              NG - removed as we create our own later 
              <xsl:call-template name="container" />
              -->
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="package-identifier">  
    <xsl:choose>
      <xsl:when test="/*/*[contains(name(.), 'info')]/d:biblioid">
        <xsl:if test="/*/*[contains(name(.), 'info')][1]/d:biblioid[1][@class = 'doi' or 
                                                                      @class = 'isbn' or
                                                                      @class = 'isrn' or
                                                                      @class = 'issn']">
          <xsl:text>urn:</xsl:text>
          <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:biblioid[1]/@class"/>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:biblioid[1]"/>
      </xsl:when>
      <xsl:when test="/*/*[contains(name(.), 'info')]/d:isbn">
        <xsl:text>urn:isbn:</xsl:text>
        <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:isbn[1]"/>
      </xsl:when>
      <xsl:when test="/*/*[contains(name(.), 'info')]/d:issn">
        <xsl:text>urn:issn:</xsl:text>
        <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:issn[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:invpartnumber"> <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:invpartnumber[1]"/> </xsl:when>
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:issuenum">      <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:issuenum[1]"/> </xsl:when>
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:productnumber"> <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:productnumber[1]"/> </xsl:when>
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:seriesvolnums"> <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:seriesvolnums[1]"/> </xsl:when>
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:volumenum">     <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:volumenum[1]"/> </xsl:when>
          <!-- Deprecated -->
          <xsl:when test="/*/*[contains(name(.), 'info')]/d:pubsnumber">    <xsl:value-of select="/*/*[contains(name(.), 'info')][1]/d:pubsnumber[1]"/> </xsl:when>
        </xsl:choose>  
        <xsl:text>_</xsl:text>
        <xsl:choose>
          <xsl:when test="/*/@id">
            <xsl:value-of select="/*/@id"/>
          </xsl:when>
          <xsl:when test="/*/@xml:id">
            <xsl:value-of select="/*/@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- TODO: Do UUIDs here -->
            <xsl:value-of select="generate-id(/*)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="opf">
    <xsl:variable name="package-identifier-id"><xsl:value-of select="concat(name(/*), 'id')"/></xsl:variable>
    <xsl:variable name="doc.title">
      <xsl:call-template name="get.doc.title" />
    </xsl:variable>
    <xsl:call-template name="write.chunk">
      <xsl:with-param name="filename">
        <xsl:value-of select="$epub.opf.filename" />
      </xsl:with-param>
      <xsl:with-param name="method" select="'xml'" />
      <xsl:with-param name="encoding" select="'utf-8'" />
      <xsl:with-param name="indent" select="'no'" />
      <xsl:with-param name="quiet" select="$chunk.quietly" />
      <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank -->
      <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank -->
      <xsl:with-param name="content">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="package">
          <xsl:attribute name="version">2.0</xsl:attribute>
          <xsl:attribute name="unique-identifier"> <xsl:value-of select="$package-identifier-id"/> </xsl:attribute>

          <xsl:element namespace="http://www.idpf.org/2007/opf" name="metadata">
            <xsl:element name="dc:identifier">
              <xsl:attribute name="id"><xsl:value-of select="$package-identifier-id"/></xsl:attribute>
              <xsl:call-template name="package-identifier"/>
            </xsl:element>  

            <xsl:element name="dc:title">
              <xsl:value-of select="normalize-space($doc.title)"/>
            </xsl:element>

            <xsl:apply-templates select="/*/*[contains(name(.), 'info')]/*"
                                 mode="opf.metadata"/>        
            <xsl:element name="dc:language">
              <xsl:call-template name="l10n.language">
                <xsl:with-param name="target" select="/*"/>
              </xsl:call-template>  
            </xsl:element>

            <xsl:if test="/*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"> 
              <xsl:element namespace="http://www.idpf.org/2007/opf" name="meta">
                <xsl:attribute name="name">cover</xsl:attribute>
                <xsl:attribute name="content">
                  <xsl:value-of select="$epub.cover.image.id"/>
                </xsl:attribute>
              </xsl:element>
            </xsl:if>

          </xsl:element>
          <xsl:call-template name="opf.manifest"/>
          <xsl:call-template name="opf.spine"/>
          <xsl:call-template name="opf.guide"/>

        </xsl:element>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  
 
 <xsl:template match="*" mode="opf.metadata">
    <!-- override if you care -->
  </xsl:template>

  <xsl:template match="d:authorgroup" mode="opf.metadata">
    <xsl:apply-templates select="d:author|d:corpauthor" mode="opf.metadata"/>
  </xsl:template>

  <xsl:template match="d:author|d:corpauthor" mode="opf.metadata">
    <xsl:variable name="n">
      <xsl:call-template name="person.name">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="dc:creator">
      <xsl:attribute name="opf:file-as">
        <xsl:call-template name="person.name.last-first">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="normalize-space(string($n))"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:date" mode="opf.metadata">
    <xsl:element name="dc:date">
      <xsl:value-of select="normalize-space(string(.))"/>
    </xsl:element>
  </xsl:template>


  <!-- Space separate the compontents of the abstract (dropping the inline markup, sadly) -->
  <xsl:template match="d:abstract" mode="opf.metadata">
    <xsl:element name="dc:description">
      <xsl:for-each select="d:formalpara|d:para|d:simpara|d:title">
        <xsl:choose>
          <xsl:when test="self::d:formalpara">
            <xsl:value-of select="normalize-space(string(d:title))"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="normalize-space(string(d:para))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(string(.))"/>
          </xsl:otherwise>  
        </xsl:choose>
        <xsl:if test="self::d:title">
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:if test="not(position() = last())">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>  
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:subjectset" mode="opf.metadata">
    <xsl:apply-templates select="d:subject/d:subjectterm" mode="opf.metadata"/>
  </xsl:template>
  
  <xsl:template match="d:subjectterm" mode="opf.metadata">
    <xsl:element name="dc:subject">
      <xsl:value-of select="normalize-space(string(.))"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:publisher" mode="opf.metadata">
    <xsl:apply-templates select="d:publishername" mode="opf.metadata"/>
  </xsl:template>
  
  <xsl:template match="d:publishername" mode="opf.metadata">
    <xsl:element name="dc:publisher">
      <xsl:value-of select="normalize-space(string(.))"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:copyright" mode="opf.metadata">
    <xsl:variable name="copyright.date">
      <xsl:call-template name="copyright.years">
        <xsl:with-param name="years" select="d:year"/>
        <xsl:with-param name="print.ranges" select="$make.year.ranges"/>
        <xsl:with-param name="single.year.ranges" select="$make.single.year.ranges"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="not(../d:date)">
      <xsl:element name="dc:date">
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="d:year[last()]"/>
          <xsl:with-param name="print.ranges" select="0"/>
          <xsl:with-param name="single.year.ranges" select="0"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:if>
    <xsl:element name="dc:rights">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'Copyright'"/>
      </xsl:call-template>
      <xsl:call-template name="gentext.space"/>
      <xsl:text>&#x00A9;</xsl:text>
      <xsl:call-template name="gentext.space"/>
      <xsl:value-of select="$copyright.date"/>
      <xsl:call-template name="gentext.space"/>
      <xsl:apply-templates select="d:holder" mode="titlepage.mode"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="opf.guide">
    <xsl:if test="contains($toc.params, 'toc') or 
                  /*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"> 
      <xsl:element namespace="http://www.idpf.org/2007/opf" name="guide">
        <xsl:if test="/*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"> 
          <xsl:element namespace="http://www.idpf.org/2007/opf" name="reference">
            <xsl:attribute name="href">
              <xsl:value-of select="$epub.cover.html" />
            </xsl:attribute>
            <xsl:attribute name="type">cover</xsl:attribute>
            <xsl:attribute name="title">Cover</xsl:attribute>
          </xsl:element>
        </xsl:if>  

        <xsl:if test="contains($toc.params, 'toc')">
          <xsl:element namespace="http://www.idpf.org/2007/opf" name="reference">
            <xsl:attribute name="href">
              <xsl:call-template name="toc-href">
                <xsl:with-param name="node" select="/*"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="type">toc</xsl:attribute>
            <xsl:attribute name="title">Table of Contents</xsl:attribute>
          </xsl:element>
        </xsl:if>  
      </xsl:element>  
    </xsl:if>  
  </xsl:template>

  <xsl:template name="opf.spine">

    <xsl:element namespace="http://www.idpf.org/2007/opf" name="spine">
      <xsl:attribute name="toc">
        <xsl:value-of select="$epub.ncx.toc.id"/>
      </xsl:attribute>

      <xsl:if test="/*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"> 
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref">
            <xsl:value-of select="$epub.cover.id"/>
          </xsl:attribute>
          <xsl:attribute name="linear">
          <xsl:choose>
            <xsl:when test="$epub.cover.linear">
              <xsl:text>yes</xsl:text>
            </xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
          </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>


      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref"> <xsl:value-of select="$epub.html.toc.id"/> </xsl:attribute>
          <xsl:attribute name="linear">yes</xsl:attribute>
        </xsl:element>
      </xsl:if>  

      <!-- TODO: be nice to have a idref="titlepage" here -->
      <xsl:choose>
        <xsl:when test="$root.is.a.chunk != '0'">
          <xsl:apply-templates select="/*" mode="opf.spine"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/*/*" mode="opf.spine"/>
        </xsl:otherwise>
      </xsl:choose>
                                   
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="opf.spine">
    <xsl:variable name="is.chunk">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$is.chunk != 0">
      <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
        <xsl:attribute name="idref">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="*|.//d:refentry" mode="opf.spine"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="opf.manifest">
    <xsl:element namespace="http://www.idpf.org/2007/opf" name="manifest">
      <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
        <xsl:attribute name="id"> <xsl:value-of select="$epub.ncx.toc.id"/> </xsl:attribute>
        <xsl:attribute name="media-type">application/x-dtbncx+xml</xsl:attribute>
        <xsl:attribute name="href"><xsl:value-of select="$epub.ncx.filename"/> </xsl:attribute>
      </xsl:element>

      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
          <xsl:attribute name="id"> <xsl:value-of select="$epub.html.toc.id"/> </xsl:attribute>
          <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
          <xsl:attribute name="href">
            <xsl:call-template name="toc-href">
              <xsl:with-param name="node" select="/*"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>  

      <xsl:if test="$html.stylesheet != ''">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
          <xsl:attribute name="media-type">text/css</xsl:attribute>
          <xsl:attribute name="id">css</xsl:attribute>
          <xsl:attribute name="href"><xsl:value-of select="$html.stylesheet"/></xsl:attribute>
        </xsl:element>
      </xsl:if>

      <xsl:if test="/*/*[d:cover or contains(name(.), 'info')]//d:mediaobject[@role='cover' or ancestor::d:cover]"> 
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
          <xsl:attribute name="id"> <xsl:value-of select="$epub.cover.id"/> </xsl:attribute>
          <xsl:attribute name="href"> 
            <xsl:value-of select="$epub.cover.html"/>
          </xsl:attribute>
          <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
        </xsl:element>
      </xsl:if>  

      <xsl:choose>
        <xsl:when test="$epub.embedded.fonts != '' and not(contains($epub.embedded.fonts, ','))">
          <xsl:call-template name="embedded-font-item">
            <xsl:with-param name="font.file" select="$epub.embedded.fonts"/> <!-- There is just one -->
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$epub.embedded.fonts != ''">
          <xsl:variable name="font.file.tokens" select="str:tokenize($epub.embedded.fonts, ',')"/>
          <xsl:for-each select="exsl:node-set($font.file.tokens)">
            <xsl:call-template name="embedded-font-item">
              <xsl:with-param name="font.file" select="."/>
              <xsl:with-param name="font.order" select="position()"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>

      <!-- TODO: be nice to have a id="titlepage" here -->
      <xsl:apply-templates select="//d:part|
                                   //d:book[*[last()][self::d:bookinfo]]|
                                   //d:book[d:bookinfo]|
                                   /d:set|
                                   /d:set/d:book|
                                   //d:reference|
                                   //d:preface|
                                   //d:chapter|
                                   //d:bibliography|
                                   //d:appendix|
                                   //d:article|
                                   //d:glossary|
                                   //d:section|
                                   //d:sect1|
                                   //d:sect2|
                                   //d:sect3|
                                   //d:sect4|
                                   //d:sect5|
                                   //d:refentry|
                                   //d:colophon|
                                   //d:bibliodiv[d:title]|
                                   //d:index|
                                   //d:setindex|
                                   //d:graphic|
                                   //d:inlinegraphic|
                                   //d:mediaobject|
                                   //d:mediaobjectco|
                                   //d:inlinemediaobject" 
                           mode="opf.manifest"/>
      <xsl:call-template name="opf.calloutlist"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="opf.calloutlist">
    <xsl:variable name="format">
      <xsl:call-template name="guess-media-type">
        <xsl:with-param name="ext" select="$callout.graphics.extension"/>
      </xsl:call-template>
    </xsl:variable>  
    <xsl:if test="(//d:calloutlist|//d:co)">
      <xsl:call-template name="opf.reference.callout">
        <xsl:with-param name="conum" select="1"/>
        <xsl:with-param name="format" select="$format"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="opf.reference.callout">
    <xsl:param name="conum"/>
    <xsl:param name="format"/>

    <xsl:variable name="filename" select="concat($callout.graphics.path, $conum, $callout.graphics.extension)"/>

    <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
      <xsl:attribute name="id"> <xsl:value-of select="concat(generate-id(.), 'callout', $conum)"/> </xsl:attribute>
      <xsl:attribute name="href"> <xsl:value-of select="$filename"/> </xsl:attribute>
      <xsl:attribute name="media-type">
        <xsl:value-of select="$format"/>
      </xsl:attribute>
    </xsl:element>
    <xsl:if test="($conum &lt; $callout.graphics.number.limit)">
      <xsl:call-template name="opf.reference.callout">
        <xsl:with-param name="conum" select="$conum + 1"/>
        <xsl:with-param name="format" select="$format"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="guess-media-type">
    <xsl:param name="ext"></xsl:param>
    <xsl:choose>
      <xsl:when test="contains($ext, '.gif')">
        <xsl:text>image/gif</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, 'GIF')">
        <xsl:text>image/gif</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, '.png')">
        <xsl:text>image/png</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, 'PNG')">
        <xsl:text>image/png</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, '.jpeg')">
        <xsl:text>image/jpeg</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, 'JPEG')">
        <xsl:text>image/jpeg</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, '.jpg')">
        <xsl:text>image/jpeg</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, 'JPG')">
        <xsl:text>image/jpeg</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, '.svg')">
        <xsl:text>image/svg+xml</xsl:text>
      </xsl:when>
      <xsl:when test="contains($ext, 'SVG')">
        <xsl:text>image/svg+xml</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- we failed -->
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:mediaobject|
                       d:mediaobjectco|
                       d:inlinemediaobject" 
                mode="opf.manifest">

    <xsl:variable name="olist" select="d:imageobject|d:imageobjectco                      |d:videoobject|d:audioobject                      |d:textobject"/>

    <xsl:variable name="object.index">
      <xsl:call-template name="select.mediaobject.index">
        <xsl:with-param name="olist" select="$olist"/>
        <xsl:with-param name="count" select="1"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="object" select="$olist[position() = $object.index]"/>

    <xsl:choose>
      <xsl:when test="$object/descendant::d:imagedata[@format = 'GIF' or 
                                                    @format = 'GIF87a' or 
                                                    @format = 'GIF89a' or 
                                                    @format = 'JPEG' or 
                                                    @format = 'JPG' or 
                                                    @format = 'PNG' or 
                                                    @format = 'SVG']">
        <xsl:apply-templates select="$object[descendant::d:imagedata[@format = 'GIF' or 
                                                                   @format = 'GIF87a' or 
                                                                   @format = 'GIF89a' or 
                                                                   @format = 'JPEG' or 
                                                                   @format = 'JPG' or 
                                                                   @format = 'PNG' or 
                                                                   @format = 'SVG']][1]/d:imagedata"
                             mode="opf.manifest"/>              
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$object/d:imagedata[1]"
                             mode="opf.manifest"/>              
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>

  <xsl:template match="d:cover/d:mediaobject|
                       d:mediaobject[@role='cover']"
                mode="opf.manifest">
    <xsl:choose>
      <xsl:when test="d:imageobject[@role='front-large']">
        <xsl:apply-templates select="d:imageobject[@role='front-large']/d:imagedata"
                             mode="opf.manifest"/>              
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="d:imageobject/d:imagedata[1]"
                             mode="opf.manifest"/>              
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>

  <xsl:template match="d:mediaobjectco"
                mode="opf.manifest">
    <xsl:message>WARNING: mediaobjectco almost certainly will not render as expected in .epub!</xsl:message>
    <xsl:apply-templates select="d:imageobjectco/d:imageobject/d:imagedata" 
                         mode="opf.manifest"/>              
  </xsl:template>

  <!-- TODO: Barf (xsl:message terminate=yes) if you find a graphic with no reasonable format or a mediaobject w/o same? [option to not die?] -->

  <!-- wish I had XSLT2 ...-->
  <!-- TODO: priority a hack -->
  <xsl:template match="d:graphic[not(@format)]|
                       d:inlinegraphic[not(@format)]|
                       d:imagedata[not(@format)]"
                mode="opf.manifest">        
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="contains(name(.), 'graphic')">
          <xsl:choose>
            <xsl:when test="@entityref">
              <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="@fileref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="mediaobject.filename">
            <xsl:with-param name="object" select=".."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>  
    <xsl:variable name="format"> 
      <xsl:call-template name="guess-media-type">
        <xsl:with-param name="ext" select="@fileref"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fr" select="@fileref"/>
    <xsl:if test="$format != ''">
      <!-- only do this if we're the first file to match -->
      <!-- TODO: Why can't this be simple equality?? (I couldn't get it to work) -->
      <xsl:if test="generate-id(.) = generate-id(key('image-filerefs', $fr)[1])">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
          <xsl:attribute name="id"> 
            <xsl:choose>
              <xsl:when test="ancestor::d:mediaobject[@role='cover'] and parent::*[@role='front-large']">
                <xsl:value-of select="$epub.cover.image.id"/>
              </xsl:when>
              <xsl:when test="ancestor::d:mediaobject[@role='cover'] and (count(ancestor::d:mediaobject//d:imageobject) = 1)">
                <xsl:value-of select="$epub.cover.image.id"/>
              </xsl:when>
              <xsl:when test="ancestor::d:cover">
                <xsl:value-of select="$epub.cover.image.id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="generate-id(.)"/> 
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>  
          <xsl:attribute name="href"> <xsl:value-of select="$filename"/> </xsl:attribute>
          <xsl:attribute name="media-type">
            <xsl:value-of select="$format"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Note: Selection of the first interesting imagedata is done in the select -->
  <xsl:template match="d:graphic[@format = 'GIF' or @format = 'GIF87a' or @format = 'GIF89a' or @format = 'JPEG' or @format = 'JPG' or @format = 'PNG' or @format = 'SVG']|
                       d:inlinegraphic[@format = 'GIF' or @format = 'GIF87a' or @format = 'GIF89a' or @format = 'JPEG' or @format = 'JPG' or @format = 'PNG' or @format = 'SVG']|
                       d:imagedata[@format]"
                mode="opf.manifest">
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="contains(name(.), 'graphic')">
          <xsl:choose>
            <xsl:when test="@entityref">
              <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="@fileref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="mediaobject.filename">
            <xsl:with-param name="object" select=".."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>  
    <xsl:variable name="fr" select="@fileref"/>
    <!-- only do this if we're the first file to match -->
    <!-- TODO: Why can't this be simple equality?? (I couldn't get it to work) -->
    <xsl:if test="generate-id(.) = generate-id(key('image-filerefs', $fr)[1])">
      <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
        <xsl:attribute name="id"> 
          <xsl:choose>
            <xsl:when test="ancestor::d:mediaobject[@role='cover'] and parent::*[@role='front-large']">
              <xsl:value-of select="$epub.cover.image.id"/>
            </xsl:when>
            <xsl:when test="ancestor::d:mediaobject[@role='cover'] and (count(ancestor::d:mediaobject//d:imageobject) = 1)">
              <xsl:value-of select="$epub.cover.image.id"/>
            </xsl:when>
            <xsl:when test="ancestor::d:cover">
              <xsl:value-of select="$epub.cover.image.id"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="generate-id(.)"/> 
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="href"> <xsl:value-of select="$filename"/> </xsl:attribute>
        <xsl:attribute name="media-type">
          <xsl:call-template name="guess-media-type">
            <xsl:with-param name="ext" select="@format"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- Warning: While the test indicate this match list is accurate, it may 
       need further tweaking to ensure _never_ dropping generated content (XHTML)
       from the manifest (OPF file) -->
  <xsl:template
      match="d:set|
            d:book[parent::d:set]|
            d:book[*[last()][self::d:bookinfo]]|
            d:book[d:bookinfo]|
            d:article|
            d:part|
            d:reference|
            d:preface|
            d:chapter|
            d:bibliography|
            d:appendix|
            d:glossary|
            d:section|
            d:sect1|
            d:sect2|
            d:sect3|
            d:sect4|
            d:sect5|
            d:refentry|
            d:colophon|
            d:bibliodiv[d:title]|
            d:setindex|
            d:index"
      mode="opf.manifest">
    <xsl:variable name="href">
      <xsl:call-template name="href.target.with.base.dir">
        <xsl:with-param name="context" select="/" />
        <!-- Generate links relative to the location of root file/toc.xml file -->
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>

    <xsl:variable name="is.chunk">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$is.chunk != 0">
      <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
        <xsl:attribute name="id"> <xsl:value-of select="$id"/> </xsl:attribute>
        <xsl:attribute name="href"> <xsl:value-of select="$href"/> </xsl:attribute>
        <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
      </xsl:element>
    </xsl:if>  
  </xsl:template>  

  <xsl:template match="text()" mode="ncx" />

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


  </xsl:template>




</xsl:stylesheet>
