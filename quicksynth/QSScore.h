//
//  QSScore.h
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QSSound.h"
#import "QSWaveform.h"
#import "QSPulse.h"

#import "QSModifier.h"
#import "QSEnvelope.h"

@interface QSScore : NSObject {
    NSNumber *nextID;
    NSMutableDictionary *sounds;
}

- (id)init;

//======================================================
// SOUNDS
//======================================================
// Add Sounds
//- (NSNumber*)addSound;
- (NSNumber*)addWaveform;
- (NSNumber*)addPulse;
- (NSNumber*)addNoise;
// Get Sounds
- (QSSound*)getSoundForID:(NSNumber*)soundID;
- (NSArray*)getSoundIDs;
- (NSArray*)getSounds;
// Remove Sounds
- (void)removeSoundForID:(NSNumber*)soundID;

//======================================================
// MODIFIERS
//======================================================
// Add Modifiers
//- (NSNumber*)addModifierToSound:(NSNumber*)soundID;
- (NSNumber*)addEnvelopeToSound:(NSNumber*)soundID;
// Get Sounds
- (QSModifier*)getModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID;
- (NSArray*)getModifierIDsForSound:(NSNumber*)soundID;
- (NSArray*)getModifiersForSound:(NSNumber*)soundID;
// Remove Sounds
- (void)removeModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID;

@end
