//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSScoreView.h"
#import "QSSoundPopoverController.h"

#import "QSScore.h"
#import "QSSound.h"
#import "QSAudioEngine.h"

@interface QSViewController : UIViewController {
    IBOutlet UIImageView *toolbox;
    IBOutlet QSScoreView *scoreView;
    IBOutlet UIButton *waveformGeneratorAnchor, *waveformGeneratorModule;
    IBOutlet UIButton *envelopeAnchor, *envelopeModule;
    
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *trash, *save;
    
    float snapFraction;
    
    CGPoint prevPoint;
    Boolean moved;
    
    NSMutableDictionary *soundItems;
    NSMutableDictionary *modifierIetms;
}

@property (nonatomic, retain) QSScore *score;
@property (nonatomic, retain) QSAudioEngine *audioEngine;

@property (nonatomic, retain) QSSoundPopoverController *_soundDetails;
@property (nonatomic, retain) UIPopoverController *_soundDetailsController;

@end
