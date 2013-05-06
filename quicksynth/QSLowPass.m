//
//  QSLowPass.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSLowPass.h"

@implementation QSLowPass

@synthesize freq;
@synthesize aMag, dMag, sMag;
@synthesize aLen, dLen, sLen;
@synthesize startMag, endMag;

- (id)init
{
    freq = 440;
    startMag = 0;
    endMag = 0;
    aMag = 100; dMag = 50; sMag = 50;
    aLen = .5; dLen = .3; sLen = .1;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
