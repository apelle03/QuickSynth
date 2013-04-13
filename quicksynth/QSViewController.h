//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSScoreView.h"

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
    
    CGPoint prevPoint;
    
    NSMutableDictionary *soundItems;
    NSMutableDictionary *modifierIetms;
    
    QSScore *score;
}

@property (readwrite) QSAudioEngine *audioEngine;

@end
