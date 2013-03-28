//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSScore.h"
#import "QSSound.h"
#import "QSAudioPlayer.h"
#import "QSAudioController.h"

@interface QSViewController : UIViewController {
    IBOutlet UIImageView *toolbox;
    IBOutlet UIScrollView *scoreView;
    IBOutlet UIButton *waveformGeneratorAnchor, *waveformGeneratorModule;
    IBOutlet UIButton *envelopeAnchor, *envelopeModule;
    
    CGPoint prevPoint;
    
    NSMutableDictionary *soundItems;
    NSMutableDictionary *modifierIetms;
    
    QSScore *score;
    
    QSAudioController *audioController;
}

@end
