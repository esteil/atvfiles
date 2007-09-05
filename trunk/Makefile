# Makefile
#
# Just some convenience scripts

REVISION=$(shell agvtool vers -terse)
VERSION=$(shell xcodeversion version -terse)
PROJNAME=ATVFiles

DISTROOT=dist
TMPROOT=$(DISTROOT)/tmp
DISTCONFIG=Release
TARDIR=$(PROJNAME)-$(VERSION)
TARBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).tar.gz

TEST_VERSION_SUFFIX_DATE=$(shell date +"%y.%m.%d.%H%M")
TEST_VERSION_SUFFIX=-TEST-$(TEST_VERSION_SUFFIX_DATE)
TEST_VERSION=$(VERSION)$(TEST_VERSION_SUFFIX)

EXTRA_OPTS=

default: build

strings: English.lproj/Localizable.strings
	
English.lproj/Localizable.strings: *.m
	genstrings -s BRLocalizedString -o English.lproj *.m
		
build:
	xcodebuild -configuration Debug
	
release:
	xcodebuild -configuration "$(DISTCONFIG)" clean $(EXTRA_OPTS)
	xcodebuild -configuration "$(DISTCONFIG)" $(EXTRA_OPTS)
	
dist: release
	@echo "BUILDING DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	cp README.txt "build/$(DISTCONFIG)/"
	
	# build tarball
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(TARBALL)"
	
	# copy contents to tmproot
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/$(TARDIR)"
	rm -rf "$(TMPROOT)/$(TARDIR)/AGRegex.framework"
	tar -C "$(TMPROOT)" -czf "$(PWD)/$(TARBALL)" "$(TARDIR)"
	rm -rf "$(TMPROOT)"
	
testdist:
	echo "Building debug distribution $(TEST_VERSION)"
	$(MAKE) dist DISTCONFIG=Debug VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
.PHONY: default build dist release
