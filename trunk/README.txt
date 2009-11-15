Format: complete
Title: ATVFiles Readme
Date: 2009-11-15
XHTML Header: <style>body{font-family: 'Lucida Grande', 'Verdana', Arial, Helvetica, sans-serif;}</style>

# ATVFiles Readme
Version 1.3.0b1 (502)
November 15, 2009

Copyright (c) 2007-2009 Eric Steil III (ericiii.net)

[Download][]  
[Screenshot gallery][]  
[Discussion forum][]  
[Development site][]
  
  [screenshot gallery]: http://www.tuaw.com/photos/atv-files-beta/
  [discussion forum]: http://forum.awkwardtv.org/viewforum.php?f=18
  [download]: http://atvfiles.com
  [development site]: http://atvfiles.googlecode.com

## Description

ATVFiles is an Apple TV plugin that allows the user to browse the entire ATV filesystem 
via the Apple Remote. This allows you to navigate to files that would not
normally sync to the ATV, files stored on a network drive or another Mac for instance.
Combined with the proper codecs, ATVFiles will allow you to play any of your media.

Please note that ATVFiles does not provide the codecs.  [Perian][] is highly recommended as it provides
all the common codecs.

  [perian]: http://perian.org

## Installation

### Apple TV

*NOTE:* As of version 1.3.0, ATVFiles requires at least the Apple TV 3.0 update to run.

ATVFiles can be installed via Software Menu, or manually via the `ATVFiles-1.3.0.run` file.

To install manually,

1. Copy the file `ATVFiles-1.3.0.run` to the Apple TV.
2. SSH into the Apple TV, and run the following command: `sudo sh ATVFiles-1.3.0.run`

It does not matter what the file is named, if Safari renames it to something like `ATVFiles-1.3.0.run.sh` it will still work fine.

### Manual method

Engadget posted a pretty good [tutorial][] on installing this.

  [tutorial]: http://www.engadget.com/2007/04/10/how-to-play-divx-and-xvid-on-your-apple-tv/

1. Copy ATVFiles.frappliance to this folder:
   `/System/Library/CoreServices/Finder.app/Contents/PlugIns`
   on the Apple TV.  You may want to create a symlink from there to some more 
   convenient place.
2. Restart Finder.
   The command `ps awx|grep [F]inder` will list the PID as the first number,
   then running `kill PID` will kill it.

If you have the Apple TV drive mounted on your local system, the correct path
is on the OSBoot volume.

If you have the drive installed in the Apple TV, you will likely have to mount
the root partition as read-write (using `sudo /sbin/mount -uw /`) to copy it.
The command `sudo /sbin/mount -ur /` will reverse the above action.

## Usage

Enter the new "Files" menu on the main menu.

It lists files in /Users/frontrow/Movies, so mount or put your video files
in that folder.

NOTE: 0.4 MAY HAVE A DELAY UPON ENTERING A DIRECTORY FOR THE FIRST TIME WHILE
IT CACHES METADATA AND FILE DURATIONS.  FOR A LARGE DIRECTORY THIS MAY TAKE A
FEW MINUTES, DURING WHICH THERE IS NO INDICATION OF ANY ACTIVITY.

### Cover Art

ATVFiles looks for cover art in either JPG, TIFF, or PNG formats.  It looks for
specific filenames of the following formats (the jpg extension is an example,
and can be either `jpg`, `tif`, `tiff`, or `png`):

For folders: Either `folder.jpg` or `cover.jpg` in the folder.

For other files: The same as the filename without the extension, and the image
extension (jpg, tif, tiff, png).  For instance, `anchorman-xvid.avi` would look 
for `anchorman-xvid.jpg` for cover art.

## Preferences

The preferences can be set using the "defaults" command, such as:

    defaults write net.ericiii.ATVFiles RootPath /mnt/Server

To change a boolean preference, use:

    defaults write net.ericiii.ATVFiles EnableAC3Passthrough -bool YES

Finder needs to be restarted to pick up any changes.

The preferences available are:

RootDirectory: The path it looks at when first entering the plugin.
> Default: `/Users/frontrow/Movies`
>
> The default is actually whatever user the ATV interface is running.  On an Apple TV, this user is `frontrow`.
  
EnableAC3Passthrough: Boolean, enable AC3 passthrough support in A52Codec (see 0.3.0 release notes for details)
> Default: NO

EnableFileDurations: Boolean, disable scanning files for their duration, as it can be slow.
> Default: YES

ShowFileExtensions: Boolean, show filename extensions
> Default: YES

ShowFileSize: Boolean, show file size
> Default: YES

ShowUnplayedDot: Boolean, show the blue unplayed dot
> Default: YES

VideoExtensions: Array of file extensions (without leading ".") that are video files.
> Default:
  `(m4v, 3gp, m3u, pls, divx, xvid, avi, mov, wmv, asx, asf, 
    ogm, mpg, mpeg, mp4, mkv, avc, flv, dv, fli, m2v, ts)`

AudioExtensions: Array of file extensions (without leading ".") that are audio files.
> Default: 
  `(m4b, m4a, mp3, wma, wav, aif, aiff, flac, alac, m3u, mp2)`

ResumeOffset: Integer, number of seconds to add to the bookmark time when resuming. Negative will go back in time.
> Default: 0

EnableStacking: Boolean, enable stacking of files
> Default: YES

StackRegexps: Array of regular expressions to group for stacking
> These are in PCRE format, if one group to match it is the part number, 
  if multiple groups, the second one is the part number.

> Default: `(
    [ _\\.-]+cd[ _\\.-]*([0-9a-d]+),
    [ _\\.-]+dvd[ _\\.-]*([0-9a-d]+),
    [ _\\.-]+part[ _\\.-]*([0-9a-d]+),
    ()([a-d])(\\....)$
  )`
  
EnableSubtitlesbyDefault: Boolean, enable subtitles when starting playback
> Default: NO

EnterAutomatically: Boolean, automatically enter ATVFiles at boot.
> Default: NO

ShowFileIcons: Boolean, show the playlist/stack icons in the file listings.
> Default: YES

MountBlacklist: Array, paths to mount points to never show.
> Default: ("/")

EnableFolderParades: Boolean, enable showing folder parades when a folder has no cover.jpg.
> Default: YES

ShowPlacesOnMenu: Boolean, show the Places menu item on the main menu (Apple TV 2.0 only)
> Default: YES

ShowSettingsOnMenu: Boolean, show the Settings menu item on the main menu (Apple TV 2.0 only)
> Default: YES

UsePlaybackMenu: Boolean, show the in-playback menu when pressing MENU during playback
> Default: YES

Places: Array, paths for "places"
> Default: (*RootDirectory*)

PlacesMode: String, places mode enabled.
> This setting has no effect on Apple TV 2.0.
>
> Default: `On`

Valid values for `PlacesMode` are:

* `On`: Enabled, with volumes and bookmarked folders on the initial list.
* `Volumes`: Show contents of `RootDirectory` along with any mounted volumes.
* `Off`: Do not show bookmarks or volumes in the initial listing.

Bookmarks/volumes will always be accessible from the context menu.  On Take 2, this setting
is ignored.

Note: Files with extensions not listed in either VideoExtensions or AudioExtensions
are not displayed.  Just because an extension is listed does not mean it will play
without appropriate components installed, the list is mostly copied from XBMC.

When updating the VideoExtensions and AudioExtensions pref, you must include all
default items (if you want them), the defaults will not be used if you override
them.  You also must use the array options (-array and -array-add) to defaults to 
update them.  The extensions should also be listed in lowercase.

The list of extensions is also used to determine which player (video or audio) is
used for playback.

## XML Metadata Format

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

## Release Notes

### 1.3.0 (???) November ??, 2009

* Support for Apple TV 3.0

### 1.2.1.1 (491) November 1, 2009

* Rebuild with latest SapphireCompatibilityClasses to fix compatibility with newer Sapphire releases.
* Fix crash when deleting files.

### 1.2.1 (485) June 28, 2009
 
* Support for Apple TV 2.4
  * Limited support for the new iPhone Remote (basically, the gesture navigation).

### 1.2.0 (479) December 14, 2008

* Support for Apple TV 2.2 and 2.3.
  * Use a more robust implementation of stacking and playlist playback.
  * Perian 1.1.2 (or newer) is required for AC3 passthrough on Apple TV 2.2 or newer.
* Drop official support for Apple TV versions older than 2.1.

### 1.1.1 (444) July 14, 2008

* Various crash fixes for Apple TV 2.1:
  * Fix AC3 passthrough
  * Fix folder parades
  * Fix not returning to menu on end of video playback

### 1.1.0 (435) March 17, 2008

* Add support for running on Apple TV Take Two.
  * Places is always enabled on Take Two, as the right side of the main menu shows all the manually set ones.
* Fix music player on Leopard.
* Speed up the folder parades a bit.
  * Added entry in the Settings menu to enable/disable folder parades.
* Fix music playback not stopping when leaving ATVFiles when Places is in use.
* Add preferences `ShowPlacesOnMenu`, `ShowSettingsOnMenu` and `UsePlaybackMenu` for advanced tweaks.
  * `Show...OnMenu` preferences enable/disable Places or Settings on the Take Two main menu (Take Two only).
  * `UsePlaybackMenu` disables the menu when pressing MENU during playback.

### 1.0.2 (379) February 10, 2008

* Fix "blinking" of in-playback menu when choosing "Return to file listing."
* Swap the positions of "resume" and "return to file listing" options on the in-playback menu, two make it two presses instead of three to return to the menu.
* Fix incorrect duration when first playing back a previously unseen audio file.
* Fix potential crash when returning to browser from video player.
* Add prefix option to .run installer for automated installs (i.e. Patchstick).
  * Usage: `sh ATVFiles-1.0.2.run install /path/to/root`

### 1.0.1 (362) January 20, 2008

* Don't include playlists and other folders when gathering assets for folder art parades.
  * Add a preference `EnableFolderParades` to completely disable folder parades (pre-1.0 behavior).
* Fix display of folder cover art when a cover image is present.
* Fix display of cover art on Apple TV just not working.

### 1.0.0 (361) January 13, 2008

* Add menu on MENU press during playback.
  * Playlist previous/next navigation for video playlists
  * Subtitle toggling
* Add option to toggle subtitles.
  * Add `EnableSubtitlesByDefault` preference to enable them by default.
* Fix the "unknown" genre problem, now any genre can be displayed with the metadata, and "unknown" will not be displayed when not specified.
* Move file size (still optional) to the metadata display instead of in the file listing.
* Add cover art preview of playlist/folder contents.
* Fix crashes with cover art and unicode file names.
* Delay resolving symlinks until playback, allowing metadata/cover art to be displayed for the symlink
  instead of that for the target.
* Add option to delete entire folders.
* Fix file deletion not deleting all stack segments and metadata.
* Add `EnterAutomatically` preference to automatically enter ATVFiles at boot.
* Add `ShowFileIcons` preference to hide the playlist/stack icons in the listing.
* Add Places feature, which are essentially bookmarks for favorite folders.
  * Mounted volumes are listed independently (no need for mounting/symlinking under `~/Movies`).
  * Folders can be added/removed from places by pressing RIGHT with the folder highlighted.
* Leopard compatibility, thanks to the Sapphire team!
  * Add pkg file for easy Leopard installation.
* The settings menu now takes up the full width of the screen, instead of just the right-hand side.
* Now open-sourced under GPL 3.

### 0.5.1 (273) October 15, 2007

* Fix memory leak, which was holding files open after playback.
* Actually add the Finnish translations. Sorry about that.

### 0.5.0 (45) September 29, 2007

* Now requires Apple TV OS 1.1 (full or safe update).
* Fix extensions being stripped from non-filename titles.
* Add file stacking and seamless playback.
* Delay duration scanning until file playback.  Files will show duration of 0 until they
  are played, or it is specified in the XML file.  The detected duration will be saved 
  regardless of if it's in the XML.
* Added playlist support (only m3u files for now).
* Added context menu accessed by pressing right on any file browser item.
  * Options for: deleting files, playing entire selected directory contents, viewing detailed info
    on a file.
* Add support for adjusting most preferences in the app.
* Add German translation from teldec and Finnish translation from ryokale.
* Added icons in file list for playlists and file stacks.
* Added self-extracting shell script to automate manual installation.

### 0.4.0 (22) July 23, 2007

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

### 0.3.2 (14) June 20, 2007

* Update for compatibility with the Apple TV 1.1 update.

### 0.3.1 (13) May 20, 2007

* Add resume feature to 0.3.0 release notes.
* Fix problem with disabling file duration scanning ignoring duration specified in
  XML file.
* Add ResumeOffset preference to allow offsetting the resume time.
* Fix crash with changing media type in XML.
  
### 0.3.0 (12) May 19, 2007

* Remember last playback position and offer to resume resume.
* Show blue dots next to unplayed files.
* Read metadata from an XML file alongside the media file (like coverart).
  * See above for the format
* Add EXPERIMENTAL AC3 Passthrough support with the EnableAC3Passthrough preference
  when using optical audio out.
  * This requires Perian 1.0.
  * Will not work properly for non-48k sample rate AC3 tracks, as it sets the sample
    rate to 48000 on startup and leaves it there.  These, however, are rare.
* Fix stripping extensions from folder names
* Use home directory of current user instead of hardcoding /Users/frontrow/Movies
* Hide the files "Icon\r" (folder icons), "Desktop DB" and "Desktop DF" from listings
* Revert to showing on all sources, not just local
   * Can be changed by adjusting the value of FRRemoteAppliance in Info.plist
* Include fix from alan_quatermain to allow the main menu to scroll if there are
  a bunch of items

### 0.2.2 (8) April 11, 2007

* Added French and Spanish localizations
* Fix problem with absolute symlinks
* Use natural sorting for files with numbers
* Add preferences to hide filename extensions and file sizes

### 0.2.1 (6) April 8, 2007

* Added Japanese localizations
* Fixed case-sensitivity when matching valid filename extensions
* Fixed a minor problem with certain symlinks
* Changed EnableFileDurations default to NO until metadata is cached
* Fixed not finding cover art when folder name contains [, ], ? or *.

### 0.2.0 (5) April 8, 2007

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

### 0.1.0 (2) March 30, 2007

* First release

## Known Issues

* Files on AFP shares sometimes don't play even if they show up and are 
  supported. (Seems to be a BackRow problem, try restarting the ATV.)
* There is lag when a directory is first visited since it has to load and
  scan all metadata, and no indiciation is displayed.  This will only happen
  the first time, future visits should be faster (as it only loads changed
  metadata)
* Metadata is not read from the media files themselves (ID3, etc.)
* Some stuttering of playing music can occur when browsing files.
* Playlist issues:
  * Video playlist playback shows seek bar for every entry after first one.
  * No UI for creating/managing playlists.
* No adjustment of root directory from the preferences UI.

## Plans

* Minimize delays on opening directories
* Read ID3 and similar tags
* Cover art url tag in XML

## Building

Requires Xcode 3 on Mac OS X 10.5 to build.

You need to do some setup beforehand.  See [the wiki][sdk_setup] for details.

  [sdk_setup]: http://wiki.awkwardtv.org/wiki/Create_Environment_for_stock_ATV_1.1_Development_with_Leopard

## License

Copyright (C) 2007-2009 Eric Steil III.

ATVFiles is licensed under GPL 3.  The full license can be found in LICENSE.txt.
 
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Notice

This program is provided at your own risk.  The author claims no responsibility
for any damage or other outcome that may occur from use of this software.

The author is not affiliated with Apple, Inc.

## Acknowledgements

Contains AGRegex, copyright (c) 2002 Aram Greenman, which in turns contains
PCRE, both of which are available under the BSD license.

Leopard compatibility code is based off the work of the Sapphire team, 
which they made available under the GPL 3 license.

## Special Thanks

* alan_quatermain (#awkwardtv) for his magic code to bypass the plugin 
  whitelist.
* Telusman (http://telusman.deviantart.com/) for the new icon.
* The Sapphire Team (http://appletv.nanopi.net) for the Leopard compatibility code.
* jsh, Marco Schreijen, tomoto, GoldstarQC, elchubi, Valdemar, Stefan 
  Christiansson, slump, BABAPUS, teldec and ryokale for translations. 
