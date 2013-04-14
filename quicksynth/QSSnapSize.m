//
//  QSSnapSize.m
//  quicksynth
//
//  Created by Andrew on 4/13/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSnapSize.h"

@implementation QSSnapSize

+ (SnapSize)fractionToSnap:(float)fraction
{
    if (fabsf(fraction - 1) < .001) {
        return WHOLE;
    } else if (fabsf(fraction - .5) < .001) {
        return HALF;
    } else if (fabsf(fraction - (1.0/3)) < .001) {
        return THIRD;
    } else if (fabsf(fraction - .25) < .001) {
        return QUARTER;
    } else if (fabsf(fraction - .125) < .001) {
        return EIGTH;
    } else if (fabsf(fraction - .0625) < .001) {
        return SIXTEENTH;
    } else {
        return WHOLE;
    }
}

+ (float)snapToFraction:(SnapSize)size
{
    switch (size) {
        case WHOLE:
            return 1;
        case HALF:
            return .5;
        case THIRD:
            return 1.0/3;
        case QUARTER:
            return .25;
        case EIGTH:
            return .125;
        case SIXTEENTH:
            return .0625;
            
        default:
            return 1;
    }
}

@end
