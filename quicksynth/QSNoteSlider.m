//
//  QSNoteSlider.m
//  quicksynth
//
//  Created by Andrew on 4/24/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSNoteSlider.h"

@interface QSNoteSlider()

@end

@implementation QSNoteSlider

double keys[10][12] = {
    {16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87},
    {32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74},
    {65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.83, 110.00, 116.54, 123.47},
    {130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.00, 196.00, 207.65, 220.00, 233.08, 246.94},
    {261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88},
    {523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880.00, 932.33, 987.77},
    {1046.50, 1108.73, 1174.66, 1244.51, 1318.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.00, 1864.66, 1975.53},
    {2093.00, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96, 3322.44, 3520.00, 3729.31, 3951.07},
    {4186.01, 4434.92, 4698.64, 4978.03, 5274.04, 5588.00, 5919.52, 6271.92, 6644.88, 7040.00, 7458.62, 7902.14},
    {8372.02, 8869.84, 9397.28, 9956.06, 10548.08, 11176.00, 11839.04, 12543.84, 13289.76, 14080.00, 14917.24, 15804.28}  };

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"QSNoteSlider" owner:self options:nil];
    
    [self addSubview:contentView];
}

- (void)setValue:(float)value
{
    _value = value;
    [self setUI];
}

- (void)setUI
{
    freqSlider.value = _value;
    freqText.text = [NSString stringWithFormat:@"%.0f", _value];
    
    noteType.selectedSegmentIndex = UISegmentedControlNoSegment;
    noteOctive.selectedSegmentIndex = UISegmentedControlNoSegment;
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 12; j++) {
            if (fabs(_value - keys[i][j]) < .5) {
                noteType.selectedSegmentIndex = j;
                noteOctive.selectedSegmentIndex = i;
            }
        }
    }
}

- (IBAction)noteChanged:(id)sender
{
    _value = keys[noteOctive.selectedSegmentIndex][noteType.selectedSegmentIndex];
    [self setUI];
}

- (IBAction)freqSliderChanged:(id)sender
{
    _value = freqSlider.value;
    [self setUI];
}

- (IBAction)freqTextChanged:(id)sender
{
    _value = [freqText.text floatValue];
    if (_value < freqSlider.minimumValue) _value = freqSlider.minimumValue;
    else if (_value > freqSlider.maximumValue) _value = freqSlider.maximumValue;
    freqSlider.value = _value;
}

- (IBAction)freqTextFinalized:(id)sender
{
    _value = [freqText.text floatValue];
    if (_value < freqSlider.minimumValue) _value = freqSlider.minimumValue;
    else if (_value > freqSlider.maximumValue) _value = freqSlider.maximumValue;
    [self setUI];
}

@end
