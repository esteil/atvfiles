// Configuration for building ATVFiles
// really just on/off defines

// Enable legacy 1.0 compatibility code
//  NOTE: THIS WILL NOT MAGICALLY MAKE THE PLUGIN RUN ON 1.0
#undef ENABLE_1_0_COMPATABILITY

// Enable reading the duration of files at the menu.  Does not
// work properly for playlists.
#undef READ_DURATIONS_AT_MENU

// Use QuickTime to read the durations
//  If undefined, will use mplayer IF READ_DURATIONS_AT_MENU is defined
//  Otherwise, QuickTime will be used at file playback.
#undef USE_QTKIT_DURATIONS
