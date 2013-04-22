//
//  QSPulse.m
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSPulse.h"

@implementation QSPulse

@synthesize frequency, duty, theta;

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
