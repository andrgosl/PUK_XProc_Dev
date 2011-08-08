<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template name="opf">
        
        <xsl:variable name="package-identifier-id">
           <xsl:call-template name="opf.package.identifier.id"/>
        </xsl:variable>

        <!-- get.doc.title from common/utility.xsl -->
        <xsl:variable name="doc.title">
            <xsl:call-template name="get.doc.title"/>
        </xsl:variable>

        <xsl:element namespace="http://www.idpf.org/2007/opf" name="package">
            
            <xsl:attribute name="version">2.0</xsl:attribute>
            <xsl:attribute name="unique-identifier">
                <xsl:value-of select="$package-identifier-id"/>
            </xsl:attribute>

 
            <xsl:call-template name="opf.metadata"/>          
            <xsl:call-template name="opf.manifest"/>
            <xsl:call-template name="opf.spine"/>
            <xsl:call-template name="opf.guide"/>

        </xsl:element>

    </xsl:template>
    
    <xsl:template name="opf.metadata">
        
           <xsl:element namespace="http://www.idpf.org/2007/opf" name="metadata">
                <xsl:element name="dc:identifier">
                    <xsl:attribute name="id">
                        <xsl:value-of select="$package-identifier-id"/>
                    </xsl:attribute>
                    <xsl:call-template name="package-identifier"/>
                </xsl:element>

                <xsl:element name="dc:title">
                    <xsl:value-of select="normalize-space($doc.title)"/>
                </xsl:element>

                <xsl:apply-templates select="/*/*[contains(name(.), 'info')]/*" mode="opf.metadata"/>
                <xsl:element name="dc:language">
                    <xsl:call-template name="l10n.language">
                        <xsl:with-param name="target" select="/*"/>
                    </xsl:call-template>
                </xsl:element>

                <xsl:if
                    test="/*/*[cover or contains(name(.), 'info')]//mediaobject[@role='cover' or ancestor::cover]">
                    <xsl:element namespace="http://www.idpf.org/2007/opf" name="meta">
                        <xsl:attribute name="name">cover</xsl:attribute>
                        <xsl:attribute name="content">
                            <xsl:value-of select="$epub.cover.image.id"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:if>

            </xsl:element>    
    
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

      <xsl:if test="/*/*[cover or contains(name(.), 'info')]//mediaobject[@role='cover' or ancestor::cover]"> 
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
      <xsl:apply-templates select="//part|
                                   //book[*[last()][self::bookinfo]]|
                                   //book[bookinfo]|
                                   /set|
                                   /set/book|
                                   //reference|
                                   //preface|
                                   //chapter|
                                   //bibliography|
                                   //appendix|
                                   //article|
                                   //glossary|
                                   //section|
                                   //sect1|
                                   //sect2|
                                   //sect3|
                                   //sect4|
                                   //sect5|
                                   //refentry|
                                   //colophon|
                                   //bibliodiv[title]|
                                   //index|
                                   //setindex|
                                   //graphic|
                                   //inlinegraphic|
                                   //mediaobject|
                                   //mediaobjectco|
                                   //inlinemediaobject" 
                           mode="opf.manifest"/>
      <xsl:call-template name="opf.calloutlist"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>

