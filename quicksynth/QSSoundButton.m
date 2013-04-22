//
//  QSSoundButton.m
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSoundButton.h"

@implementation QSSoundButton

@synthesize sound;

@synthesize _border;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:FALSE];
        _border = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 1, 1) cornerRadius:10];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    _border = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 1, 1) cornerRadius:10];
    [_border fill];
    [_border stroke];

    UIImage *image;
    switch (sound.waveType) {
        case SINE:
            image = [UIImage imageNamed:@"sine.png"];
            break;
        case SQUARE:
            image = [UIImage imageNamed:@"square.png"];
            break;
        case TRIANGLE:
            image = [UIImage imageNamed:@"triangle.png"];
            break;
        case SAWTOOTH:
            image = [UIImage imageNamed:@"sawtooth.png"];
            break;
        default:
            image = [UIImage imageNamed:@"sine.png"];
            break;
    }
    [image drawInRect:self.bounds];
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [[NSString stringWithFormat: @"%.0fHz", sound.frequency]
                     drawInRect: CGRectInset(self.bounds, 4, 0)
                       withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
                  lineBreakMode: NSLineBreakByCharWrapping
                      alignment: NSTextAlignmentLeft];
    [[NSString stringWithFormat: @"%.2f", sound.gain]
                     drawInRect: CGRectInset(self.bounds, 4, 0)
                       withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
                  lineBreakMode: NSLineBreakByCharWrapping
                      alignment: NSTextAlignmentRight];
    CGContextStrokePath(context);
}

@end
