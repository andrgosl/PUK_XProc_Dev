<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:peng="http://www.penguingroup.com/ns/standard"
    xmlns:cfn="urn:corbas:functions"
    xpath-default-namespace="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="xhtml"/>

    <xsl:param name="image-dir" select="&quot;images&quot;"/>

    <xsl:template match="/">
        <xsl:apply-templates select="book"/>
        <xsl:apply-templates select="book" mode="toc"/>
    </xsl:template>

    <xsl:template match="book">
        <xsl:apply-templates select="dedication|info/cover|preface|chapter|part"/>
        <xsl:apply-templates select="info" mode="copyright"/>
    </xsl:template>

    <xsl:template match="part">

        <xsl:apply-templates/>

    </xsl:template>

    <xsl:template match="part/info">

        <xsl:variable name="chapnum" select="count(preceding::part) + 1"/>
        <xsl:variable name="page-id" select="concat('part', format-number($chapnum, '000'))"/>
        <xsl:variable name="filename" select="concat($page-id, '.html')"/>

        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$page-id"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="chapter">

        <xsl:variable name="chapnum" select="count(preceding::chapter) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <xsl:variable name="filename" select="concat($page-id, '.html')"/>

        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$page-id"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="preface">
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <xsl:variable name="filename" select="concat($basis, '.html')"/>

        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$basis"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="preface[@role='books-by']">
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <xsl:variable name="filename" select="concat($basis, '.html')"/>
        
        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$basis"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    

    <xsl:template match="cover">
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <xsl:variable name="filename" select="concat($basis, '.html')"/>

        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$basis"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <title>
                    <xsl:value-of select="if (@role) then @role else 'Cover'"/>
                </title>
            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>


    <xsl:template match="author//personblurb">
        <xsl:variable name="filename" select="'author.html'"/>
        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="'author'"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dedication">
        <xsl:variable name="filename" select="'dedication.html'"/>
        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="'dedication'"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title"><title>Dedication</title></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="title|info/title">
        <h2 class="EB04MainHead">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="preface[@role='books-by']/title|preface[@role='books-by']/info/title">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>
    
    <xsl:template match="part/title|part/info/title">
        <h2 class="EB04MainHead">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>


    <xsl:template match="title|info/title" mode="as-title">
        <title>
            <xsl:apply-templates select="*" mode="as-title"/>
        </title>
    </xsl:template>
    
    <xsl:template match="title|info/title" mode="toc">
        <xsl:apply-templates select="node()" mode="as-title"/>
    </xsl:template>

    <xsl:template match="*" mode="as-title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="section/title|section/info/title|bridgehead|subtitle" priority="2">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>

    <xsl:template match="itemizedlist/title">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>

    <xsl:template match="info">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="preface/para[position() = 1]|chapter/para[position() = 1]|section/para[position()=1]">
        <p class="EB02BodyTextFullOut">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    
    <xsl:template match="dedication/para">
        <p class="EB12SmallItalic">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>

    <xsl:template match="para">
        <p class="EB03BodyTextIndented">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    
    <xsl:template match="blockquote/para[position()=1]" priority='2'>
        <p class="EB19ExtraFeatureFullOut">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    
    <xsl:template match="blockquote/para">
        <p class="EB21ExtraFeatureIndented">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>

    <xsl:template match="cover[@role='reviews']//blockquote">
        <blockquote>
            <xsl:apply-templates select="* except attribution"/>
            <xsl:apply-templates select="attribution"/>
        </blockquote>
    </xsl:template>

    <xsl:template match="blockquote">
        <blockquote>
            <xsl:apply-templates select="@*|node()"/>
        </blockquote>
    </xsl:template>

    <xsl:template match="section">
           <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

    <xsl:template match="para[. = '*']">
        <p class="asterisk"><span>*</span></p>
    </xsl:template>
    
    <xsl:template match="para[preceding-sibling::*[1][self::para][. = '*']]">
        <p class="EB02BodyTextFullOut"><xsl:apply-templates select='@*|node()'/></p>
    </xsl:template>
    


    <xsl:template match="attribution">
        <p class="EB18EpigraphSource">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="citetitle">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="peng:stanza">
        <div class="AFStanza">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="peng:linegroup">
        <div class="AFLinegroup">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="peng:line">
        <p class="AFLine">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="peng:poem">
        <div class="AFPoetry">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="mediaobject">
        <div class="image">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="inlinemediaobject">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template
        match="inlinemediaobject[count(imageobject) = 1]/imageobject|mediaobject[count(imageobject) = 1]/imageobject">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template
        match="inlinemediaobject[count(imageobject) gt 1]/imageobject[@role='web']|mediaobject[count(imageobject) gt 1]/imageobject[@role='web']">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="imagedata">
        <xsl:variable name="current" select="."/>
        <xsl:variable name='role' select='(ancestor-or-self::*/@role)[1]'/>
        <xsl:variable name='id' select='@xml:id'/>
        <xsl:analyze-string select="@fileref" regex="([\w_-]+)\.[a-zA-Z]+$">
            <xsl:matching-substring>
                <img src="{concat('../', $image-dir, '/', regex-group(1), '.jpg')}" alt="{regex-group(1)}">
                    <xsl:apply-templates select="$id|$role"/>
                </img>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="emphasis">
        <span class='{@role}'>
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>

    <xsl:template match="emphasis[@role=('bold', 'strong')]">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="emphasis[@role='italic']">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="phrase">
        <span>
            <xsl:apply-templates select="@*|node()"/>
        </span>
    </xsl:template>

    <xsl:template match="itemizedlist">
        <xsl:apply-templates select="title"/>
        <ul>
            <xsl:apply-templates select="@*|node() except title"/>
        </ul>
    </xsl:template>

    <xsl:template match="itemizedlist[@mark='none']">
        <xsl:apply-templates select="title"/>
        <div class="pseudo-list">
            <xsl:apply-templates select="node() except title" mode="no-mark"/>
        </div>
    </xsl:template>


    <xsl:template match="listitem">
        <li>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="count(*) = 1 and child::para">
                    <xsl:apply-templates select="para/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="listitem" name="list-item-default" mode="no-mark">
        
        <xsl:param name='class' select="'listitem'"/>

        <xsl:choose>

            <xsl:when test="count(*) = 1 and child::para">
                <p class="{$class}">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="para/node()"/>
                </p>
            </xsl:when>

            <xsl:otherwise>
                <div class="{$class}">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <xsl:template match="preface[@role='books-by']//listitem" mode="no-mark">
        <xsl:call-template name="list-item-default">
            <xsl:with-param name="class">EB01BodyTextLineSpace</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="uri">
        <span class='url'><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match='superscript'>
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

    <xsl:template match='subscript'>
        <sub><xsl:apply-templates/></sub>
    </xsl:template>
    
    <xsl:template match="@xml:id">
        <xsl:message>Generating id attribute for <xsl:value-of select='.'/></xsl:message> 
        <xsl:attribute name="id" select="."/>
    </xsl:template>

    <xsl:template match="@role">
        <xsl:attribute name="class" select="."/>
    </xsl:template>

    <xsl:template match="itemizedlist/@role"/>
    
    <xsl:template match="section/@*"/>

    <xsl:template match="itemizedlist/@mark">
        <xsl:attribute name="class" select="."/>
    </xsl:template>

    <xsl:template match="@*"/>

    <xsl:template match="*">
        <xsl:message terminate="yes">Unhandled element - <xsl:value-of select="local-name()"/></xsl:message>
    </xsl:template>


    <xsl:template name="html-doc">
        <xsl:param name="filename"/>
        <xsl:param name="page-id"/>
        <xsl:param name="title"/>
        <xsl:variable name="class" select="if (@role) then @role else local-name()"/>
        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml" href="{$filename}">
            <html>
                <head>
                    <xsl:copy-of select="$title"/>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                    <link rel="stylesheet" type="text/css" href="../styles/fowl.css"/>
                    <meta name="page-id" content="{$page-id}"/>
                </head>
                <body class="{$class}">
                    <xsl:apply-templates mode="#current"/>
                </body>
            </html>
        </xsl:result-document>

    </xsl:template>
    
    
    <!-- Table of Contents -->
    
    <xsl:template match="book" mode="toc">
        
        
        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml" href="toc.html">
            <html>
                <head>
                    <title>Contents</title>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                    <link rel="stylesheet" type="text/css" href="../styles/fowl.css"/>
                    <meta name="page-id" content="toc"/>
                </head>
                <body class="toc">
                    <h2 class="EB04MainHead">Contents</h2>
                    <xsl:apply-templates select="/book/info/cover[@role='cover']" mode='toc'/>
                    <xsl:apply-templates select="dedication" mode='toc'/>
                    <xsl:apply-templates select="/book/info/cover[@role='title']" mode='toc'/>
                    <xsl:apply-templates select="preface[not(@role) or not(@role = ('author', 'books-by'))]" mode='toc'/>
                    <xsl:apply-templates select="part|chapter" mode='toc'/>
                    <xsl:apply-templates select="author//personblurb" mode='toc'/>
                    <xsl:apply-templates select="preface[@role = ('author', 'books-by')]" mode='toc'/>
                </body>
            </html>
        </xsl:result-document>
        
        
    </xsl:template>
    
    <xsl:template match="preface" mode='toc'>
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <xsl:variable name="filename" select="concat($basis, '.html')"/>
        <p class="EB15ContentsText"><a href="{$filename}"><xsl:apply-templates select="info/title|title" mode="toc"/></a></p>        
    </xsl:template>
    
    <xsl:template match="cover" mode="toc">
        <xsl:variable name="basis" select="(@role, @xml:id, local-name())[1]"/>
        <xsl:variable name="filename" select="concat($basis, '.html')"/>
        <xsl:variable name="title" select="concat(upper-case(substring(@role, 1, 1)), lower-case(substring(@role, 2)))"/>
        <p class="EB15ContentsText"><a href="{$filename}"><xsl:value-of select="$title"/></a></p>
    </xsl:template>

    <xsl:template match="dedication" mode="toc">
        <p class="EB15ContentsText"><a href="dedication.html">Dedication</a></p>
    </xsl:template>
    
    <xsl:template match="personblurb" mode="toc">
        <p class="EB15ContentsText"><a href="author.html">About the author</a></p>
    </xsl:template>
    
    <xsl:template match="chapter|part" mode='toc'>
        <xsl:variable name="chapnum" select="count(preceding::*[local-name(.) = local-name(current())]) + 1"/>
        <xsl:variable name="page-id" select="concat(local-name(), format-number($chapnum, '000'))"/>
        <xsl:variable name="filename" select="concat($page-id, '.html')"/>
        <p class="EB15ContentsText"><a href="{$filename}"><xsl:apply-templates select="info/title|title" mode="toc"/></a></p>        
        <xsl:apply-templates select='chapter'  mode='toc'/>
    </xsl:template>
    
    
    <!-- copyright page -->
    <xsl:template match="book/info" mode='copyright'>
        <xsl:result-document href="'copyright.html" encoding="utf-8" exclude-result-prefixes="#all" method="xhtml">
        <html>
            <head>
                <title><xsl:apply-templates select='publisher/publishername'/></title>
                <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                <link rel="stylesheet" type="text/css" href="../styles/fowl.css"/>
                <meta name="page-id" content="copyright"/>
            </head>
            <body class='copyright'>    
                
                <p class='EB13CopyrightHead'><xsl:value-of select='upper-case(publisher/publishername)'/></p>
                
                <p class="EB14CopyrightText">Published by the Penguin Group</p>
                <p class="EB14CopyrightText">Penguin Books Ltd, 80 Strand, London WC2R 0RL, England</p>
                <p class="EB14CopyrightText">Penguin Group (USA) Inc., 375 Hudson Street, New York, New York 10014, USA</p>
                <p class="EB14CopyrightText">Penguin Group (Canada), 90 Eglinton Avenue East, Suite 700, Toronto, Ontario, Canada M4P 2Y3 (a division of Pearson Penguin Canada Inc.)</p>
                <p class="EB14CopyrightText">Penguin Ireland, 25 St Stephen’s Green, Dublin 2, Ireland (a division of Penguin Books Ltd)</p>
                <p class="EB14CopyrightText">Penguin Group (Australia), 250 Camberwell Road, Camberwell, Victoria 3124, Australia (a division of Pearson Australia Group Pty Ltd)</p>
                <p class="EB14CopyrightText">Penguin Books India Pvt Ltd, 11 Community Centre, Panchsheel Park, New Delhi – 110 017, India</p>
                <p class="EB14CopyrightText">Penguin Group (NZ), 67 Apollo Drive, Rosedale, Auckland 0632, New Zealand (a division of Pearson New Zealand Ltd)</p>
                <p class="EB14CopyrightText">Penguin Books (South Africa) (Pty) Ltd, 24 Sturdee Avenue, Rosebank, Johannesburg 2196, South Africa</p>
                
                <p class="EB14CopyrightText">Penguin Books Ltd, Registered Offices: 80 Strand, London WC2R 0RL, England</p>
                
                <p class="EB14CopyrightText">www.puffinbooks.com</p>
                
                <xsl:apply-templates select="biblioset[@relation='publicationhistory']/pubdate"/>
                
                <xsl:apply-templates select='.//copyright'/>
                <xsl:apply-templates select="biblioset[@relation='credits']"/>
                <p class="EB14CopyrightText">All rights reserved</p>
                
                <p class="EB14CopyrightText">The moral right of the author and illustrators has been asserted</p>
                
                <p class="EB14CopyrightText">Except in the United States of America, this book is sold subject to the condition 
                    that it shall not, by way of trade or otherwise, be lent, re-sold, hired out, 
                    or otherwise circulated without the publisher’s prior consent in any form of binding or cover 
                    other than that in which it is published and without a similar condition including this condition 
                    being imposed on the subsequent purchaser</p>
                                
                <p class="EB14CopyrightText">ISBN: <xsl:apply-templates select=".//biblioid[@class='isbn'][@role='epub']"/></p>
            </body>
            </html>
        </xsl:result-document>  
    </xsl:template>
    
    <xsl:template match="pubdate[1]">
        <p class="EB14CopyrightText">
            <xsl:apply-templates select='ancestor::info/title' mode='toc'/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
       </p>
    </xsl:template>
    
    <xsl:template match="biblioset[@relation='credits']/bibliomisc">
        <p class="EB14CopyrightText"><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="pubdate[position() gt 1]">
        <p class="EB14CopyrightText"><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="copyright">
        <p class="EB14CopyrightText">Text copyright © <xsl:apply-templates select='holder'/>, <xsl:apply-templates select='year'/></p>    
    </xsl:template>
    
    <xsl:template match="publishername|pubdate|holder|year">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="biblioid[@class='isbn']">
        <xsl:value-of select='cfn:format-isbn(.)'/>
    </xsl:template>
    
    <xsl:template match='biblioset'>
        <xsl:apply-templates/>
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
