//
//  QSNoteSlider.h
//  quicksynth
//
//  Created by Andrew on 4/24/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSSimpleSlider.h"

@interface QSNoteSlider : UIView {
    IBOutlet UIView *contentView;
    
    IBOutlet UISlider *noteSlider, *freqSlider;
    IBOutlet UITextField *noteText, *freqText;
}

@property (nonatomic) float value;

- (IBAction)noteSliderChanged:(id)sender;
- (IBAction)freqSliderChanged:(id)sender;
- (IBAction)freqTextChanged:(id)sender;
- (IBAction)freqTextFinalized:(id)sender;

@end
