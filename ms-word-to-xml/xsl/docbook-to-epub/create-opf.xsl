<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.idpf.org/2007/opf"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:db="http://docbook.org/ns/docbook"  xmlns:cfn="http://www.corbas.net/ns/functions"
    
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf"
    version="2.0" xpath-default-namespace="http://docbook.org/ns/docbook" exclude-result-prefixes="xd db xsl cfn">
    
    <xsl:import href="page-ids.xsl"/>
    
    <xsl:param name="isbn" select="/*/info/biblioid[@class='isbn'][1]"/>
    <xsl:param name='pagination' select='"pagebreaks"'/>
    <xsl:param name='language' select="'en-GB'"/>
    
    <xsl:param name='xhtml-dir' select="'xhtml'"/>
    <xsl:param name='image-dir' select="'images'"/>
    <xsl:param name='styles-dir' select="'styles'"/>
    
    
    <xsl:output method='xml'
         omit-xml-declaration="no"
         indent="yes"
         encoding="UTF-8"/>
    
    <xsl:strip-space elements="*"/>
    
    <!-- create an opf file from DocBook -->
    <xsl:template match='/'>
        <package version="2.0" unique-identifier="bookid">
            <xsl:apply-templates select='book/info'/>
            <xsl:apply-templates select='book' mode='manifest'/>
            <xsl:apply-templates select='book' mode='spine'/>
            <xsl:apply-templates select='book' mode='guide'/>
        </package>
    </xsl:template>
    
    <xsl:template match='/book/info'>
        <metadata>
            <xsl:apply-templates select='authorgroup|author|editor|othercredit'/>
            <xsl:apply-templates select='pubdate[1]'/>
            
            <dc:date opf:event="converted"><xsl:value-of select="format-date(current-date(), '[Y]-[M,02]-[D,02]')"/></dc:date>
            <xsl:apply-templates select="bibliomisc[@role='specification']"/>
            <dc:identifier id="bookid">URN:ISBN:<xsl:value-of select='$isbn'/></dc:identifier>
            <dc:publisher><xsl:value-of select='publisher/publishername'/></dc:publisher>
            <dc:title><xsl:value-of select='title'/></dc:title>
            <dc:language><xsl:value-of select='$language'/></dc:language>            
            <meta name="cover" content="cover-image"/>
        </metadata>
    </xsl:template>
   
    <!-- dc:date expects just a date. Look for a four digit number -->
    <xsl:template match='pubdate'>
        <xsl:if test="matches(., '\d{4}')">
            <xsl:analyze-string select="." regex="(\d{4})">
                <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- Generate the manifest -->
    
    <xsl:template match='book' mode='manifest'>
        <manifest>
            <xsl:apply-templates select='/book/info/cover' mode='manifest'/>
            <xsl:apply-templates select="*[not(self::info)]" mode="manifest"/>
            
            
            <!-- this needs to be parameterised properly -->
            <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            <item id="toc" href="{concat($xhtml-dir, '/toc.', $xhtml.suffix)}" media-type="application/xhtml+xml"/>
            <item id="styles" href="{concat($styles-dir, '/stylesheet.css')}"  media-type="text/css"/>
            <xsl:apply-templates select='descendant::mediaobject|descendant::inlinemediaobject'/>
            
        </manifest>
    </xsl:template>
        
    <xsl:template match='part' mode='manifest'>
       <xsl:variable name="page-id"><xsl:call-template name="page.id"/></xsl:variable>
        <xsl:variable name="file-name"><xsl:call-template name="page.href"/></xsl:variable>        
        <item id="{$page-id}" href="{concat($xhtml-dir, '/', $file-name)}" media-type='application/xhtml+xml'/>
        <xsl:apply-templates select='preface|chapter' mode='manifest'/>
    </xsl:template>  
    
    <xsl:template match="personblurb|dedication|preface|cover|chapter|bibliography|appendix" mode='manifest'>
        <xsl:variable name="page-id"><xsl:call-template name="page.id"/></xsl:variable>
        <xsl:variable name="file-name"><xsl:call-template name="page.href"/></xsl:variable>        
        <item id='{$page-id}' href="{concat($xhtml-dir, '/', $file-name)}" media-type='application/xhtml+xml'/>
    </xsl:template>
    
    <xsl:template match="mediaobject[ancestor::cover/@role]">
        <xsl:variable name='role' select='ancestor::cover/@role'/>
        <xsl:variable name="fileref" select="imageobject/imagedata/@fileref"/>
        <xsl:analyze-string select="$fileref" regex="([\w_-]+\.[a-zA-Z]+)$">
            <xsl:matching-substring>
                <item id="{concat($role, '-image')}" media-type="{cfn:guess-media-type($fileref)}" href="{concat($image-dir, '/', regex-group(1))}"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="mediaobject|inlinemediaobject">
        <xsl:variable name='id' select='generate-id(.)'/>
        <xsl:variable name="fileref" select="imageobject/imagedata/@fileref"/>        
        <xsl:analyze-string select="$fileref" regex="([\w_-]+\.[a-zA-Z]+)$">
            <xsl:matching-substring>
                <item id="{$id}" media-type="{cfn:guess-media-type($fileref)}" href="{concat($image-dir, '/', regex-group(1))}"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
        
        
    </xsl:template>
    
    
    <!-- Generate the spine -->
    
    <xsl:template match='book' mode='spine'>
        <spine toc="ncx">
            <xsl:apply-templates select="info/cover" mode='spine'/>
            <itemref idref="toc"/>
            <xsl:call-template name="notes.spine"/>
            <xsl:apply-templates select="*[not(self::info)]" mode="spine"/>
        </spine>
    </xsl:template>
    
     <xsl:template match='chapter|preface|personblurb|dedication|bibliography|appendix' mode='spine'>
       <xsl:variable name="page-id"><xsl:call-template name="page.id"/></xsl:variable>
        <itemref idref="{$page-id}"/>
    </xsl:template>

    <xsl:template match='part' mode='spine'>
       <xsl:variable name="page-id"><xsl:call-template name="page.id"/></xsl:variable>
        <itemref idref="{$page-id}"/>
        <xsl:apply-templates select='preface|chapter' mode='spine'/>
    </xsl:template>
    
    <xsl:template name="notes.spine">
        <xsl:if test="descendant::footnote">
            <itemref idref="notes"/>
        </xsl:if>
    </xsl:template>
 
    <!-- Generate the guide -->
    
    <xsl:template match='book' mode='guide'>
        <xsl:variable name='first-page' select="(//preface|//chapter)[1]"/>
        
        
        <guide>
            <reference type="cover" title="Cover" href="{concat($xhtml-dir, '/cover.', $xhtml.suffix)}"/>
            <reference type="toc" title="Contents" href="{concat($xhtml-dir, '/toc.', $xhtml.suffix)}"/>
            <xsl:apply-templates select='$first-page' mode='guide'/>           
        </guide>
        
    </xsl:template>
    
    <xsl:template match='chapter|preface' mode='guide'>
        <xsl:variable name="file-name"><xsl:call-template name="page.href"/></xsl:variable>
        <reference type="text" title="Text" href="{concat($xhtml-dir, '/', $file-name)}"/>
    </xsl:template>
    
    
    <!-- Output the cover elements -->
    <xsl:template match='cover' mode='spine'>
            <itemref idref='{@role}'/>
    </xsl:template>
    
    <xsl:template match="cover[@role='cover']" mode='spine'>
        <itemref idref='{@role}' linear="no"/>
    </xsl:template>
        
    <!-- basic templates -->
    
    <xsl:template match='authorgroup'>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match='author'>
        <dc:creator opf:role='aut'><xsl:apply-templates select='personname'/></dc:creator>
    </xsl:template>

    <xsl:template match='editor'>
        <dc:creator opf:role='edt'><xsl:apply-templates select='personname'/></dc:creator>
    </xsl:template>
    
    <xsl:template match='othercredit'>
        <dc:creator opf:role='@role'><xsl:apply-templates select='personname'/></dc:creator>
    </xsl:template>
    
       
    <!-- very basic - remember xslt 2 will put a space between-->
    <xsl:template match='personname'>
        <xsl:value-of select='honorific|firstname|givenname|surname|text()'/>
    </xsl:template> 
 
        
    <xsl:function name="cfn:format-isbn">
        <xsl:param name="isbn"/>
        <xsl:variable name="stripped" select="translate($isbn, '-', '')"/>
        <xsl:value-of
            select="concat( 
            substring($stripped, 1, 3),
            '-',
            substring($stripped, 4, 1),
            '-',
            substring($stripped, 5, 2),
            '-',
            substring($stripped, 7, 6),
            '-',
            substring($stripped, 13))"
        />
    </xsl:function>
 
  <xsl:function name="cfn:guess-media-type">
    <xsl:param name="ext"/>
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
  </xsl:function>

  
    
</xsl:stylesheet>
