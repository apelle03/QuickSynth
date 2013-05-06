//
//  QSFilterPopover.h
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSSimpleSlider.h"
#import "QSNoteSlider.h"
#import "QSADSRSlider.h"

#import "FilterType.h"

@interface QSFilterPopover : UIViewController {
    IBOutlet UISegmentedControl *typeSelector;
    IBOutlet QSNoteSlider *freqSlider;
    IBOutlet QSSimpleSlider *bandwidthSlider;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;
@property (nonatomic, readonly) CGSize size;

- (void)setFilterType:(FilterType)type;
- (FilterType)getFilterType;

- (void)setFrequency:(float)frequency;
- (float)getFrequency;

- (void)setBandwidth:(float)bandwidth;
- (float)getBandwidth;

@end
