//
//  QSNoisePopover.m
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSNoisePopover.h"

@interface QSNoisePopover ()

@end

@implementation QSNoisePopover

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
    gainSlider.name = @"Gain";
    gainSlider.format = @"%1.3f";
    gainSlider.unit = @"%";
    gainSlider.min = 0;
    gainSlider.max = 1;
    gainSlider.value = .250;
    
    size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
