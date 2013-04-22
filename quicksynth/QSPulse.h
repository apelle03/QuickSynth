//
//  QSPulse.h
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@interface QSPulse : QSSound

@property (nonatomic, readwrite) float frequency;
@property (nonatomic, readwrite) float duty;
@property (nonatomic, readwrite) float theta;

@end
