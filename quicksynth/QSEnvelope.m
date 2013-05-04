//
//  QSEnvelope.m
//  quicksynth
//
//  Created by Andrew on 4/25/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSEnvelope.h"

@implementation QSEnvelope

@synthesize aMag, dMag, sMag;
@synthesize aLen, dLen, sLen;
@synthesize startMag, endMag;

- (id)init
{
    startMag = 0;
    endMag = 0;
    aMag = 1; dMag = .5; sMag = .5;
    aLen = .1; dLen = .1; sLen = .7;
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
