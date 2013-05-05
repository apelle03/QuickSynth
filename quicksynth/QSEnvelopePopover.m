//
//  QSEnvelopePopover.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSEnvelopePopover.h"

@interface QSEnvelopePopover ()

@end

@implementation QSEnvelopePopover

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

- (void)setMax:(float)max { adsrSlider.max = max; maxLabel.text = [NSString stringWithFormat:@"%.2f", max]; }
- (void)setMin:(float)min { adsrSlider.min = min; minLabel.text = [NSString stringWithFormat:@"%.2f", min]; }
- (void)setAPos:(float)aPos { adsrSlider.aPos = aPos; }
- (void)setDPos:(float)dPos { adsrSlider.dPos = dPos; }
- (void)setSPos:(float)sPos { adsrSlider.sPos = sPos; }
- (void)setStartVal:(float)startVal { adsrSlider.startVal = startVal; }
- (void)setAVal:(float)aVal { adsrSlider.aVal = aVal; }
- (void)setDVal:(float)dVal { adsrSlider.dVal = dVal; }
- (void)setSVal:(float)sVal { adsrSlider.sVal = sVal; }
- (void)setEndVal:(float)endVal { adsrSlider.endVal = endVal; }

- (float)getAPos { return adsrSlider.aPos; }
- (float)getDPos { return adsrSlider.dPos; }
- (float)getSPos { return adsrSlider.sPos; }
- (float)getStartVal { return adsrSlider.startVal; }
- (float)getAVal { return adsrSlider.aVal; }
- (float)getDVal { return adsrSlider.dVal; }
- (float)getSVal { return adsrSlider.sVal; }
- (float)getEndVal { return adsrSlider.endVal; }

@end
