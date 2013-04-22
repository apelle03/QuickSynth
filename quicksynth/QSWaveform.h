//
//  QSWaveform.h
//  quicksynth
//
//  Created by Andrew on 4/22/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSSound.h"

@interface QSWaveform : QSSound

@property (nonatomic, readwrite) float frequency;
@property (nonatomic)         WaveType waveType;
@property (nonatomic, readwrite) float gain;
@property (nonatomic, readwrite) float theta;

@end
