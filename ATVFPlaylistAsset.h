//
// ATVFPlaylistAsset.h
// ATVFiles asset for playlists
//
// Essentially is ATVFMediaAsset, except the stack array is used for playlists
// contents instead, and the assets are stored.
//
// This essentially turns it into an asset that contains other assets.  Enjoy!
//
// The primary difference is that mediaURL returns the url of the PLAYLIST FILE
// if one exists, otherwise it returns an internal URL.
//
// Created by Eric Steil III on 8/4/07.
// Copyright (C) 2007 Eric Steil III
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

#import <Cocoa/Cocoa.h>
#import "ATVFMediaAsset.h"

#define kATVFAssetTypePlaylist @"playlist"

@interface ATVFPlaylistAsset : ATVFMediaAsset {
  BOOL _isFile;
}

-(id)initWithMediaURL:(id)url playlistFile:(BOOL)file;
-(BOOL)isStack;
-(BOOL)isPlaylist;
-(BOOL)isFile;
-(NSArray *)playlistContents;
-(BOOL)appendToPlaylist:(ATVFMediaAsset *)asset;
-(BOOL)insertAsset:(ATVFMediaAsset *)asset atPosition:(long)index;
-(BOOL)removeFromPlaylist:(ATVFMediaAsset *)asset;
-(BOOL)removePositionFromPlaylist:(long)index;

@end
