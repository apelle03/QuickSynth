//
//  QSSoundPopoverController.m
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSoundPopoverController.h"

@implementation QSSoundPopoverController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)freqSliderChanged:(id)sender
{
    [freqText setText:[NSString stringWithFormat:@"%.0f", freqSlider.value]];
}

- (IBAction)freqTextChanged:(id)sender
{
    [freqSlider setValue:[freqText.text floatValue]];
}

- (IBAction)gainSliderChanged:(id)sender
{
    [gainText setText:[NSString stringWithFormat:@"%1.3f", gainSlider.value]];
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
    [freqSlider setValue:frequency];
    [freqText setText:[NSString stringWithFormat:@"%.0f", freqSlider.value]];
}

- (float)getFrequency
{
    return freqSlider.value;
}

- (void)setGain:(float)gain
{
    [gainSlider setValue:gain];
    [gainText setText:[NSString stringWithFormat:@"%1.3f", gainSlider.value]];
}

- (float)getGain
{
    return gainSlider.value;
}

@end
