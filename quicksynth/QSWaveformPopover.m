//
//  QSSoundPopoverController.m
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSWaveformPopover.h"

@implementation QSWaveformPopover

@synthesize apply, cancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setWaveType:(WaveType)type
{
    [waveSelector setSelectedSegmentIndex:type];
}

- (WaveType)getWaveType
{
    return waveSelector.selectedSegmentIndex;
}

- (void)setFrequency:(float)frequency
{
    noteSlider.value = frequency;
}

- (float)getFrequency
{
    return noteSlider.value;
}

- (void)setGain:(float)gain
{
    gainSlider.value = gain;
}

- (float)getGain
{
    return gainSlider.value;
}

@end
