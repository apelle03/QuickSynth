//
//  QSScoreAudio.h
//  quicksynth
//
//  Created by Andrew on 4/3/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "QSScore.h"

#import "QSSoundNode.h"

#import "QSWaveform.h"
#import "QSPulse.h"
#import "QSNoise.h"

@interface QSAudioEngine : NSObject

@property (readwrite, retain) QSScore *score;

@property (readwrite) AUGraph scoreGraph;
@property (readwrite) AUNode ioNode;
@property (readwrite) AUNode mixerNode;
@property (readwrite) AudioUnit ioUnit;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) BOOL playing;
@property (retain, readwrite) NSMutableDictionary *soundNodes;

- (id)init;
- (void)update;
- (void)play;
- (void)stop;

@end