//
//  QSPulseButton.m
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSPulseButton.h"

@implementation QSPulseButton

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
    QSPulse *sound = (QSPulse*)super.sound;
    UIImage *image =[UIImage imageNamed:@"pulse.png"];
    [image drawInRect:self.bounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
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
    [[NSString stringWithFormat: @"%.2f", sound.duty]
                     drawInRect: CGRectInset(CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20), 4, 0)
                       withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
                  lineBreakMode: NSLineBreakByCharWrapping
                      alignment: NSTextAlignmentRight];
    CGContextStrokePath(context);
}

@end
