//
//  QSSound.h
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "QSModifier.h"

typedef enum waveTypes {
    SIN,
    SQUARE,
    TRIANGLE,
    SAWTOOTH
} WaveType;

@interface QSSound : NSObject {
    NSMutableDictionary *modifiers;
}

@property (nonatomic, retain) NSNumber *ID;
@property (nonatomic, readwrite) float startTime;
@property (nonatomic, readwrite) float duration;
@property (nonatomic, readwrite) float frequency;
@property (nonatomic)         WaveType waveType;
@property (nonatomic, readwrite) float theta;

- (id) initWithID:(NSNumber*)ID;

- (void) addModifier:(QSModifier*)modifier;
- (QSModifier*) getModifier:(NSNumber*)modifierID;
- (NSArray*) getModifiers;

@end
