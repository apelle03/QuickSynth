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

#import "QSSimpleSlider.h"
#import "QSNoteSlider.h"

@interface QSWaveformPopover : UIViewController {
    IBOutlet UISegmentedControl *waveSelector;
    IBOutlet QSNoteSlider *noteSlider;
    IBOutlet QSSimpleSlider *gainSlider;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;
@property (nonatomic, readonly) CGSize size;

- (void)setWaveType:(WaveType)type;
- (WaveType)getWaveType;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setGain:(float)gain;
- (float)getGain;

@end
