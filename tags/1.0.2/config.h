//
// Configuration for building ATVFiles
// really just on/off defines
//
// These really shouldn't be changed, this is mainly for development/debugging
// aids.
//
// Copyright (C) 2007-2008 Eric Steil III
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// Enable legacy 1.0 compatibility code
//  NOTE: THIS WILL NOT MAGICALLY MAKE THE PLUGIN RUN ON 1.0 AS ATVFVideoPlayer IS NOT 1.0 COMPATIBLE
#undef ENABLE_1_0_COMPATABILITY

// Enable reading the duration of files at the menu.  Does not
// work properly for playlists.
#undef READ_DURATIONS_AT_MENU

// Use QuickTime to read the durations
//  If undefined, will use mplayer IF READ_DURATIONS_AT_MENU is defined
//  Otherwise, QuickTime will be used at file playback.
#undef USE_QTKIT_DURATIONS

// Use the ATVFPlaylistPlayer controller to push/pop one controller per playlist entry
//  NOTE: HAS ODD PROBLEMS WITH UI DISAPPEARING AFTER PLAYING
#undef USE_NEW_PLAYLIST_THING

// (0.6) Enable the new playback context menu
#define PLAYBACK_CONTEXT_MENU

// (future) Enable VIDEO_TS playback.
//  10.5 FRONT ROW ONLY NOT ATV.
//  NOTE: this playback is a complete hack, really just some test code.
#undef ENABLE_VIDEO_TS
