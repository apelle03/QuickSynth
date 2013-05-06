//
//  QSFilterButton.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSFilterButton.h"

@implementation QSFilterButton

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
    UIImage *image;
    QSFilter *filter = (QSFilter*)super.modifier;
    switch (filter.type) {
        case HIGHPASS:
            image = [UIImage imageNamed:@"highpass.png"];
            break;
        case BANDPASS:
            image = [UIImage imageNamed:@"bandpass.png"];
            break;
        case LOWPASS:
        default:
            image = [UIImage imageNamed:@"lowpass.png"];
            break;
    }
    [image drawInRect:self.bounds];
}

@end
