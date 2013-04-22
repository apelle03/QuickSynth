//
//  QSWaveformButton.m
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSWaveformButton.h"

@implementation QSWaveformButton

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
    QSWaveform *waveform = (QSWaveform*)super.sound;
    UIImage *image;
    switch (waveform.waveType) {
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
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [[NSString stringWithFormat: @"%.0fHz", waveform.frequency]
     drawInRect: CGRectInset(self.bounds, 4, 0)
     withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
     lineBreakMode: NSLineBreakByCharWrapping
     alignment: NSTextAlignmentLeft];
    [[NSString stringWithFormat: @"%.2f", waveform.gain]
     drawInRect: CGRectInset(self.bounds, 4, 0)
     withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
     lineBreakMode: NSLineBreakByCharWrapping
     alignment: NSTextAlignmentRight];
    CGContextStrokePath(context);
}

@end
