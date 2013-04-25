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
    //QSEnvelope *waveform = (QSEnvelope*)super.modifier;
    UIImage *image = [UIImage imageNamed:@"envelope.png"];
    [image drawInRect:self.bounds];
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*
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
    */
}

@end
