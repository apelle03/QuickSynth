//
//  QSWaveform.m
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSWaveform.h"

@implementation QSWaveform

@synthesize frequency, waveType, gain, theta;

- (id)init
{
    self = [super init];
    self.theta = 0;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
