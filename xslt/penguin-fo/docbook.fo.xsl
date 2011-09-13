<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  version="1.0"
  xmlns:dp="http://www.dpawson.co.uk/ns#"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:d="http://docbook.org/ns/docbook"
exclude-result-prefixes="db dp exsl"

>

<xsl:import href="/sgml/docbook/docbook-xsl-ns-1.76.1/fo/docbook.xsl"/>
  <xsl:import href="dbpub.attset.xsl"/>
  <xsl:import href="penguin.titlepage.xsl"/>

<!-- For back of book footnotes
<xsl:import href='fnAppendix.xsl'/>
 -->
  <dp:doc >
 <revhistory>
   <purpose><para>Penguin style1</para></purpose>
   <revision>
    <revnumber>1.0</revnumber>
    <date>2011-08-03</date>
    <authorinitials>DaveP</authorinitials>
    <revdescription>
     <para></para>
    </revdescription>
    <revremark></revremark>
   </revision>
  </revhistory>
  </dp:doc>
  
<xsl:output method='xml' indent='yes'/>




<!--  -->
<!--  Kill all back matter  -->
<!--  -->

<xsl:template match="d:appendix">
<fo:page-sequence master-reference="index">
<fo:flow flow-name="xsl-region-body">
  <fo:block id="the0001875"/>
  <fo:block id="the0001879"/>
  <fo:block id="the0001789"/>
</fo:flow>
</fo:page-sequence>
</xsl:template>

<!-- Not required, as of 2011-08-02 -->
<xsl:template match="d:footnote|d:index|d:bibliography"/>
<xsl:template match="d:acknowledgements" mode="acknowledgements"/>

<!-- Formatting for chapter number -->
<!-- Should only be called in chapter start -->
<!-- Removed.... Need to get number automatically -->
<xsl:template match="d:XXchapter/d:info/d:title/d:phrase[@role='prefix']">
<fo:block
font-family='nubianl'
font-weight='bold'
text-align='center'
space-before='16.933mm'
font-size='21pt'
color="rgb(153,153,153)"
space-after="6mm"
space-after.conditionality="retain"
><xsl:apply-templates/></fo:block>
</xsl:template>



<!-- dropcap first letter Requires markup prior to this processing-->
<xsl:template match="db:phrase[@role='firstChar']">
  <fo:float float="start">
    <fo:block margin="0pt" 
      font-weight="normal"
      text-depth="10pt" 
      font-family="nubiant"
      font-size="60pt" 
      line-height="40pt" 
      padding-end="2pt">
      <xsl:apply-templates/><!-- 2011-08-18 -->
    </fo:block>
  </fo:float>

</xsl:template>

<!-- Epigraph -->
<!-- To get space-before on first chapter/para -->

<xsl:template match="d:epigraph">
  <fo:block font-size="9pt" 
	    font-family="berling,SymbolStd"
	    line-height="14.75pt"
	    start-indent="12.7mm"
	    end-indent="12.7mm"
	    space-before="5.368mm"
	    text-indent="0pt">
 <xsl:if test="following-sibling::*[1][self::d:para]">
      <xsl:attribute name="space-after">10.7mm</xsl:attribute>
    </xsl:if>
	    
    <xsl:call-template name="anchor"/>
   
    <xsl:apply-templates select="d:para|d:simpara|d:formalpara|d:literallayout"/>
    <xsl:if test="d:attribution">
      <fo:inline>
        <xsl:text></xsl:text>
        <xsl:apply-templates select="d:attribution"/>
      </fo:inline>
    </xsl:if>
  </fo:block>
</xsl:template>

<!-- Special for first para in a chapter, triggered off last -->
<xsl:template match="d:epigraph/d:para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block 
      font-family="berling,SymbolStd"
      text-align="justify"
      text-align-last="start"
    text-indent="0pt">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- epigraph source -->
<xsl:template match="d:attribution">
  <fo:block
      font-family="berling,  SymbolStd"
    font-style='normal'
    font-size='8.25pt'
    line-height="14pt"
    text-align="end"
    start-indent="25.7mm"
    end-indent="12.7mm"
><xsl:apply-templates/></fo:block><!-- 2011-08-18 start indent to 25.7 from 22.7 -->
</xsl:template>

<xsl:template match="d:attribution/d:personname">
  <fo:inline font-style='italic'>
<xsl:call-template name="person.name"/>
</fo:inline>
</xsl:template>


<!-- For chapter number ONLY -->

<xsl:template name="chapter.titlepage.before.recto">
<fo:block
font-family='nubian'
font-weight='bold'
text-align='center'
space-before='16.933mm'
font-size='21pt'
color="rgb(153,153,153)"
space-after.minimum="4.5mm"
space-after.optimum="4.5mm"
space-after.maximum="4.5mm"
space-after.conditionality="retain"
  ><xsl:value-of select="count(preceding::d:chapter) + 1"/></fo:block>
</xsl:template>



<!-- Special for first para in a chapter -->
<xsl:template match="d:chapter/d:para[1]">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block 
    xsl:use-attribute-sets="normal.para.spacing2"
    text-indent="0pt"
>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Special for first para in a section.  -->
<xsl:template match="d:section/d:para[1]">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block 
    xsl:use-attribute-sets="normal.para.spacing"
    text-indent="0pt"
>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>






<!-- Special for first para in a chapter -->
<xsl:template match="d:blockquote/d:para[1]">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block 
    xsl:use-attribute-sets="normal.para.spacing"
    text-indent="0pt"
>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>





<!-- Normal para -->
<xsl:template match="d:para">  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="normal.para.spacing">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- para in listitem -->
<xsl:template match="d:listitem/d:para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block text-indent="0pt"
	  >
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<!-- Normal para, @role='spacebreak' -->
<xsl:template match="d:para[@role='spacebreak']">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="normal.para.spacing2">
<xsl:attribute name='space-before'>11.289mm</xsl:attribute>
<xsl:attribute name='text-indent'>0pt</xsl:attribute>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<!-- itemized list -->
<xsl:template match="d:itemizedlist">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:variable name="pi-label-width">
    <xsl:call-template name="pi.dbfo_label-width"/>
  </xsl:variable>

  <xsl:variable name="label-width">
    <xsl:choose>
      <xsl:when test="$pi-label-width = ''">
        <xsl:value-of select="$itemizedlist.label.width"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$pi-label-width"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="d:title">
    <xsl:apply-templates select="d:title" mode="list.title.mode"/>
  </xsl:if>

  <!-- Preserve order of PIs and comments -->
  <xsl:apply-templates 
      select="*[not(self::d:listitem
                or self::d:title
                or self::d:titleabbrev)]
              |comment()[not(preceding-sibling::d:listitem)]
              |processing-instruction()[not(preceding-sibling::d:listitem)]"/>

  <xsl:variable name="content">
    <xsl:apply-templates 
          select="d:listitem
                  |comment()[preceding-sibling::d:listitem]
                  |processing-instruction()[preceding-sibling::d:listitem]"/>
  </xsl:variable>

  <!-- nested lists don't add extra list-block spacing -->
  <xsl:choose>
    <xsl:when test="ancestor::d:listitem">
      <fo:list-block id="{$id}" xsl:use-attribute-sets="itemizedlist.properties">
        <xsl:attribute name="provisional-distance-between-starts">
          <xsl:value-of select="$label-width"/>
        </xsl:attribute>
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:when>
    <xsl:otherwise>
<!-- This property list is too long. 
removed
xsl:use-attribute-sets="list.block.spacing itemizedlist.properties"
-->
      <fo:list-block id="{$id}" 
		     space-before="5.664mm"
		     space-after="5.664mm"
		     space-before.conditionality="retain"
		     >
        <xsl:attribute name="provisional-distance-between-starts">
          <xsl:value-of select="$label-width"/>
        </xsl:attribute>
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>





<!-- Programs -->
<xsl:template match="d:literallayout">
  <xsl:param name="suppress-numbers" select="'0'"/>
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$suppress-numbers = '0'
                      and @linenumbering = 'numbered'
                      and $use.extensions != '0'
                      and $linenumbering.extension != '0'">
        <xsl:call-template name="number.rtf.lines">
          <xsl:with-param name="rtf">
            <xsl:apply-templates/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@class='monospaced'">
      <xsl:choose>
        <xsl:when test="$shade.verbatim != 0">
          <fo:block id="{$id}"
                    xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style">

            <xsl:copy-of select="$content"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block id="{$id}"
                    xsl:use-attribute-sets="monospace.verbatim.properties">
            <xsl:copy-of select="$content"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$shade.verbatim != 0">
          <fo:block id="{$id}"
                    xsl:use-attribute-sets="verbatim.properties shade.verbatim.style">
            <xsl:copy-of select="$content"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block id="{$id}"
                    xsl:use-attribute-sets="verbatim.properties">
            <xsl:copy-of select="$content"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- screen, -->
<xsl:template match="d:screen">
  <xsl:param name="suppress-numbers" select="'0'"/>
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$suppress-numbers = '0'
                      and @linenumbering = 'numbered'
                      and $use.extensions != '0'
                      and $linenumbering.extension != '0'">
        <xsl:call-template name="number.rtf.lines">
          <xsl:with-param name="rtf">
            <xsl:choose>
              <xsl:when test="$highlight.source != 0">
                <xsl:call-template name="apply-highlighting"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$highlight.source != 0">
            <xsl:call-template name="apply-highlighting"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Content of element -->
  <xsl:variable name="block.content">
    <xsl:choose>
      <!-- Shading -->
      <xsl:when test="$shade.verbatim != 0">
        <fo:block id="{$id}"
             xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style">
	  <xsl:choose>
	    <xsl:when test="$hyphenate.verbatim != 0 and 
			    $exsl.node.set.available != 0">
	      <xsl:apply-templates select="exsl:node-set($content)" 
				   mode="hyphenate.verbatim"/>
	    </xsl:when>
	    <!-- No hyph -->
	    <xsl:otherwise>
	      <xsl:copy-of select="$content"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</fo:block>
      </xsl:when>
      <xsl:otherwise>
	<!-- Not shaded -->
        <fo:block id="{$id}">
	  <xsl:attribute name="text-align">start</xsl:attribute>
	  <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
	  <xsl:attribute name="white-space-collapse">false</xsl:attribute>
	  <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
	  <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
	  <xsl:attribute name="font-style">italic</xsl:attribute>
	  <xsl:attribute name="font-family">nubian</xsl:attribute>
	  <xsl:attribute name="start-indent">7.761mm</xsl:attribute>
	  <xsl:attribute name="end-indent">7.761mm</xsl:attribute>
	  <xsl:attribute name="space-before">2.822mm</xsl:attribute>
	  <xsl:attribute name="space-after">2.822mm</xsl:attribute>
	  <xsl:attribute name="font-size">9.75pt</xsl:attribute>
	  <xsl:attribute name="line-height">16pt</xsl:attribute>
          <xsl:choose>
            <xsl:when test="$hyphenate.verbatim != 0 and 
                            $exsl.node.set.available != 0">
              <xsl:apply-templates select="exsl:node-set($content)" 
                                   mode="hyphenate.verbatim"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  
      <xsl:copy-of select="$block.content"/>
   
</xsl:template>







<!-- First three letters after spacebreak -->
<xsl:template match="d:phrase[@role='leadin']">
  <fo:inline font-family='nubian' 
    font-weight='bold'
    font-size='9pt'
    letter-spacing="0.2em"
    color='rgb(153,153,153)'>
    <xsl:apply-templates/>
</fo:inline>
</xsl:template>


<!-- Poetry -->
<xsl:template match="db:poetry">
  <fo:block-container 
    space-before="5.644mm"
    space-after="5.644mm">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates />
  </fo:block-container>
</xsl:template>


<!-- lingroup, poetry -->
<xsl:template match="db:linegroup">
    <fo:block>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </fo:block>
  </xsl:template>



<xsl:template match="db:line">
    <fo:block
      font-style="italic"
      start-indent="8.476mm"
      >
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </fo:block>
  </xsl:template>

 

<xsl:template match="db:dialogue">
    <fo:block-container>
      <xsl:apply-templates select="@*|node()"/>
    </fo:block-container>
  </xsl:template>








<xsl:template match="db:speaker">
    <fo:block>
      <xsl:apply-templates select="@*|node()"/>
    </fo:block>
  </xsl:template>

  





<!-- From pagesetup.xsl, for page number in outer header -->
<xsl:template name="header.content">
  <xsl:param name="pageclass" select="''"/><!-- titlepage|lot|front| -->
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

<xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ.'"/>
<xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyz.'"/>


<xsl:variable name='book.title' select="translate(//d:book/d:info[1]/d:title,$lc,$uc)"/>

<xsl:variable name='ch.title' >
  <xsl:apply-templates select="."   mode="title.markup"/>
</xsl:variable>

  <fo:block>
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$sequence = 'blank'">
        <!-- no output nothing -->
      </xsl:when>

      <xsl:when test="$position='left'">
        <xsl:if test="$sequence='even'">
          <!-- verso, outside. Insert folio -->
          <!-- Font changed to Nubian medium -->
	  <fo:inline 
	      font-family="nubianl"
	      letter-spacing=".2em"
	      color="black"
	      font-size="8pt"><fo:page-number/></fo:inline>
	</xsl:if>
      </xsl:when>

      <!-- centre of page RH content-->
      <xsl:when test="($sequence='odd' or $sequence='even') and $position='center'">
        <xsl:if test="$pageclass != 'titlepage'">
          <xsl:choose>
            <xsl:when test="ancestor::d:book and ($double.sided != 0)">
	      <!-- page centre, in book, dble sided, not title page -->
	      <xsl:if test="$sequence = 'odd'">
		<fo:block 
		    font-family="nubian"
                    font-weight="bold"
		    letter-spacing=".2em"
		    font-size="9pt"
		    space-after="7.5mm"
		    color="rgb(153,153,153)"
		    > <!-- 2011-08-18 removed bold -->

 	  	  <xsl:choose>
		    <xsl:when test="string-length(normalize-space($ch.title)) &lt; 30"> 
		      <xsl:value-of select="$ch.title"/>
		    </xsl:when> <!-- end of ancestor::book -->

		    <xsl:otherwise>
		      <xsl:apply-templates select="." 
					   mode="titleabbrev.markup"/> 
		    </xsl:otherwise>
		  </xsl:choose>
	      </fo:block>
	      </xsl:if>

	      <!-- Even pages, not titlepage -->
	      <xsl:if test="$sequence = 'even'">
		<fo:inline 
		    font-family="nubian"
		    font-weight="bold"
		    letter-spacing=".2em"
		    font-size="9pt"
		    color="rgb(153,153,153)">
		  <xsl:value-of select="$book.title"/>
		</fo:inline>
	      </xsl:if>
            </xsl:when> <!-- when    -->
	    <!-- What's left.  Should never be selected -->
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:when>

      <xsl:when test="$position='center'">
        <!-- nothing for empty and blank sequences -->
      </xsl:when>

      <xsl:when test="$position='right'">
      <xsl:if test="$sequence='odd' and not($pageclass='titlepage')">
	<!-- Insert folio,  -->
	<fo:inline 
	    font-family="nubianl"
	    letter-spacing=".2em"
	    color="black"
	    font-size="9pt"><fo:page-number/></fo:inline>
      </xsl:if>
      </xsl:when>

      <xsl:when test="$sequence = 'first'">
        <!-- nothing for first pages -->
      </xsl:when>

      <xsl:when test="$sequence = 'blank'">
        <!-- nothing for blank pages -->
      </xsl:when>
    </xsl:choose>
  </fo:block>
</xsl:template>


<!-- page number format -->
<xsl:template name="initial.page.number">auto-odd</xsl:template>
<xsl:template name="page.number.format">1</xsl:template>


<!-- footer template, page number only on Openers -->


<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <fo:block >
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$pageclass = 'titlepage'"></xsl:when>
      <xsl:when test="$double.sided != 0 and $sequence = 'even'
                      and $position='left'"></xsl:when>
      <xsl:when test="$double.sided != 0 and  $sequence = 'first'
                      and $position='center'">
	<fo:inline 
	    font-family="nubianl"
	    font-weight="normal"
	    letter-spacing=".2em"
	    font-size="8pt"><fo:page-number/></fo:inline>
      </xsl:when>
      <xsl:when test="$double.sided = 0 and $position='center'"></xsl:when>
      <xsl:when test="$sequence='blank'">
        <xsl:choose>
          <xsl:when test="$double.sided != 0 and $position = 'left'"> </xsl:when>
          <xsl:when test="$double.sided = 0 and $position = 'center'"></xsl:when>
          <xsl:otherwise>  </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>
  



</xsl:stylesheet>
