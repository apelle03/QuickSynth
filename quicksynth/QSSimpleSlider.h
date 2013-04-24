//
//  QSSimpleSlider.h
//  quicksynth
//
//  Created by Andrew on 4/24/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSSimpleSlider : UIView {
    IBOutlet UIView *contentView;
    IBOutlet UILabel *uiName;
    IBOutlet UISlider *uiSlider;
    IBOutlet UITextField *uiText;
    IBOutlet UILabel *uiUnit;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic)         float    value;
@property (nonatomic)         float    min, max;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *unit;

@end
