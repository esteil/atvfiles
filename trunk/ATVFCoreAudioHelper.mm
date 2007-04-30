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

+(Component)getOutputComponent {
  Component component;
  ComponentDescription desc;
  desc.componentType = kAudioUnitType_Output;
  desc.componentSubType = kAudioUnitSubType_HALOutput;
  desc.componentManufacturer = kAudioUnitManufacturer_Apple;
  desc.componentFlags = 0;
  desc.componentFlagsMask = 0;
  
  component = FindNextComponent(NULL, &desc);
  if(component == NULL) {
    LOG(@"Can't find the HAL component");
    return nil;
  }
  
  return component;
}

+(AudioStreamBasicDescription)getStreamDescription:(Component)component {
  AudioStreamBasicDescription DeviceFormat;
  AudioUnit unit;
  OSStatus err = noErr;
  UInt32 size;
  
  err = OpenAComponent(component, &unit);
  if(err != noErr) {
    ELOG(@"Unable to open HAL component for absd: %d", err);
    return nil;
  }
  
  // get the fomrat?
  size = sizeof(AudioStreamBasicDescription);
  err = AudioUnitGetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &DeviceFormat, &size);
  if(err != noErr) {
    ELOG(@"Unable to get Stream Format: %d", err);
    return nil;
  }
  
  LOG(STREAM_FORMAT_MSG(@"Stream format", DeviceFormat));
}

+(BOOL)setStreamDescription:(AudioStreamBasicDescription)description component:(Component)component {
  AudioUnit unit;
  OSStatus err = noErr;
  UInt32 size;
  err = OpenAComponent(component, &unit);
  if(err != noErr) {
    ELOG(@"Unable to open HAL component for absd: %d", err);
    return NO;
  }
  
  // set it
  size = sizeof(AudioStreamBasicDescription);
  LOG(STREAM_FORMAT_MSG(@"Setting stream format", DeviceFormat));
  err = AudioUnitSetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &DeviceFormat, size);
  if(err != noErr) {
    ELOG(@"Unable to set stream format: %d", err);
    return NO;
  }
}

+(float)systemSampleRate {
  Float64 sampleRate = 0.0;
  AudioDeviceID outDevice = CAAudioHardwareSystem::GetDefaultDevice(false, false);
  CAAudioHardwareDevice *device = new CAAudioHardwareDevice(outDevice);
  
  sampleRate = device->GetNominalSampleRate();
  
  delete device;
  
  return sampleRate;
}

+(BOOL)setSystemSampleRate:(float)rate {
  AudioDeviceID outDevice = CAAudioHardwareSystem::GetDefaultDevice(false, false);
  CAAudioHardwareDevice *device = new CAAudioHardwareDevice(outDevice);
  
  LOG(@"Setting system sample rate to: %f", rate);
  if(device->IsValidNominalSampleRate(rate)) {
    LOG(@"Valid sample rate!");
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
