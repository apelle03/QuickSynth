//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
// UI
#import "QSHelpViewController.h"
#import "QSScoreView.h"
#import "QSOptionsPopoverController.h"

#import "QSSoundButton.h"
#import "QSWaveformButton.h"
#import "QSWaveformPopover.h"
#import "QSPulseButton.h"
#import "QSPulsePopover.h"
#import "QSNoiseButton.h"
#import "QSNoisePopover.h"

#import "QSModifierButton.h"
#import "QSEnvelopeButton.h"
#import "QSEnvelopePopover.h"
#import "QSFilterButton.h"
#import "QSFilterPopover.h"

// AUDIO
#import "QSScore.h"

#import "QSSound.h"
#import "QSWaveform.h"
#import "QSPulse.h"
#import "QSNoise.h"

#import "QSModifier.h"
#import "QSEnvelope.h"

#import "QSAudioEngine.h"

@interface QSViewController : UIViewController {
    IBOutlet UIImageView *toolbox;
    IBOutlet QSScoreView *scoreView;
    // Sound generators
    IBOutlet UIButton *waveformGeneratorAnchor, *waveformGeneratorModule;
    IBOutlet UIButton *pulseGeneratorAnchor, *pulseGeneratorModule;
    IBOutlet UIButton *noiseGeneratorAnchor, *noiseGeneratorModule;
    // Modifiers
    IBOutlet UIButton *envelopeAnchor, *envelopeModule;
    IBOutlet UIButton *filterAnchor, *filterModule;
    
    // Trash
    IBOutlet UIButton *trash;
    
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *option;
    
    float snapFraction;
    
    CGPoint soundPrevPoint;
    Boolean soundMoved, soundFront, soundBack;
    
    CGPoint modifierPrevPoint;
    Boolean modifierMoved, modifierFront, modifierBack;
    
    NSMutableDictionary *soundItems;
    NSMutableDictionary *modifierIetms;
}

@property (nonatomic, retain) QSScore *score;
@property (nonatomic, retain) QSAudioEngine *audioEngine;

@property (nonatomic, retain) QSHelpViewController *_helpScreen;

@property (nonatomic, retain) QSOptionsPopoverController *_options;
@property (nonatomic, retain) UIPopoverController *_optionsController;

#warning TODO: Add declaration of sound and modifier popover controllers here
@property (nonatomic, retain) QSWaveformPopover *_waveformDetails;
@property (nonatomic, retain) QSPulsePopover *_pulseDetails;
@property (nonatomic, retain) QSNoisePopover *_noiseDetails;
@property (nonatomic, retain) UIPopoverController *_soundDetailsController;
@property (nonatomic, retain) QSSoundButton *_soundDetailsButton;

@property (nonatomic, retain) QSEnvelopePopover *_envelopeDetails;
@property (nonatomic, retain) QSFilterPopover *_filterDetails;
@property (nonatomic, retain) UIPopoverController *_modifierDetailsController;
@property (nonatomic, retain) QSModifierButton *_modifierDetailsButton;

@property (nonatomic, retain) UITapGestureRecognizer *_resetZeroGesture;

- (IBAction)toolboxModulePressed:(id)sender withEvent:(UIEvent*)event;
- (IBAction)toolboxModuleMoved:(id)sender withEvent:(UIEvent*)event;
- (IBAction)toolboxModuleReleased:(id)sender withEvent:(UIEvent*)event;

- (IBAction)helpClicked:(id)sender;

@end
