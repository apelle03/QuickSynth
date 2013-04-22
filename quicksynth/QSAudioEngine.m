//
//  QSScoreAudio.m
//  quicksynth
//
//  Created by Andrew on 4/3/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSAudioEngine.h"

@implementation QSAudioEngine

@synthesize score;

@synthesize scoreGraph;
@synthesize ioNode;
@synthesize mixerNode;
@synthesize ioUnit;
@synthesize mixerUnit;

@synthesize playing;
@synthesize soundNodes;

- (id) init {
    NSLog(@"init");
    soundNodes = [[NSMutableArray alloc] init];
    [self createAUGraph];
    [self initGraph];
    
    return self;
}

- (BOOL) createAUGraph {
    NSLog(@"create");
    
    NewAUGraph(&scoreGraph);
        
    // I/O unit
    AudioComponentDescription iOUnitDesc;
    iOUnitDesc.componentType          = kAudioUnitType_Output;
    iOUnitDesc.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDesc.componentFlags         = 0;
    iOUnitDesc.componentFlagsMask     = 0;
    AUGraphAddNode(scoreGraph, &iOUnitDesc, &ioNode);
    
    // Mixer Unit
    AudioComponentDescription mixerUnitDesc;
    mixerUnitDesc.componentType          = kAudioUnitType_Mixer;
    mixerUnitDesc.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    mixerUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    mixerUnitDesc.componentFlags         = 0;
    mixerUnitDesc.componentFlagsMask     = 0;
    AUGraphAddNode(scoreGraph, &mixerUnitDesc, &mixerNode);
    
    // Graph Node Units
	AUGraphOpen(scoreGraph);
    AUGraphNodeInfo(scoreGraph, ioNode, NULL, &ioUnit);
    AUGraphNodeInfo(scoreGraph, mixerNode, NULL, &mixerUnit);
    
    // Mixer Input Setup
    UInt32 numBuses = 0;
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
        mixerInput.inputProc = &renderWaveform;
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

- (void) update {
    if (score) {
        [self stopGraph];
        
        // Disconnect old sound nodes from mixer	
        for (int i = 0; i < soundNodes.count; i++) {
            AUGraphDisconnectNodeInput(scoreGraph, mixerNode, i);
            AUGraphRemoveNode(scoreGraph, ((QSSoundNode*)soundNodes[i]).node);
        }
        [soundNodes removeAllObjects];

        // Add new sounds
        NSArray *newSounds = [score getSounds];

        UInt32 numSounds = newSounds.count;
        AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numSounds, sizeof(numSounds));

        for (int i = 0; i < newSounds.count; i++) {
            QSSound *sound = newSounds[i];
            
            AudioComponentDescription soundDesc;
            soundDesc.componentType = kAudioUnitType_Mixer;
            soundDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
            soundDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
            soundDesc.componentFlags = 0;
            soundDesc.componentFlagsMask = 0;
            AUNode soundNode;
            AudioUnit soundUnit;
            AUGraphAddNode(scoreGraph, &soundDesc, &soundNode);
            AUGraphNodeInfo(scoreGraph, soundNode, NULL, &soundUnit);
            AUGraphConnectNodeInput(scoreGraph, soundNode, 0, mixerNode, i);
            
            AudioStreamBasicDescription soundStreamDesc;
            UInt32 size;
            AudioUnitGetProperty(soundUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &soundStreamDesc, &size);
            memset(&soundStreamDesc, 0, sizeof(soundStreamDesc));
            soundStreamDesc.mSampleRate = 44100;
            soundStreamDesc.mFormatID = kAudioFormatLinearPCM;
            soundStreamDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            soundStreamDesc.mBitsPerChannel = sizeof(AudioSampleType) * 8;
            soundStreamDesc.mChannelsPerFrame = 1;
            soundStreamDesc.mFramesPerPacket = 1;
            soundStreamDesc.mBytesPerFrame = (soundStreamDesc.mBitsPerChannel / 8) * soundStreamDesc.mChannelsPerFrame;
            soundStreamDesc.mBytesPerPacket = soundStreamDesc.mBytesPerFrame * soundStreamDesc.mFramesPerPacket;
            AudioUnitSetProperty(soundUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &soundStreamDesc, sizeof(soundStreamDesc));
            
            AURenderCallbackStruct soundInput;
            if ([sound isKindOfClass:[QSWaveform class]]) {
                soundInput.inputProc = &renderWaveform;
            } else if ([sound isKindOfClass:[QSPulse class]]) {
                soundInput.inputProc = &renderPulse;
            }/* else if ([sound isKindOfClass:[QSNoise class]]) {
                
            }
              */
#warning TODO: add these types
            soundInput.inputProcRefCon = (__bridge void *)(sound);
            AUGraphSetNodeInputCallback(scoreGraph, soundNode, 0, &soundInput);
            
            [soundNodes addObject:[[QSSoundNode alloc] initWithAUNode:soundNode]];
        }
        CAShow(scoreGraph);
    }
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
        startTime = [NSDate date];
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

OSStatus renderWaveform(void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp *inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList *ioData) {
    QSWaveform *sound = (__bridge QSWaveform *)(inRefCon);
    double theta_increment = 2.0 * M_PI * sound.frequency / 44100;
    const int channel = 0;
    AudioSampleType *buffer = ioData->mBuffers[channel].mData;
    NSTimeInterval curTime = -[startTime timeIntervalSinceNow];
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= sound.startTime && curTime <= sound.startTime + sound.duration) {
            switch (sound.waveType) {
                case SQUARE:
                    buffer[frame] = (sound.theta < M_PI) ? (sound.gain * 32767) : (-sound.gain * 32767);
                    break;
                case TRIANGLE:
                    buffer[frame] = (1 - fabsf((sound.theta / (2 * M_PI)) - .5) * 4) * sound.gain * 32767;
                    break;
                case SAWTOOTH:
                    buffer[frame] = fmodf((sound.theta / M_PI) + 1, 2) * sound.gain * 32767;
                    break;
                case SINE:
                default:
                    buffer[frame] = (AudioSampleType)(sin(sound.theta) * sound.gain * 32767);
                    break;
            }
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
        } else {
            buffer[frame] = 0;
        }
    }
    return noErr;
}

OSStatus renderPulse(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 inBusNumber,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData) {
    QSPulse *sound = (__bridge QSPulse *)(inRefCon);
    double theta_increment = 2.0 * M_PI * sound.frequency / 44100;
    const int channel = 0;
    AudioSampleType *buffer = ioData->mBuffers[channel].mData;
    NSTimeInterval curTime = -[startTime timeIntervalSinceNow];
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= sound.startTime && curTime <= sound.startTime + sound.duration) {
            buffer[frame] = (sound.theta < (M_PI * 2 * sound.duty)) ? (sound.gain * 32767) : (-sound.gain * 32767);
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
        } else {
            buffer[frame] = 0;
        }
    }
    return noErr;
}

@end
