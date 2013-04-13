//
//  QSSoundNode.m
//  quicksynth
//
//  Created by Andrew on 4/10/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSoundNode.h"

@implementation QSSoundNode
@synthesize node = _node;

- (id) initWithAUNode:(AUNode)node {
    _node = node;
    return self;
}

@end
