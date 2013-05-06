//
//  QSNoise.m
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSNoise.h"

@implementation QSNoise

@synthesize noise, numSamples, sample;

static float *_samples;

+ (void)initialize {
    [super initialize];
    _samples = (float*)malloc(44100 * sizeof(*_samples));
    for (UInt64 i = 0; i < 44100; i++) {
        _samples[i] = drand48() * 2 - 1;
    }
}

- (id)init {
    self = [super init];
    self.sample = 0;
    return self;
}

- (id)initWithID:(NSNumber *)newID {
    self = [self init];
    self.ID = newID;
    return self;
}

- (float *)noise {
    return _samples;
}

- (UInt32)numSamples {
    return 44100;
}

@end
