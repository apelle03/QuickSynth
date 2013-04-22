//
//  QSSound.m
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@implementation QSSound

@synthesize ID, startTime, duration;

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
    modifier.width = [NSNumber numberWithFloat:1.0 / ([modifiers count] + 1)];
    for (QSModifier *m in [modifiers allValues]) {
        m.width = [NSNumber numberWithFloat:[m.width floatValue] * (1 - 1.0 / ([modifiers count] + 1))];
    }
    [modifiers setObject:modifier forKey:modifier.ID];
}

- (QSModifier*) getModifier:(NSNumber*)modifierID
{
    return [modifiers objectForKey:modifierID];
}

- (NSArray*) getModifiers
{
    return [modifiers allValues];
}

@end
