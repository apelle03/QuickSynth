//
//  QSAudioPlayer.m
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//
/*
#import "QSAudioPlayer.h"

#include <AudioUnit/AudioUnit.h>

#define kOutputBus 0
#define kInputBus 1
#define SAMPLE_RATE 44100

int *_pcm;
int _numSamples;
int _index;

@implementation QSAudioPlayer

void generateTone(
                  int **pcm,
                  int *numSamples,
                  int freq,
                  double lengthMS,
                  int sampleRate,
                  double riseTimeMS,
                  double gain)
{
    *numSamples = ((double) sampleRate) * lengthMS / 1000.;
    int riseTimeSamples = ((double) sampleRate) * riseTimeMS / 1000.;
    
    if(gain > 1.)
        gain = 1.;
    if(gain < 0.)
        gain = 0.;
    
    *pcm = malloc(*numSamples * sizeof(int));
    
    for(int i = 0; i < *numSamples; ++i)
    {
        double value = sin(2. * M_PI * freq * i / sampleRate);
        if(i < riseTimeSamples)
            value *= sin(i * M_PI / (2.0 * riseTimeSamples));
        if(i > *numSamples - riseTimeSamples - 1)
            value *= sin(2. * M_PI * (i - (*numSamples - riseTimeSamples) + riseTimeSamples)/ (4. * riseTimeSamples));
        
        (*pcm)[i] = (int) (value * 32500.0 * gain);
        (*pcm)[i] += ((*pcm)[i]<<16);
    }
    
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData)
{
    int totalNumberOfSamples = _numSamples;
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
	{
        int samplesLeft = totalNumberOfSamples - _index;
        int numSamples = ioData->mBuffers[i].mDataByteSize / 4;
        if(samplesLeft > 0)
        {
            if(samplesLeft < numSamples)
            {
                memcpy(ioData->mBuffers[i].mData, &_pcm[_index], samplesLeft * 4);
                _index += samplesLeft;
                memset((char*) ioData->mBuffers[i].mData + samplesLeft * 4, 0, (numSamples - samplesLeft) * 4) ;
            }
            else
            {
                memcpy(ioData->mBuffers[i].mData, &_pcm[_index], numSamples * 4) ;
                _index += numSamples;
            }
        }
        else
            memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
	}
    
    return noErr;
}


+ (void)playSound
{
    if (_pcm != NULL) {
        free(_pcm);
    }
    generateTone(&_pcm, &_numSamples, 800, 1000, SAMPLE_RATE, 5, 0.8);
    _index = 0;
    
    OSStatus status;
    AudioComponentInstance audioUnit;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    //checkStatus(status);
    
    UInt32 flag = 1;
    // Enable IO for playback
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    //checkStatus(status);
    
    // Describe format
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = SAMPLE_RATE;
    audioFormat.mFormatID	= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 2;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 4;
    audioFormat.mBytesPerFrame = 4;
    
    // Apply format
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    //  checkStatus(status);
    
    // Set output callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
    // Initialize
    status = AudioUnitInitialize(audioUnit);
    
    // Start playing
    
    status = AudioOutputUnitStart(audioUnit);
}
@end
*/