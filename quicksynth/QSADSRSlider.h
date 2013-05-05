//
//  QSADSRSlider.h
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSADSRSlider : UIView

@property (nonatomic) CGPoint lastPoint;
@property (nonatomic, retain) UIButton *start, *a, *d, *s, *end;

@property (nonatomic, readwrite) float max, min;
@property (nonatomic, readwrite) float aPos, dPos, sPos;
@property (nonatomic, readwrite) float startVal, aVal, dVal, sVal, endVal;

@end
