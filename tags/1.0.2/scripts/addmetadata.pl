#!/usr/bin/env perl
#
# $Id$
#
# Command line tool to prepend metadata in a MulitMarkdown document
# before processing.
#
# Copyright (c) 2006-2007 Fletcher T. Penney
#	<http://fletcherpenney.net/>
#
# MultiMarkdown Version 2.0.b4
#

# grab metadata from args

my $result = "";

foreach $data (@ARGV) {
	$result .= $data . "\n";	
}

@ARGV = ();

# grab document from stdin

undef $/;
$result .= <>;


print $result;