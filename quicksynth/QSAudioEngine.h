//
//  QSScoreAudio.h
//  quicksynth
//
//  Created by Andrew on 4/3/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface QSAudioEngine : NSObject

@property (readwrite) AUGraph scoreGraph;
@property (readwrite) AUNode mixerNode;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit mixerUnit;
@property (readwrite) AudioUnit ioUnit;

@property (readwrite) BOOL playing;

- (id)init;
- (void)play;
- (void)stop;

@end
