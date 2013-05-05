//
//  QSLowPass.h
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSModifier.h"

@interface QSLowPass : QSModifier

@property (nonatomic) float freq;
@property (nonatomic) float aMag, dMag, sMag;
@property (nonatomic) float aLen, dLen, sLen;
@property (nonatomic) float startMag, endMag;

@end
