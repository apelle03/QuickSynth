//
//  QSViewController.m
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSViewController.h"

@implementation QSViewController

@synthesize audioEngine;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundItems = [[NSMutableDictionary alloc] init];
    modifierIetms = [[NSMutableDictionary alloc] init];
	score = [[QSScore alloc] init];
    
    audioEngine = [[QSAudioEngine alloc] init];
    audioEngine.score = score;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetViewLayers
{
    [self.view bringSubviewToFront:toolbar];
    [self.view bringSubviewToFront:toolbox];
    [self.view bringSubviewToFront:waveformGeneratorAnchor];
    [self.view bringSubviewToFront:waveformGeneratorModule];
    [self.view bringSubviewToFront:envelopeAnchor];
    [self.view bringSubviewToFront:envelopeModule];
}

- (IBAction)toolboxModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    [self.view bringSubviewToFront:sender];
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
    
    if (CGRectIntersectsRect(control.frame, scoreView.frame)) {
        if (control == waveformGeneratorModule) {
            // Add sound to score
            NSNumber *soundID = [score addSound];
            
            // Set sound default properties
            QSSound *sound = [score getSoundForID:soundID];
            sound.frequency = 440;
            sound.waveType = SIN;
            
            // Add sound button to view
            QSSoundButton *soundButton = [[QSSoundButton alloc] initWithFrame:control.frame];// buttonWithType:UIButtonTypeRoundedRect];
            soundButton.sound = sound;
//            [soundButton setFrame:control.frame];
            [soundButton setTag:[soundID intValue]];
//            [soundButton setTitle:[NSString stringWithFormat:@"%d", [soundID intValue]] forState:UIControlStateNormal];
            [soundButton addTarget:self action:@selector(scoreModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
            [soundButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
            [soundButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
            [soundButton addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            [soundButton addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view insertSubview:soundButton belowSubview:toolbar];
            
            // Add sound module to soundItems and scoreView
            [soundItems setObject:soundButton forKey:soundID];
            [scoreView addObject:soundButton forKey:soundID];
            
            // Set sound non-default properties
            sound.startTime = [scoreView getStartTimeForX:soundButton.frame.origin.x];
            sound.duration = [scoreView getDurationForWidth:soundButton.frame.size.width];
            
        } else if (control == envelopeModule) {
            /*
            for (UIButton *sound in [soundItems allValues]) {
                if (CGRectIntersectsRect(control.frame, sound.frame)) {
                    int modifierID = [[score addModifierToSound:[NSNumber numberWithInt:sound.tag]] intValue];
                    UIButton *modifier = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [modifier setTag:modifierID];
                    [modifier setTitle:[NSString stringWithFormat:@"%d", modifierID] forState:UIControlStateNormal];
                    [self.view insertSubview:modifier aboveSubview:control];
                    [modifierIetms setObject:modifier forKey:[NSNumber numberWithInt:modifierID]];
                    
                    float offsetX = 0;
                    for (QSModifier *m in [[score getSoundForID:[NSNumber numberWithInt:sound.tag]] getModifiers]) {
                        float width = [m.width floatValue];
                        UIButton *mView = [modifierIetms objectForKey:m.ID];
                        [mView setFrame:CGRectMake(sound.frame.origin.x + offsetX, sound.frame.origin.y + sound.frame.size.height,
                                                   sound.frame.size.width * width, 20)];
                        offsetX += sound.frame.size.width * width;
                    }
                }
            }
            */
        }
        [audioEngine update];
    }
    
    if (control == waveformGeneratorModule) {
        [control setFrame:waveformGeneratorAnchor.frame];
    } else if (control == envelopeModule) {
        [control setFrame:envelopeAnchor.frame];
    }
}

- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = (UIControl*)sender;
    [self.view bringSubviewToFront:control];
}

- (IBAction)scoreModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    int deltaX = newPoint.x - prevPoint.x;
    int deltaY = newPoint.y - prevPoint.y;
    CGPoint newCenter;
    newCenter.x = control.center.x + deltaX;
    newCenter.y = control.center.y + deltaY;
    control.center = newCenter;
    
    for (QSModifier *modifier in [[score getSoundForID:[NSNumber numberWithInt:control.tag]] getModifiers]) {
        UIButton *modifierView = [modifierIetms objectForKey:modifier.ID];
        CGPoint newCenter;
        newCenter.x = modifierView.center.x + deltaX;
        newCenter.y = modifierView.center.y + deltaY;
        modifierView.center = newCenter;
    }
    prevPoint = newPoint;
}

- (IBAction)scoreModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    QSSoundButton *control = sender;
    
    CGPoint touchPoint = [[[event touchesForView:control] anyObject] locationInView:self.view];
    CGRect deleteFrame = ((UIView*)toolbar.subviews[5]).frame;
    CGRect saveFrame = ((UIView*)toolbar.subviews[6]).frame;
    
    if (CGRectContainsPoint(deleteFrame, touchPoint)) {
        [score removeSoundForID:control.sound.ID];
        [control removeFromSuperview];
        [audioEngine update];
    } else if (CGRectContainsPoint(saveFrame, touchPoint)) {
    } else {
        control.sound.startTime = [scoreView getStartTimeForX:control.frame.origin.x];
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
    }
}

- (IBAction)scoreViewPressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
}

- (IBAction)scoreViewMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    int deltaX = newPoint.x - prevPoint.x;
    int deltaY = newPoint.y - prevPoint.y;
    [scoreView scroll:CGPointMake(deltaX, deltaY)];
    prevPoint = newPoint;
}

- (IBAction)scoreViewReleased:(id)sender withEvent:(UIEvent *)event
{
    
}

- (IBAction)playClicked:(id)sender
{
    [audioEngine play];
}

- (IBAction)stopClicked:(id)sender
{
    [audioEngine stop];
}

@end
