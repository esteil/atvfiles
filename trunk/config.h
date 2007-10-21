// Configuration for building ATVFiles
// really just on/off defines

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
#undef PLAYBACK_CONTEXT_MENU
