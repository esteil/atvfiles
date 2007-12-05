//
//  ATVFInfoController.m
//  ATVFiles
//
//  Created by Eric Steil III on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFInfoController.h"
#import "ATVFPlaylistAsset.h"

static float spacerRatio = 0.019999999552965164f;
// static float imageHeightRatio = 0.2f;

// helpers because it doesn't let us get direct access to the text object
@interface BRVerticalScrollControl (ATVFiles_ParagraphTextObject)
-(void)__ATVFiles_setParagraphAttributedString:(NSAttributedString *)string;
@end

@implementation BRVerticalScrollControl (ATVFiles_ParagraphTextObject)
-(void)__ATVFiles_setParagraphAttributedString:(NSAttributedString *)string {
  [_paragraphText setAttributedString:string];
  [self _updateScrollArrows];
}
@end

// private methods
@interface ATVFInfoController (Private)
-(NSAttributedString *)_getAssetInfo;
-(NSSize)_scrollSizeForFrame:(NSRect)frame;
-(NSString *)_formatDuration:(long)duration;
@end

@implementation ATVFInfoController

-(id)initWithScene:(BRRenderScene *)scene {
  if([super initWithScene:scene] == nil) return nil;
  
  _document = [[BRVerticalScrollControl alloc] initWithScene:scene];

  return self;
}

-(void)dealloc {
  [_asset release];
  [_document release];
  [_header release];
  [super dealloc];
}

-(void)doLayout {
  LOG(@"In -doLayout");
  NSRect masterFrame = [[self masterLayer] frame];
  LOG(@"Master frame: %@", NSStringFromRect(masterFrame));
  
  float spacer = masterFrame.size.height * spacerRatio;
  float nextYOffset = 0.0f;
  
  if(_header != nil) {
    NSRect centerRect = [[BRThemeInfo sharedTheme] centeredMenuHeaderFrameForMasterFrame:masterFrame];
    [_header setFrame:centerRect];
    LOG(@"Header frame: %@", NSStringFromRect(centerRect));
    
    [self addControl:_header];
    nextYOffset = centerRect.origin.y - spacer;
  }
  
  if(_document != nil) {
    NSRect scrollFrame;
    scrollFrame.size = [self _scrollSizeForFrame:masterFrame];
    scrollFrame.origin.x = (masterFrame.size.width - scrollFrame.size.width) * 0.5f;
    scrollFrame.origin.y = nextYOffset - scrollFrame.size.height;
    
    [_document setFrame:scrollFrame];
    [self addControl:_document];
    
    nextYOffset = scrollFrame.origin.y - spacer;    
    LOG(@"_document frame: %@", NSStringFromRect(scrollFrame));
  }
  
  if(_document == nil)
    return;
    
  NSRect docFrame = [_document frame];
  NSRect textFrame = [_document paragraphTextFrame];
  float scrollerOffset = (textFrame.size.width * 0.5f) + docFrame.origin.x;
  
  if(_header != nil) {
    NSRect headerFrame = [_header frame];
    headerFrame.origin.x += (headerFrame.size.width * -0.5f) + scrollerOffset;
    [_header setFrame:headerFrame];
  }
}

-(NSSize)_scrollSizeForFrame:(NSRect)frame {
  // borrowed from ATVLoader
  NSSize result = NSMakeSize(frame.size.width * 0.8f, frame.size.height * 0.75f);
  
  return result;
}

#define APPEND_STRING(str, attr) { \
    NSAttributedString *a = [[NSAttributedString alloc] initWithString:str attributes:attr]; \
    [content appendAttributedString:a]; \
    [a release]; \
  } 

#define APPEND_LINE(lbl, val) { \
    APPEND_STRING(lbl, boldAttrs); \
    APPEND_STRING(@": ", boldAttrs); \
    APPEND_STRING(val, plainAttrs); \
    APPEND_STRING(@"\n", plainAttrs); \
  }

#define APPEND_NEWLINE APPEND_STRING(@"\n", boldAttrs);

-(NSAttributedString *)_getAssetInfo {
  LOG(@"In _getAssetInfo");
  // build a set of attributes for bold and normal text
  NSMutableDictionary *boldAttrs = [[[BRThemeInfo sharedTheme] paragraphTextAttributes] mutableCopy];
  NSMutableDictionary *plainAttrs = nil;
  // LOG(@"Bold: %@, plain: %@", boldAttrs, plainAttrs);

  // left-align and break by wrapping words.
  [boldAttrs setObject:[NSNumber numberWithInt:NSNaturalTextAlignment] forKey:@"CTTextAlignment"];
  [boldAttrs setObject:[NSNumber numberWithInt:NSLineBreakByWordWrapping] forKey:@"CTLineBreakMode"];
  
  plainAttrs = [boldAttrs mutableCopy];
  [plainAttrs setObject:[[[BRThemeInfo sharedTheme] iconMessageBodyAttributes] objectForKey:@"NSFont"] forKey:@"NSFont"];
  // LOG(@"Modified bold: %@, plain: %@", boldAttrs, plainAttrs);
  
  // build up the info page here
  NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
  NSString *s;
  
  // generic asset info (url, etc.)
  NSURL *_url = [NSURL URLWithString:[_asset mediaURL]];
  if([_url isFileURL]) {
    APPEND_LINE(BRLocalizedString(@"Asset Path", "Asset Path label for info screen"), [_url path]);
  } else {
    APPEND_LINE(BRLocalizedString(@"Asset URL", "Asset URL label for info screen"), [_url absoluteString]);
  }
  
  if([_asset isPlaylist]) {
    // playlist info
    APPEND_LINE(BRLocalizedString(@"Asset Type", "Asset Type label for info screen"), BRLocalizedString(@"Playlist Asset", "Playlist asset type for info screen"));
    APPEND_NEWLINE;
    
    APPEND_STRING(BRLocalizedString(@"Playlist Contents", "Playlist Contents label for info screen"), boldAttrs);
    APPEND_STRING(@":\n", boldAttrs);
    
    // loop through playlist, adding each asset as a content
    NSArray *contents = [(ATVFPlaylistAsset *)_asset playlistContents];
    int length = [contents count];
    int i;
    for(i = 0; i < length; i++) {
      ATVFMediaAsset *asset = [contents objectAtIndex:i];
      APPEND_STRING([[NSURL URLWithString:[asset mediaURL]] path], plainAttrs);
      APPEND_NEWLINE;
    }
    
    APPEND_NEWLINE;
    
  } else {
    // single-file info
    if([_asset isStack]) {
      s = [NSString stringWithFormat:BRLocalizedString(@"Stacked %@", "Stacked Asset type label for info screen"), [[_asset mediaType] typeString]];
    } else {
      s = [[_asset mediaType] typeString];
    }
    APPEND_LINE(BRLocalizedString(@"Asset Type", "Asset Type label for info screen"), s);
    APPEND_NEWLINE;
    
    // asset metadata
    APPEND_LINE(BRLocalizedString(@"Title", "Asset Title label for info screen"), [_asset title]);
    if([_asset mediaSummary]) APPEND_LINE(BRLocalizedString(@"Summary", "Asset Summary label for info screen"), [_asset mediaSummary]);
    if([_asset mediaDescription]) APPEND_LINE(BRLocalizedString(@"Description", "Asset Description label for info screen"), [_asset mediaDescription]);
    
    // qtkit info
    if([QTMovie canInitWithURL:_url]) {
      // NeverIdleFile of net.telestream.wmv.import NO
      CFPreferencesSetAppValue(CFSTR("NeverIdleFile"), kCFBooleanTrue, CFSTR("net.telestream.wmv.import"));
      CFPreferencesAppSynchronize(CFSTR("net.telestream.wmv.import"));
      
      NSError *error = nil;
      QTMovie *movie = [[QTMovie alloc] initWithURL:_url error:&error];
    
      // if we could open the movie
      if(movie) {

        [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

        // Is this a stack where we have to append to the video?
        if([_asset isStack]) {
          int i;
          int count = [[_asset stackContents] count];

          NSError *error = nil;
          for(i = 1; i < count; i++) {
            NSURL *segmentURL = [[_asset stackContents] objectAtIndex:i];

            QTDataReference *segmentRef = [QTDataReference dataReferenceWithReferenceToURL:segmentURL];
            LOG(@"Ref: %@", segmentRef);
            QTMovie *segment = [QTMovie movieWithDataReference:segmentRef error:&error];
            if(error) {
              LOG(@"Error adding segment: %@", error);
              break;
            }

            // add it
            [movie insertSegmentOfMovie:segment timeRange:QTMakeTimeRange(QTZeroTime, [segment duration]) atTime:[movie duration]];
          }
        }

        // get codec info
        APPEND_NEWLINE;
        // NSDictionary *attributes = [movie movieAttributes];
        // LOG(@"%@", attributes);
        
        // NSSize resolution = [[attributes valueForKey:QTMovieNaturalSizeAttribute] sizeValue];
        // s = [NSString stringWithFormat:@"%0.0fx%0.0f", resolution.width, resolution.height];
        // APPEND_LINE(BRLocalizedString(@"Resolution", "Asset Resolution label for info screen"), s);

        // duration
        NSTimeInterval duration;
        if(QTGetTimeInterval([movie duration], &duration)) {
          [_asset setDuration:duration];
          s = [self _formatDuration:duration];
          LOG(@"Appending duration: (%@)%@", [s class], s);
          APPEND_LINE(BRLocalizedString(@"Duration", "Asset Duration label for info screen"), s);//[self _formatDurationAsTime:[_asset duration]]);
        } else {
          LOG(@"Unable to get duration!");
          return nil;
        }
        
        // get video codec info
        NSArray *tracks = [movie tracksOfMediaType:QTMediaTypeVideo];
        LOG(@"Video tracks: %@", tracks);
        QTTrack *track;
        if([tracks count] > 0) {
          track = [tracks objectAtIndex:0];
          LOG(@"Video track 0 attributes: %@", [track trackAttributes]);
          LOG(@"Video track 0 media attributes: %@", [[track media] mediaAttributes]);

          s = [[track trackAttributes] valueForKey:@"QTTrackFormatSummaryAttribute"];
          LOG(@"Appending video format: (%@)%@", [s class], s);
          if(s) APPEND_LINE(BRLocalizedString(@"Video Format", "Video Format label for info screen"), s);
        }
        
        // and audio
        tracks = [movie tracksOfMediaType:QTMediaTypeSound];
        LOG(@"Audio tracks: %@", tracks);
        if([tracks count] > 0) {
          track = [tracks objectAtIndex:0];
          LOG(@"Audio track 0 attributes: %@", [track trackAttributes]);
          LOG(@"Audio track 0 media attributes: %@", [[track media] mediaAttributes]);

          s = [[track trackAttributes] valueForKey:@"QTTrackFormatSummaryAttribute"];
          LOG(@"Appending audio format: (%@)%@", [s class], s);
          if(s) APPEND_LINE(BRLocalizedString(@"Audio Format", "Audio Format label for info screen"), s);
        }
        
        [movie release];
      }
      // NeverIdleFile of net.telestream.wmv.import YES
      CFPreferencesSetAppValue(CFSTR("NeverIdleFile"), NULL, CFSTR("net.telestream.wmv.import"));
      CFPreferencesAppSynchronize(CFSTR("net.telestream.wmv.import"));
    }
    
    // stack contents
    if([_asset isStack]) {
      APPEND_NEWLINE;
      APPEND_STRING(BRLocalizedString(@"Stack Contents", "Stack Contents label for info screen"), boldAttrs);
      APPEND_STRING(@":\n", boldAttrs);
      
      // loop through playlist, adding each asset as a content
      NSArray *contents = [_asset stackContents];
      int length = [contents count];
      int i;
      for(i = 0; i < length; i++) {
        NSURL *path = [contents objectAtIndex:i];
        APPEND_STRING([path path], plainAttrs);
        APPEND_NEWLINE;
      }
    } 

    APPEND_NEWLINE
  }
  // release attributes
  [boldAttrs release];
  [plainAttrs release];
  
  // LOG(@"_getAssetInfo -> %@", content);
  return [content autorelease];
}

-(void)setAsset:(ATVFMediaAsset *)asset {
  [_asset release];
  _asset = asset;
  [asset retain];
  
  // update our header
  if(_header == nil)
    _header = [[BRHeaderControl controlWithScene:[self scene]] retain];
  [_header setTitle:[asset title]];
  
  // update our info string
  NSRect scrollFrame = [_document frame];
  NSRect masterFrame = [[self masterLayer] frame];
  scrollFrame.size = [self _scrollSizeForFrame:masterFrame];
  [_document setFrame:scrollFrame];
  [_document __ATVFiles_setParagraphAttributedString:[self _getAssetInfo]];
}

-(ATVFMediaAsset *)asset {
  return _asset;
}

-(NSString *)_formatDuration:(long)duration {
  LOG(@"In _formatDuration: %d", duration);
  
  long hours = 0;
  long minutes = 0;
  long seconds = 0;
  
  if(duration < 60) {
    seconds = duration;
  } else {
    minutes = duration / 60;
    seconds = duration % 60;
    
    if(minutes > 60) {
      hours = minutes / 60;
      minutes = minutes % 60;
    }
  }
  
  NSString *r = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
  LOG(@"Returning: %@", r);
  return r;
}
@end
