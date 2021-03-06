#!/usr/bin/env perl
#
# $Id$
#
# Required for using MultiMarkdown
#
# Copyright (c) 2006-2007 Fletcher T. Penney
#	<http://fletcherpenney.net/>
#
# MultiMarkdown Version 2.0.b4
#

# Combine all the steps necessary to process MultiMarkdown text into XHTML
# Not necessary, but might be easier than stringing the commands together
# manually

# TODO: Add an option to turn SmartyPants off?

# Add metadata to guarantee we can transform to a complete XHTML
$data = "Format: complete\n";


# Parse stdin (MultiMarkdown file)
undef $/;
$data .= <>;


# Find name of XHTML File if specified
$xslt_file = _XhtmlXSLT($data);
$xslt_file = "" if ($xslt_file eq "");
$xslt = "";

# Decide which flavor of SmartyPants to use
$language = _Language($data);
$SmartyPants = "SmartyPants.pl";

$SmartyPants = "SmartyPantsGerman.pl" if ($language =~ /^\s*german\s*$/i);

$SmartyPants = "SmartyPantsFrench.pl" if ($language =~ /^\s*french\s*$/i);

$SmartyPants = "SmartyPantsSwedish.pl" if ($language =~ /^\s*(swedish|norwegian|finnish|danish)\s*$/i);

$SmartyPants = "SmartyPantsDutch.pl" if ($language =~ /^\s*dutch\s*$/i);


# Create a pipe and process
$me = $0;				# Where am I?

# Am I running in Windoze?
my $os = $^O;

if ($os =~ /MSWin/) {
	$me =~ s/\\([^\\]*?)$/\\/;	# Get just the directory portion
} else {
	$me =~ s/\/([^\/]*?)$/\//;	# Get just the directory portion	
}

if ($os =~ /MSWin/) {
	$xslt = "| xsltproc -nonet -novalid ..\\XSLT\\$xslt_file -" if ($xslt_file ne "");
	open (MultiMarkdown, "| cd \"$me\"& .\\MultiMarkdown.pl | .\\$SmartyPants $xslt");
} else {
	$xslt = "| xsltproc -nonet -novalid ../XSLT/$xslt_file -" if ($xslt_file ne "");
	open (MultiMarkdown, "| cd \"$me\"; ./MultiMarkdown.pl | ./$SmartyPants $xslt");
}
print MultiMarkdown $data;

close(MultiMarkdown);


sub _XhtmlXSLT {
	my $text = shift;
	
	my ($inMetaData, $currentKey) = (1,'');
	
	foreach my $line ( split /\n/, $text ) {
		$line =~ /^$/ and $inMetaData = 0 and next;
		if ($inMetaData) {
			if ($line =~ /^([a-zA-Z0-9][0-9a-zA-Z _-]*?):\s*(.*)$/ ) {
				$currentKey = $1;
				my $temp = $2;
				$currentKey =~ s/ //g;
				$g_metadata{$currentKey} = $temp;
				if (lc($currentKey) eq "xhtmlxslt") {
					$g_metadata{$currentKey} =~ s/(\.xslt)?$/.xslt/;
					return $g_metadata{$currentKey};
				}
			} else {
				if ($currentKey eq "") {
					# No metadata present
					$inMetaData = 0;
					next;
				}
			}
		}
	}
		
	return;
}

sub _Language {
	my $text = shift;
	
	my ($inMetaData, $currentKey) = (1,'');
	
	foreach my $line ( split /\n/, $text ) {
		$line =~ /^$/ and $inMetaData = 0 and next;
		if ($inMetaData) {
			if ($line =~ /^([a-zA-Z0-9][0-9a-zA-Z _-]*?):\s*(.*)$/ ) {
				$currentKey = $1;
				$currentKey =~ s/  / /g;
				$g_metadata{$currentKey} = $2;
				if (lc($currentKey) eq "language") {
					return $g_metadata{$currentKey};
				}
			} else {
				if ($currentKey eq "") {
					# No metadata present
					$inMetaData = 0;
					next;
				}
			}
		}
	}
		
	return;
}