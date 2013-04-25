//
//  QSSoundButton.h
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QSButton.h"
#import "QSModifierButton.h"

#import "QSSound.h"

@interface QSSoundButton : QSButton {
    NSMutableArray *modifiers;
}

@property (nonatomic, retain) QSSound *sound;

- (void)addModifierButton:(QSModifierButton*)modifierButton;
- (NSArray*)getModifierButtons;
- (void)removeModifierButton:(QSModifierButton*)modifierButton;

- (void)placeModifiers;

@end
