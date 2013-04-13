//
//  QSSoundButton.h
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSSound.h"

@interface QSSoundButton : UIControl

@property (nonatomic, retain) QSSound *sound;

@property (nonatomic, retain) UIBezierPath *_border;

@end
