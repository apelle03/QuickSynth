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

@synthesize _helpScreen;

@synthesize _options;
@synthesize _optionsController;

@synthesize _waveformDetails;
@synthesize _pulseDetails;
@synthesize _soundDetailsController;
@synthesize _soundDetailsButton;

@synthesize _envelopeDetails;
@synthesize _filterDetails;
@synthesize _modifierDetailsController;
@synthesize _modifierDetailsButton;

@synthesize _resetZeroGesture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundItems = [[NSMutableDictionary alloc] init];
    modifierIetms = [[NSMutableDictionary alloc] init];
	score = [[QSScore alloc] init];

    audioEngine = [[QSAudioEngine alloc] init];
    audioEngine.score = score;
    
    snapFraction = .25;
    
    // Help Screen
    _helpScreen = [[QSHelpViewController alloc] init];

    // General Options Popover
    _options = [[QSOptionsPopoverController alloc] init];
    _optionsController = [[UIPopoverController alloc] initWithContentViewController:_options];
    [_optionsController setPopoverContentSize:_options.view.frame.size];
    
    // Sound Details Popover
    _waveformDetails = [[QSWaveformPopover alloc] init];
    _pulseDetails = [[QSPulsePopover alloc] init];
    
    _soundDetailsController = [[UIPopoverController alloc] initWithContentViewController:_waveformDetails];
    
    // Modifier Details Popover
    _envelopeDetails = [[QSEnvelopePopover alloc] init];
    _filterDetails = [[QSFilterPopover alloc] init];
    
    _modifierDetailsController = [[UIPopoverController alloc] initWithContentViewController:_envelopeDetails];
    
    _resetZeroGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetZero:)];
    [_resetZeroGesture setNumberOfTapsRequired:2];
    [_resetZeroGesture setNumberOfTouchesRequired:1];
    [scoreView addGestureRecognizer:_resetZeroGesture];
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

- (void)snapToGrid:(QSModifierButton*)modifier forSoundButton:(QSSoundButton*)sound
{
    float start = MAX([scoreView getX: modifier.frame.origin.x ForFraction: snapFraction], sound.frame.origin.x);
    float end = MIN([scoreView getX: modifier.frame.origin.x + modifier.frame.size.width ForFraction: snapFraction],
                    sound.frame.origin.x + sound.frame.size.width);
    [modifier setFrame:CGRectMake(start, modifier.frame.origin.y, end - start, modifier.frame.size.height)];
    [self setModifierPercents:modifier forSoundButton:sound];
}

- (void) setModifierPercents:(QSModifierButton*)modifier forSoundButton:(QSSoundButton*)sound
{
    modifier.modifier.startPercent = (modifier.frame.origin.x - sound.frame.origin.x) / sound.frame.size.width;
    modifier.modifier.endPercent = (modifier.frame.origin.x + modifier.frame.size.width - sound.frame.origin.x) / sound.frame.size.width;
}

//---------------------------------------------------------------------------------------------------------------------------------------
// TOOLOX MODUE MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)toolboxModulePressed:(id)sender withEvent:(UIEvent *)event
{
    soundPrevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    [self.view bringSubviewToFront:sender];
}

- (IBAction)toolboxModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    CGPoint newCenter;
    newCenter.x = control.center.x + (newPoint.x - soundPrevPoint.x);
    newCenter.y = control.center.y + (newPoint.y - soundPrevPoint.y);
    control.center = newCenter;
    soundPrevPoint = newPoint;
}

- (IBAction)toolboxModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    UIControl *control = sender;
    
    if (CGRectIntersectsRect(control.frame, scoreView.frame) && !CGRectIntersectsRect(control.frame, trash.frame)) {
        if (control == waveformGeneratorModule || control == pulseGeneratorModule) {// || control == noiseGeneratorModule) {
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
                // Set sound default properties
                QSPulse *sound = (QSPulse*)[score getSoundForID:soundID];
                sound.frequency = 440;
                sound.duty = .5;
                sound.gain = .25;
                soundButton = [[QSPulseButton alloc] initWithFrame:control.frame];
            } /*else if (control == noiseGeneratorModule) {
                soundID = [score addNoise];
            }*/
#warning TODO: add types
            
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
            
        } else if (control == envelopeModule || control == filterModule) {
            for (QSSoundButton *soundButton in [soundItems allValues]) {
                if (CGRectIntersectsRect(control.frame, soundButton.frame)) {
                    NSNumber *soundID = soundButton.sound.ID;
                    NSNumber *modifierID;
                    QSModifierButton *modifierButton;
                    if (control == envelopeModule) {
                        int modNum = [score getModifiersForSound:soundID].count;
                        modifierID = [score addEnvelopeToSound:soundID];
                        // Set modifier default properties
                        QSEnvelope *modifier = (QSEnvelope*)[score getModifierForSound:soundID withID:modifierID];
                        modifier.startPercent = 0;
                        modifier.endPercent = 1;
                        modifierButton = [[QSEnvelopeButton alloc] initWithFrame:CGRectMake(soundButton.frame.origin.x, soundButton.frame.origin.y + soundButton.frame.size.height + 100 * modNum, soundButton.frame.size.width, 200)];
                    } else if (control == filterModule) {
                        int modNum = [score getModifiersForSound:soundID].count;
                        modifierID = [score addLowPassToSound:soundID];
                        // Set modifier default properties
                        QSFilter *modifier = (QSFilter*)[score getModifierForSound:soundID withID:modifierID];
                        modifier.startPercent = 0;
                        modifier.endPercent = 1;
                        modifierButton = [[QSFilterButton alloc] initWithFrame:CGRectMake(soundButton.frame.origin.x, soundButton.frame.origin.y + soundButton.frame.size.height + 100 * modNum, soundButton.frame.size.width, 200)];
                    }
                    
                    // Add modifier button to view
                    modifierButton.modifier = [score getModifierForSound:soundID withID:modifierID];
                    [modifierButton setTag:[modifierID intValue]];
                    [modifierButton addTarget:self action:@selector(modifierModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
                    [modifierButton addTarget:self action:@selector(modifierModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
                    [modifierButton addTarget:self action:@selector(modifierModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
                    [modifierButton addTarget:self action:@selector(modifierModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                    [modifierButton addTarget:self action:@selector(modifierModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
                    [self.view insertSubview:modifierButton belowSubview:soundButton];
                    
                    // Add modifier module to scoreView
                    [soundButton addModifierButton:modifierButton];
                    [soundButton placeModifiers];
                    [soundButton.sound updateEnvelope];
                }
            }
        }
        [audioEngine update];
    }
    
    if (control == waveformGeneratorModule) {
        [control setFrame:waveformGeneratorAnchor.frame];
    } else if (control == pulseGeneratorModule) {
        [control setFrame:pulseGeneratorAnchor.frame];
    } else if (control == noiseGeneratorModule) {
        [control setFrame:noiseGeneratorAnchor.frame];
    } else if (control == envelopeModule) {
        [control setFrame:envelopeAnchor.frame];
    } else if (control == filterModule) {
        [audioEngine update];
        [control setFrame:filterAnchor.frame];
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------
// SCORE MODUE MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event
{
    soundPrevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    soundMoved = false;
    QSSoundButton *control = (QSSoundButton*)sender;
    soundFront = false;
    soundBack = false;
    if ([[[event allTouches] anyObject] locationInView:control].x < 20) {
        soundFront = true;
    } else if ([[[event allTouches] anyObject] locationInView:control].x > control.bounds.size.width - 20) {
        soundBack = true;
    }
    [self.view bringSubviewToFront:control];
    for (QSModifierButton *modifier in [control getModifierButtons]) {
        [self.view bringSubviewToFront:modifier];
    }
}

- (IBAction)scoreModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    soundMoved = true;
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    int deltaX = newPoint.x - soundPrevPoint.x;
    int deltaY = newPoint.y - soundPrevPoint.y;
    
    if (!soundFront && !soundBack) {
        CGPoint newCenter;
        newCenter.x = control.center.x + deltaX;
        newCenter.y = control.center.y + deltaY;
        control.center = newCenter;
    } else if (soundFront) {
        [control setFrame:CGRectMake(control.frame.origin.x + deltaX, control.frame.origin.y + deltaY,
                                     control.frame.size.width - deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    } else if (soundBack) {
        [control setFrame:CGRectMake(control.frame.origin.x, control.frame.origin.y + deltaY,
                                     control.frame.size.width + deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    }
    soundPrevPoint = newPoint;
}

- (IBAction)scoreModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    QSSoundButton *control = sender;
    
    if (!soundMoved) {
        _soundDetailsButton = control;
        if ([control isKindOfClass:[QSWaveformButton class]]) {
            [_soundDetailsController setContentViewController:_waveformDetails];
            [_waveformDetails setWaveType:((QSWaveform*)control.sound).waveType];
            [_waveformDetails setFrequency:((QSWaveform*)control.sound).frequency];
            [_waveformDetails setGain:((QSWaveform*)control.sound).gain];
            [_waveformDetails.apply addTarget:self action:@selector(soundDetailsApplied:) forControlEvents:UIControlEventTouchUpInside];
            [_waveformDetails.cancel addTarget:self action:@selector(soundDetailsCancelled:) forControlEvents:UIControlEventTouchUpInside];
            [_soundDetailsController setPopoverContentSize:_waveformDetails.size];
        } else if ([control isKindOfClass:[QSPulseButton class]]) {
            [_soundDetailsController setContentViewController:_pulseDetails];
            [_pulseDetails setDuty:((QSPulse*)control.sound).duty];
            [_pulseDetails setFrequency:((QSPulse*)control.sound).frequency];
            [_pulseDetails setGain:((QSPulse*)control.sound).gain];
            [_pulseDetails.apply addTarget:self action:@selector(soundDetailsApplied:) forControlEvents:UIControlEventTouchUpInside];
            [_pulseDetails.cancel addTarget:self action:@selector(soundDetailsCancelled:) forControlEvents:UIControlEventTouchUpInside];
            [_soundDetailsController setPopoverContentSize:_pulseDetails.size];
        }/* else if ([control isKindOfClass:[qsNoiseButton class]]) {
            
        }
        */
#warning TODO: add types here
        
        [_soundDetailsController presentPopoverFromRect:control.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:true];
        
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
        for (QSModifierButton *modifier in [control getModifierButtons]) {
            [modifier removeFromSuperview];
            [self.view insertSubview:modifier belowSubview:toolbar];
        }
    } else if (CGRectIntersectsRect(trash.frame, control.frame) || CGRectContainsRect(toolbox.frame, control.frame)) {
        [score removeSoundForID:control.sound.ID];
        for (QSModifierButton *modifierButton in [control getModifierButtons]) {
            [modifierButton removeFromSuperview];
        }
        [soundItems removeObjectForKey:control.sound.ID];
        [control removeFromSuperview];
        [audioEngine update];
    } else {
        [self snapToGrid:control];
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
        for (QSModifierButton *modifier in [control getModifierButtons]) {
            [modifier removeFromSuperview];
            [self.view insertSubview:modifier belowSubview:toolbar];
        }
        if (control.sound.duration == 0) {
            if (soundFront) {
                control.frame = CGRectMake(control.frame.origin.x - [scoreView getWidthForDuration:snapFraction], control.frame.origin.y,
                                           [scoreView getWidthForDuration:snapFraction], control.frame.size.height);
            } else {
                control.frame = CGRectMake(control.frame.origin.x, control.frame.origin.y,
                                           [scoreView getWidthForDuration:snapFraction], control.frame.size.height);
            }
            [self snapToGrid:control];
        }
        [control setNeedsDisplay];
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------
// MODIFIER MODUE MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)modifierModulePressed:(id)sender withEvent:(UIEvent *)event
{
    modifierPrevPoint = [[[event allTouches] anyObject] locationInView:self.view];
    modifierMoved = false;
    UIControl *control = (UIControl*)sender;
    modifierFront = false;
    modifierBack = false;
    if ([[[event allTouches] anyObject] locationInView:control].x < 20) {
        modifierFront = true;
    } else if ([[[event allTouches] anyObject] locationInView:control].x > control.bounds.size.width - 20) {
        modifierBack = true;
    }
    [self.view bringSubviewToFront:control];
}

- (IBAction)modifierModuleMoved:(id)sender withEvent:(UIEvent *)event
{
    modifierMoved = true;
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    int deltaX = newPoint.x - modifierPrevPoint.x;
    int deltaY = newPoint.y - modifierPrevPoint.y;
    
    if (!modifierFront && !modifierBack) {
        CGPoint newCenter;
        newCenter.x = control.center.x + deltaX;
        newCenter.y = control.center.y + deltaY;
        control.center = newCenter;
    } else if (modifierFront) {
        [control setFrame:CGRectMake(control.frame.origin.x + deltaX, control.frame.origin.y + deltaY,
                                     control.frame.size.width - deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    } else if (modifierBack) {
        [control setFrame:CGRectMake(control.frame.origin.x, control.frame.origin.y + deltaY,
                                     control.frame.size.width + deltaX, control.frame.size.height)];
        [control setNeedsDisplay];
    }
    modifierPrevPoint = newPoint;
}

- (IBAction)modifierModuleReleased:(id)sender withEvent:(UIEvent *)event
{
    QSModifierButton *control = sender;
    
    if (!modifierMoved) {
        _modifierDetailsButton = control;
        if ([control isKindOfClass:[QSEnvelopeButton class]]) {
            [_modifierDetailsController setContentViewController:_envelopeDetails];
            
            [_envelopeDetails setAPos:((QSEnvelope*)control.modifier).aLen];
            [_envelopeDetails setDPos:((QSEnvelope*)control.modifier).aLen + ((QSEnvelope*)control.modifier).dLen];
            [_envelopeDetails setSPos:((QSEnvelope*)control.modifier).aLen + ((QSEnvelope*)control.modifier).dLen + ((QSEnvelope*)control.modifier).sLen];
            [_envelopeDetails setStartVal:((QSEnvelope*)control.modifier).startMag];
            [_envelopeDetails setAVal:((QSEnvelope*)control.modifier).aMag];
            [_envelopeDetails setDVal:((QSEnvelope*)control.modifier).dMag];
            [_envelopeDetails setSVal:((QSEnvelope*)control.modifier).sMag];
            [_envelopeDetails setEndVal:((QSEnvelope*)control.modifier).endMag];
            [_envelopeDetails setMax:1];
            [_envelopeDetails setMin:0];
            
            [_envelopeDetails.apply addTarget:self action:@selector(modifierDetailsApplied:) forControlEvents:UIControlEventTouchUpInside];
            [_envelopeDetails.cancel addTarget:self action:@selector(modifierDetailsCancelled:) forControlEvents:UIControlEventTouchUpInside];
            [_modifierDetailsController setPopoverContentSize:_envelopeDetails.size];
        } else if ([control isKindOfClass:[QSFilterButton class]]) {
            [_modifierDetailsController setContentViewController:_filterDetails];
            
            [_filterDetails setFilterType:((QSFilter*)control.modifier).type];
            [_filterDetails setFrequency:((QSFilter*)control.modifier).freq];
            [_filterDetails setBandwidth:((QSFilter*)control.modifier).bandwidth];
            
            [_filterDetails.apply addTarget:self action:@selector(modifierDetailsApplied:) forControlEvents:UIControlEventTouchUpInside];
            [_filterDetails.cancel addTarget:self action:@selector(modifierDetailsCancelled:) forControlEvents:UIControlEventTouchUpInside];
            [_modifierDetailsController setPopoverContentSize:_filterDetails.size];
        }
#warning TODO: add types here
        [_modifierDetailsController presentPopoverFromRect:control.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:true];
        
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
    } else if (CGRectIntersectsRect(trash.frame, control.frame) || CGRectContainsRect(toolbox.frame, control.frame)) {
        [score removeModifierForSound:control.modifier.soundID withID:control.modifier.ID];
        [[soundItems objectForKey:control.modifier.soundID] removeModifierButton:control];
        [[soundItems objectForKey:control.modifier.soundID] placeModifiers];
        [((QSSoundButton*)[soundItems objectForKey:control.modifier.soundID]).sound updateEnvelope];
        [control removeFromSuperview];
        [audioEngine update];
    } else {
        [self snapToGrid:control forSoundButton:[soundItems objectForKey:control.modifier.soundID]];
        [control removeFromSuperview];
        [self.view insertSubview:control belowSubview:toolbar];
        [[soundItems objectForKey:control.modifier.soundID] placeModifiers];
        [((QSSoundButton*)[soundItems objectForKey:control.modifier.soundID]).sound updateEnvelope];
        [control setNeedsDisplay];
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------
// SCORE VIEW MOVEMENT
//---------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)scoreViewPressed:(id)sender withEvent:(UIEvent *)event
{
    soundPrevPoint = [[[event allTouches] anyObject] locationInView:self.view];
}

- (IBAction)scoreViewMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self.view];
    int deltaX = newPoint.x - soundPrevPoint.x;
    int deltaY = newPoint.y - soundPrevPoint.y;
    [scoreView scroll:CGPointMake(deltaX, deltaY)];
    soundPrevPoint = newPoint;
}

- (IBAction)scoreViewReleased:(id)sender withEvent:(UIEvent *)event
{
    
}

- (void)resetZero:(UITapGestureRecognizer*)recognizer
{
    CGPoint tap = [recognizer locationInView:scoreView];
    int x = [scoreView getX:tap.x ForFraction:snapFraction];
    [scoreView resetZero:x];
    [scoreView setNeedsDisplay];
    for (QSSoundButton *button in [soundItems allValues]) {
        [self snapToGrid:button];
    }
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

- (IBAction)helpClicked:(id)sender
{
    [_helpScreen setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:_helpScreen animated:true completion:^{}];
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
    } else if ([_soundDetailsButton isKindOfClass:[QSPulseButton class]]) {
        ((QSPulse*)_soundDetailsButton.sound).duty = [_pulseDetails getDuty];
        ((QSPulse*)_soundDetailsButton.sound).frequency = [_pulseDetails getFrequency];
        ((QSPulse*)_soundDetailsButton.sound).gain = [_pulseDetails getGain];
    }
#warning TODO: add other types
    
    [_soundDetailsButton setNeedsDisplay];
    [_soundDetailsButton.sound updateEnvelope];
    _soundDetailsButton = nil;
}

- (IBAction)soundDetailsCancelled:(id)sender
{
    [_soundDetailsController dismissPopoverAnimated:true];
    _soundDetailsButton = nil;
}

- (IBAction)modifierDetailsApplied:(id)sender
{
    [_modifierDetailsController dismissPopoverAnimated:true];
    if ([_modifierDetailsButton isKindOfClass:[QSEnvelopeButton class]]) {
        ((QSEnvelope*)_modifierDetailsButton.modifier).aLen = [_envelopeDetails getAPos];
        ((QSEnvelope*)_modifierDetailsButton.modifier).dLen = [_envelopeDetails getDPos] - [_envelopeDetails getAPos];
        ((QSEnvelope*)_modifierDetailsButton.modifier).sLen = [_envelopeDetails getSPos] - [_envelopeDetails getDPos];
        ((QSEnvelope*)_modifierDetailsButton.modifier).startMag = [_envelopeDetails getStartVal];
        ((QSEnvelope*)_modifierDetailsButton.modifier).aMag = [_envelopeDetails getAVal];
        ((QSEnvelope*)_modifierDetailsButton.modifier).dMag = [_envelopeDetails getDVal];
        ((QSEnvelope*)_modifierDetailsButton.modifier).sMag = [_envelopeDetails getSVal];
        ((QSEnvelope*)_modifierDetailsButton.modifier).endMag = [_envelopeDetails getEndVal];
    } else if ([_modifierDetailsButton isKindOfClass:[QSFilterButton class]]) {
        ((QSFilter*)_modifierDetailsButton.modifier).type = [_filterDetails getFilterType];
        ((QSFilter*)_modifierDetailsButton.modifier).freq = [_filterDetails getFrequency];
        ((QSFilter*)_modifierDetailsButton.modifier).bandwidth = [_filterDetails getBandwidth];
        [audioEngine update];
    }
#warning TODO: add other types
    [_modifierDetailsButton setNeedsDisplay];
    [((QSSoundButton*)[soundItems objectForKey:_modifierDetailsButton.modifier.soundID]).sound updateEnvelope];
    _modifierDetailsButton = nil;
}

- (IBAction)modifierDetailsCancelled:(id)sender
{
    [_modifierDetailsController dismissPopoverAnimated:true];
    _modifierDetailsButton = nil;
}

@end
