//
//  QSPulsePopoverViewController.h
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSPulsePopover : UIViewController {
    IBOutlet UISlider *dutySlider;
    IBOutlet UITextField *dutyText;
    IBOutlet UISlider *freqSlider;
    IBOutlet UITextField *freqText;
    IBOutlet UISlider *gainSlider;
    IBOutlet UITextField *gainText;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;

- (void)setDuty:(float)duty;
- (float)getDuty;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setGain:(float)gain;
- (float)getGain;

@end
