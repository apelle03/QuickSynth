//
//  QSScore.m
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSScore.h"

@implementation QSScore

- (id)init
{
    sounds = [[NSMutableDictionary alloc] init];
    nextID = [NSNumber numberWithInt:1];
    return self;
}

//======================================================
// SOUNDS
//======================================================
// Add Sounds
- (NSNumber*)addSound
{
    [sounds setObject:[[QSSound alloc] initWithID:nextID] forKey:nextID];
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (NSNumber*)addWaveform
{
    [sounds setObject:[[QSWaveform alloc] initWithID:nextID] forKey:nextID];
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (NSNumber*)addPulse
{
    [sounds setObject:[[QSPulse alloc] initWithID:nextID] forKey:nextID];
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (NSNumber*)addNoise
{
    [sounds setObject:[[QSNoise alloc] initWithID:nextID] forKey:nextID];
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

// Get Sounds
- (QSSound*)getSoundForID:(NSNumber*)soundID
{
    return [sounds objectForKey:soundID];
}

- (NSArray*)getSoundIDs
{
    return [sounds allKeys];
}

- (NSArray*)getSounds
{
    return [sounds allValues];
}

// Remove Sounds
- (void)removeSoundForID:(NSNumber*)soundID
{
    [sounds removeObjectForKey:soundID];
}

//======================================================
// MODIFIERS
//======================================================
// Add Modifiers
- (NSNumber*)addModifierToSound:(NSNumber*)soundID
{
    QSSound *sound = [sounds objectForKey:soundID];
    [sound addModifier:[[QSModifier alloc] initWithID:nextID]];
    [self getModifierForSound:soundID withID:nextID].soundID = soundID;
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (NSNumber*)addEnvelopeToSound:(NSNumber*)soundID
{
    QSSound *sound = [sounds objectForKey:soundID];
    [sound addModifier:[[QSEnvelope alloc] initWithID:nextID]];
    [self getModifierForSound:soundID withID:nextID].soundID = soundID;
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (NSNumber*)addLowPassToSound:(NSNumber *)soundID
{
    QSSound *sound = [sounds objectForKey:soundID];
    [sound addModifier:[[QSFilter alloc] initWithID:nextID]];
    [self getModifierForSound:soundID withID:nextID].soundID = soundID;
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

// Get Sounds
- (QSModifier*)getModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID
{
    return [[sounds objectForKey:soundID] getModifier:modifierID];
}

- (NSArray*)getModifierIDsForSound:(NSNumber*)soundID {
    return [[sounds objectForKey:soundID] getModifierIDs];
}

- (NSArray*)getModifiersForSound:(NSNumber*)soundID
{
    return [[sounds objectForKey:soundID] getModifiers];
}

// Remove Sounds
- (void)removeModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID
{
    [[sounds objectForKey:soundID] removeModifier:modifierID];
}

@end
