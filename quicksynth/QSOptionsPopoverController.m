//
//  QSOptionsPopoverController.m
//  quicksynth
//
//  Created by Andrew on 4/13/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSOptionsPopoverController.h"

@implementation QSOptionsPopoverController

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

- (IBAction)bpmSliderChanged:(id)sender
{
    [bpmText setText:[NSString stringWithFormat:@"%.0f", bpmSlider.value]];
}

- (IBAction)bpmTextChanged:(id)sender
{
    [bpmSlider setValue:[bpmText.text floatValue]];
}

- (void)setBPM:(float)bpm
{
    [bpmSlider setValue:[bpmText.text floatValue]];
    [bpmText setText:[NSString stringWithFormat:@"%.0f", bpmSlider.value]];
}

- (float)getBPM
{
    return bpmSlider.value;
}

- (void)setSnapSize:(SnapSize)size
{
    [snapSelector setSelectedSegmentIndex:size];
}

- (SnapSize)getSnapSize
{
    return snapSelector.selectedSegmentIndex;
}

@end
