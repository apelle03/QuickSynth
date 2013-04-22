//
//  QSViewController.m
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSViewController.h"

@implementation QSViewController

@synthesize score;
@synthesize audioEngine;

@synthesize _options;
@synthesize _optionsController;

@synthesize _waveformDetails;
@synthesize _soundDetailsController;
@synthesize _soundDetailsButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundItems = [[NSMutableDictionary alloc] init];
    modifierIetms = [[NSMutableDictionary alloc] init];
	score = [[QSScore alloc] init];
    
    audioEngine = [[QSAudioEngine alloc] init];
    audioEngine.score = score;
    
    snapFraction = .25;

    // General Options Popover
    _options = [[QSOptionsPopoverController alloc] init];
    _optionsController = [[UIPopoverController alloc] initWithContentViewController:_options];
    [_optionsController setPopoverContentSize:_options.view.frame.size];
    
    // Sound Details Popover
    _waveformDetails = [[QSWaveformPopover alloc] init];
    
    _soundDetailsController = [[UIPopoverController alloc] initWithContentViewController:_waveformDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)snapToGrid:(QSSoundButton*)button
{
    float start = [scoreView getX: button.frame.origin.x
                      ForFraction: snapFraction];
    float end = [scoreView getX: button.frame.origin.x + button.frame.size.width
                    ForFraction: snapFraction];
    [button setFrame:CGRectMake(start, button.frame.origin.y, end - start, button.frame.size.height)];
    
    [self setSoundTimes:button];
}

- (void)setSoundTimes:(QSSoundButton*)button
{
    button.sound.startTime = [scoreView getStartTimeForX:button.frame.origin.x];
    button.sound.duration = [scoreView getDurationForWidth:button.frame.size.width];
}

//---------------------------------------------------------------------------------------------------------------------------------------
// TOOLOX MODUE MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

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
        if (control == waveformGeneratorModule || control == pulseGeneratorModule || control == noiseGeneratorModule) {
            // Add sound to score
            NSNumber *soundID;
            QSSoundButton *soundButton;
            if (control == waveformGeneratorModule) {
                soundID = [score addWaveform];
                // Set sound default properties
                QSWaveform *sound = (QSWaveform*)[score getSoundForID:soundID];
                sound.frequency = 440;
                sound.waveType = SINE;
                sound.gain = .25;
                soundButton = [[QSWaveformButton alloc] initWithFrame:control.frame];
            } else if (control == pulseGeneratorModule) {
                soundID = [score addPulse];
            } else if (control == noiseGeneratorModule) {
                soundID = [score addNoise];
            }
            
            // Add sound button to view
            soundButton.sound = [score getSoundForID:soundID];
            [soundButton setTag:[soundID intValue]];
            [soundButton addTarget:self action:@selector(scoreModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
            [soundButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
            [soundButton addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
            [soundButton addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            [soundButton addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
            [self snapToGrid:soundButton];
            [self.view insertSubview:soundButton belowSubview:toolbar];
            
            // Add sound module to soundItems and scoreView
            [soundItems setObject:soundButton forKey:soundID];
            [scoreView addObject:soundButton forKey:soundID];
            
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

//---------------------------------------------------------------------------------------------------------------------------------------
// SCORE MODUE MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    moved = false;
    UIControl *control = (UIControl*)sender;
    front = false;
    back = false;
    if ([[[event allTouches] anyObject] locationInView:control].x < 20) {
        front = true;
    } else if ([[[event allTouches] anyObject] locationInView:control].x > control.bounds.size.width - 20) {
        back = true;
    }
    [self.view bringSubviewToFront:control];
}

- (IBAction)scoreModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    moved = true;
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    int deltaX = newPoint.x - prevPoint.x;
    int deltaY = newPoint.y - prevPoint.y;
    
    if (!front && !back) {
        CGPoint newCenter;
        newCenter.x = control.center.x + deltaX;
        newCenter.y = control.center.y + deltaY;
        control.center = newCenter;
    } else if (front) {
        [control setFrame:CGRectMake(control.frame.origin.x + deltaX, control.frame.origin.y + deltaY,
                                     control.frame.size.width - deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    } else if (back) {
        [control setFrame:CGRectMake(control.frame.origin.x, control.frame.origin.y + deltaY,
                                     control.frame.size.width + deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    }
    
    /*
    for (QSModifier *modifier in [[score getSoundForID:[NSNumber numberWithInt:control.tag]] getModifiers]) {
        UIButton *modifierView = [modifierIetms objectForKey:modifier.ID];
        CGPoint newCenter;
        newCenter.x = modifierView.center.x + deltaX;
        newCenter.y = modifierView.center.y + deltaY;
        modifierView.center = newCenter;
    }
    */
    prevPoint = newPoint;
}

- (IBAction)scoreModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    QSSoundButton *control = sender;
    
    CGPoint touchPoint = [[[event touchesForView:control] anyObject] locationInView:self.view];
    CGRect deleteFrame = ((UIView*)toolbar.subviews[5]).frame;
    CGRect saveFrame = ((UIView*)toolbar.subviews[6]).frame;
    
    if (!moved) {
        _soundDetailsButton = control;
        if ([control isKindOfClass:[QSWaveformButton class]]) {
            [_waveformDetails setWaveType:((QSWaveform*)control.sound).waveType];
            [_waveformDetails setFrequency:((QSWaveform*)control.sound).frequency];
            [_waveformDetails setGain:((QSWaveform*)control.sound).gain];
            [_waveformDetails.apply addTarget:self action:@selector(soundDetailsApplied:) forControlEvents:UIControlEventTouchUpInside];
            [_waveformDetails.cancel addTarget:self action:@selector(soundDetailsCancelled:) forControlEvents:UIControlEventTouchUpInside];
            [_soundDetailsController setContentViewController:_waveformDetails];
            [_soundDetailsController setPopoverContentSize:_waveformDetails.view.bounds.size];
        }/* else if ([control isKindOfClass:[QSPulseButton class]]) {
            
        } else if ([control isKindOfClass:[qsNoiseButton class]]) {
            
        }
        */
        
        [_soundDetailsController presentPopoverFromRect:control.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:true];
        
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
    } else if (CGRectContainsPoint(deleteFrame, touchPoint)) {
        [score removeSoundForID:control.sound.ID];
        [control removeFromSuperview];
        [audioEngine update];
    } else if (CGRectContainsPoint(saveFrame, touchPoint)) {
    } else {
        [self snapToGrid:control];
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
        [control setNeedsDisplay];
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------
// SCORE VIEW MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

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

//---------------------------------------------------------------------------------------------------------------------------------------
// TOOLBAR ITEM ACTIONS
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)playClicked:(id)sender
{
    [audioEngine play];
}

- (IBAction)stopClicked:(id)sender
{
    [audioEngine stop];
}

- (IBAction)optionsClicked:(id)sender
{
    [_options.apply addTarget:self action:@selector(optionsApplied:) forControlEvents:UIControlEventTouchUpInside];
    [_options.cancel addTarget:self action:@selector(optionsCancelled:) forControlEvents:UIControlEventTouchUpInside];
    [_optionsController presentPopoverFromBarButtonItem:option permittedArrowDirections:UIPopoverArrowDirectionDown animated:true];
}

//---------------------------------------------------------------------------------------------------------------------------------------
// POPUPS CLOSED
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)optionsApplied:(id)sender
{
    [_optionsController dismissPopoverAnimated:true];
    scoreView.bpm = [_options getBPM];
    snapFraction = [QSSnapSize snapToFraction:[_options getSnapSize]];
    for (QSSoundButton *button in [soundItems allValues]) {
        button.sound.startTime = [scoreView getStartTimeForX:button.frame.origin.x];
        button.sound.duration = [scoreView getDurationForWidth:button.frame.size.width];
    }
    [scoreView setNeedsDisplay];
}

- (IBAction)optionsCancelled:(id)sender
{
    [_optionsController dismissPopoverAnimated:true];
    [_options setBPM:scoreView.bpm];
    [_options setSnapSize:[QSSnapSize fractionToSnap:snapFraction]];
}

- (IBAction)soundDetailsApplied:(id)sender
{
    [_soundDetailsController dismissPopoverAnimated:true];
    if ([_soundDetailsButton isKindOfClass:[QSWaveformButton class]]) {
        ((QSWaveform*)_soundDetailsButton.sound).waveType = [_waveformDetails getWaveType];
        ((QSWaveform*)_soundDetailsButton.sound).frequency = [_waveformDetails getFrequency];
        ((QSWaveform*)_soundDetailsButton.sound).gain = [_waveformDetails getGain];
    }
#warning TODO: add other types
    
    [_soundDetailsButton setNeedsDisplay];
    _soundDetailsButton = nil;
}

- (IBAction)soundDetailsCancelled:(id)sender
{
    [_soundDetailsController dismissPopoverAnimated:true];
    _soundDetailsButton = nil;
}

@end
