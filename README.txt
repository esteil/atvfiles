ATVFiles README
Version 0.5.0 (43)
September ??, 2007

Copyright (c) 2007 Eric Steil III (ericiii.net)

Discussion forum: http://forum.awkwardtv.org/viewforum.php?f=18

== Description ==
Simple file browser plugin for Apple TV Finder.  Think XBMC, it can play video
files without transcoding and syncing/streaming them.  

Please note that ATVFiles does not provide the codecs.  
Perian (http://perian.org) and A52Codec (http://trac.cod3r.com/a52codec/) are
highly recommended to be installed to provide support for a wide variety of codecs.

== Installation ==
Engadget posted a pretty good tutorial on installing this:
http://www.engadget.com/2007/04/10/how-to-play-divx-and-xvid-on-your-apple-tv/

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

NOTE: 0.4 MAY HAVE A DELAY UPON ENTERING A DIRECTORY FOR THE FIRST TIME WHILE
IT CACHES METADATA AND FILE DURATIONS.  FOR A LARGE DIRECTORY THIS MAY TAKE A
FEW MINUTES, DURING WHICH THERE IS NO INDICATION OF ANY ACTIVITY.

=== Cover Art ===
ATVFiles looks for cover art in either JPG, TIFF, or PNG formats.  It looks for
specific filenames of the following formats (the jpg extension is an example,
and can be either "jpg", "tif", "tiff", or "png"):

For folders: Either "folder.jpg" or "cover.jpg" in the folder.

For other files: The same as the filename without the extension, and the image
extension (jpg, tif, tiff, png).  For instance, "anchorman-xvid.avi" would look 
for "anchorman-xvid.jpg" for cover art.

== Preferences ==
The preferences can be set using the "defaults" command, such as:
  defaults write net.ericiii.ATVFiles RootPath /mnt/Server

To change a boolean preference, use:
  defaults write net.ericiii.ATVFiles EnableAC3Passthrough -bool YES

Finder needs to be restarted to pick up any changes.

The preferences available are:

RootDirectory: The path it looks at when first entering the plugin.
  Defaults to /Users/frontrow/Movies (or whatever user the ATV interface is running
  as, i.e. frontrow on Apple TV)
EnableAC3Passthrough: Boolean, enable AC3 passthrough support in A52Codec (see 0.3.0 
  release notes for details)
  Default: NO
EnableFileDurations: Boolean, disable scanning files for their duration, as it can
  be slow.
  Default: YES
ShowFileExtensions: Boolean, show filename extensions
  Default: YES
ShowFileSize: Boolean, show file size
  Default: YES
ShowUnplayedDot: Boolean, show the blue unplayed dot
  Default: YES
VideoExtensions: Array of file extensions (without leading ".") that are
  video files.
  Default: (m4v, 3gp, m3u, pls, divx, xvid, avi, mov, wmv, asx, asf, ogm,
            mpg, mpeg, mp4, mkv, avc, flv, dv, fli, m2v, ts)
AudioExtensions: Array of file extensions (without leading ".") that are
  audio files.
  Default: (m4b, m4a, mp3, wma, wav, aif, aiff, flac, alac, m3u, mp2)
ResumeOffset: Integer, number of seconds to add to the bookmark time when resuming.
  Negative will go back in time.
  Default: 0
EnableStacking: Boolean, enable stacking of files
  Default: YES
StackRegexps: Array of regular expressions to group for stacking
  PCRE format, if one group to match it is the part number, 
  if multiple groups, the second one is the part number.
  Default: (
    [ _\\.-]+cd[ _\\.-]*([0-9a-d]+),
    [ _\\.-]+dvd[ _\\.-]*([0-9a-d]+),
    [ _\\.-]+part[ _\\.-]*([0-9a-d]+),
    ()([a-d])(\\....)$
  )
  
Note: Files with extensions not listed in either VideoExtensions or AudioExtensions
are not displayed.  Just because an extension is listed does not mean it will play
without appropriate components installed, the list is mostly copied from XBMC.

When updating the VideoExtensions and AudioExtensions pref, you must include all
default items (if you want them), the defaults will not be used if you override
them.  You also must use the array options (-array and -array-add) to defaults to 
update them.  The extensions should also be listed in lowercase.

The list of extensions is also used to determine which player (video or audio) is
used for playback.

== XML Metadata Format ==
The xml file is looked for along side the video file (and cover art), with the same name
and an "xml" extension.  That is, "anchorman-divx.avi" will look for "anchorman-divx.xml".

Not all of the fields are shown in the UI, this just represents the data stored and
available internally.

Example file, see the wiki for more complete examples:

  <media type="TV Show">
    <title>Title</title>
    <artist>Artist</artist>
    <summary>Summary of Media</summary>
    <description>Description of Media</description>
    <publisher>Publisher</publisher>
    <composer>Composer</composer>
    <copyright>Copyright</copyright>
    <userStarRating>5</userStarRating>
    <starRating>5</starRating>
    <rating>TV-PG</rating>
    <seriesName>Veronica Mars</seriesName>
    <broadcaster>The CW</broadcaster>
    <episodeNumber>101</episodeNumber>
    <season>1</season>
    <episode>1</episode>
    <published>2006-01-01</published>
    <acquired>2006-01-01</acquired>
    <duration>3600</duration>
    
    <genres>
      <genre primary="true">Mystery</genre>
      <genre>Drama</genre>
    </genres>
    
    <cast>
      <name>Kristen Bell</name>
    </cast>
    
    <producers>
      <name>Rob Thomas</name>
    </producers>
    
    <directors>
      <name>Rob Thomas</name>
    </directors>
  </media>
  
Random Notes about the data:
* All these are optional
* duration is only to override if the QuickTime scanning gets it wrong, otherwise it
  should not be used.
* rating will display graphics for the usual ones (R, TV-PG, etc.)
* the type attribute has some control over the values shown in the metadata,
  possible values are "Song", "Music Video", "Podcast", "Movie", "TV Show",
  "Audio Book".  The default type is Movie
* published is the original air date for TV Shows
* not all values are actually used for display, regardless of the "type",
  but all are stored

== Release Notes ==
0.5.0 (??) September ??, 2007
* Now requires Apple TV OS 1.1 (full or safe update).
* Fix extensions being stripped from non-filename titles.
* Add file stacking and seamless playback.
* Delay duration scanning until file playback.  Files will show duration of 0 until they
  are played, or it is specified in the XML file.  The detected duration will be saved 
  regardless of if it's in the XML.
* Added playlist support (only m3u files for now).
* Added context menu accessed by pressing right on any file browser item.
** Options for: deleting files, playing entire selected directory contents, viewing detailed info
   on a file.
* Add support for adjusting most preferences in the app.
* Add German translation from teldec and Finnish translation from ryokale.

* Support proper
0.4.0 (22) July 23, 2007
* Add new icon from Telusman.
* Proper music playback with fancy UI.
* Fixed holding files open, preventing deletion.
* Actually set the A52Codec passthrough preference on startup, for real (AC3 passthrough
  should work now without setting the com.cod3r.a52codec preference).
* Gracefully handle XML files in a format other than expected.
* No longer stores a bookmark time when a file has been completely played.
* Use mplayer for duration checking, should be somewhat faster overall now, at the expense
  of a much larger download size.
* Disable sound effects when playing back video with AC3 passthrough enabled
* Reverted directory scanning code, should cope better with non-ASCII filenames.
* Stop music playback when starting video/exiting ATVFiles.

0.3.2 (14) June 20, 2007
* Update for compatibility with the Apple TV 1.1 update.

0.3.1 (13) May 20, 2007
* Add resume feature to 0.3.0 release notes.
* Fix problem with disabling file duration scanning ignoring duration specified in
  XML file.
* Add ResumeOffset preference to allow offsetting the resume time.
* Fix crash with changing media type in XML.
  
0.3.0 (12) May 19, 2007
* Remember last playback position and offer to resume resume.
* Show blue dots next to unplayed files.
* Read metadata from an XML file alongside the media file (like coverart).
** See above for the format
* Add EXPERIMENTAL AC3 Passthrough support with the EnableAC3Passthrough preference
  when using optical audio out.
** This requires Perian 1.0.
** Will not work properly for non-48k sample rate AC3 tracks, as it sets the sample
   rate to 48000 on startup and leaves it there.  These, however, are rare.
* Fix stripping extensions from folder names
* Use home directory of current user instead of hardcoding /Users/frontrow/Movies
* Hide the files "Icon\r" (folder icons), "Desktop DB" and "Desktop DF" from listings
* Revert to showing on all sources, not just local
** Can be changed by adjusting the value of FRRemoteAppliance in Info.plist
* Include fix from alan_quatermain to allow the main menu to scroll if there are
  a bunch of items

0.2.2 (8) April 11, 2007
* Added French and Spanish localizations
* Fix problem with absolute symlinks
* Use natural sorting for files with numbers
* Add preferences to hide filename extensions and file sizes

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
  supported. (Seems to be a BackRow problem, try restarting the ATV.)
* There is lag when a directory is first visited since it has to load and
  scan all metadata, and no indiciation is displayed.  This will only happen
  the first time, future visits should be faster (as it only loads changed
  metadata)
* Metadata is not read from the media files themselves (ID3, etc.)
* Some stuttering of playing music can occur when browsing files.
* Playlist issues:
** Video playlist playback shows seek bar for every entry after first one.
** No UI for creating/managing.
** No easy way to seek between entries in a video playlist, and seek back.
* No adjustment of root directory from the preferences UI.

== Plans ==
* Support running an external editor (i.e. VLC) for specific file extensions
* Minimize delays on opening directories
* Use media parades for folders without explicit cover art
* Read ID3 and similar tags
* Cover art url tag in XML, and cache cover art

== License ==
It's free to use, however please don't redistribute it without my permission.

== Notice ==
This program is provided at your own risk.  The author claims no responsibility
for any damage or other outcome that may occur from use of this software.

The author is not affiliated with Apple, Inc.

== Acknowledgements ==
Contains AGRegex, copyright (c) 2002 Aram Greenman, which in turns contains
PCRE, both of which are available under the BSD license.

== Special Thanks ==
* alan_quatermain (#awkwardtv) for his magic code to bypass the plugin 
  whitelist.
* Telusman (http://telusman.deviantart.com/) for the new icon.
* jsh, Marco Schreijen, tomoto, GoldstarQC, elchubi, Valdemar, Stefan 
  Christiansson, slump, BABAPUS, teldec and ryokale for translations. 
