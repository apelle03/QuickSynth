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

@synthesize aMag, dMag, sMag;
@synthesize aLen, dLen, sLen;
@synthesize startMag, endMag;

- (id)init
{
    type = LOWPASS;
    freq = 440;
    bandwidth = 1000;
    
    startMag = 0;
    endMag = 0;
    aMag = 1000; dMag = 500; sMag = 500;
    aLen = .3; dLen = .3; sLen = .3;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
