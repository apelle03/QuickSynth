//
//  QSLowPassPopover.h
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSNoteSlider.h"
#import "QSADSRSlider.h"

@interface QSLowPassPopover : UIViewController {
    IBOutlet QSNoteSlider *noteSlider;
    IBOutlet QSADSRSlider *adsrSlider;
    IBOutlet UILabel *maxLabel, *midLabel, *minLabel;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;
@property (nonatomic, readonly) CGSize size;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setMax:(float)max;
- (void)setMin:(float)min;
- (void)setAPos:(float)aPos;
- (void)setDPos:(float)dPos;
- (void)setSPos:(float)sPos;
- (void)setStartVal:(float)startVal;
- (void)setAVal:(float)aVal;
- (void)setDVal:(float)dVal;
- (void)setSVal:(float)sVal;
- (void)setEndVal:(float)endVal;

- (float)getAPos;
- (float)getDPos;
- (float)getSPos;
- (float)getStartVal;
- (float)getAVal;
- (float)getDVal;
- (float)getSVal;
- (float)getEndVal;

@end