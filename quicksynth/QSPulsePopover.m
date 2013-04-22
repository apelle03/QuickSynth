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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dutySliderChanged:(id)sender
{
    [dutyText setText:[NSString stringWithFormat:@"%1.3f", dutySlider.value]];
}

- (IBAction)dutyTextChanged:(id)sender
{
    [dutySlider setValue:[dutyText.text floatValue]];
}

- (IBAction)dutyTextFinished:(id)sender
{
    [dutyText setText:[NSString stringWithFormat:@"%1.3f", dutySlider.value]];
}

- (IBAction)freqSliderChanged:(id)sender
{
    [freqText setText:[NSString stringWithFormat:@"%.0f", freqSlider.value]];
}

- (IBAction)freqTextChanged:(id)sender
{
    [freqSlider setValue:[freqText.text floatValue]];
}

- (IBAction)freqTextFinished:(id)sender
{
    [freqText setText:[NSString stringWithFormat:@"%.0f", freqSlider.value]];
}

- (IBAction)gainSliderChanged:(id)sender
{
    [gainText setText:[NSString stringWithFormat:@"%1.3f", gainSlider.value]];
}

- (IBAction)gainTextChanged:(id)sender
{
    [gainSlider setValue:[gainText.text floatValue]];
}

- (IBAction)gainTextFinished:(id)sender
{
    [gainText setText:[NSString stringWithFormat:@"%1.3f", gainSlider.value]];
}

- (void)setDuty:(float)duty
{
    [dutySlider setValue:duty];
}

- (float)getDuty
{
    return dutySlider.value;
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
