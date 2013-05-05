//
//  QSLowPassButton.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSLowPassButton.h"

@implementation QSLowPassButton

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
    UIImage *image = [UIImage imageNamed:@"lowpass.png"];
    [image drawInRect:self.bounds];
}

@end
