ATVFiles README
Version 0.1.0 (2)
March 30, 2007

Copyright (c) 2007 Eric Steil III (ericiii.net)

DESCRIPTION
===========
Simple file browser plugin for Apple TV Finder.  Perian (http://perian.org)
and A52Codec (http://trac.cod3r.com/a52codec/) are highly recommended.

See http://wiki.awkwardtv.org/ for more details.

INSTALLATION
============
1. Copy ATVFiles.frappliance to this folder:
   /System/Library/CoreServices/Finder.app/Contents/PlugIns 
   on the Apple TV.  You may want to create a symlink from there to some more 
   convenient place.
2. Restart Finder.
   The command "ps awx|grep Finder" will list the PID as the first number,
   then running "kill PID" will kill it.

USAGE
=====
Enter the new "Files" menu on the main menu.

It lists files in /Users/frontrow/Movies, so mount or put your video files
in that folder.

RELEASE NOTES
=============
0.2.0 (??) ???
* Don't show the menu item when viewing remote sources
* Cleaner plugin whitelist handling that doesn't raise an exception
* Add basic metadata preview, including cover art
* Don't show Movies folder title as root ATVFiles menu title
* Update icon to a non-Apple icon, and show it on all menu titles
* Add basic German and Dutch localizations
* Filter filenames based on extension to predefined list
 
0.1.0 (2) March 30, 2007
* First release

KNOWN ISSUES
============
* AFP mounts don't seem to show up if they're in a location symlinked to.
  Mount them directly under Movies instead.
* Non-video files are played back using the QT player.
* No previews, etc.
* The icon is ugly and scaled way up.

PLANS
=====
In no particular order:
* Implement media previews and fill in the blank space on the left side of
  the screen.
* Non-video playback support?

LICENSE
=======
Right now, it's free to use, however don't redistribute it without my
permission.

NOTICE
======
This program is provided at your own risk.  The author claims no responsibility
for any damage or other outcome that may occur from use of this software.

The author is not affiliated with Apple, Inc.

SPECIAL THANKS
==============
Thanks to alan_quatermain (#awkwardtv) for his magic code to bypass the plugin
whitelist.
