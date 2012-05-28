<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ixwd="http://www.ixxus.co.uk/ns/word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs ixwd xd db w ixwd">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 9, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match='w:tbl'>
        <db:informaltable>     
            <db:tgroup>
                <xsl:apply-templates select='w:tblGrid'/>                
                <db:tbody>
                    <xsl:apply-templates select='w:tr'/>
                </db:tbody>
            </db:tgroup>
        </db:informaltable>
    </xsl:template>
    
    <xsl:template match='w:tblPr'/>
    
     <xsl:template match='w:tr'>
        <db:row>
            <xsl:apply-templates select='w:tc'/>
        </db:row>
    </xsl:template>
    
    <xsl:template match='w:tc'>
        
         
        <xsl:if test='not(w:tcPr/w:vMerge) or w:tcPr/w:vMerge[@w:val = "restart"]'>
        
         <db:entry>
           
            <xsl:variable name='this.colnum'
                select='count(preceding-sibling::w:tc) + 1 +
                sum(preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val) -
                count(preceding-sibling::w:tc/w:tcPr/w:gridSpan[@w:val])'/>
            
            <xsl:if test='w:tcPr/w:gridSpan[@w:val > 1]'>
                <xsl:attribute name='namest'>
                    <xsl:text>column-</xsl:text>
                    <xsl:value-of select='$this.colnum'/>
                </xsl:attribute>
                <xsl:attribute name='nameend'>
                    <xsl:text>column-</xsl:text>
                    <xsl:value-of select='$this.colnum + w:tcPr/w:gridSpan/@w:val - 1'/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:if test='w:tcPr/w:vMerge[@w:val = "restart"]'>
                <xsl:attribute name='morerows'>
                    <xsl:call-template name='ixwd:count-rowspan'>
                        <xsl:with-param name='row' select='../following-sibling::w:tr[1]'/>
                        <xsl:with-param name='colnum' select='$this.colnum'/>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:if>
             
             <xsl:if test="position() = 1">
                 <xsl:attribute name='role' select="'first-col'"/>
             </xsl:if>
           
            <xsl:apply-templates/>
            
         </db:entry>
        </xsl:if> 

    </xsl:template>
    
    <xsl:template name='ixwd:count-rowspan'>
        <xsl:param name='row' select='/..'/>
        <xsl:param name='colnum' select='0'/>
        
        <xsl:variable name='cell'
            select='$row/w:tc[count(preceding-sibling::w:tc) + 1 +
            sum(preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val) -
            count(preceding-sibling::w:tc/w:tcPr/w:gridSpan[@w:val]) = $colnum]'/>
        
        <xsl:choose>
            <xsl:when test='not($cell)'>
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test='$cell/w:tcPr/w:vMerge[not(@w:val = "restart")]'>
                <xsl:variable name='remainder'>
                    <xsl:call-template name='ixwd:count-rowspan'>
                        <xsl:with-param name='row'
                            select='$row/following-sibling::w:tr[1]'/>
                        <xsl:with-param name='colnum' select='$colnum'/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select='$remainder + 1'/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template match='w:tblGrid/w:gridCol'>
        <db:colspec colwidth='{@w:w}*'
            colname='column-{count(preceding-sibling::w:gridCol) + 1}'/>
    </xsl:template>
    
</xsl:stylesheet>
