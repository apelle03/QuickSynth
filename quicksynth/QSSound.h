//
//  QSSound.h
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "WaveType.h"

#import "QSModifier.h"
#import "QSEnvelope.h"

@interface QSSound : NSObject {
    NSMutableDictionary *modifiers;
}

@property (nonatomic, retain) NSNumber *ID;
@property (nonatomic, readwrite) float startTime;
@property (nonatomic, readwrite) float duration;
@property (nonatomic, readwrite) float gain;
@property (nonatomic, readonly)  float *envelope;

- (id) initWithID:(NSNumber*)ID;

- (void) updateEnvelope;

- (void) addModifier:(QSModifier*)modifier;
- (QSModifier*) getModifier:(NSNumber*)modifierID;
- (NSArray*) getModifierIDs;
- (NSArray*) getModifiers;
- (void) removeModifier:(NSNumber*)modifierID;

@end
