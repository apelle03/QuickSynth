//
//  QSSound.m
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@implementation QSSound

@synthesize ID, startTime, duration, gain;

- (id)init
{
    modifiers = [[NSMutableDictionary alloc] init];
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

- (void) addModifier:(QSModifier*)modifier
{
    [modifiers setObject:modifier forKey:modifier.ID];
}

- (QSModifier*) getModifier:(NSNumber*)modifierID
{
    return [modifiers objectForKey:modifierID];
}

- (NSArray*) getModifierIDs
{
    return [modifiers allKeys];
}

- (NSArray*) getModifiers
{
    return [modifiers allValues];
}

- (void) removeModifier:(NSNumber*)modifierID
{
    [modifiers removeObjectForKey:modifierID];
}



@end
