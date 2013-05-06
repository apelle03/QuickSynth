//
//  QSNoiseButton.m
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSNoiseButton.h"

@implementation QSNoiseButton

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
    QSNoise *sound = (QSNoise*)super.sound;
    UIImage *image =[UIImage imageNamed:@"noise.png"];
    [image drawInRect:self.bounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [[NSString stringWithFormat: @"%.2f", sound.gain]
                     drawInRect: CGRectInset(self.bounds, 4, 0)
                       withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
                  lineBreakMode: NSLineBreakByCharWrapping
                      alignment: NSTextAlignmentRight];
    CGContextStrokePath(context);
}

@end
