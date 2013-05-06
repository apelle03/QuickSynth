//
//  QSFilterPopover.m
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSFilterPopover.h"

@interface QSFilterPopover ()

@end

@implementation QSFilterPopover

@synthesize apply, cancel;
@synthesize size;

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
    
    bandwidthSlider.name = @"Bandwidth";
    bandwidthSlider.format = @"%.0f";
    bandwidthSlider.unit = @"Hz";
    bandwidthSlider.min = 0;
    bandwidthSlider.max = 20000;
    bandwidthSlider.value = 10000;
    size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFilterType:(FilterType)type
{
    typeSelector.selectedSegmentIndex = type;
}

- (FilterType)getFilterType
{
    return typeSelector.selectedSegmentIndex;
}

- (void)setFrequency:(float)frequency {
    freqSlider.value = frequency;
}
- (float)getFrequency {
    return freqSlider.value;
}

- (void)setBandwidth:(float)bandwidth
{
    bandwidthSlider.value = bandwidth;
}

- (float)getBandwidth
{
    return bandwidthSlider.value;
}

@end
