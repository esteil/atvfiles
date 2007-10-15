/*
 *  LoggingUtils.h
 *  ATVFiles
 *
 *  Just some utility macros for logging...
 *
 *  Created by Eric Steil III on 4/1/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef DEBUG
#define LOG(s, ...)  NSLog(@"[DEBUG] " s, ##__VA_ARGS__)
#define ILOG(s, ...) NSLog(@"[INFO]  " s, ##__VA_ARGS__)
#define ELOG(s, ...) NSLog(@"[ERROR] " s, ##__VA_ARGS__)
#define DLOG(s, ...) LOG(s, ##__VA_ARGS__)
#else
#define LOG(s, ...) 
#define ILOG(s, ...) NSLog(@"[INFO]  " s, ##__VA_ARGS__)
#define ELOG(s, ...) NSLog(@"[ERROR] " s, ##__VA_ARGS__)
#define DLOG(s, ...) LOG(s, ##__VA_ARGS__)
#endif