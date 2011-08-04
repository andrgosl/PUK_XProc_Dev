<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xd"
    version="1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 10, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
            <xd:p>Parameters defined for poetry</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- 
        Parameters to define if html class attributes are to be defined for
        poetry.
    -->

    <!-- generate classes for lines? -->
    <xsl:param name="poetry.generate.line.classes">1</xsl:param>
    
    <!-- generate an additional class for the first line of a stanza? -->
    <xsl:param name="poetry.generate.first.line.class">1</xsl:param>
    
    <!-- generate an additional class for the last line of a stanza? -->
    <xsl:param name="poetry.generate.last.line.class">1</xsl:param>
    
    <!-- class names to use for the above -->
    <xsl:param name="poetry.first.line.class">first-line</xsl:param>
    <xsl:param name="poetry.last.line.class">last-line</xsl:param>
    <xsl:param name="poetry.odd.line.class">odd-line</xsl:param>
    <xsl:param name="poetry.even.line.class">even-line</xsl:param>
       
    <!-- generate the speaker of a speech as a child of the first element
    or as a preceding sibling of the first element. Set to 1 to make
    the speaker a block on its own -->
    <xsl:param name="drama.speaker.block-formatted">0</xsl:param>
    
    <!-- text to use as a separator between the speaker and the text
    defaults to a colon and a space -->
    <xsl:param name="drama.speaker.separator" select="': '"/>
    
    
    <!-- class control -->
    
    <!-- We need to be able to override the separator used when concatenating @class values
    so that output aimed at the Kindle can use a non space separator - multiple html
    @class values are not supported by the Kindle. -->
    <xsl:param name="line-based.class.separator" select="' '"/>
    
    <!-- Override the default processing of model used with para.propagates.class. We
        often need multiple styles (especially with poetry). In order to handle the
        line based content (drama, poetry, dialogues) merge the role and the local
        name to create the class if this is set (using the separator above). 
        Set linebased.merge.classes to zero to return to the normal behaviour. -->
    <xsl:param name="line-based.merge.classes">1</xsl:param>
    
 
    
</xsl:stylesheet>