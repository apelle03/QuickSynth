//
//  QSSimpleSlider.m
//  quicksynth
//
//  Created by Andrew on 4/24/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSimpleSlider.h"

@implementation QSSimpleSlider

@synthesize name = _name, value = _value, min = _min, max = _max, format = _format, unit = _unit;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"QSSimpleSlider" owner:self options:nil];
    
    [self addSubview:contentView];
}

- (void)setName:(NSString *)name
{
    _name = name;
    uiName.text = _name;
}

- (void)setValue:(float)value
{
    _value = value;
    [self setUI];
}

- (void)setMin:(float)min
{
    _min = min;
    uiSlider.minimumValue = _min;
    if (_value < _min) _value = _min;
    [self setUI];
}

- (void)setMax:(float)max
{
    _max = max;
    uiSlider.maximumValue = _max;
    if (_value > _max) _value = _max;
    [self setUI];
}

- (void)setFormat:(NSString *)format
{
    _format = format;
    [self setUI];
}

- (void)setUnit:(NSString *)unit
{
    _unit = unit;
    uiUnit.text = _unit;
}

- (void)setUI
{
    uiSlider.value = _value;
    uiText.text = [NSString stringWithFormat:_format, _value];
}

- (IBAction)sliderChanged:(id)sender
{
    _value = uiSlider.value;
    [self setUI];
}

- (IBAction)textChanged:(id)sender
{
    _value = [uiText.text floatValue];
    if (_value < _min) _value = _min;
    else if (_value > _max) _value = _max;
    uiSlider.value = _value;
}

- (IBAction)textFinalized:(id)sender
{
    _value = [uiText.text floatValue];
    if (_value < _min) _value = _min;
    else if (_value > _max) _value = _max;
    [self setUI];
}

@end
