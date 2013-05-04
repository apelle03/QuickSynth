//
//  QSADSRSlider.m
//  quicksynth
//
//  Created by Andrew on 5/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSADSRSlider.h"

@implementation QSADSRSlider

@synthesize contentView, start, a, d, s, end;

- (id)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void) initUI
{
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
    [self addSubview:contentView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
