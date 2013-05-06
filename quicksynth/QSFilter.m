//
//  QSLowPass.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSFilter.h"

@implementation QSFilter

@synthesize type, freq, bandwidth;

- (id)init
{
    type = LOWPASS;
    freq = 440;
    bandwidth = 1000;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
