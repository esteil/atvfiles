# Makefile
#
# Just some convenience scripts

REVISION=$(shell agvtool vers -terse)
VERSION=$(shell agvtool mvers -terse | grep 'Found CFBundleShortVersionString' | sed -e "s,Found CFBundleShortVersionString of ,,g" -e 's,",,g' | cut -d" " -f 1 )
PROJNAME=ATVFiles

DISTROOT=dist
TMPROOT=$(DISTROOT)/tmp
DISTCONFIG=Release
TARDIR=$(PROJNAME)-$(VERSION)
TARBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).tar.gz

default: build

strings: English.lproj/Localizable.strings
	
English.lproj/Localizable.strings: *.m
	genstrings -s BRLocalizedString -o English.lproj *.m
		
build:
	xcodebuild -configuration Debug
	
dist:
	@echo "BUILDING DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	xcodebuild -configuration "$(DISTCONFIG)" clean
	xcodebuild -configuration "$(DISTCONFIG)"
	
	cp README.txt "build/$(DISTCONFIG)/"
	
	# build tarball
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(TARBALL)"
	
	# copy contents to tmproot
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/$(TARDIR)"
	tar -C "$(TMPROOT)" -czf "$(PWD)/$(TARBALL)" "$(TARDIR)"
	rm -rf "$(TMPROOT)"
	
.PHONY: default build dist
