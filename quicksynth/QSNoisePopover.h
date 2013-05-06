//
//  QSNoisePopover.h
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSSimpleSlider.h"

@interface QSNoisePopover : UIViewController {
    IBOutlet QSSimpleSlider *gainSlider;
}

@property (nonatomic, retain, readonly) IBOutlet UIButton *apply;
@property (nonatomic, retain, readonly) IBOutlet UIButton *cancel;
@property (nonatomic, readonly) CGSize size;

- (void)setGain:(float)gain;
- (float)getGain;

@end
