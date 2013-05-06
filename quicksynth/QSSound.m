//
//  QSSound.m
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@implementation QSSound

@synthesize ID, startTime, duration = _duration, gain = _gain, curGain, envelope = _envelope;

- (id)init
{
    modifiers = [[NSMutableDictionary alloc] init];
    _envelope = NULL;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

- (void)setDuration:(float)duration
{
    _duration = duration;
    [self updateEnvelope];
}

- (void)setGain:(float)gain
{
    _gain = gain;
    [self updateEnvelope];
}

- (void)updateEnvelope
{
    if (_envelope != NULL) { free(_envelope); }
    UInt64 numSamples = _duration * 44100;
    _envelope = (float*)malloc(numSamples * sizeof(*_envelope));
    for (UInt64 i = 0; i < numSamples; i++) {
        _envelope[i] = _gain;
    }
    for (QSModifier *modifier in [self getModifiers]) {
        if ([modifier isKindOfClass:[QSEnvelope class]]) {
            QSEnvelope *env = (QSEnvelope*)modifier;
            UInt64 startSample = (_duration * env.startPercent) * 44100;
            UInt64 aSample = startSample + (_duration * (env.endPercent - env.startPercent) * env.aLen) * 44100;
            UInt64 dSample = aSample + (_duration * (env.endPercent - env.startPercent) * env.dLen) * 44100;
            UInt64 sSample = dSample + (_duration * (env.endPercent - env.startPercent) * env.sLen) * 44100;
            UInt64 endSample = (_duration * env.endPercent) * 44100;
            for (UInt64 i = startSample; i < endSample; i++) {
                if (i  <= aSample) {
                    _envelope[i] *= env.startMag + (env.aMag - env.startMag) / (aSample - startSample) * (i - startSample);
                } else if (i <= dSample) {
                    _envelope[i] *= env.aMag + (env.dMag - env.aMag) / (dSample - aSample) * (i - aSample);
                } else if (i <= sSample) {
                    _envelope[i] *= env.dMag + (env.sMag - env.dMag) / (sSample - dSample) * (i - dSample);
                } else if (i <= endSample) {
                    _envelope[i] *= env.sMag + (env.endMag - env.sMag) / (endSample - sSample) * (i - sSample);
                }
            }
        }
    }
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
