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

static Float64 startTime;

- (id) init {
    NSLog(@"init");
    soundNodes = [[NSMutableDictionary alloc] init];
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
        UInt32 numInputs = 0;
        UInt32 inputSize = sizeof(numInputs);
        AudioUnitGetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numInputs, &inputSize);
        for (int i = 0; i < numInputs; i++) {
            AUGraphDisconnectNodeInput(scoreGraph, mixerNode, i);
        }
        
        // Disconnect old modifiers
        for (QSSoundNode *node in [soundNodes allValues]) {
            AUGraphDisconnectNodeInput(scoreGraph, node.node, 0);
        }

        // Remove non existing AUNodes
        NSMutableSet *IDs = [[NSMutableSet alloc] init];
        for (NSNumber *ID in [score getSoundIDs]) {
            [IDs addObjectsFromArray:[score getModifierIDsForSound:ID]];
            [IDs addObject:ID];
        }
        for (NSNumber *ID in [soundNodes allKeys]) {
            if (![IDs containsObject:ID]) {
                AUGraphRemoveNode(scoreGraph, ((QSSoundNode*)[soundNodes objectForKey:ID]).node);
                [soundNodes removeObjectForKey:ID];
            }
        }
                
        // Add new sounds
        NSArray *newSounds = [score getSounds];
        
        UInt32 numSounds = newSounds.count;
        AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numSounds, sizeof(numSounds));

        for (int i = 0; i < newSounds.count; i++) {
            QSSound *sound = newSounds[i];
            //============================================================================
            // Sound is not already created
            //============================================================================
            if ([soundNodes objectForKey:sound.ID] == nil) {
                // Create sound node
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
                
                // Setup sound input stream
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
                
                // Add sound node to all sound nodes
                [soundNodes setObject:[[QSSoundNode alloc] initWithAUNode:soundNode] forKey: sound.ID];
            }
            AUNode headNode = ((QSSoundNode*)[soundNodes objectForKey:sound.ID]).node;
            
            // Setup sound callback
            AURenderCallbackStruct soundInput;
            if ([sound isKindOfClass:[QSWaveform class]]) {
                soundInput.inputProc = &renderWaveform;
            } else if ([sound isKindOfClass:[QSPulse class]]) {
                soundInput.inputProc = &renderPulse;
            } else if ([sound isKindOfClass:[QSNoise class]]) {
                soundInput.inputProc = &renderNoise;
            }
#warning TODO: Add render callback function for new sound types here
            soundInput.inputProcRefCon = (__bridge void *)(sound);
            AUGraphSetNodeInputCallback(scoreGraph, headNode, 0, &soundInput);
            
            // Create sound modifier chain
            for (QSModifier *modifier in [score getModifiersForSound:sound.ID]) {
                // Modifier needs node, add to head of chain
                if ([modifier isKindOfClass:[QSFilter class]]) {
                    AUNode filterNode;
                    if ([soundNodes objectForKey:modifier.ID] != nil) {
                        filterNode = ((QSSoundNode*)[soundNodes objectForKey:modifier.ID]).node;
                        AUGraphRemoveNode(scoreGraph, filterNode);
                        [soundNodes removeObjectForKey:modifier.ID];
                    }
                    if ([soundNodes objectForKey:modifier.ID] == nil) {
                        QSFilter *filter = (QSFilter*)modifier;
                        // Create lowpass node
                        AudioComponentDescription filterDesc;
                        filterDesc.componentType = kAudioUnitType_Effect;
                        if (filter.type == LOWPASS) {
                            filterDesc.componentSubType = kAudioUnitSubType_LowPassFilter;
                        } else if (filter.type == HIGHPASS) {
                            filterDesc.componentSubType = kAudioUnitSubType_HighPassFilter;
                        } else if (filter.type == BANDPASS) {
                            filterDesc.componentSubType = kAudioUnitSubType_BandPassFilter;
                        } else {
                            filterDesc.componentSubType = kAudioUnitSubType_LowPassFilter;
                        }
                        filterDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
                        filterDesc.componentFlags = 0;
                        filterDesc.componentFlagsMask = 0;
                        
                        AUGraphAddNode(scoreGraph, &filterDesc, &filterNode);
                        [soundNodes setObject:[[QSSoundNode alloc] initWithAUNode:filterNode] forKey: modifier.ID];
                    }
                    filterNode = ((QSSoundNode*)[soundNodes objectForKey:modifier.ID]).node;
                    // Setup lowpass params
                    AudioUnit lastUnit, filterUnit;
                    AUGraphNodeInfo(scoreGraph, headNode, NULL, &lastUnit);
                    AUGraphNodeInfo(scoreGraph, filterNode, NULL, &filterUnit);
                    // Set stream format
                    AudioStreamBasicDescription soundStreamDesc;
                    UInt32 size;
                    AudioUnitGetProperty(filterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &soundStreamDesc, &size);
                    AudioUnitSetProperty(lastUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &soundStreamDesc, size);
                    // set cutoff frequency
                    QSFilter *filter = (QSFilter*)modifier;
                    if (filter.type == LOWPASS) {
                        AudioUnitSetParameter(filterUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, filter.freq, 0);
                    } else if (filter.type == HIGHPASS) {
                        AudioUnitSetParameter(filterUnit, kHipassParam_CutoffFrequency, kAudioUnitScope_Global, 0, filter.freq, 0);
                    } else if (filter.type == BANDPASS) {
                        AudioUnitSetParameter(filterUnit, kBandpassParam_Bandwidth, kAudioUnitScope_Global, 0, filter.bandwidth, 0);
                        AudioUnitSetParameter(filterUnit, kBandpassParam_CenterFrequency, kAudioUnitScope_Global, 0, filter.freq, 0);
                    } else {
                        AudioUnitSetParameter(filterUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, filter.freq, 0);
                    }
                    
                    // Connect node and move head up
                    AUGraphConnectNodeInput(scoreGraph, headNode, 0, filterNode, 0);
                    headNode = filterNode;
                }
            }
            AudioUnit headUnit;
            AUGraphNodeInfo(scoreGraph, headNode, NULL, &headUnit);
            AudioStreamBasicDescription soundStreamDesc;
            UInt32 size;
            AudioUnitGetProperty(headUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &soundStreamDesc, &size);
            AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &soundStreamDesc, size);
            
            // Connect sound modifier chain to mixer
            AUGraphConnectNodeInput(scoreGraph, headNode, 0, mixerNode, i);
            
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
        startTime = -1;
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
    if (score) {
        for (QSSound *sound in [score getSounds]) {
            if ([sound isKindOfClass:[QSWaveform class]]) {
                ((QSWaveform*)sound).theta = 0;
            } else if ([sound isKindOfClass:[QSPulse class]]) {
                ((QSPulse*)sound).theta = 0;
            } else if ([sound isKindOfClass:[QSNoise class]]) {
                ((QSNoise*)sound).sample = 0;
            }
#warning TODO: Add sound initializers here for new sound types
        }
    }
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
    if (startTime == -1) { startTime = inTimeStamp->mSampleTime; }
    UInt64 curTime = inTimeStamp->mSampleTime - startTime;
    // Generate the samples
    UInt64 startSample = sound.startTime * 44100;
    UInt64 endSample = startSample + sound.duration * 44100;
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= startSample && curTime < endSample) {
            switch (sound.waveType) {
                case SQUARE:
                    buffer[frame] = (sound.theta < M_PI) ? (sound.envelope[curTime - startSample] * 32767) : (-sound.envelope[curTime - startSample] * 32767);
                    break;
                case TRIANGLE:
                    buffer[frame] = (1 - fabsf((sound.theta / (2 * M_PI)) - .5) * 4) * sound.envelope[curTime - startSample] * 32767;
                    break;
                case SAWTOOTH:
                    buffer[frame] = fmodf((sound.theta / M_PI) + 1, 2) * sound.envelope[curTime - startSample] * 32767;
                    break;
                case SINE:
                default:
                    buffer[frame] = (AudioSampleType)(sin(sound.theta) * sound.envelope[curTime - startSample] * 32767);
                    break;
            }
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
        } else {
            buffer[frame] = 0;
        }
        curTime++;
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
    if (startTime == -1) { startTime = inTimeStamp->mSampleTime / 44100; }
    UInt64 curTime = inTimeStamp->mSampleTime - startTime;
    // Generate the samples
    UInt64 startSample = sound.startTime * 44100;
    UInt64 endSample = startSample + sound.duration * 44100;
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= startSample && curTime < endSample) {
            buffer[frame] = (sound.theta < M_PI) ? (sound.envelope[curTime - startSample] * 32767) : (-sound.envelope[curTime - startSample] * 32767);
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
        } else {
            buffer[frame] = 0;
        }
        curTime++;
    }
    return noErr;
}

OSStatus renderNoise(void *inRefCon,
                     AudioUnitRenderActionFlags *ioActionFlags,
                     const AudioTimeStamp *inTimeStamp,
                     UInt32 inBusNumber,
                     UInt32 inNumberFrames,
                     AudioBufferList *ioData) {
    QSNoise *sound = (__bridge QSNoise *)(inRefCon);
    const int channel = 0;
    AudioSampleType *buffer = ioData->mBuffers[channel].mData;
    if (startTime == -1) { startTime = inTimeStamp->mSampleTime / 44100; }
    UInt64 curTime = inTimeStamp->mSampleTime - startTime;
    // Generate the samples
    UInt64 startSample = sound.startTime * 44100;
    UInt64 endSample = startSample + sound.duration * 44100;
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= startSample && curTime < endSample) {
            buffer[frame] = sound.noise[sound.sample] * sound.envelope[curTime - startSample] * 32767;
            sound.sample++;
            if (sound.sample > sound.numSamples) {
                sound.sample = 0;
            }
        } else {
            buffer[frame] = 0;
        }
        curTime++;
    }
    return noErr;
}

@end
