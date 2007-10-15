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
RUNARCHIVENAME=$(PROJNAME)-$(VERSION).zip
RUNBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).run

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
	
dist-tarball: release
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
	
dist-sfx: release
	@echo "BUILDING SFX DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	mkdir -p "$(TMPROOT)/ARCTEMP/$(TARDIR)"
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(RUNBALL)"
	
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/ARCTEMP/$(TARDIR)"
	rm -rf "$(TMPROOT)/ARCTEMP/$(TARDIR)/AGRegex.framework"
	mv "$(TMPROOT)/ARCTEMP/$(TARDIR)/README.txt" "$(TMPROOT)/$(TARDIR)/README.txt"
	
	# build the archive of this
	ditto -c -k --rsrc "$(TMPROOT)/ARCTEMP/$(TARDIR)" "$(TMPROOT)/$(TARDIR)/$(RUNARCHIVENAME)"
	rm -rf "$(TMPROOT)/$(TARDIR)/ARCTEMP"
	
	sed -e "s,@VERSION@,$(VERSION),g" \
		-e "s,@TARDIR@,$(TARDIR),g" \
		-e "s,@ARCHIVE_NAME@,$(RUNARCHIVENAME),g" \
		< tools/install.sh > "$(TMPROOT)/$(TARDIR)/install.sh"
	chmod a+x "$(TMPROOT)/$(TARDIR)/install.sh"
	
	# build the sfx
	makeself --nocrc --nocomp --nox11 "$(TMPROOT)/$(TARDIR)" "$(RUNBALL)" "$(PROJNAME) $(VERSION)" "./install.sh"
	
	rm -rf "$(TMPROOT)"
	
dist: dist-tarball dist-sfx
	
testrel:
	echo "Building release nightly"
	$(MAKE) dist VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
testdist:
	echo "Building debug distribution $(TEST_VERSION)"
	$(MAKE) dist DISTCONFIG=Debug VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
.PHONY: default build dist release dist-tarball testdist testrel dist-sfx

