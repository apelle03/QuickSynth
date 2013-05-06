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

static QSAudioEngine *instance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        instance = [[QSAudioEngine alloc] init];
    }
}

+ (QSAudioEngine *)getInstance
{
    return instance;
}

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
            }
#warning TODO: add these types
            soundInput.inputProcRefCon = (__bridge void *)(sound);
            AUGraphSetNodeInputCallback(scoreGraph, headNode, 0, &soundInput);
            
            /*
            // Create sound modifier chain
            for (QSModifier *modifier in [score getModifiersForSound:sound.ID]) {
                // Modifier needs node, add to head of chain
                if ([modifier isKindOfClass:[QSLowPass class]]) {
                    AUNode lowPassNode;
                    if ([soundNodes objectForKey:modifier.ID] == nil) {
                        // Create lowpass node
                        AudioComponentDescription lowPassDesc;
                        lowPassDesc.componentType = kAudioUnitType_Effect;
                        lowPassDesc.componentSubType = kAudioUnitSubType_LowPassFilter;
                        lowPassDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
                        lowPassDesc.componentFlags = 0;
                        lowPassDesc.componentFlagsMask = 0;
                        
                        AUGraphAddNode(scoreGraph, &lowPassDesc, &lowPassNode);
                        [soundNodes setObject:[[QSSoundNode alloc] initWithAUNode:lowPassNode] forKey: modifier.ID];
                    }
                    lowPassNode = ((QSSoundNode*)[soundNodes objectForKey:modifier.ID]).node;
                    // Setup lowpass params
                    AudioUnit lastUnit, lowPassUnit;
                    AUGraphNodeInfo(scoreGraph, headNode, NULL, &lastUnit);
                    AUGraphNodeInfo(scoreGraph, lowPassNode, NULL, &lowPassUnit);
                    // Set stream format
                    AudioStreamBasicDescription soundStreamDesc;
                    UInt32 size;
                    AudioUnitGetProperty(lowPassUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &soundStreamDesc, &size);
                    AudioUnitSetProperty(lastUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &soundStreamDesc, size);
                    // set cutoff frequency
                    AudioUnitSetParameter(lowPassUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Input, 0, ((QSLowPass*)modifier).freq, 0);
                    
                    // Connect node and move head up
                    NSLog(@"%ld", AUGraphConnectNodeInput(scoreGraph, headNode, 0, lowPassNode, 0));
                    headNode = lowPassNode;
                }
            }
            AudioUnit headUnit;
            AUGraphNodeInfo(scoreGraph, headNode, NULL, &headUnit);
            AudioStreamBasicDescription soundStreamDesc;
            UInt32 size;
            AudioUnitGetProperty(headUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &soundStreamDesc, &size);
            AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &soundStreamDesc, size);
            */
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
    if (score) {
        for (QSSound *sound in [score getSounds]) {
            sound.curGain = sound.gain;
            if ([sound isKindOfClass:[QSWaveform class]]) {
                ((QSWaveform*)sound).theta = 0;
            } else if ([sound isKindOfClass:[QSPulse class]]) {
                ((QSPulse*)sound).theta = 0;
            }
#warning TODO:add types
        }
    }
    [self startGraph];
}

- (void)stop {
    [self stopGraph];
}

+ (float) getGain:(QSSound*)sound atTime:(NSTimeInterval)curTime {
    float gain = sound.gain;
    for (QSModifier *modifier in [sound getModifiers]) {
        if ([modifier isKindOfClass:[QSEnvelope class]]) {
            QSEnvelope *env = (QSEnvelope*)modifier;
            NSTimeInterval startTime = sound.startTime + sound.duration * env.startPercent;
            NSTimeInterval aTime = startTime + sound.duration * (env.endPercent - env.startPercent) * env.aLen;
            NSTimeInterval dTime = aTime + sound.duration * (env.endPercent - env.startPercent) * env.dLen;
            NSTimeInterval sTime = dTime + sound.duration * (env.endPercent - env.startPercent) * env.sLen;
            NSTimeInterval endTime = sound.startTime + sound.duration * env.endPercent;
            if (curTime >= startTime && curTime < aTime) {
                gain *= env.startMag + (env.aMag - env.startMag) / (aTime - startTime) * (curTime - startTime);
            } else if (curTime >= aTime && curTime < dTime) {
                gain *= env.aMag + (env.dMag - env.aMag) / (dTime - aTime) * (curTime - aTime);
            } else if (curTime >= dTime && curTime < sTime) {
                gain *= env.dMag + (env.sMag - env.dMag) / (sTime - dTime) * (curTime - dTime);
            } else if (curTime >= sTime && curTime < endTime) {
                gain *= env.sMag + (env.endMag - env.sMag) / (endTime - sTime) * (curTime - sTime);
            }
        }
    }
    return gain;
}

+ (float) getGainIncrement:(QSSound*)sound atTime:(NSTimeInterval)curTime {
    float gainIncrement = 0;
    for (QSModifier *modifier in [sound getModifiers]) {
        if ([modifier isKindOfClass:[QSEnvelope class]]) {
            QSEnvelope *env = (QSEnvelope*)modifier;
            NSTimeInterval startTime = sound.startTime + sound.duration * env.startPercent;
            NSTimeInterval aTime = startTime + sound.duration * (env.endPercent - env.startPercent) * env.aLen;
            NSTimeInterval dTime = aTime + sound.duration * (env.endPercent - env.startPercent) * env.dLen;
            NSTimeInterval sTime = dTime + sound.duration * (env.endPercent - env.startPercent) * env.sLen;
            NSTimeInterval endTime = sound.startTime + sound.duration * env.endPercent;
            if (curTime >= startTime && curTime < aTime) {
                gainIncrement += (env.aMag - env.startMag) / (aTime - startTime);
            } else if (curTime >= aTime && curTime < dTime) {
                gainIncrement += (env.dMag - env.aMag) / (dTime - aTime);
            } else if (curTime >= dTime && curTime < sTime) {
                gainIncrement += (env.sMag - env.dMag) / (sTime - dTime);
            } else if (curTime >= sTime && curTime < endTime) {
                gainIncrement += (env.endMag - env.sMag) / (endTime - sTime);
            }
        }
    }
    return sound.gain * gainIncrement / 44100;
}

void getLPCoefficientsButterworth2Pole(const int samplerate, const float cutoff, float* const ax, float* const by)
{
    double PI    = 3.1415926535897932385;
    double sqrt2 = 1.4142135623730950488;
    
    double QcRaw  = (2 * PI * cutoff) / samplerate; // Find cutoff frequency in [0..PI]
    double QcWarp = tan(QcRaw); // Warp cutoff frequency
    
    double gain = 1 / (1+sqrt2/QcWarp + 2/(QcWarp*QcWarp));
    by[2] = (1 - sqrt2/QcWarp + 2/(QcWarp*QcWarp)) * gain;
    by[1] = (2 - 2 * 2/(QcWarp*QcWarp)) * gain;
    by[0] = 1;
    ax[0] = 1 * gain;
    ax[1] = 2 * gain;
    ax[2] = 1 * gain;
}

+ (float) getCutoffFreq:(QSLowPass*)lowpass forSound:(QSSound*)sound atTime:(NSTimeInterval)curTime
{
    float freq = -1;
    NSTimeInterval startTime = sound.startTime + sound.duration * lowpass.startPercent;
    NSTimeInterval aTime = startTime + sound.duration * (lowpass.endPercent - lowpass.startPercent) * lowpass.aLen;
    NSTimeInterval dTime = aTime + sound.duration * (lowpass.endPercent - lowpass.startPercent) * lowpass.dLen;
    NSTimeInterval sTime = dTime + sound.duration * (lowpass.endPercent - lowpass.startPercent) * lowpass.sLen;
    NSTimeInterval endTime = sound.startTime + sound.duration * lowpass.endPercent;
    if (curTime >= startTime && curTime < aTime) {
        freq = lowpass.freq + lowpass.startMag + (lowpass.aMag - lowpass.startMag) / (aTime - startTime) * (curTime - startTime);
    } else if (curTime >= aTime && curTime < dTime) {
        freq = lowpass.freq + lowpass.aMag + (lowpass.dMag - lowpass.aMag) / (dTime - aTime) * (curTime - aTime);
    } else if (curTime >= dTime && curTime < sTime) {
        freq = lowpass.freq + lowpass.dMag + (lowpass.sMag - lowpass.dMag) / (sTime - dTime) * (curTime - dTime);
    } else if (curTime >= sTime && curTime < endTime) {
        freq = lowpass.freq + lowpass.sMag + (lowpass.endMag - lowpass.sMag) / (endTime - sTime) * (curTime - sTime);
    }
    return freq;
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
    NSTimeInterval curTime = -[startTime timeIntervalSinceNow]; // time in seconds
    // Generate the samples
    //sound.curGain = [QSAudioEngine getGain:sound atTime:curTime];
    //float gain_increment = [QSAudioEngine getGainIncrement:sound atTime:curTime];
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= sound.startTime && curTime <= sound.startTime + sound.duration) {
            switch (sound.waveType) {
                case SQUARE:
                    buffer[frame] = (sound.theta < M_PI) ? (sound.curGain * 32767) : (-sound.curGain * 32767);
                    break;
                case TRIANGLE:
                    buffer[frame] = (1 - fabsf((sound.theta / (2 * M_PI)) - .5) * 4) * sound.curGain * 32767;
                    break;
                case SAWTOOTH:
                    buffer[frame] = fmodf((sound.theta / M_PI) + 1, 2) * sound.curGain * 32767;
                    break;
                case SINE:
                default:
                    buffer[frame] = (AudioSampleType)(sin(sound.theta) * sound.curGain * 32767);
                    break;
            }
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
            //sound.curGain += gain_increment;
            if (sound.curGain > 1) {
                sound.curGain = 1;
            }
        } else {
            buffer[frame] = 0;
        }
    }/*
    // Pass through filter
    for (QSModifier *modifier in [sound getModifiers]) {
        if ([modifier isKindOfClass:[QSLowPass class]]) {
            float cutoff = [QSAudioEngine getCutoffFreq:(QSLowPass*)modifier forSound:sound atTime:curTime];
            if (cutoff != -1) {
                static float xv[3]; static float yv[3];
                float ax[3]; float by[3];
                getLPCoefficientsButterworth2Pole(44100, cutoff, ax, by);
                for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
                    xv[2] = xv[1]; xv[1] = xv[0];
                    xv[0] = buffer[frame];
                    yv[2] = yv[1]; yv[1] = yv[0];
                    yv[0] = (ax[0] * xv[0] + ax[1] * xv[1] + ax[2] * xv[2] - by[1] * yv[0] - by[2] * yv[1]);
                    buffer[frame] = yv[0];
                }
            }
        }
    }*/
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
    sound.curGain = [QSAudioEngine getGain:sound atTime:curTime];
    float gain_increment = [QSAudioEngine getGainIncrement:sound atTime:curTime];
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (curTime >= sound.startTime && curTime <= sound.startTime + sound.duration) {
            buffer[frame] = (sound.theta < (M_PI * 2 * sound.duty)) ? (sound.curGain * 32767) : (-sound.curGain * 32767);
            sound.theta += theta_increment;
            if (sound.theta > 2.0 * M_PI) {
                sound.theta -= 2.0 * M_PI;
            }
            sound.curGain += gain_increment;
            if (sound.curGain > 1) {
                sound.curGain = 1;
            }
        } else {
            buffer[frame] = 0;
        }
    }
    // Pass through filter
    for (QSModifier *modifier in [sound getModifiers]) {
        if ([modifier isKindOfClass:[QSLowPass class]]) {
            float cutoff = [QSAudioEngine getCutoffFreq:(QSLowPass*)modifier forSound:sound atTime:curTime];
            if (cutoff != -1) {
                static float xv[3]; static float yv[3];
                float ax[3]; float by[3];
                getLPCoefficientsButterworth2Pole(44100, cutoff, ax, by);
                for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
                    xv[2] = xv[1]; xv[1] = xv[0];
                    xv[0] = buffer[frame];
                    yv[2] = yv[1]; yv[1] = yv[0];
                    yv[0] = (ax[0] * xv[0] + ax[1] * xv[1] + ax[2] * xv[2] - by[1] * yv[0] - by[2] * yv[1]);
                    buffer[frame] = yv[0];
                }
            }
        }
    }
    return noErr;
}

@end
