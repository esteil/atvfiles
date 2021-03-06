# Makefile
#
# Copyright (C) 2007 Eric Steil III
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

REVISION=$(shell agvtool vers -terse)
VERSION=$(shell scripts/xcodeversion version -terse)
PROJNAME=ATVFiles

# SDK to build against
#
# If you have modified your 10.4 sdk normally, this should be "macosx10.4"
SDK=macosx10.4-atv

DISTROOT=dist
TMPROOT=$(DISTROOT)/tmp
DISTCONFIG=Release

# tarball archive settings
TARDIR=$(PROJNAME)-$(VERSION)
TARBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).tar.gz

# sfx archive settings
RUNARCHIVENAME=$(PROJNAME)-$(VERSION).zip
RUNBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).run

# pkg settings
PKGTREE=System/Library/CoreServices/Front Row.app/Contents/PlugIns/
PKGBALL=$(DISTROOT)/$(PROJNAME)-$(VERSION).pkg

# SoftwareMenu plist files
VERSION_PLIST_SOURCE=tools/ATVFiles.plist
VERSION_PLIST=$(PWD)/dist/ATVFiles
VERSION_PLIST_FILE=$(VERSION_PLIST).plist

TEST_VERSION_SUFFIX_DATE=$(shell date +"%y.%m.%d.%H%M")
TEST_VERSION_SUFFIX=-TEST-$(TEST_VERSION_SUFFIX_DATE)
TEST_VERSION=$(VERSION)$(TEST_VERSION_SUFFIX)

EXTRA_OPTS=

# doc settings
README_SOURCE=README.txt
README_DEST=dist/README.html
LICENSE_SOURCE=LICENSE.txt
LICENSE_DEST=dist/LICENSE.txt

default: build

strings: English.lproj/Localizable.strings
	
English.lproj/Localizable.strings: *.m
	genstrings -s BRLocalizedString -o English.lproj *.m
		
build:
	xcodebuild -sdk $(SDK) -configuration Debug
	
release: build/$(DISTCONFIG)/ATVFiles.frappliance/Contents/MacOS/ATVFiles

build/$(DISTCONFIG)/ATVFiles.frappliance/Contents/MacOS/ATVFiles: *.h *.m
	xcodebuild -sdk $(SDK) -configuration "$(DISTCONFIG)" clean $(EXTRA_OPTS)
	xcodebuild -sdk $(SDK) -configuration "$(DISTCONFIG)" $(EXTRA_OPTS)

	rm -rf "build/$(DISTCONFIG)/ATVFiles.frappliance.dSYM"
	rm -rf "build/$(DISTCONFIG)/AGRegex.framework"
	rm -rf "build/$(DISTCONFIG)/AGRegex.framework.dSYM"
	rm -rf "build/$(DISTCONFIG)/SapphireCompatClasses.framework"
	rm -rf "build/$(DISTCONFIG)/SapphireCompatClasses.framework.dSYM"
	rm -rf "build/$(DISTCONFIG)/SapphireLeopardCompatClasses.framework"
	rm -rf "build/$(DISTCONFIG)/SapphireLeopardCompatClasses.framework.dSYM"
	rm -rf "build/$(DISTCONFIG)/SapphireTakeTwoCompatClasses.framework"
	rm -rf "build/$(DISTCONFIG)/SapphireTakeTwoCompatClasses.framework.dSYM"	

docs: $(README_DEST) $(LICENSE_DEST)
	mkdir -p "build/$(DISTCONFIG)"
	cp README.txt LICENSE.txt "build/$(DISTCONFIG)/"

$(README_DEST): $(README_SOURCE)
	scripts/multimarkdown2XHTML.pl $(README_SOURCE) > $(README_DEST)
	
$(LICENSE_DEST): $(LICENSE_SOURCE)
	cp $(LICENSE_SOURCE) $(LICENSE_DEST)

# Build the tarball for ATVLoader
dist-tarball: docs release 
	@echo "BUILDING DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	# build tarball
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(TARBALL)"
	
	# copy contents to tmproot
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/$(TARDIR)"
	
	tar -C "$(TMPROOT)" -czf "$(PWD)/$(TARBALL)" "$(TARDIR)"
	rm -rf "$(TMPROOT)"
	
	# Update the plist version
	cp "$(VERSION_PLIST_SOURCE)" "$(VERSION_PLIST_FILE)"
	defaults write "$(VERSION_PLIST)" ATVFiles3 -dict-add \
		Version "$(REVISION)" \
		displayVersion "$(VERSION)" \
		theURL "http://ericiii.net/sa/appletv/$(shell basename $(TARBALL))" \
		ReleaseDate -date "$(shell date +%Y-%m-%d)" \
		md5 "$$(md5sum "$(PWD)/$(TARBALL)" | cut -d' ' -f1)"
	plutil -convert xml1 "$(VERSION_PLIST_FILE)"
	
# Build the self-extracting archive
dist-sfx: docs release
	@echo "BUILDING SFX DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	mkdir -p "$(TMPROOT)/ARCTEMP/$(TARDIR)"
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(RUNBALL)"
	
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/ARCTEMP/$(TARDIR)"

	mv "$(TMPROOT)/ARCTEMP/$(TARDIR)/README.txt" "$(TMPROOT)/$(TARDIR)/README.txt"
	mv "$(TMPROOT)/ARCTEMP/$(TARDIR)/LICENSE.txt" "$(TMPROOT)/$(TARDIR)/LICENSE.txt"
	
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
	
# Build the Leopard distribution package
dist-pkg: docs release
	@echo "BUILDING LEOPARD PKG FOR ATVFiles $(VERSION) ($(REVISION))"
	
	mkdir -p "$(TMPROOT)/PKGROOT"
	rm -f "$(PKGBALL)"
	
	cp $(LICENSE_DEST) $(README_DEST) $(README_CSS) "$(TMPROOT)/"
	
	# copy stuff in place
	ditto "build/$(DISTCONFIG)/ATVFiles.frappliance" "$(TMPROOT)/PKGROOT/ATVFiles.frappliance"
	
	# build the archive
	/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -o "$(PKGBALL)" --target 10.5 --root-volume-only \
		--id net.ericiii.ATVFiles --version "$(VERSION)" --title "ATVFiles $(VERSION)" --doc "ATVFiles.pmdoc"
	
	# clean up
	rm -rf "$(TMPROOT)"
	
	
dist: dist-tarball dist-sfx
	
dist-debug:
	$(MAKE) dist DISTCONFIG=Debug EXTRA_OPTS="RELEASE_SUFFIX=\"-debug\"" VERSION="$(VERSION)-debug"
	
fulldist: dist-debug dist

testrel:
	echo "Building release nightly"
	$(MAKE) dist VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
testdist:
	echo "Building debug distribution $(TEST_VERSION)"
	$(MAKE) dist DISTCONFIG=Debug VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""

clean:
	xcodebuild -sdk $(SDK) clean -configuration Release
	xcodebuild -sdk $(SDK) clean -configuration Debug
		
.PHONY: default build dist dist-tarball testdist testrel dist-sfx dist-pkg dist-debug clean

