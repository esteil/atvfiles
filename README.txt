ATVFiles README
Version 0.2.1 (6)
April 8, 2007

Copyright (c) 2007 Eric Steil III (ericiii.net)

== Description ==
Simple file browser plugin for Apple TV Finder.  Think XBMC, it can play video
files without transcoding and syncing/streaming them.  

Please note that ATVFiles does not provide the codecs.  
Perian (http://perian.org) and A52Codec (http://trac.cod3r.com/a52codec/) are
highly recommended to be installed to provide support for a wide variety of codecs.

== Installation ==
1. Copy ATVFiles.frappliance to this folder:
   /System/Library/CoreServices/Finder.app/Contents/PlugIns 
   on the Apple TV.  You may want to create a symlink from there to some more 
   convenient place.
2. Restart Finder.
   The command "ps awx|grep [F]inder" will list the PID as the first number,
   then running "kill PID" will kill it.

If you have the Apple TV drive mounted on your local system, the correct path
is on the OSBoot volume.

If you have the drive installed in the Apple TV, you will likely have to mount
the root partition as read-write (using "sudo /sbin/mount -uw /") to copy it.
The command "sudo /sbin/mount -ur /" will reverse the above action.

== Usage ==
Enter the new "Files" menu on the main menu.

It lists files in /Users/frontrow/Movies, so mount or put your video files
in that folder.

=== Cover Art ===
ATVFiles looks for cover art in either JPG, TIFF, or PNG formats.  It looks for
specific filenames of the following formats (the jpg extension is an example,
and can be either "jpg", "tif", "tiff", or "png"):

For folders: Either "folder.jpg" or "cover.jpg" in the folder.

For other files: The same as the filename without the extension, and the image
extension (jpg, tif, tiff, png).  For instance, "anchorman.xvid.avi" would look 
for "anchorman.xvid.jpg" for cover art.

== Preferences ==
The preferences can be set using the "defaults" command, such as:
  defaults write net.ericiii.ATVFiles RootPath /mnt/Server

Finder needs to be restarted to pick up any changes.

The preferences available are:

RootDirectory: The path it looks at when first entering the plugin.
  Defaults to /Users/frontrow/Movies
EnableAC3Passthrough: Boolean (unused, for future use)
  Default: NO
EnableFileDurations: Boolean, disable scanning files for their duration, as it can
  be slow.
  Default: NO
VideoExtensions: Array of file extensions (without leading ".") that are
  video files.
  Default: (m4v, 3gp, m3u, pls, divx, xvid, avi, mov, wmv, asx, asf, ogm,
            mpg, mpeg, mp4, mkv, avc, flv, dv, fli, m2v, ts)
AudioExtensions: Array of file extensions (without leading ".") that are
  audio files.
  Default: (m4b, m4a, mp3, wma, wav, aif, aiff, flac, alac, m3u, mp2)

Note: Files with extensions not listed in either VideoExtensions or AudioExtensions
are not displayed.  Just because an extension is listed does not mean it will play
without appropriate components installed, the list is mostly copied from XBMC.

When updating the VideoExtensions and AudioExtensions pref, you must include all
default items (if you want them), the defaults will not be used if you override
them.  You also must use the array options (-array and -array-add) to defaults to 
update them.  The extensions should also be listed in lowercase.

== Release Notes ==
0.2.1 (6) April 8, 2007
* Added Japanese localizations
* Fixed case-sensitivity when matching valid filename extensions
* Fixed a minor problem with certain symlinks
* Changed EnableFileDurations default to NO until metadata is cached
* Fixed not finding cover art when folder name contains [, ], ? or *.

0.2.0 (5) April 8, 2007
* Don't show the menu item when viewing remote sources
* Cleaner plugin whitelist handling that doesn't raise an exception
* Add basic metadata preview, including cover art
* Don't show Movies folder title as root ATVFiles menu title (match root menu title)
* Update icon to a non-Apple icon, and show it on all menu titles
* Add basic German and Dutch localizations
* Filter filenames based on extension to predefined list
* Added preferences to deal with root directory 
* Distribute as .tar.gz instead of .dmg
* Change directory content scanning method, fixes some AFP problems but not all.

0.1.0 (2) March 30, 2007
* First release

== Known Issues ==
* Files on AFP shares sometimes don't play even if they show up and are 
  supported.
* Non-video files are played back using the QT player.
* With certain combinations of codec and source location, there can be
  some lag when browsing menus and looking at the previews.

== Plans ==
* (0.3) Add code necessary to enable AC3 Passthrough with recent A52Codec svn
  builds.
* (0.3) Add persistent metadata caching, and read more metadata from media
  files (or external metadata file, like cover art)
* Use media parades for folders without explicit cover art?
* Non-video playback support?

== License ==
Right now, it's free to use, however don't redistribute it without my
permission.

== Notice ==
This program is provided at your own risk.  The author claims no responsibility
for any damage or other outcome that may occur from use of this software.

The author is not affiliated with Apple, Inc.

== Special Thanks ==
* alan_quatermain (#awkwardtv) for his magic code to bypass the plugin 
  whitelist.
* BigBaconAndEggs (#awkwardtv) for the new icon.
* jsh, Macro Schreijen and tomoto for translations. 