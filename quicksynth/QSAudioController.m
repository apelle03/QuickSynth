//
//  QSAudioController.m
//  quicksynth
//
//  Created by Andrew on 3/27/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSAudioController.h"
#include <AudioUnit/AudioUnit.h>

#define kOutputBus 0
#define kInputBus 1
#define SAMPLE_RATE 44100

@implementation QSAudioController

AudioUnit outputUnit;
AudioSampleType *samples;
int numSamples;
int curSample;

void generateSamples(double freq, double gain, double length) {
    numSamples = length * SAMPLE_RATE;
    samples = malloc(numSamples * sizeof(AudioSampleType));
    
    double phase_inc = 2 * M_PI * freq / SAMPLE_RATE;
    double phase = 0;
    for (int i = 0; i < numSamples; i++) {
        samples[i] = (AudioSampleType)(sin(phase) * gain * 32767);
        phase += phase_inc;
        if (phase > 2 * M_PI) {
            phase -= 2 * M_PI;
        }
    }
    curSample = 0;
}

void generateTone(AudioSampleType *buffer, double freq, double gain, double length) {
    int numSamples = length * SAMPLE_RATE;
    
    double phase_inc = 2 * M_PI * freq / SAMPLE_RATE;
    double phase = 0;
    for (int i = 0; i < numSamples; i++) {
        buffer[i] += (AudioSampleType)(sin(phase) * gain * 32767);
        phase += phase_inc;
        if (phase > 2 * M_PI) {
            phase -= 2 * M_PI;
        }
    }
}

static OSStatus playbackCallback(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList *ioData) {

	for(UInt32 i = 0; i < ioData->mNumberBuffers; i++)
	{
        int samplesLeft = numSamples - curSample;
        int bufferSize = ioData->mBuffers[i].mDataByteSize / sizeof(AudioSampleType);
        if(samplesLeft > 0)
        {
            if(samplesLeft < bufferSize)
            {
                memcpy(ioData->mBuffers[i].mData, &samples[curSample], samplesLeft * sizeof(AudioSampleType));
                curSample += samplesLeft;
                memset(ioData->mBuffers[i].mData + samplesLeft * sizeof(AudioSampleType), 0, (bufferSize - samplesLeft) * sizeof(AudioSampleType)) ;
            }
            else
            {
                memcpy(ioData->mBuffers[i].mData, &samples[curSample], bufferSize * sizeof(AudioSampleType)) ;
                curSample += bufferSize;
            }
        }
        else
        {
            memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
            AudioOutputUnitStop(outputUnit);
        }
	}
    
    return noErr;    
}

- (void)initSound {
    generateSamples(440, .5, 1);
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    AudioComponentInstanceNew(outputComponent, &outputUnit);
    
    UInt32 flag = 1;
    // Enable IO for playback
    AudioUnitSetProperty(outputUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &flag,
                         sizeof(flag));
    
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = SAMPLE_RATE;
    audioFormat.mFormatID	= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 8 * sizeof(AudioSampleType);
    audioFormat.mBytesPerPacket = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerFrame = audioFormat.mBytesPerPacket / audioFormat.mFramesPerPacket;
    
    // Apply format
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kOutputBus,
                         &audioFormat,
                         sizeof(audioFormat));
    
    // Set output callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kOutputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
}

- (void)initSoundWithScore:(QSScore *)score {
    [self generateSoundWithScore:score];
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    AudioComponentInstanceNew(outputComponent, &outputUnit);
    
    UInt32 flag = 1;
    // Enable IO for playback
    AudioUnitSetProperty(outputUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &flag,
                         sizeof(flag));
    
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = SAMPLE_RATE;
    audioFormat.mFormatID	= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 8 * sizeof(AudioSampleType);
    audioFormat.mBytesPerPacket = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerFrame = audioFormat.mBytesPerPacket / audioFormat.mFramesPerPacket;
    
    // Apply format
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kOutputBus,
                         &audioFormat,
                         sizeof(audioFormat));
    
    // Set output callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kOutputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
}

- (void)generateSoundWithScore:(QSScore *)score {
    numSamples = 0;
    for (NSNumber *soundID in [score getSoundIDs]) {
        QSSound *sound = [score getSoundForID:soundID];
        double startTime = [sound.startTime doubleValue];
        double duration = [sound.duration doubleValue];
        int end = (startTime + duration) * SAMPLE_RATE;
        if (end > numSamples) {
            numSamples = end;
        }
    }
    if (samples != NULL) {
        free(samples);
    }
    samples = malloc(numSamples * sizeof(AudioSampleType));
    memset(samples, 0, numSamples * sizeof(AudioSampleType));
    for (NSNumber *soundID in [score getSoundIDs]) {
        QSSound *sound = [score getSoundForID:soundID];
        double freq = [sound.frequency doubleValue];
        double startTime = [sound.startTime doubleValue];
        double length = [sound.duration doubleValue];
        generateTone(&samples[(int)(startTime * SAMPLE_RATE)],
                     freq, .5, length);
    }
}

- (void)playSound {
    curSample = 0;
    AudioUnitInitialize(outputUnit);
    AudioOutputUnitStart(outputUnit);
}

- (void)stopSound {
    AudioOutputUnitStop(outputUnit);
}

@end
