//
//  ATVFCoreAudioHelper.mm
//  ATVFiles
//
//  Helper functions for CoreAudio since I don't do C++.
//
//  Actually has a stupid wrapper for CFPreferences for the A52Codec namespace as well, just to be nice.
//
//  Created by Eric Steil III on 4/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFCoreAudioHelper.h"
#include <CAAudioHardwareSystem.h>
#include <CAAudioHardwareDevice.h>

#include <CoreAudio/CoreAudio.h>
#include <AudioUnit/AudioUnitProperties.h>
#include <AudioUnit/AudioUnitParameters.h>
#include <AudioUnit/AudioOutputUnit.h>
#include <AudioToolbox/AudioFormat.h>

#define STREAM_FORMAT_MSG(pre, sfm) \
  pre @":\n samplerate: [%ld]\n formatid: [%4.4s]\n formatflags: [%ld]\n bytesPerPacket: [%ld]\n framesPerPacket: [%ld]\n bytesPerFrame: [%ld]\n channelsPerFrame: [%ld]\n bitsPerChannel: [%ld]", \
  (UInt32)sfm.mSampleRate, (char *)&sfm.mFormatID, sfm.mFormatFlags, sfm.mBytesPerPacket, sfm.mFramesPerPacket, sfm.mBytesPerFrame, sfm.mChannelsPerFrame, sfm.mBitsPerChannel
  
@implementation ATVFCoreAudioHelper

+(AudioDeviceID)getOutputDevice {
  AudioDeviceID device;
  UInt32 size;
  OSStatus err;
  
  size = sizeof(device);
  err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &size, &device);
  
  if(err != noErr) {
    ELOG(@"Unable to get output device!");
    return NULL;
  }
  
  LOG(@"Output device: %d", device);
  return device;
}

+(AudioStreamBasicDescription)getStreamDescription:(AudioDeviceID)device {
  AudioStreamBasicDescription DeviceFormat;
  OSStatus err = noErr;
  UInt32 size;
  
  // get the fomrat?
  size = sizeof(AudioStreamBasicDescription);
  err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &size, &DeviceFormat);
  if(err != noErr) {
    ELOG(@"Unable to get Stream Format: %d", err);
    return DeviceFormat;
  }
  
  LOG(STREAM_FORMAT_MSG(@"Stream format", DeviceFormat));
  
  return DeviceFormat;
}

+(BOOL)setStreamDescription:(AudioStreamBasicDescription)DeviceFormat device:(AudioDeviceID)device {
  OSStatus err = noErr;
  UInt32 size;
  
  // set it
  size = sizeof(AudioStreamBasicDescription);
  LOG(STREAM_FORMAT_MSG(@"Setting stream format", DeviceFormat));
  err = AudioDeviceSetProperty(device, NULL, 0, false, kAudioDevicePropertyStreamFormat, size, &DeviceFormat);
  if(err != noErr) {
    ELOG(@"Unable to set stream format: %d", err);
    return NO;
  }
  
  return YES;
}

+(BOOL)isFormatSupported:(AudioStreamBasicDescription)DeviceFormat device:(AudioDeviceID)device {
  OSStatus err = noErr;
  UInt32 size;
  
  size = sizeof(DeviceFormat);
  err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormatSupported, &size, &DeviceFormat);
  if(err != noErr) {
    return NO;
  }
  
  return YES;
}

+(float)systemSampleRate {

  OSStatus err;
  Float64 samplerate = 0.0;
  UInt32 size;
  
  size = sizeof(samplerate);
  err = AudioDeviceGetProperty([self getOutputDevice], 0, false, kAudioDevicePropertyNominalSampleRate, &size, &samplerate);
  
  return samplerate;
#if 0  
  // VLC
  AudioStreamBasicDescription desc = [self getStreamDescription:[self getOutputDevice]];
  
  return desc.mSampleRate;
#endif

#if 0  
  // HALLAB
  Float64 sampleRate = 0.0;
  AudioDeviceID outDevice = CAAudioHardwareSystem::GetDefaultDevice(false, false);
  CAAudioHardwareDevice *device = new CAAudioHardwareDevice(outDevice);
  
  sampleRate = device->GetNominalSampleRate();
  
  delete device;
  
  return sampleRate;
#endif
}

+(BOOL)setSystemSampleRate:(float)rate {
  AudioDeviceID outDevice = CAAudioHardwareSystem::GetDefaultDevice(false, false);
  CAAudioHardwareDevice *device = new CAAudioHardwareDevice(outDevice);
  
  LOG(@"Setting system sample rate to: %f", rate);
  if(device->IsValidNominalSampleRate(rate)) {
    LOG(@"Valid sample rate!");

    AudioStreamBasicDescription desc = [self getStreamDescription:outDevice];
    desc.mSampleRate = rate;
    desc.mFormatID = kAudioFormatLinearPCM;

    device->SetNominalSampleRate(rate);

    return YES;
  } else {
    LOG(@"Invalid sample rate!");
    return NO;
  }
}

// MUST CFRELEASE THIS AFTER DONE
+(CFTypeRef)getPassthroughPreference {
  CFTypeRef result = CFPreferencesCopyAppValue(CFSTR("attemptPassthrough"), CFSTR("com.cod3r.a52codec"));
  return result;
}

+(void)setPassthroughPreference:(CFTypeRef)value {
  CFPreferencesSetAppValue(CFSTR("attemptPassthrough"), value, CFSTR("com.cod3r.a52codec"));
  CFPreferencesAppSynchronize(CFSTR("com.cod3r.a52codec"));
}

@end
