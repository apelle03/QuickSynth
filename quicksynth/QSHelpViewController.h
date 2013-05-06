//
//  QSHelpViewController.h
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSHelpViewController : UIViewController {
    IBOutlet UIButton *exit;
    IBOutlet UIImageView *image;
    IBOutlet UILabel *text;
    IBOutlet UIButton *prev, *next;
}

@property (nonatomic, readwrite) int slide;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *texts;

- (IBAction)dismiss:(id)sender;

- (IBAction)prev:(id)sender;
- (IBAction)next:(id)sender;

@end
