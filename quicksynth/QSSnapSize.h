//
//  QSSnapSize.h
//  quicksynth
//
//  Created by Andrew on 4/13/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSSnapSize : NSObject

typedef enum snapSizes {
    WHOLE = 0,
    HALF = 1,
    THIRD = 2,
    QUARTER = 3,
    EIGTH = 4,
    SIXTEENTH = 5
} SnapSize;

+ (float)snapToFraction:(SnapSize)size;
+ (SnapSize)fractionToSnap:(float)fraction;

@end
