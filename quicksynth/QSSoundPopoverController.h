//
//  QSSoundPopoverController.h
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WaveType.h"
#import "QSSound.h"

@interface QSSoundPopoverController : UIViewController {
    IBOutlet UISegmentedControl *waveSelector;
    IBOutlet UISlider *freqSlider;
    IBOutlet UITextField *freqText;
    IBOutlet UISlider *gainSlider;
    IBOutlet UITextField *gainText;
}

@property (nonatomic, retain) QSSound *sound;
@property (nonatomic, assign) UIPopoverController *container;

- (void)setWaveType:(WaveType)type;
- (WaveType)getWaveType;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setGain:(float)gain;
- (float)getGain;

@end
