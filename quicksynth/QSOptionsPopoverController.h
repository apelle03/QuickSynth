//
//  QSOptionsPopoverController.h
//  quicksynth
//
//  Created by Andrew on 4/13/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapSize.h"

@interface QSOptionsPopoverController : UIViewController {
    IBOutlet UISlider *bpmSlider;
    IBOutlet UITextField *bpmText;
    IBOutlet UISegmentedControl *snapSelector;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;

@property (nonatomic, assign) UIPopoverController *container;

- (void)setBPM:(float)bpm;
- (float)getBPM;

- (void)setSnapSize:(SnapSize)size;
- (SnapSize)getSnapSize;

@end
