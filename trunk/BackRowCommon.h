/*
 *  BackRowCommon.h
 *  ATVFiles
 *
 *  Created by Eric Steil III on 11/28/08.
 *  Copyright 2008 BetaNews, Inc.. All rights reserved.
 *
 */

typedef enum {
  kBRMediaPlayerStateStopped =            0,
  kBRMediaPlayerStatePaused,
  kBRMediaPlayerStateLoading,
  kBRMediaPlayerStatePlaying,
  kBRMediaPlayerStateFastForwardLevel1,
  kBRMediaPlayerStateFastForwardLevel2,
  kBRMediaPlayerStateFastForwardLevel3,
  kBRMediaPlayerStateRewindLevel1,
  kBRMediaPlayerStateRewindLevel2,
  kBRMediaPlayerStateRewindLevel3,
  kBRMediaPlayerStateSlowForwardLevel1,
  kBRMediaPlayerStateSlowForwardLevel2,
  kBRMediaPlayerStateSlowForwardLevel3,
  kBRMediaPlayerStateSlowRewindLevel1,
  kBRMediaPlayerStateSlowRewindLevel2,
  kBRMediaPlayerStateSlowRewindLevel3,
  kBRMediaPlayerStateRewind = kBRMediaPlayerStateRewindLevel1,    // default
  kBRMediaPlayerStateFastForward = kBRMediaPlayerStateFastForwardLevel1,  
  // default
  
  kBRMediaPlayerStateRESERVED     =               20,
  
  // Individual player subclasses may create their own states beyond the
  // reserved states. For instance, the DVD player may want to create states
  // for when it's in menus.
  
} BRMediaPlayerState;

// Gesture events have a dictionary defining the touch points and other info.
typedef enum {
  kBREventOriginatorRemote = 1,
  kBREventOriginatorGesture = 3
} BREventOriginator;

typedef enum {
  // for originator kBREventOriginatorRemote
  kBREventRemoteActionMenu = 1,
  kBREventRemoteActionMenuHold,
  kBREventRemoteActionUp,
  kBREventRemoteActionDown,
  kBREventRemoteActionPlay,
  kBREventRemoteActionLeft,
  kBREventRemoteActionRight,
  
  kBREventRemoteActionPlayHold = 20,
  
  // Gestures, for originator kBREventOriginatorGesture
  kBREventRemoteActionTap = 30,
  kBREventRemoteActionSwipeLeft,
  kBREventRemoteActionSwipeRight,
  kBREventRemoteActionSwipeUp,
  kBREventRemoteActionSwipeDown
  
} BREventRemoteAction;
