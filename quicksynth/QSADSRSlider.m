//
//  QSADSRSlider.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSADSRSlider.h"

@implementation QSADSRSlider

@synthesize lastPoint;
@synthesize start, a, d, s, end;

- (id)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void) initUI
{
    _max = 1;
    _min = 0;
    [self setBackgroundColor:[UIColor whiteColor]];
    start = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    a = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    d = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    s = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    end = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self addSubview:start];
    [self addSubview:a];
    [self addSubview:d];
    [self addSubview:s];
    [self addSubview:end];
    [start addTarget:self action:@selector(nodePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
    [start addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [start addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [a addTarget:self action:@selector(nodePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
    [a addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [a addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [d addTarget:self action:@selector(nodePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
    [d addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [d addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [s addTarget:self action:@selector(nodePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
    [s addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [s addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [end addTarget:self action:@selector(nodePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
    [end addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [end addTarget:self action:@selector(nodeDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    
    [self setUI];
}

- (void)setMax:(float)max { _max = max; [self setUI]; }
- (void)setMin:(float)min { _min = min; [self setUI]; }
- (void)setAPos:(float)aPos { _aPos = aPos; [self setUI]; }
- (void)setDPos:(float)dPos { _dPos = dPos; [self setUI]; }
- (void)setSPos:(float)sPos { _sPos = sPos; [self setUI]; }
- (void)setStartVal:(float)startVal { _startVal = startVal; [self setUI]; }
- (void)setAVal:(float)aVal { _aVal = aVal; [self setUI]; }
- (void)setDVal:(float)dVal { _dVal = dVal; [self setUI]; }
- (void)setSVal:(float)sVal { _sVal = sVal; [self setUI]; }
- (void)setEndVal:(float)endVal { _endVal = endVal; [self setUI]; }

- (void)setUI
{
    float bottom = self.frame.size.height - 15;
    float pxPerValY = (self.frame.size.height - 30) / (_max - _min);
    float pxPerValX = (self.frame.size.width - 30);
    start.frame = CGRectMake(0, bottom - pxPerValY * _startVal - 15, 30, 30);
    a.frame = CGRectMake(pxPerValX * _aPos, bottom - pxPerValY * _aVal - 15, 30, 30);
    d.frame = CGRectMake(pxPerValX * _dPos, bottom - pxPerValY * _dVal - 15, 30, 30);
    s.frame = CGRectMake(pxPerValX * _sPos, bottom - pxPerValY * _sVal - 15, 30, 30);
    end.frame = CGRectMake(self.frame.size.width - 30, bottom - pxPerValY * _endVal - 15, 30, 30);
    [self setNeedsDisplay];
}

- (void)updateValues
{
    float bottom = self.frame.size.height - 15;
    float pxPerValY = (self.frame.size.height - 30) / (_max - _min);
    float pxPerValX = (self.frame.size.width - 30);
    _aPos = a.frame.origin.x / pxPerValX;
    _dPos = d.frame.origin.x / pxPerValX;
    _sPos = s.frame.origin.x / pxPerValX;
    _startVal = (start.frame.origin.y + 15 - bottom) / -pxPerValY;
    _aVal = (a.frame.origin.y + 15 - bottom) / -pxPerValY;
    _dVal = (d.frame.origin.y + 15 - bottom) / -pxPerValY;
    _sVal = (s.frame.origin.y + 15 - bottom) / -pxPerValY;
    _endVal = (end.frame.origin.y + 15 - bottom) / -pxPerValY;
}

- (IBAction)nodePressed:(id)sender withEvent:(UIEvent*)event
{
    lastPoint = [[[event allTouches] anyObject] locationInView:self];
}

- (IBAction)nodeDragged:(id)sender withEvent:(UIEvent*)event
{
    UIButton *control = (UIButton*)sender;
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self];
    CGPoint newCenter = CGPointMake(control.center.x + newPoint.x - lastPoint.x, control.center.y + newPoint.y - lastPoint.y);
    if (newCenter.x < 15) { newCenter.x = 15; }
    if (newCenter.x > self.frame.size.width - 15) { newCenter.x = self.frame.size.width - 15; }
    if (newCenter.y < 15) { newCenter.y = 15; }
    if (newCenter.y > self.frame.size.height - 15) { newCenter.y = self.frame.size.height - 15; }
    if (control == start) { newCenter.x = 15; }
    if (control == end) { newCenter.x = self.frame.size.width - 15; }
    if (control == a) {
        if (newCenter.x > d.center.x) {
            d.center = CGPointMake(newCenter.x, d.center.y);
        }
        if (newCenter.x > s.center.x) {
            s.center = CGPointMake(newCenter.x, s.center.y);
        }
    }
    if (control == d) {
        if (newCenter.x < a.center.x) {
            a.center = CGPointMake(newCenter.x, a.center.y);
        }
        if (newCenter.x > s.center.x) {
            s.center = CGPointMake(newCenter.x, s.center.y);
        }
    }
    if (control == s) {
        if (newCenter.x < a.center.x) {
            a.center = CGPointMake(newCenter.x, a.center.y);
        }
        if (newCenter.x < d.center.x) {
            d.center = CGPointMake(newCenter.x, d.center.y);
        }
    }
    
    control.center = newCenter;
    lastPoint = newPoint;
    [self updateValues];
    [self setUI];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.origin.y);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
        
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, start.center.x, start.center.y);
    CGContextAddLineToPoint(context, a.center.x, a.center.y);
    CGContextAddLineToPoint(context, d.center.x, d.center.y);
    CGContextAddLineToPoint(context, s.center.x, s.center.y);
    CGContextAddLineToPoint(context, end.center.x, end.center.y);
    CGContextStrokePath(context);
    [super drawRect:rect];
}

@end
