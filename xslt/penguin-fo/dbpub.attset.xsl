<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.dpawson.co.uk/ns#"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="2.0"
exclude-result-prefixes="d xs"
>

  <dp:doc xmlns:d="http://www.dpawson.co.uk/ns#">
    <dp:revhistory>
      <dp:purpose>
        <dp:para>These att sets  with a db pubs  file to style fo output</dp:para>
      </dp:purpose>
      <dp:revision>
        <dp:revnumber>1.0</dp:revnumber>
        <dp:date>2011-08-03</dp:date>
        <dp:authorinitials>DaveP</dp:authorinitials>
        <dp:revdescription>
          <dp:para></dp:para>
        </dp:revdescription>
        <dp:revremark></dp:revremark>
      </dp:revision>
    </dp:revhistory>
  </dp:doc>
  




<xsl:variable name='base-font-size' select='10'/>   
<xsl:variable name='title-font-size' select='$base-font-size * 1.5'/>
<xsl:variable name='head-font-size' select='$base-font-size * 1.2'/>
<xsl:variable name='small-font-size' select='$base-font-size div 2'/>

<xsl:variable name='base-sz' select= 'concat ($base-font-size,"pt")'/>
<xsl:variable name='title-sz' select= 'concat ($title-font-size,"pt")'/>
<xsl:variable name='head-sz' select= 'concat ($head-font-size,"pt")'/>
<xsl:variable name='small-sz' select= 'concat ($small-font-size,"pt")'/>


<!-- toc, change for book or article -->
<!-- List elements for which a table of contents entry is wanted -->
<!-- No table of contents -->
<xsl:param name="generate.toc"></xsl:param>

<!-- toc depth -->
<xsl:param name="toc.max.depth">1</xsl:param>

<!-- Index please -->
<xsl:param name="generate.index" select="0"></xsl:param>
<!-- Not draft mode -->
<xsl:param name="draft.mode" select="'no'"></xsl:param>


<!-- Add legalnotice to head (Not working )-->
<xsl:param name="generate.legalnotice.link" select="0"></xsl:param>


<!-- Where to get the graphics, for page navigation etc -->
<xsl:param name="admon.graphics.path"   select="'/styles/docbook/images/'"/>
<xsl:param name="callout.graphics.path" select="'/styles/docbook/images/callouts'"></xsl:param>
<xsl:param name="navig.graphics" select="1"/>
<xsl:param name="navig.graphics.path">/styles/docbook/images/</xsl:param>


<!-- Admonitions -->
<xsl:param name="admon.graphics"        select="1"/>
<xsl:param name="admon.graphics.extension" select="'.png'"></xsl:param>

<!-- metadata, keywords -->
<xsl:param name="inherit.keywords" select="'1'"></xsl:param>


<!-- Paper size 
<xsl:param name="page.height.portrait">297mm</xsl:param>
<xsl:param name="page.width.portrait">210mm</xsl:param>
-->
<xsl:param name='paper.type'>A4</xsl:param>
<xsl:param name="page.orientation">portrait</xsl:param>

<xsl:param name="page.height">
  <xsl:choose>
    <xsl:when test="$page.orientation = 'portrait'">
      <xsl:value-of select="$page.height.portrait"></xsl:value-of>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$page.width.portrait"></xsl:value-of>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>


<!-- double sided please -->
<xsl:param name="double.sided" select="1"/>



<!-- margins on A4 page-->
<xsl:param name="page.margin.top">56mm</xsl:param>
<xsl:param name="page.margin.bottom">44mm</xsl:param><!-- should be 54 -->

<!-- body-region margins -->

<!-- Reduced by 2mm both sides, 59-> 57, 55-> 53-->
<xsl:param name="page.margin.inner">57mm</xsl:param>
<xsl:param name="page.margin.outer">53mm</xsl:param>


<xsl:param name="region.before.extent">3.5mm</xsl:param>
<xsl:param name="region.after.extent">3.5mm</xsl:param>

<!-- Required margins on body region-->
<!-- From which RH and footers come -->

<xsl:param name="body.margin.top">11mm</xsl:param>
<xsl:param name="body.margin.bottom">4mm</xsl:param><!-- should be 14 -->

<!-- left/right margins -->

<!-- Crop marks Not required-->
<xsl:param name="crop.marks" select="0"/>


<!-- No toc on sections -->
<xsl:param name="toc.section.depth">0</xsl:param>
<!-- Yes to callouts, use graphics -->
<xsl:param name="callout.graphics" select="'1'" />
<!-- Don't use dingbats -->
<xsl:param name="callout.dingbats" select="0"/>
<!-- Don't use Unicode -->
<xsl:param name="callout.unicode" select="0"/>
<!-- Use processing extensions for callouts -->
<xsl:param name="callouts.extension" select="1"/>
<!-- No more than 14 -->
<xsl:param name="callout.graphics.number.limit" select="14"/>
<!-- Fonts in use -->
<xsl:param name="body.font.family">berling, nubian, SymbolStd</xsl:param>
<xsl:param name="title.font.family">berling</xsl:param>
<xsl:param name="dingbat.font.family">SymbolStd</xsl:param><!-- tbc -->
<xsl:param name="monospace.font.family">Courier</xsl:param>

<!-- main font size -->
<xsl:param name="body.font.master">10</xsl:param>
<xsl:param name="alignment">justify</xsl:param>
<xsl:param name="line-height">16pt</xsl:param>
<xsl:param name="body.font.size">
 <xsl:value-of select="$body.font.master"></xsl:value-of><xsl:text>pt</xsl:text>
</xsl:param>


<!-- body indent -->
<xsl:param name="body.start.indent">0pt</xsl:param>

<!-- No hyphenation -->
<xsl:param name="hyphenate">false</xsl:param>


<!-- Leave empty toc alone -->
<xsl:param name="process.empty.source.toc" select='0'/>
<xsl:param name="use.extensions" select="1"/>
<!-- No part toc -->
<xsl:param name="generate.part.toc" select='0' />
<!-- No app toc -->
<xsl:param name="generate.appendix.toc" select='0' />

<!-- images -->
<!-- Where to get any graphics from, when referenced from the source XML -->
<xsl:param name="img.src.path" select="'/sgml/dbpubs/nic/images/'"/>


<!-- What to do with the output -->
<xsl:param name="base.dir" select="'fo'"></xsl:param>


<!-- Number chaps, sections -->
<xsl:param name="chapter.autolabel" select="0"></xsl:param>
<xsl:param name="section.autolabel" select="0"></xsl:param>
<xsl:param name="section.autolabel.max.depth" select="3"></xsl:param>
<!-- Include chap # in section number -->
<xsl:param name="section.label.includes.component.label" select="0"></xsl:param>
<xsl:param name="reference.autolabel" select="'1'"></xsl:param>

<!-- Im using xep -->
<!-- Select for xep -->
<xsl:param name="xep.extensions" select="1"></xsl:param>
<!-- Select for AH use -->
<xsl:param name="axf.extensions" select="0"></xsl:param>
<!-- Select for fop usage -->
<xsl:param name="fop1.extensions" select="0"></xsl:param>
<!-- xrefs to examples -->
<xsl:param name="xref.with.number.and.title" select="0"></xsl:param>


<xsl:param name="footnote.font.size">
 <xsl:value-of select="9"></xsl:value-of><xsl:text>pt</xsl:text>
</xsl:param>

<!-- Numbering -->
<xsl:param name="footnote.number.format">1</xsl:param>


<!-- to hyphenate url's  -->
<xsl:param name="ulink.hyphenate.chars">/ &amp; ? _ = &#x2009;</xsl:param>
<xsl:param name="ulink.hyphenate">&#x200B;</xsl:param>

<!-- bibliography -->
<xsl:param name="bibliography.numbered" select="1"></xsl:param>

<!-- callout location -->
<xsl:param name="callout.defaultcolumn" select="'60'"></xsl:param>


<!-- No warnings please -->
<xsl:param name="id.warnings" select="1"></xsl:param>

<!-- Retrieve only chapter titles for rh -->
<xsl:param name="marker.section.level">0</xsl:param>

<!--  Header -->
<xsl:param name="header.column.widths">1 6 1</xsl:param>
<!-- rule in header -->
<xsl:param name="header.rule" select="0"></xsl:param>
<xsl:param name="footer.rule" select="0"></xsl:param>      



<!--                          -->
<!--   att sets             -->
<!--                           -->

<!--  Header -->
<xsl:attribute-set name="header.table.properties">
  <xsl:attribute name="table-layout">fixed</xsl:attribute>
  <xsl:attribute name="width">100%</xsl:attribute>
</xsl:attribute-set>

 





<!-- To stop header wrapping -->
<xsl:param name="title.margin.left">
  <xsl:choose>
    <xsl:when test="$fop.extensions != 0">-4pc</xsl:when>
    <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
    <xsl:otherwise>0pt</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:attribute-set name="itemizedlist.properties" 
		   use-attribute-sets="list.block.properties">
<xsl:attribute name="space-before">5.644mm</xsl:attribute>
  <xsl:attribute name="space-after">5.644mm</xsl:attribute>
</xsl:attribute-set>
<!-- itemized list-block the entire list-->
<xsl:attribute-set name="list.block.spacing">
 <!-- removed -->
  </xsl:attribute-set>


<!-- Entire list, imported by itemizedlist.properties -->
<xsl:attribute-set name="list.block.properties">
  <xsl:attribute name="provisional-label-separation">0pt</xsl:attribute>
  <xsl:attribute name="provisional-distance-between-starts">4.233mm</xsl:attribute>
  <xsl:attribute name="line-height">16pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="list.item.spacing">
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="compact.list.item.spacing">
  <xsl:attribute name="space-before.optimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
</xsl:attribute-set>

<!-- Literallayout ... Should be programlisting-->


<xsl:attribute-set name="verbatim.properties">
  <xsl:attribute name='font-family'>nubian</xsl:attribute><!-- 2011-08-18 -->
<xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  <xsl:attribute name="white-space-collapse">false</xsl:attribute>
  <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
  <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  <!-- 2011-08-18 space before/after set to 6.5, 5.5mm -->
  <xsl:attribute name="space-before">6.5mm</xsl:attribute>
  <xsl:attribute name="space-after">5.5mm</xsl:attribute>
  <xsl:attribute name="font-size">9.75pt</xsl:attribute>
  <xsl:attribute name="line-height">16pt</xsl:attribute>
  <xsl:attribute name="start-indent">25.4mm</xsl:attribute>
  <xsl:attribute name="end-indent">25.4mm</xsl:attribute>
  

</xsl:attribute-set>

<!-- Verbatim -->
<xsl:attribute-set name="verbatim.properties">
  <xsl:attribute name="space-before.minimum">6.5mm</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6.5mm</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6.5mm</xsl:attribute>
  <xsl:attribute name="space-after.minimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-after.optimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-after.maximum">5.5mm</xsl:attribute>
  <xsl:attribute name="hyphenate">true</xsl:attribute>
  <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  <xsl:attribute name="white-space-collapse">false</xsl:attribute>
  <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
  <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="monospace.verbatim.properties" 
  use-attribute-sets="verbatim.properties monospace.properties">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$monospace.font.family"></xsl:value-of>
  </xsl:attribute>
</xsl:attribute-set>



<!-- Section formatting -->
<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-size">
    <xsl:value-of select="12"></xsl:value-of>
    <xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="line-height">
    <xsl:value-of select="15"/><xsl:text>pt</xsl:text>
  </xsl:attribute>
<xsl:attribute name='font-weight'>
  <xsl:value-of select="'bold'"/>
</xsl:attribute>
<xsl:attribute name="text-align">
  <xsl:value-of select="'center'"/>
</xsl:attribute>
<xsl:attribute name="space-before">
  <xsl:value-of select="30"/><xsl:text>pt</xsl:text>
</xsl:attribute>
<xsl:attribute name="space-after">
  <xsl:value-of select="24"/><xsl:text>pt</xsl:text>
</xsl:attribute>
</xsl:attribute-set>




<!-- blockquotes -->
<xsl:attribute-set name="blockquote.properties">
<xsl:attribute name="font-size">
  <xsl:value-of select="9"/><xsl:text>pt</xsl:text>
</xsl:attribute>
<xsl:attribute name="line-height">
  <xsl:value-of select="11"/><xsl:text>pt</xsl:text>
</xsl:attribute>
<xsl:attribute name="text-align">
  <xsl:value-of select="'justify'"/>
</xsl:attribute>
<xsl:attribute name="start-indent">
  <xsl:value-of select="12"/><xsl:text>pt</xsl:text>
</xsl:attribute>
<xsl:attribute name="end-indent">
  <xsl:value-of select="12"/><xsl:text>pt</xsl:text>
</xsl:attribute>
<xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
<xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
 <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>

<xsl:attribute name="space-after.minimum">0pt</xsl:attribute>
<xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
<xsl:attribute name="space-after.maximum">0pt</xsl:attribute>

<xsl:attribute name="text-indent">0pt</xsl:attribute>
</xsl:attribute-set>


<!-- footnotes -->
<xsl:attribute-set name="footnote.mark.properties">
  <xsl:attribute name="font-family"><xsl:value-of select="$body.fontset"></xsl:value-of></xsl:attribute>
  <xsl:attribute name="font-size">
    <xsl:value-of select="8"/><xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-style">normal</xsl:attribute>
</xsl:attribute-set>


<!-- For xrefs.  -->
<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="hyphenate">
    <xsl:value-of select="'true'"/>
  </xsl:attribute>
</xsl:attribute-set>

<!-- section title line height is odd -->
<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$title.font.family"></xsl:value-of>
  </xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <!-- font size is calculated dynamically by section.heading template -->
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">1.0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="start-indent"><xsl:value-of select="$title.margin.left"></xsl:value-of></xsl:attribute>
  <xsl:attribute name="line-height"><xsl:value-of select="13"/><xsl:text>pt</xsl:text></xsl:attribute>
  <xsl:attribute name="space-after">8mm</xsl:attribute>


</xsl:attribute-set>

<!-- Used for chapter titles.  -->
<!--chapter title line height is odd -->
<xsl:attribute-set name="component.title.properties">
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="space-before">3.528mm</xsl:attribute>
  <xsl:attribute name="hyphenate">true</xsl:attribute>
<!-- from penguin spec -->
<xsl:attribute name="text-align">center</xsl:attribute>
<xsl:attribute name="font-family">nubianl</xsl:attribute><!-- 2011-08-18 -->
<xsl:attribute name="font-size">18pt</xsl:attribute>
<xsl:attribute name="line-height">23pt</xsl:attribute>
<xsl:attribute name="space-before.minimum">7.5mm</xsl:attribute>
<xsl:attribute name="space-before.optimum">7.5mm</xsl:attribute>
<xsl:attribute name="space-before.maximum">7.5mm</xsl:attribute>
<xsl:attribute name="space-after">2.368mm</xsl:attribute>
</xsl:attribute-set>




<xsl:attribute-set name='font'> <!-- Font family -->
  <xsl:attribute 
    name='font-family'>berling, nubian, SymbolStd, Serif</xsl:attribute>
</xsl:attribute-set>

<!-- Standard para spacing  -->
<!-- Introduced 2011-08-17.  -->
<!-- Room for confusion with normal.para.spacing2 -->
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
<xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="space-after">0pt</xsl:attribute>
  <xsl:attribute name="line-height">16pt</xsl:attribute>
  <!-- Added for last line -->
  <xsl:attribute name='text-align-last'>start</xsl:attribute>
  <!-- Added for normal indent -->
  <xsl:attribute name="text-indent">4.233mm</xsl:attribute>

</xsl:attribute-set>

<!-- Para spacing first para of body text-->
<xsl:attribute-set name="normal.para.spacing2">
  <xsl:attribute name="space-before">0pt</xsl:attribute>
  <xsl:attribute name="line-height">16pt</xsl:attribute>
  <!-- Added for last line -->
  <xsl:attribute name='text-align-last'>start</xsl:attribute>
  <!-- Added for normal indent -->
  <xsl:attribute name="text-indent">4.233mm</xsl:attribute>
<!-- 2011-08-17 Additional 12mm space before -->
<xsl:attribute name="space-before">26mm</xsl:attribute>
</xsl:attribute-set>


<!-- Header properties -->
<xsl:attribute-set name="header.content.properties">
  <xsl:attribute name="font-family">nubian</xsl:attribute>
 
<!-- 2011-08-18 removed font settings. See docbook.fo.xsl, header.content-->
 <xsl:attribute name='font-weight'>
    <xsl:value-of select="'bold'"/>
  </xsl:attribute>
  <xsl:attribute name='space-before'>
    <xsl:value-of select="'5.75mm'"/>
  </xsl:attribute>
<!-- 2011-08-18  Added 4mm to header -->
 <xsl:attribute name="space-after">7mm</xsl:attribute>
  <xsl:attribute name='space-before.conditionality'>
    <xsl:value-of select="'retain'"/>
  </xsl:attribute>
 <xsl:attribute name='space-after.conditionality'>
    <xsl:value-of select="'retain'"/>
  </xsl:attribute>

  <xsl:attribute name='color'>
    <xsl:value-of select="'rgb(153,153,153)'"/>
  </xsl:attribute>
</xsl:attribute-set>

<!-- Footer Table properties -->
<xsl:attribute-set name="footer.table.properties">
  <xsl:attribute name="table-layout">fixed</xsl:attribute>
  <xsl:attribute name="width">100%</xsl:attribute>
</xsl:attribute-set>

<!-- Footer content properties.  -->
<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="font-family">nubiant</xsl:attribute><!-- 2011-08-18 -->
  <xsl:attribute name="margin-left">
    <xsl:value-of select="$title.margin.left"></xsl:value-of>
  </xsl:attribute>
<xsl:attribute name='font-size'>
    <xsl:value-of select="'8pt'"/>
  </xsl:attribute>
  <xsl:attribute name="margin-left">
    <xsl:value-of select="$title.margin.left"></xsl:value-of>
  </xsl:attribute>
  <xsl:attribute name="space-before.minimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-before.optimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-before.maximum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-after.minimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-after.optimum">5.5mm</xsl:attribute>
  <xsl:attribute name="space-after.maximum">5.5mm</xsl:attribute>
<!-- 2011-08-17 reduced, 11mm to 5.5mm -->
<!-- 2011-08-18 reduced to 0.5mm -->
  <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>

</xsl:attribute-set>


<!-- section/ title properties -->
<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-family">nubianl</xsl:attribute><!-- 2011-08-18T -->
  <xsl:attribute name="font-size">12pt</xsl:attribute>
  <xsl:attribute name='text-align'>center</xsl:attribute>
  <xsl:attribute name='space-after'>8mm</xsl:attribute><!-- 2011-08-18 11.289 to 8mm -->
  <xsl:attribute name="space-before">5.644mm</xsl:attribute>
  </xsl:attribute-set>

<xsl:attribute-set name="italic">
<xsl:attribute name="font-style" >italic</xsl:attribute>
</xsl:attribute-set>


<!-- extracts / blockquotes -->
<xsl:attribute-set name="blockquote.properties">
<xsl:attribute name="margin-{$direction.align.start}">0.5in</xsl:attribute>
<xsl:attribute name="margin-{$direction.align.end}">0.5in</xsl:attribute>
<xsl:attribute name="font-size">9.5pt</xsl:attribute>
<xsl:attribute name="line-height">15.5pt</xsl:attribute>
<xsl:attribute name='start-indent'>6.35mm</xsl:attribute>
<xsl:attribute name="end-indent">6.35mm</xsl:attribute>
<xsl:attribute name="space-before">6.085mm</xsl:attribute>
<xsl:attribute name="space-after">6.085mm</xsl:attribute>
</xsl:attribute-set>




<!-- Within poetry -->
<xsl:template match="linegroup">
  <fo:block-container
      xsl:use-attribute-sets='font '>
    <xsl:attribute name="space-before.conditionality">retain </xsl:attribute>
    <xsl:attribute name="space-after.optimum">
      <xsl:value-of select="$small-sz"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </fo:block-container>
</xsl:template>

<!-- Basic id att -->

<xsl:template match="@xml:id">
  <xsl:attribute name='id'>
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

</xsl:stylesheet>
