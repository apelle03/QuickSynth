//
//  QSScoreView.h
//  quicksynth
//
//  Created by Andrew on 4/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSSoundButton.h"

@interface QSScoreView : UIControl

@property (nonatomic, retain) NSMutableDictionary *scoreObjects;
@property (nonatomic, retain) UIPinchGestureRecognizer *scaleGesture;
@property float bpm;

@property int _startPinchX;
@property CGPoint _lastPinchLocation;
@property CGPoint _startOffset, _offset;
@property float _startScale, _scale;

- (void)addObject:(QSSoundButton *)object forKey:(NSNumber *)key;
- (void)removeObjectForKey:(NSNumber *)key;

- (float)getXForStartTime:(float)startTime;
- (float)getStartTimeForX:(float)x;
- (float)getWidthForDuration:(float)duration;
- (float)getDurationForWidth:(float)width;

- (void)scroll:(CGPoint)offset;

@end
