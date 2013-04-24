//
//  QSPulsePopoverViewController.m
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSPulsePopover.h"

@implementation QSPulsePopover

@synthesize apply, cancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    gainSlider.name = @"Gain";
    gainSlider.format = @"%1.3f";
    gainSlider.unit = @"%";
    gainSlider.min = 0;
    gainSlider.max = 1;
    gainSlider.value = .250;

    dutySlider.name = @"Duty";
    dutySlider.format = @"%1.3f";
    dutySlider.unit = @"%";
    dutySlider.min = 0;
    dutySlider.max = 1;
    dutySlider.value = .5;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFrequency:(float)frequency
{
    freqSlider.value = frequency;
}

- (float)getFrequency
{
    return freqSlider.value;
}

- (void)setGain:(float)gain
{
    gainSlider.value = gain;
}

- (float)getGain
{
    return gainSlider.value;
}

- (void)setDuty:(float)duty
{
    dutySlider.value = duty;
}

- (float)getDuty
{
    return dutySlider.value;
}

@end
