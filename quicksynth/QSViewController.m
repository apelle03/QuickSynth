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

@synthesize _soundDetails;
@synthesize _soundDetailsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundItems = [[NSMutableDictionary alloc] init];
    modifierIetms = [[NSMutableDictionary alloc] init];
	score = [[QSScore alloc] init];
    
    audioEngine = [[QSAudioEngine alloc] init];
    audioEngine.score = score;
    
    snapFraction = .25;
    
    _options = [[QSOptionsPopoverController alloc] init];
    _optionsController = [[UIPopoverController alloc] initWithContentViewController:_options];
    _options.container = _optionsController;
    [_options.apply addTarget:self action:@selector(optionsApplied:) forControlEvents:UIControlEventTouchUpInside];
    [_options.cancel addTarget:self action:@selector(optionsCancelled:) forControlEvents:UIControlEventTouchUpInside];
    [_optionsController setPopoverContentSize:_options.view.frame.size];
    
    _soundDetails = [[QSSoundPopoverController alloc] init];
    _soundDetailsController = [[UIPopoverController alloc] initWithContentViewController:_soundDetails];
    _soundDetails.container = _soundDetailsController;
    [_soundDetailsController setPopoverContentSize:_soundDetails.view.frame.size];
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
            sound.waveType = SINE;
            sound.gain = .25;
            
            // Add sound button to view
            QSSoundButton *soundButton = [[QSSoundButton alloc] initWithFrame:control.frame];
            soundButton.sound = sound;
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

- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event
{
    prevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    moved = false;
    UIControl *control = (UIControl*)sender;
    [self.view bringSubviewToFront:control];
}

- (IBAction)scoreModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    moved = true;
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
    
    if (!moved) {
        _soundDetails.sound = control.sound;
        [_soundDetails setWaveType:control.sound.waveType];
        [_soundDetails setFrequency:control.sound.frequency];
        [_soundDetails setGain:control.sound.gain];
        [_soundDetailsController presentPopoverFromRect:control.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:true];
    } else if (CGRectContainsPoint(deleteFrame, touchPoint)) {
        [score removeSoundForID:control.sound.ID];
        [control removeFromSuperview];
        [audioEngine update];
    } else if (CGRectContainsPoint(saveFrame, touchPoint)) {
    } else {
        control.sound.startTime = [scoreView getStartTimeForX:control.frame.origin.x];
        [self snapToGrid:control];
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

- (IBAction)optionsClicked:(id)sender
{
    [_optionsController presentPopoverFromBarButtonItem:option permittedArrowDirections:UIPopoverArrowDirectionDown animated:true];
}

- (IBAction)optionsApplied:(id)sender
{
    [_optionsController dismissPopoverAnimated:true];
    scoreView.bpm = [_options getBPM];
    snapFraction = snapToFraction([_options getSnapSize]);
    for (QSSoundButton *button in [soundItems allValues]) {
        button.sound.startTime = [scoreView getStartTimeForX:button.frame.origin.x];
        button.sound.duration = [scoreView getDurationForWidth:button.frame.size.width];
    }
}

- (IBAction)optionsCancelled:(id)sender
{
    [_optionsController dismissPopoverAnimated:true];
    [_options setBPM:scoreView.bpm];
    [_options setSnapSize:fractionToSnap(snapFraction)];
}

float snapToFraction(SnapSize size) {
    switch (size) {
        case WHOLE:
            return 1;
        case HALF:
            return .5;
        case THIRD:
            return 1.0/3;
        case QUARTER:
            return .25;
        case EIGTH:
            return .125;
        case SIXTEENTH:
            return .0625;
            
        default:
            return 1;
    }
}

SnapSize fractionToSnap(float fraction) {
    if (fabsf(fraction - 1) < .001) {
        return WHOLE;
    } else if (fabsf(fraction - .5) < .001) {
        return HALF;
    } else if (fabsf(fraction - (1.0/3)) < .001) {
        return THIRD;
    } else if (fabsf(fraction - .25) < .001) {
        return QUARTER;
    } else if (fabsf(fraction - .125) < .001) {
        return EIGTH;
    } else if (fabsf(fraction - .0625) < .001) {
        return SIXTEENTH;
    } else {
        return WHOLE;
    }
}

@end
