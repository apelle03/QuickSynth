//
//  QSEnvelope.h
//  quicksynth
//
//  Created by Andrew on 4/25/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSModifier.h"

@interface QSEnvelope : QSModifier

@property (nonatomic) float aMag, dMag, sMag;
@property (nonatomic) float aLen, dLen, sLen;
@property (nonatomic) float startMag, endMag;

@end
