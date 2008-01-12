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
	
# Build the tarball for ATVLoader
dist-tarball: release
	@echo "BUILDING DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	cp README.txt LICENSE.txt "build/$(DISTCONFIG)/"
	
	# build tarball
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(TARBALL)"
	
	# copy contents to tmproot
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/$(TARDIR)"
	rm -rf "$(TMPROOT)/$(TARDIR)/AGRegex.framework"
	rm -rf "$(TMPROOT)/$(TARDIR)/CompatClasses.framework"
	tar -C "$(TMPROOT)" -czf "$(PWD)/$(TARBALL)" "$(TARDIR)"
	rm -rf "$(TMPROOT)"
	
# Build the self-extracting archive
dist-sfx: release
	@echo "BUILDING SFX DISTRIBUTION FOR ATVFiles $(VERSION) ($(REVISION))"
	
	mkdir -p "$(TMPROOT)/ARCTEMP/$(TARDIR)"
	mkdir -p "$(TMPROOT)/$(TARDIR)"
	rm -f "$(RUNBALL)"
	
	ditto "build/$(DISTCONFIG)/" "$(TMPROOT)/ARCTEMP/$(TARDIR)"
	rm -rf "$(TMPROOT)/ARCTEMP/$(TARDIR)/AGRegex.framework"
	rm -rf "$(TMPROOT)/ARCTEMP/$(TARDIR)/CompatClasses.framework"
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
dist-pkg: release
	@echo "BUILDING LEOPARD PKG FOR ATVFiles $(VERSION) ($(REVISION))"
	
	mkdir -p "$(TMPROOT)/PKGROOT"
	rm -f "$(PKGBALL)"
	
	cp LICENSE.txt README.txt "$(TMPROOT)/"
	
	# copy stuff in place
	ditto "build/$(DISTCONFIG)/ATVFiles.frappliance" "$(TMPROOT)/PKGROOT/ATVFiles.frappliance"
	
	# build the archive
	/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -o "$(PKGBALL)" --target 10.5 --root-volume-only \
		--id net.ericiii.ATVFiles --version "$(VERSION)" --title "ATVFiles $(VERSION)" --doc "ATVFiles.pmdoc"
	
	# clean up
	rm -rf "$(TMPROOT)"
	
	
dist: dist-tarball dist-sfx dist-pkg
	
testrel:
	echo "Building release nightly"
	$(MAKE) dist VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
testdist:
	echo "Building debug distribution $(TEST_VERSION)"
	$(MAKE) dist DISTCONFIG=Debug VERSION="$(TEST_VERSION)" EXTRA_OPTS="RELEASE_SUFFIX=\"$(TEST_VERSION_SUFFIX)\""
	
.PHONY: default build dist release dist-tarball testdist testrel dist-sfx dist-pkg

