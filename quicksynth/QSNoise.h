//
//  QSNoise.h
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@interface QSNoise : QSSound

@property (nonatomic, readonly) float *noise;
@property (nonatomic, readonly) UInt32 numSamples;
@property (nonatomic, readwrite) UInt32 sample;

@end
