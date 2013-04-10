//
//  QSScoreAudio.m
//  quicksynth
//
//  Created by Andrew on 4/3/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSAudioEngine.h"

@implementation QSAudioEngine

@synthesize scoreGraph;
@synthesize mixerNode;
@synthesize ioNode;
@synthesize mixerUnit;
@synthesize ioUnit;

@synthesize playing;

double theta = 0;

- (id) init {
    NSLog(@"init");
    [self createAUGraph];
    [self initGraph];
    
    return self;
}

- (BOOL) createAUGraph {
    NSLog(@"create");
    
    AUGraph moduleGraph;
    AUNode moduleIONode;
    AudioUnit moduleIOUnit;
    
    NewAUGraph(&moduleGraph);
    AudioComponentDescription moduleIODesc;
    moduleIODesc.componentType = kAudioUnitType_Output;
    moduleIODesc.componentSubType = kAudioUnitSubType_GenericOutput;
    moduleIODesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    moduleIODesc.componentFlags = 0;
    moduleIODesc.componentFlagsMask = 0;
    AUGraphAddNode(moduleGraph, &moduleIODesc, &moduleIONode);
    
    AUGraphOpen(moduleGraph);
    AUGraphNodeInfo(moduleGraph, moduleIONode, NULL, &moduleIOUnit);
    
    // Module Stream Format
    AudioStreamBasicDescription desc;
    UInt32 size;
    AudioUnitGetProperty(moduleIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size);
    memset(&desc, 0, sizeof(desc));
    desc.mSampleRate = 44100;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    desc.mBitsPerChannel = sizeof(AudioSampleType) * 8;
    desc.mChannelsPerFrame = 1;
    desc.mFramesPerPacket = 1;
    desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
    desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
    AudioUnitSetProperty(moduleIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc));
    
    // Module Input Callbacks
    AURenderCallbackStruct moduleInput;
    moduleInput.inputProc = &renderTone;
    moduleInput.inputProcRefCon = (__bridge void *)(self);
    AUGraphSetNodeInputCallback(moduleGraph, moduleIONode, 0, &moduleInput);
    
    CAShow(moduleGraph);
    
    
    //
    ////////////////////////
    //
    
    NewAUGraph(&scoreGraph);
        
    // Mixer Unit
    AudioComponentDescription mixerUnitDesc;
    mixerUnitDesc.componentType          = kAudioUnitType_Mixer;
    mixerUnitDesc.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    mixerUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    mixerUnitDesc.componentFlags         = 0;
    mixerUnitDesc.componentFlagsMask     = 0;
    AUGraphAddNode(scoreGraph, &mixerUnitDesc, &mixerNode);
    
    // I/O unit
    AudioComponentDescription iOUnitDesc;
    iOUnitDesc.componentType          = kAudioUnitType_Output;
    iOUnitDesc.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDesc.componentFlags         = 0;
    iOUnitDesc.componentFlagsMask     = 0;
    AUGraphAddNode(scoreGraph, &iOUnitDesc, &ioNode);
    
    // Graph Node Units
	AUGraphOpen(scoreGraph);
    AUGraphNodeInfo(scoreGraph, mixerNode, NULL, &mixerUnit);
    AUGraphNodeInfo(scoreGraph, ioNode, NULL, &ioUnit);
    
    // Mixer Input Setup
    UInt32 numBuses = 1;
    AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numBuses, sizeof(numBuses));
    
    for (int i = 0; i < numBuses; i++) {
        // Mixer Input Stream Formats
        AudioStreamBasicDescription desc;
        UInt32 size;
        AudioUnitGetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, &size);
        memset(&desc, 0, sizeof(desc));
        desc.mSampleRate = 44100;
        desc.mFormatID = kAudioFormatLinearPCM;
        desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        desc.mBitsPerChannel = sizeof(AudioSampleType) * 8;
        desc.mChannelsPerFrame = 1;
        desc.mFramesPerPacket = 1;
        desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
        desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
        AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, sizeof(desc));
        
        // Mixer Input Callbacks
        AURenderCallbackStruct mixerInput;
        mixerInput.inputProc = &renderTone;
        mixerInput.inputProcRefCon = (__bridge void *)(self);
        AUGraphSetNodeInputCallback(scoreGraph, mixerNode, i, &mixerInput);
    }
    
    // Mixer to I/O  connection
    AudioUnitElement ioUnitInputNumber = 0;
    AudioUnitElement mixerUnitOutputNumber = 0;
    AUGraphConnectNodeInput(scoreGraph, mixerNode, mixerUnitOutputNumber, ioNode, ioUnitInputNumber);
    
    CAShow(scoreGraph);
    
    return YES;
}

- (void) initGraph {
    if (scoreGraph) {
        Boolean outIsInitialized;
        AUGraphIsInitialized(scoreGraph, &outIsInitialized);
        if(!outIsInitialized)
            AUGraphInitialize(scoreGraph);
    }
}

- (void) startGraph {
    NSLog(@"start");
    if (scoreGraph) {
        Boolean isRunning;
        AUGraphIsRunning(scoreGraph, &isRunning);
        if(!isRunning) {
            AUGraphStart(scoreGraph);
        }
        playing = TRUE;
    }
}

- (void) stopGraph {
    NSLog(@"stop");
    if (scoreGraph) {
        Boolean isRunning;
        AUGraphIsRunning(scoreGraph, &isRunning);
        if (isRunning) {
            AUGraphStop(scoreGraph);
        }
        playing = FALSE;
    }
}

- (void)play {
    [self startGraph];
}

- (void)stop {
    [self stopGraph];
}

OSStatus renderTone(void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp *inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList *ioData) {
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 0.25;
    
    // Get the tone parameters out of the view controller
    double theta_increment = 2.0 * M_PI * 480 / 44100;
    
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    AudioSampleType *buffer = ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        buffer[frame] = (AudioSampleType)(sin(theta) * amplitude * 32767);
        theta += theta_increment;
        if (theta > 2.0 * M_PI) {
            theta -= 2.0 * M_PI;
        }
    }
    
    return noErr;
}

@end
