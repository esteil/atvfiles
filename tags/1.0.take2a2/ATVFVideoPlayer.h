//
// ATVFVideoPlayer.h
// ATVFiles
//
// Created by Eric Steil III on 7/27/07.
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

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFPlaylistAsset.h"

@interface ATVFVideoPlayer : BRQTKitVideoPlayer {
  int playlist_count, playlist_offset;
  ATVFPlaylistAsset *playlist;
  
  BOOL _subtitlesEnabled;
  BOOL _needToStack;
}

-(BOOL)hasSubtitles;
-(void)setSubtitlesEnabled:(BOOL)enabled;
-(BOOL)subtitlesEnabled;
-(int)currentPlaylistOffset;
-(int)currentPlaylistLength;
-(ATVFMediaAsset *)playlistAssetAtOffset:(int)offset;
-(BOOL)switchToPlaylistOffset:(int)offset;
-(BOOL)previousPlaylistEntry;
-(BOOL)nextPlaylistEntry;

@end
