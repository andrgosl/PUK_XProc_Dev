<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.idpf.org/2007/opf"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:db="http://docbook.org/ns/docbook"  xmlns:cfn="http://www.corbas.net/ns/functions"
    
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf"
    version="2.0" xpath-default-namespace="http://docbook.org/ns/docbook" exclude-result-prefixes="xd db xsl cfn">
    
    <xsl:param name="isbn" select="/book//biblioid[@class='isbn'][@role='epub']"/>
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
        <package version="2.0" unique-identifier="{concat('p', $isbn)}">
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
            <xsl:apply-templates select="biblioid[@class='isbn'][@role='isbn-13']"/>
            <dc:identifier id="{concat('p', $isbn)}">URN:ISBN:<xsl:value-of select='$isbn'/></dc:identifier>
            <dc:publisher><xsl:value-of select='publisher/publishername'/></dc:publisher>
            <dc:title><xsl:value-of select='title'/></dc:title>
            <dc:language><xsl:value-of select='$language'/></dc:language>            
            <meta name="cover" content="cover-image"/>
        </metadata>
    </xsl:template>
    
    <xsl:template match="biblioid[@class='isbn']">
        <dc:source><xsl:value-of select='cfn:format-isbn(.)'/></dc:source>    
    </xsl:template>
    
    <!-- dc:date expects just a date. Look for a four digit number -->
    <xsl:template match='pubdate'>
        <xsl:if test="matches(., '\d{4}')">
            <xsl:analyze-string select="." regex="(\d{4})">
                <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="bibliomisc[@role='specification']">
        <meta name="specification" content="{.}"/>
    </xsl:template>
    
    
    <!-- Generate the manifest -->
    
    <xsl:template match='book' mode='manifest'>
        <manifest>
            <xsl:apply-templates select='/book/info/cover' mode='manifest'/>
            <xsl:apply-templates select='dedication|author/personblurb' mode='manifest'/>
            <item id="stylesheet2" href="{concat($styles-dir, '/stylesheet.css')}" media-type="text/css" />
            <item id="stylesheet3" href="{concat($styles-dir, '/fowl.css')}" media-type="text/css"/>
            <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            <item id="toc" href="{concat($xhtml-dir, '/toc.html')}" media-type="application/xhtml+xml"/>
            <item id="copyright" href="{concat($xhtml-dir, '/copyright.html')}" media-type="application/xhtml+xml"/>
            <xsl:apply-templates select='descendant::mediaobject|descendant::inlinemediaobject'/>
            <xsl:apply-templates select='part|preface|chapter' mode='manifest'/>
        </manifest>
    </xsl:template>
    
    <xsl:template match='chapter' mode='manifest'>
        <xsl:variable name="chapnum" select="count(preceding::chapter) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <xsl:variable name="file-name" select="concat($xhtml-dir, '/', $page-id, '.html')"/>        
        <item id="{$page-id}" href="{$file-name}" media-type='application/xhtml+xml'/>
    </xsl:template>
    
    <xsl:template match='part' mode='manifest'>
        <xsl:variable name="partnum" select="count(preceding::part) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($partnum, '000'))"/>
        <xsl:variable name="file-name" select="concat($xhtml-dir, '/', $page-id, '.html')"/>        
        <item id="{$page-id}" href="{$file-name}" media-type='application/xhtml+xml'/>
        <xsl:apply-templates select='preface|chapter' mode='manifest'/>
    </xsl:template>
    
    
    <xsl:template match='preface|cover' mode='manifest'>
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"></xsl:variable>
        <xsl:variable name="file-name" select="concat($xhtml-dir, '/', $basis, '.html')"/>        
        <item id="{$basis}" href="{$file-name}" media-type='application/xhtml+xml'/>
    </xsl:template>
    
    
    <xsl:template match="personblurb" mode='manifest'>
        <item id='author' href="{concat($xhtml-dir, '/author.html')}" media-type='application/xhtml+xml'/>
    </xsl:template>
    
    <xsl:template match="dedication" mode='manifest'>
        <item id='dedication' href="{concat($xhtml-dir, '/dedication.html')}" media-type='application/xhtml+xml'/>
    </xsl:template>
    

    <xsl:template match="mediaobject[ancestor::cover/@role]">
        <xsl:variable name='role' select='ancestor::cover/@role'/>
        <xsl:analyze-string select="imageobject/imagedata/@fileref" regex="([\w_-]+)\.[a-zA-Z]+$">
            <xsl:matching-substring>
                <item id="{concat($role, '-image')}" media-type="image/jpeg" href="{concat($image-dir, '/', regex-group(1), '.jpg')}"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="mediaobject|inlinemediaobject">
        <xsl:variable name='id' select='generate-id(.)'/>
        <xsl:analyze-string select="imageobject/imagedata/@fileref" regex="([\w_-]+)\.[a-zA-Z]+$">
            <xsl:matching-substring>
                <item id="{$id}" media-type="image/jpeg" href="{concat($image-dir, '/', regex-group(1), '.jpg')}"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
        
        
    </xsl:template>
    
    <!-- Generate the spine -->
    
    <xsl:template match='book' mode='spine'>
        <xsl:variable name="titlepage" select="info/cover[@role='title']"/>
        <spine toc="ncx">
            <xsl:apply-templates select='info/cover[. &lt;&lt; $titlepage]' mode='spine'/>
            <xsl:apply-templates select='dedication' mode='spine'/>
            <xsl:apply-templates select="info/cover[@role='title' or . >> $titlepage]" mode='spine'/>
            <itemref idref="toc"/>
            <xsl:apply-templates mode="spine" select="preface[not(@role) or not(@role = ('author', 'books-by'))]|chapter|part"/>
            <itemref idref="copyright"/>
            <xsl:apply-templates select='author//personblurb' mode='spine'/>
            <xsl:apply-templates mode="spine" select="preface[@role = ('author', 'books-by')]"/>
        </spine>
    </xsl:template>
    
    <xsl:template match='dedication' mode='spine'>
        <itemref idref='dedication'/>
    </xsl:template>
    

    
    <xsl:template match='chapter' mode='spine'>
        <xsl:variable name="chapnum" select="count(preceding::chapter) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <itemref idref="{$page-id}"/>
    </xsl:template>

    <xsl:template match='part' mode='spine'>
        <xsl:variable name="chapnum" select="count(preceding::part) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <itemref idref="{$page-id}"/>
        <xsl:apply-templates select='preface|chapter' mode='spine'/>
    </xsl:template>
    

    <xsl:template match='preface' mode='spine'>
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <itemref idref="{$basis}"/>
    </xsl:template>
    
    <xsl:template match='personblurb' mode='spine'>
        <itemref idref="'author'"/>
    </xsl:template>

    <!-- Generate the guide -->
    
    <xsl:template match='book' mode='guide'>
        <xsl:variable name='first-page' select="(//preface[not(@role) or not(@role = ('reviews', 'author', 'books-by'))]|//chapter)[1]"/>
        
        
        <guide>
            <reference type="cover" title="Cover" href="{concat($xhtml-dir, '/cover.html')}"/>
            <reference type="toc" title="Contents" href="{concat($xhtml-dir, '/toc.html')}"/>
            <xsl:apply-templates select='$first-page' mode='guide'/>           
        </guide>
        
    </xsl:template>
    
    <xsl:template match='chapter' mode='guide'>
        <xsl:variable name="chapnum" select="position()"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <xsl:variable name="file-name" select="concat($xhtml-dir, '/', $page-id, '.html')"/>        
        <reference type="text" title="Text" href="{$file-name}"/>
    </xsl:template>
    
    <xsl:template match='preface' mode='guide'>
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"></xsl:variable>
        <xsl:variable name="file-name" select="concat($xhtml-dir, '/', $basis, '.html')"/>        
        <reference type="text" title="Text" href="{$file-name}"/>
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
        <xsl:value-of select='honorific|firstname|givenname|surname'/>
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
 
  
    
</xsl:stylesheet>
