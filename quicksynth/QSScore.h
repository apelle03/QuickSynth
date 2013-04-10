//
//  QSScore.h
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QSSound.h"
#import "QSModifier.h"

@interface QSScore : NSObject {
    NSNumber *nextID;
    NSMutableDictionary *sounds;
}

- (id)init;
- (NSNumber*)addSound;
- (QSSound*)getSoundForID:(NSNumber*)soundID;
- (NSArray*)getSoundIDs;
- (NSArray*)getSounds;

- (NSNumber*)addModifierToSound:(NSNumber*)soundID;
- (QSModifier*)getModifierForSound:(NSNumber*)soundID withID:(NSNumber*)modifierID;

@end
