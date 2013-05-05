//
//  QSEnvelopeButton.m
//  quicksynth
//
//  Created by Andrew on 4/25/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSEnvelopeButton.h"

@implementation QSEnvelopeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIImage *image = [UIImage imageNamed:@"envelope.png"];
    [image drawInRect:self.bounds];
}

@end
