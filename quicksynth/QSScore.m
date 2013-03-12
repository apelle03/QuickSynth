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

- (NSNumber*)addSound
{
    [sounds setObject:[[QSSound alloc] initWithID:nextID] forKey:nextID];
    
    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (QSSound*)getSoundForID:(NSNumber *)soundID
{
    return [sounds objectForKey:soundID];
}

- (NSArray*)getSoundIDs
{
    return [sounds allKeys];
}

- (NSNumber*)addModifierToSound:(NSNumber*)soundID
{
    QSSound *sound = [sounds objectForKey:soundID];
    [sound addModifier:[[QSModifier alloc] initWithID:nextID]];

    NSNumber *thisID = nextID;
    nextID = [NSNumber numberWithInt:[nextID intValue] + 1];
    return thisID;
}

- (QSModifier*)getModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID
{
    return [[sounds objectForKey:soundID] getModifier:modifierID];
}

@end
