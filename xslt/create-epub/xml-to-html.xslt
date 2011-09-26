<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:peng="http://www.penguingroup.com/ns/standard" xmlns:cfn="urn:corbas:functions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xpath-default-namespace="http://docbook.org/ns/docbook" exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="page-ids.xslt"/>

    <xsl:output method="xhtml"/>

    <xsl:param name="debug.page.generation" select="'no'"/>

    <xsl:param name="image-uri-base" select="'../images'"/>
    
    <xsl:param name="html.suffix" select="'.html'"/>
    
    <xsl:param name="notes.file.name" select="'notes'"/>

    <!-- params taken from docbook -->
    <xsl:param name="author.othername.in.middle" select="1"/>

    <xsl:key name="id-cache" match='*[@xml:id]'  use="@xml:id"/>

    <xsl:template match="/">
        <xsl:apply-templates select="book"/>
        <xsl:apply-templates select="book" mode="toc"/>
    </xsl:template>

    <xsl:template match="book">
        <xsl:apply-templates select="dedication|info/cover|preface|appendix|glossary|bibliography|chapter|part"/>
        <xsl:apply-templates select="info" mode="copyright"/>
        <xsl:call-template name="generate-notes"/>
    </xsl:template>

    <xsl:template match="part">

        <xsl:apply-templates/>

    </xsl:template>
    
    <!-- ignore the dummy appendix for the notes - only used in FO -->
    <xsl:template match="appendix[@role='notes']" mode='#all'/>

    <xsl:template match="part/info">

        <xsl:variable name="page-id">
            <xsl:call-template name="page.id">
                <xsl:with-param name="node" select='parent::*'/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="filename">
            <xsl:call-template name="page.href">
                <xsl:with-param name="node" select='parent::*'/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="html-doc">
            <xsl:with-param name="page-id" select="$page-id"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="chapter|preface|bibliography|appendix">

        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="preface[@role='books-by']">

        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    


    <xsl:template match="cover">

        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <title>
                    <xsl:value-of select="if (@role) then @role else 'Cover'"/>
                </title>
            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>

    <xsl:template match="bibliomixed">
        <p class="EB26SmallTextHangingIndent">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="bibliomixed/*">
        <span class="{local-name()}"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match='bibliomixed/citetitle' priority='1'>
        <em><xsl:apply-templates/></em>
    </xsl:template>

    <xsl:template match="author//personblurb">
        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <xsl:apply-templates select="info/title|title" mode="as-title"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dedication">
        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <title>Dedication</title>
            </xsl:with-param>
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
    
    <!-- titleabbrev is used in the fo but not the html -->
    <xsl:template match="titleabbrev"/>


    <xsl:template match="title|info/title" mode="as-title">
        <title>
            <xsl:apply-templates select="*" mode="as-title"/>
        </title>
    </xsl:template>
    
    <xsl:template match="title" mode="notes">
        <h5 class="EB07SmallCapsMediumHead">
            <xsl:apply-templates/>
        </h5>
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

    <xsl:template
        match="preface/para[position() = 1]|chapter/para[position() = 1]|section/para[position()=1]">
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

    <xsl:template match="blockquote/para[position()=1]" priority="2">
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
        <p class="asterisk">
            <span>*</span>
        </p>
    </xsl:template>

    <xsl:template match="para[preceding-sibling::*[1][self::para][. = '*']]">
        <p class="EB02BodyTextFullOut">
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>



    <xsl:template match="attribution">
        <p class="EB18EpigraphSource">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="citetitle">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="stanza[@role='stanza']">
        <div class="AFStanza">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="linegroup">
        <div class="AFLinegroup">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="line">
        <p class="AFLine">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="poetry">
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
        <xsl:variable name="role" select="(ancestor-or-self::*/@role)[1]"/>
        <xsl:variable name="id" select="@xml:id"/>
        <img src="{concat($image-uri-base, '/', @fileref)}" alt="{@fileref}/"/>
    </xsl:template>

    <xsl:template match="emphasis">
        <span class="{@role}">
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

        <xsl:param name="class" select="'listitem'"/>

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
        <span class="url">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="link[@linkend]">
        
        <xsl:variable name='node' select="key('id-cache', @linkend)"/>
        
        <xsl:if test="not($node)">
            <xsl:message terminate="yes">Attempt to link to non-existant id - <xsl:value-of select='@linkend'/></xsl:message>
        </xsl:if>
        
        <xsl:variable name="href">
            <xsl:call-template name='object.href'>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>    
        </xsl:variable>
        
        <a href="{$href}"><xsl:apply-templates/></a>
        
    </xsl:template>

    <xsl:template match="link[@xlink:href]">
        <a href="{@xlink:href}">
            <xsl:choose>
                <xsl:when test="normalize-space(.) = ''">
                    <xsl:value-of select="@xlink:href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    

    <xsl:template match="literallayout|screen">
        <div class="{local-name()}">
            <pre>
                <xsl:if test="@role">
                    <xsl:attribute name="class" select="@role"/>
                </xsl:if>
                <xsl:apply-templates/>
            </pre>
        </div>
    </xsl:template>

    <xsl:template match="superscript">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>

    <xsl:template match="subscript">
        <sub>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>

    <xsl:template match="@xml:id">
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
        <xsl:message terminate="yes">Unhandled element - <xsl:value-of select="local-name()"
            /></xsl:message>
    </xsl:template>


    <!-- the serialisation info here is a dummy as we actually serialise in XProc -->
    <xsl:template name="html-doc">
        
        <xsl:param name="filename">
            <xsl:call-template name="page.href"/>
        </xsl:param>
        
        <xsl:param name="page-id">
            <xsl:call-template name="page.id"/>
        </xsl:param>
        
        <xsl:param name="contents">
            <xsl:apply-templates mode="#current"/>
        </xsl:param>
        
        <xsl:param name="title"/>
        
        <xsl:if test="$debug.page.generation = 'yes'">
            <xsl:message>
                Generating page for the "<xsl:value-of select='local-name()'/>" element with id "<xsl:value-of select='@xml:id'/>".
                File name will be: "<xsl:value-of select='$filename'/>" and page-id will be "<xsl:value-of select="$page-id"/>".
            </xsl:message>
        </xsl:if>
        
        <xsl:variable name="class" select="if (@role) then @role else local-name()"/>
        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml"
            href="{$filename}">
            <html xml:id="{$page-id}">
                <head>
                    <xsl:copy-of select="$title"/>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                </head>
                <body class="{$class}">
                    <xsl:call-template name="create-body-id"/>
                    <xsl:copy-of select='$contents'/>
                </body>
            </html>
        </xsl:result-document>

    </xsl:template>


    <!-- Table of Contents -->

    <xsl:template match="book" mode="toc">


        <xsl:result-document encoding="utf-8" exclude-result-prefixes="#all" method="xhtml"
            href="toc.html">
            <html xml:id="toc">
                <head>
                    <title>Contents</title>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                    <meta name="page-id" content="toc"/>
                </head>
                <body class="toc">
                    <h2 class="EB04MainHead">Contents</h2>
                    <xsl:apply-templates select="/book/info/cover[@role='cover']" mode="toc"/>
                    <xsl:apply-templates select="dedication" mode="toc"/>
                    <xsl:apply-templates select="/book/info/cover[@role='title']" mode="toc"/>
                    <xsl:apply-templates
                        select="preface[not(@role) or not(@role = ('author', 'books-by'))]"
                        mode="toc"/>
                    <xsl:apply-templates select="part|chapter" mode="toc"/>
                    <xsl:apply-templates select="author//personblurb" mode="toc"/>
                    <xsl:apply-templates select="preface[@role = ('author', 'books-by')]" mode="toc"
                    />
                </body>
            </html>
        </xsl:result-document>


    </xsl:template>

    <xsl:template match="preface" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:apply-templates select="info/title|title" mode="toc"/>
            </a>
        </p>
    </xsl:template>

    <xsl:template match="cover" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>        
        <xsl:variable name="title"
            select="concat(upper-case(substring(@role, 1, 1)), lower-case(substring(@role, 2)))"/>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:value-of select="$title"/>
            </a>
        </p>
    </xsl:template>

    <xsl:template match="dedication" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">Dedication</a>
        </p>
    </xsl:template>

    <xsl:template match="personblurb" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">About the author</a>
        </p>
    </xsl:template>

    <xsl:template match="chapter|part" mode="toc">
        <xsl:variable name="filename"><xsl:call-template name="page.href"/></xsl:variable>
        <p class="EB15ContentsText">
            <a href="{$filename}">
                <xsl:apply-templates select="info/title|title" mode="toc"/>
            </a>
        </p>
        <xsl:apply-templates select="chapter" mode="toc"/>
    </xsl:template>


    <!-- copyright page -->
    <xsl:template match="book/info" mode="copyright">
        <xsl:result-document href="copyright.html" encoding="utf-8" exclude-result-prefixes="#all"
            method="xhtml">
            <html xml:id="copyright">
                <head>
                    <title>
                        <xsl:apply-templates select="publisher/publishername"/>
                    </title>
                    <link rel="stylesheet" type="text/css" href="../styles/stylesheet.css"/>
                    <meta name="page-id" content="copyright"/>
                </head>
                <body class="copyright">

                    <p class="EB13CopyrightHead">
                        <xsl:value-of select="upper-case(publisher/publishername)"/>
                    </p>

                    <p class="EB14CopyrightText">Published by the Penguin Group</p>
                    <p class="EB14CopyrightText">Penguin Books Ltd, 80 Strand, London WC2R 0RL,
                        England</p>
                    <p class="EB14CopyrightText">Penguin Group (USA) Inc., 375 Hudson Street, New
                        York, New York 10014, USA</p>
                    <p class="EB14CopyrightText">Penguin Group (Canada), 90 Eglinton Avenue East,
                        Suite 700, Toronto, Ontario, Canada M4P 2Y3 (a division of Pearson Penguin
                        Canada Inc.)</p>
                    <p class="EB14CopyrightText">Penguin Ireland, 25 St Stephen’s Green, Dublin 2,
                        Ireland (a division of Penguin Books Ltd)</p>
                    <p class="EB14CopyrightText">Penguin Group (Australia), 250 Camberwell Road,
                        Camberwell, Victoria 3124, Australia (a division of Pearson Australia Group
                        Pty Ltd)</p>
                    <p class="EB14CopyrightText">Penguin Books India Pvt Ltd, 11 Community Centre,
                        Panchsheel Park, New Delhi – 110 017, India</p>
                    <p class="EB14CopyrightText">Penguin Group (NZ), 67 Apollo Drive, Rosedale,
                        Auckland 0632, New Zealand (a division of Pearson New Zealand Ltd)</p>
                    <p class="EB14CopyrightText">Penguin Books (South Africa) (Pty) Ltd, 24 Sturdee
                        Avenue, Rosebank, Johannesburg 2196, South Africa</p>

                    <p class="EB14CopyrightText">Penguin Books Ltd, Registered Offices: 80 Strand,
                        London WC2R 0RL, England</p>

                    <p class="EB14CopyrightText">www.puffinbooks.com</p>

                    <xsl:apply-templates select="biblioset[@relation='publicationhistory']/pubdate"/>

                    <xsl:apply-templates select=".//copyright"/>
                    <xsl:apply-templates select="biblioset[@relation='credits']"/>
                    <p class="EB14CopyrightText">All rights reserved</p>

                    <p class="EB14CopyrightText">The moral right of the author and illustrators has
                        been asserted</p>

                    <p class="EB14CopyrightText">Except in the United States of America, this book
                        is sold subject to the condition that it shall not, by way of trade or
                        otherwise, be lent, re-sold, hired out, or otherwise circulated without the
                        publisher’s prior consent in any form of binding or cover other than that in
                        which it is published and without a similar condition including this
                        condition being imposed on the subsequent purchaser</p>

                    <p class="EB14CopyrightText">ISBN: <xsl:apply-templates
                            select=".//biblioid[@class='isbn'][@role='epub']"/></p>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="info//pubdate[1]">
        <p class="EB14CopyrightText">
            <xsl:apply-templates select="ancestor::info/title" mode="toc"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="biblioset[@relation='credits']/bibliomisc">
        <p class="EB14CopyrightText">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="info//pubdate[position() gt 1]">
        <p class="EB14CopyrightText">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="copyright">
        <p class="EB14CopyrightText">Text copyright © <xsl:apply-templates select="holder"/>,
                <xsl:apply-templates select="year"/></p>
    </xsl:template>

    <xsl:template match="publishername|pubdate|holder|year">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="biblioid[@class='isbn']">
        <xsl:value-of select="cfn:format-isbn(.)"/>
    </xsl:template>

    <xsl:template match="biblioset">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:apply-templates select='*[not(self::attribution)]'/>
            <xsl:apply-templates select='attribution'/>
        </div>
    </xsl:template>

    <xsl:template name="apply-annotations"/>

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

          

    <!-- object hrefs -->
    <xsl:template name="object.href">
        <xsl:param name='node' select='.'/>
        <xsl:variable name="object-id" select="$node/ancestor-or-self::*[@xml:id][1]/@xml:id"/>
        <xsl:variable name='page-href'>
            <xsl:call-template name="page.href">
                <xsl:with-param name='node' select='$node'/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat($page-href, '#', $object-id)"/>
    </xsl:template>

    <!-- useful styles copied from the DocBook stylesheets and then modified as needed -->

    <xsl:template name="person.name">
        <!-- Formats a personal name. Handles corpauthor as a special case. -->
        <xsl:param name="node" select="."/>

        <xsl:variable name="style">
            <xsl:choose>
                <xsl:when test="$node/@role">
                    <xsl:value-of select="$node/@role"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'person.name.first-last'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <!-- the personname element is a specialcase -->

            <xsl:when test="$node/personname">
                <xsl:call-template name="person.name">
                    <xsl:with-param name="node" select="$node/personname"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <!-- Handle case when personname contains only general markup (DocBook 5.0) -->
                    <xsl:when
                        test="$node/self::personname and not($node/firstname or $node/honorific or $node/lineage or $node/othername or $node/surname)">
                        <xsl:apply-templates select="$node/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="person.name.first-last">
                            <xsl:with-param name="node" select="$node"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="person.name.first-last">
        <xsl:param name="node" select="."/>

        <xsl:if test="$node//honorific">
            <xsl:apply-templates select="$node//honorific[1]"/>
            <xsl:value-of select="'.'"/>
        </xsl:if>

        <xsl:if test="$node//firstname">
            <xsl:if test="$node//honorific">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$node//firstname[1]"/>
        </xsl:if>

        <xsl:if test="$node//othername and $author.othername.in.middle != 0">
            <xsl:if test="$node//honorific or $node//firstname">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$node//othername[1]"/>
        </xsl:if>

        <xsl:if test="$node//surname">
            <xsl:if
                test="$node//honorific or $node//firstname
                  or ($node//othername and $author.othername.in.middle != 0)">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$node//surname[1]"/>
        </xsl:if>

        <xsl:if test="$node//lineage">
            <xsl:text>, </xsl:text>
            <xsl:apply-templates select="$node//lineage[1]"/>
        </xsl:if>

    </xsl:template>

    <xsl:template match="personname">
        <xsl:call-template name="person.name"/>
    </xsl:template>

    <xsl:template match="honorific|firstname|surname|lineage|othername">
        <xsl:call-template name="inline.charseq"/>
    </xsl:template>


    <xsl:template name="inline.charseq">
        <xsl:param name="content">
            <xsl:apply-templates/>
        </xsl:param>
        <!-- * if you want output from the inline.charseq template wrapped in -->
        <!-- * something other than a Span, call the template with some value -->
        <!-- * for the 'wrapper-name' param -->
        <xsl:param name="wrapper-name">span</xsl:param>
        <xsl:element name="{$wrapper-name}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">
                <xsl:value-of select="local-name(.)"/>
            </xsl:attribute>
            <xsl:copy-of select="$content"/>
            <xsl:call-template name="apply-annotations"/>
        </xsl:element>
    </xsl:template>
    
    <!-- footnotes -->
    
    <xsl:template name="generate-notes">
        <xsl:call-template name="html-doc">
            <xsl:with-param name="title">
                <title>Notes</title>
            </xsl:with-param>
            <xsl:with-param name="page-id" select="'notes'"/>
            <xsl:with-param name="filename" select="'notes.html'"/>
            <xsl:with-param name="contents">
                <xsl:apply-templates select="preface|appendix|glossary|bibliography|chapter|part" mode="notes"/>
            </xsl:with-param>            
        </xsl:call-template>        
    </xsl:template>

    <!-- Default mode for footnotes - we insert a link to the notes file. Because we want to
    link back we also need to create an anchor. -->
    <xsl:template match="footnote">
        <!-- what do we use as a label. Going to insert sequential number from our chapter type ancestor-->
        <xsl:variable name='container' select="if (ancestor::part) then ancestor::*[parent::*[part]] else ancestor::*[parent::book]"/>
        <xsl:variable name='chapter-pos' select="count($container//footnote[. &lt;&lt; current()]) + 1"/>
        <span class='noteref' id='{@xml:id}'><sup>
            <a href="{concat($notes.file.name, $html.suffix, '#', @xml:id)}">
                <xsl:apply-templates select='.' mode='marker'/>
            </a></sup>
        </span>
    </xsl:template>
    
    
    <xsl:template match="footnote/para[position() = 1]" mode="notes">
        <xsl:variable name="marker">
            <xsl:apply-templates select='..' mode='marker'/>
        </xsl:variable>
        
        <xsl:variable name="marker.padding" select="if (string-length($marker) lt 4) 
            then substring('&#xA0;&#xA0;&#xA0;&#xA0;', 1, 4 - string-length($marker))
            else ' '"/>
        
        <xsl:variable name='anchor'>
            <xsl:call-template name="page.href">
                <xsl:with-param name="node" select=".."/>
                <xsl:with-param name="create.fragment" select="true()"/>
            </xsl:call-template>
        </xsl:variable>        
        
        <p class='EB26SmallTextHangingIndent' id="{../@xml:id}">
            <a href="{$anchor}"><xsl:value-of select='$marker'/></a>
            <xsl:value-of select='$marker.padding'/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    
    <xsl:template match="footnote/para[position() gt 1]" mode="notes">
        <p class='EB26SmallTextHangingIndent'>
          <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="footnote" mode="notes">
        <xsl:apply-templates mode="notes"/>
    </xsl:template>
    
    <xsl:template match="footnote"  mode="marker">
        <xsl:variable name='container' select="if (ancestor::part) then ancestor::*[parent::*[part]] else ancestor::*[parent::book]"/>
        <xsl:variable name='chapter-pos' select="count($container//footnote[. &lt;&lt; current()]) + 1"/>        
        <xsl:value-of select='$chapter-pos'/>
    </xsl:template>
    
    <xsl:template match="part" mode="notes">
        <xsl:apply-templates mode='notes'/>
    </xsl:template>
    
    <xsl:template match="preface|appendix|glossary|bibliography|chapter|part" mode="notes">
        <xsl:if test="descendant::footnote">
            <div class='notes-section'>
                <xsl:apply-templates select='title|info/title' mode='notes'/>
                <xsl:apply-templates select="descendant::footnote" mode='notes'/>            
            </div>
        </xsl:if>
    </xsl:template>
    
   

    <xsl:template name="create-body-id">
        <xsl:variable name='with-id' select="ancestor-or-self::*[@xml:id][1]"/>
        <xsl:attribute name="id" select="$with-id/@xml:id"/>
    </xsl:template>
    
</xsl:stylesheet>
