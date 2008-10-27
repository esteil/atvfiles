//
//  ATVFMediaAsset-Stacking.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/25/08.
//  Copyright 2008 BetaNews, Inc.. All rights reserved.
//

#import "ATVFMediaAsset-Stacking.h"

@implementation ATVFMediaAsset (Stacking)

-(NSString *)baseMediaURL {
  LOG_MARKER;
  
  LOG(@"Stack contents: %@, (%@)%@", [self stackContents], [[[self stackContents] objectAtIndex:0] class], [[self stackContents] objectAtIndex:0]);
  if(![self isStack])
    return [self mediaURL];
  else
    return [[[self stackContents] objectAtIndex:0] absoluteString];
}

// Newish, cleaner stacking code from Sapphire.
-(BOOL)_prepareStack:(NSError **)error {
  LOG_MARKER;
  
  if(![self isStack]) return YES;
  if(![self _needsStacking]) return YES;
  
  QTMovie *theMovie = [[QTMovie alloc] init];
  if(!theMovie) return NO;
  
  [theMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
  
  LOG(@"Asset %@ is stack: %@", self, [self stackContents]);
  int i;
  int count = [[self stackContents] count];
  
  LOG(@" Movie duration is now: %@", QTStringFromTime([theMovie duration]));
  
  for(i = 0; i < count; i++) {
    NSURL *segmentURL = [[self stackContents] objectAtIndex:i];
    LOG(@" Adding %@ to playback", segmentURL);

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                segmentURL, QTMovieURLAttribute,
                                [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
                                nil];
    
    LOG(@" Attributes: %@", attributes);
    QTMovie *segment = [[[QTMovie alloc] initWithAttributes:attributes error:error] autorelease];
    LOG(@"Segment: %@, Error: %@", segment, *error);
    if(*error != nil) return NO;
    
    QTTimeRange range;
    range.time = [segment selectionStart];
    range.duration = [segment duration];
    [segment setSelection:range];
    [theMovie appendSelectionFromMovie:segment];
    
    LOG(@" Movie duration is now: %@", QTStringFromTime([theMovie duration]));
  }
  
  // write it
  LOG_MARKER;
  BOOL saved = [theMovie writeToFile:[self _stackFileURL] withAttributes:[NSDictionary dictionary]];
  LOG(@"Saved: %d", saved);
  
  [theMovie release];
  return saved;
}

-(BOOL)_needsStacking {
  LOG_MARKER;
  
  return YES;
}

-(BOOL)_removeStackMovie {
  LOG_MARKER;
  
  
  return YES;
}
/**
 * Return the URL to the reference movie for this stack.
 *
 * Basically, the absolute path of the base file, with / replaced with _, under
 * ~/Library/Caches/ATVFiles
 */
-(NSString *)_stackFileURL {
  LOG_MARKER;
  NSArray *cacheDirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cacheDir = [[cacheDirs objectAtIndex:0] stringByAppendingPathComponent:@"ATVFiles"];
  
  LOG(@"cacheDirs: %@, cacheDir: %@", cacheDirs, cacheDir);
  
  // create it if it doesn't exist
  if(![[NSFileManager defaultManager] fileExistsAtPath:cacheDir])
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir attributes:nil];
  
  NSMutableString *baseURL = [[self baseMediaURL] mutableCopy];
  [baseURL replaceOccurrencesOfString:@"/" withString:@"_" options:nil range:NSMakeRange(0, [baseURL length])];
  [baseURL replaceOccurrencesOfString:@":" withString:@"_" options:nil range:NSMakeRange(0, [baseURL length])];
  
  NSString *stackURL = [[cacheDir stringByAppendingPathComponent:baseURL] stringByAppendingPathExtension:@"mov"];
  LOG(@"stackURL: %@", stackURL);
  return [[NSURL fileURLWithPath:stackURL] absoluteString];
}

@end
