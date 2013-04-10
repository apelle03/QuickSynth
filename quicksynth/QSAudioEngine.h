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

@interface QSAudioEngine : NSObject

@property (readwrite, retain) QSScore *score;

@property (readwrite) AUGraph scoreGraph;
@property (readwrite) AUNode ioNode;
@property (readwrite) AUNode mixerNode;
@property (readwrite) AudioUnit ioUnit;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) BOOL playing;
//@property (retain, readwrite) NSDate *startTime;

- (id)init;
- (void)update;
- (void)play;
- (void)stop;

@end

NSDate *startTime;