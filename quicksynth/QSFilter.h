//
//  QSLowPass.h
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSModifier.h"
#import "FilterType.h"

@interface QSFilter : QSModifier

@property (nonatomic) FilterType type;
@property (nonatomic) float freq;
@property (nonatomic) float bandwidth;

@end
