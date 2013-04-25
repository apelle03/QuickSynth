//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
// UI
#import "QSScoreView.h"
#import "QSOptionsPopoverController.h"

#import "QSSoundButton.h"
#import "QSWaveformButton.h"
#import "QSWaveformPopover.h"
#import "QSPulseButton.h"
#import "QSPulsePopover.h"

#import "QSModifierButton.h"
#import "QSEnvelopeButton.h"

// AUDIO
#import "QSScore.h"

#import "QSSound.h"
#import "QSWaveform.h"
#import "QSPulse.h"

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
    
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *trash, *save, *option;
    
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

@property (nonatomic, retain) QSOptionsPopoverController *_options;
@property (nonatomic, retain) UIPopoverController *_optionsController;

@property (nonatomic, retain) QSWaveformPopover *_waveformDetails;
@property (nonatomic, retain) QSPulsePopover *_pulseDetails;

@property (nonatomic, retain) UIPopoverController *_soundDetailsController;
@property (nonatomic, retain) QSSoundButton *_soundDetailsButton;

@end
