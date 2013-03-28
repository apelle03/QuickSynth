//
//  QSViewController.m
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSViewController.h"

@implementation QSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundItems = [[NSMutableDictionary alloc] init];
    modifierIetms = [[NSMutableDictionary alloc] init];
	score = [[QSScore alloc] init];
    audioController = [[QSAudioController alloc] init];
    //[audioController initSound];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            int soundID = [[score addSound] intValue];
            
            // Add sound module to view
            UIButton *soundModule = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [soundModule setFrame:control.frame];
            [soundModule setTag:soundID];
            [soundModule setTitle:[NSString stringWithFormat:@"%d", soundID] forState:UIControlStateNormal];
            [soundModule addTarget:self action:@selector(scoreModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
            [soundModule addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
            [soundModule addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
            [soundModule addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            [soundModule addTarget:self action:@selector(scoreModuleReleased:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view insertSubview:soundModule aboveSubview:control];
            [soundItems setObject:soundModule forKey:[NSNumber numberWithInt:soundID]];
            
            // Set sound default properties
            QSSound *sound = [score getSoundForID:[NSNumber numberWithInt:soundID]];
            sound.startTime = [NSNumber numberWithFloat:(soundModule.frame.origin.x / 100)];
            sound.duration = [NSNumber numberWithFloat:1];
            sound.frequency = [NSNumber numberWithFloat:440];
        } else if (control == envelopeModule) {
            for (UIButton *sound in [soundItems allValues]) {
                if (CGRectIntersectsRect(control.frame, sound.frame)) {// && [[score getSoundIDs] containsObject:[NSNumber numberWithInt:control.tag]]) {
                    int modifierID = [[score addModifierToSound:[NSNumber numberWithInt:sound.tag]] intValue];
                    UIButton *modifier = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [modifier setTag:modifierID];
                    [modifier setTitle:[NSString stringWithFormat:@"%d", modifierID] forState:UIControlStateNormal];
                    //[modifier addTarget:self action:@selector(scoreModulePressed:withEvent:) forControlEvents:UIControlEventTouchDown];
                    //[modifier addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
                    //[modifier addTarget:self action:@selector(scoreModuleMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
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
        }
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
    UIControl *control = sender;
    NSNumber *moduleID = [NSNumber numberWithInteger:control.tag];
    QSSound *sound = [score getSoundForID:moduleID];
    sound.startTime = [NSNumber numberWithFloat:(control.frame.origin.x / 100)];
}

- (IBAction)playClicked:(id)sender
{
    [audioController initSoundWithScore:score];
    //[audioController initSound];
    [audioController playSound];
}

- (IBAction)stopClicked:(id)sender
{
    [audioController stopSound];
}


@end
