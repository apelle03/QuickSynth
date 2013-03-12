//
//  QSModifier.h
//  quicksynth
//
//  Created by Andrew on 3/12/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSModifier : NSObject

@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * width;

- (id)initWithID:(NSNumber*)ID;

@end
