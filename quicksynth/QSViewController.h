//
//  QSViewController.h
//  quicksynth
//
//  Created by Andrew on 3/11/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSViewController : UIViewController {
    IBOutlet UIImageView *toolbox;
    IBOutlet UIButton *waveformGeneratorAnchor, *waveformGeneratorModule;
    IBOutlet UIButton *envelopeAnchor, *envelopeModule;
    
    CGPoint prevPoint;
    int buttonNum;
}

- (IBAction)toolboxModulePressed:(id)sender withEvent:(UIEvent *)event;
- (IBAction)scoreModulePressed:(id)sender withEvent:(UIEvent *)event;

@end
