//
//  QSPulsePopoverViewController.h
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSSimpleSlider.h"
#import "QSNoteSlider.h"

@interface QSPulsePopover : UIViewController {
    IBOutlet QSNoteSlider *freqSlider;
    IBOutlet QSSimpleSlider *gainSlider, *dutySlider;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;
@property (nonatomic, readonly) CGSize size;

- (void)setDuty:(float)duty;
- (float)getDuty;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setGain:(float)gain;
- (float)getGain;

@end
