//
//  QSAudioController.h
//  quicksynth
//
//  Created by Andrew on 3/27/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "QSScore.h"
#import "QSSound.h"
#import "QSModifier.h"

@interface QSAudioController : NSObject {
}

- (void)initSound;
- (void)initSoundWithScore:(QSScore *)score;
- (void)playSound;
- (void)stopSound;
@end
