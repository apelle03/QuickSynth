//
//  QSSoundButton.m
//  quicksynth
//
//  Created by Andrew on 4/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSoundButton.h"

@implementation QSSoundButton

@synthesize sound;

- (id)init
{
    self = [super init];
    if (self) {
        modifiers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        modifiers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addModifierButton:(QSModifierButton*)modifierButton
{
    NSLog(@"add mod");
    [modifiers addObject:modifierButton];
}

- (NSArray*)getModifierButtons
{
    return modifiers;
}

- (void)removeModifierButton:(QSModifierButton*)modifierButton
{
    [modifiers removeObject:modifierButton];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self placeModifiers];
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    [self placeModifiers];
}

- (void)placeModifiers
{
    int i = 0;
    for (QSModifierButton *modifierButton in modifiers) {
        [modifierButton setFrame:CGRectMake(self.frame.origin.x + self.frame.size.width * modifierButton.modifier.startPercent,
                                            self.frame.origin.y + self.frame.size.height + 20 * i,
                                            self.frame.size.width * (modifierButton.modifier.endPercent - modifierButton.modifier.startPercent),
                                            20)];
        i++;
        [modifierButton setNeedsDisplay];
    }
}

@end
