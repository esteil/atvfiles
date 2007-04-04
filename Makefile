# Makefile
#
# Just some convenience scripts

REVISION=$(shell agvtool vers -terse)
VERSION=$(shell agvtool mvers -terse | grep 'Found CFBundleShortVersionString' | sed -e "s,Found CFBundleShortVersionString of ,,g" -e 's,",,g' | cut -d" " -f 1 )
PROJNAME=ATVFiles

DISTROOT=dist
DISTCONFIG=Release
DMGNAME=$(PROJNAME) $(VERSION)
DMGFILE=$(DISTROOT)/$(PROJNAME)-$(VERSION).dmg

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
	
	# build DMG
	mkdir -p dist
	rm -f "$(DMGFILE)"
	hdiutil create -srcfolder "build/$(DISTCONFIG)/" -volname "$(DMGNAME)" -format UDZO "$(DMGFILE)"
	
.PHONY: default build dist
