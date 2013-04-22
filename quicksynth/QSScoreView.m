//
//  QSScoreView.m
//  quicksynth
//
//  Created by Andrew on 4/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSScoreView.h"

@implementation QSScoreView

#define SPACING 100

@synthesize scoreObjects;
@synthesize scaleGesture;
@synthesize bpm;


@synthesize _lastPinchLocation;
@synthesize _startOffset;
@synthesize _offset;
@synthesize _startScale;
@synthesize _scale;
@synthesize _startPinchX;

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    bpm = 60;
    _startOffset = _offset = CGPointMake(0, 0);
    _startScale = _scale = 1;
    scoreObjects = [[NSMutableDictionary alloc] init];
    scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [self addGestureRecognizer:scaleGesture];
}

- (void)addObject:(QSSoundButton *)object forKey:(NSNumber *)key
{
    [scoreObjects setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSNumber *)key
{
    [scoreObjects removeObjectForKey:key];
}

- (float)getXForStartTime:(float)startTime
{
    return [self getWidthForDuration:startTime] + _offset.x;
}

- (float)getStartTimeForX:(float)x
{
    return [self getDurationForWidth:(x - _offset.x)];
}

- (float)getWidthForDuration:(float)duration
{
    return duration * (SPACING * _scale) * (bpm / 60.0);
}

- (float)getDurationForWidth:(float)width
{
    return width / ((SPACING * _scale) * (bpm / 60.0));
}

- (float)getXForClosestBeat:(float)x
{
    return [self getX:x ForFraction:1];
}

- (float)getX:(float)x ForFraction:(float)fraction
{
    float pixFrom0 = x - _offset.x;
    float fractionSize = SPACING * _scale * fraction;
    float nearestFraction = roundf(pixFrom0 / fractionSize);
    float nearestFractionPixFrom0 = nearestFraction * fractionSize;
    return nearestFractionPixFrom0 + _offset.x;
}

- (void)scroll:(CGPoint)offset
{
    // Set new offset
    _offset = CGPointMake(_offset.x + offset.x, _offset.y + offset.y);
    
    // Relocate components
    for (QSSoundButton *object in [scoreObjects allValues]) {
        [object setFrame:CGRectMake([self getXForStartTime:object.sound.startTime], object.frame.origin.y + offset.y,
                                    [self getWidthForDuration:object.sound.duration], object.frame.size.height)];
    }
    [self setNeedsDisplay];
}

- (void)scale:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _startPinchX = abs([recognizer locationOfTouch:0 inView:self].x - [recognizer locationOfTouch:1 inView:self].x);
        _startScale = _scale;
        _startOffset = _offset;
        _lastPinchLocation = [recognizer locationInView:self];
    }
    
    if (recognizer.numberOfTouches != 2) { return; }
    // Scale view
    int thisPinchX = abs([recognizer locationOfTouch:0 inView:self].x - [recognizer locationOfTouch:1 inView:self].x);
    if (thisPinchX == 0) {
        thisPinchX = 1;
    }
    float xScale;
    if (_startPinchX == 0) {
        xScale = 1;
    } else {
        xScale = thisPinchX / (float)_startPinchX;
    }
    _scale = _startScale * xScale;
    
    // Slide while pinching
    CGPoint thisPinchLocation = [recognizer locationInView:self];
    _startOffset.x += thisPinchLocation.x - _lastPinchLocation.x;
    _startOffset.y += thisPinchLocation.y - _lastPinchLocation.y;
    float deltaY = thisPinchLocation.y - _lastPinchLocation.y;
    _lastPinchLocation = thisPinchLocation;
    
    // Center scale on gesture center
    _offset.x = [recognizer locationInView:self].x - ([recognizer locationInView:self].x - _startOffset.x) * xScale;
    
    // Position and scale modules
    for (QSSoundButton *object in [scoreObjects allValues]) {
        [object setFrame:CGRectMake([self getXForStartTime:object.sound.startTime], object.frame.origin.y + deltaY,
                   [self getWidthForDuration:object.sound.duration], object.frame.size.height)];
        [object setNeedsDisplay];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    float spacing = SPACING * _scale;
    int offset = fmodf(_offset.x, spacing);
    if (offset < 0) {
        offset += spacing;
    }
    for (int i = 0; i < width / spacing; i++) {
        CGContextMoveToPoint(context, i * spacing + offset, 20);
        CGContextAddLineToPoint(context, i * spacing + offset, height);
    }
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 1.5);
    int secs = ceil([self getStartTimeForX:0]);
    float x = [self getXForStartTime:secs];
    spacing = [self getXForStartTime:secs + 1] - x;
    while (x >= 0 && x <= width) {
        [[NSString stringWithFormat: @"% 2.0f:%02.0f", (secs / 60 > 0) ? floor(secs / 60) : ceil(secs / 60), fabs(fmodf(secs, 60))]
                         drawInRect: CGRectMake(x - (spacing / 2), 0, spacing, 40)
                           withFont: [UIFont fontWithName:@"Trebuchet MS" size:14]
                      lineBreakMode: NSLineBreakByCharWrapping
                          alignment: NSTextAlignmentCenter];
        CGContextMoveToPoint(context, x, 20);
        CGContextAddLineToPoint(context, x, 30);
        secs++;
        x = [self getXForStartTime:secs];
    }
    CGContextStrokePath(context);
}

@end
