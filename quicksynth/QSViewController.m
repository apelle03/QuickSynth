//
//  QSViewController.m
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSViewController.h"

@interface QSViewController ()

@end

@implementation QSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	buttonNum = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toolboxModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
}

- (IBAction)toolboxModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    CGPoint newCenter;
    newCenter.x = control.center.x + (newPoint.x - prevPoint.x);
    newCenter.y = control.center.y + (newPoint.y - prevPoint.y);
    control.center = newCenter;
    prevPoint = newPoint;
}

- (IBAction)toolboxModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    UIControl *control = sender;
    NSLog(@"let go before check\n");
    
    if (!CGRectIntersectsRect(control.frame, toolbox.frame)) {
        buttonNum++;
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [newButton setFrame:control.frame];
        [newButton setTag:buttonNum];
        [newButton setTitle:[NSString stringWithFormat:@"%d", buttonNum] forState:UIControlStateNormal];
        [newButton addTarget:self action:@selector(scoreModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
        [newButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [newButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        [self.view insertSubview:newButton aboveSubview:control];
    }
    
    NSLog(@"let go after check\n");
    if (control == waveformGeneratorModule) {
        [control setFrame:waveformGeneratorAnchor.frame];
    } else if (control == envelopeModule) {
        [control setFrame:envelopeAnchor.frame];
    }
}

- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
}

- (IBAction)scoreModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    CGPoint newCenter;
    newCenter.x = control.center.x + (newPoint.x - prevPoint.x);
    newCenter.y = control.center.y + (newPoint.y - prevPoint.y);
    control.center = newCenter;
    prevPoint = newPoint;
}


@end
