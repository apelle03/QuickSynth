//
//  QSSoundNode.h
//  quicksynth
//
//  Created by Andrew on 4/10/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface QSSoundNode : NSObject

@property (readwrite) AUNode node;

- (id) initWithAUNode:(AUNode)node;
@end
