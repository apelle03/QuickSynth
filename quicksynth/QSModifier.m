//
//  QSModifier.m
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSModifier.h"

@implementation QSModifier

@synthesize ID;
@synthesize width;

- (id)init
{
    self.width = [NSNumber numberWithFloat:1.0];
    return self;
}

- (id)initWithID:(NSNumber *)newID
{
    self = [self init];
    self.ID = newID;
    return self;
}

@end
