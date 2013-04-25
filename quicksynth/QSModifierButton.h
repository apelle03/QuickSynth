//
//  QSModifierButton.h
//  quicksynth
//
//  Created by Andrew on 4/25/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSButton.h"
#import "QSModifier.h"

@interface QSModifierButton : QSButton

@property (nonatomic, retain) QSModifier *modifier;

@end
