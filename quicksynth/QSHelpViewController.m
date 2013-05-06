//
//  QSHelpViewController.m
//  quicksynth
//
//  Created by Andrew on 5/6/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "QSHelpViewController.h"

@interface QSHelpViewController ()

@end

@implementation QSHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.slide = 0;
    self.images = [[NSArray alloc] initWithObjects:@"dragon.png", @"tapdetails.png", @"dragmove.png", @"dragresize.png", @"dragoff.png", @"pinchsize.png", @"tapreset.png", nil];
    self.texts = [[NSArray alloc] initWithObjects:@"Drag an object from the toolbox to the score to add it", @"Tap an object to edit options", @"Drag an object to move it", @"Drag an object from its edge to resize it", @"Drag an object into the trash or the toolbox to delete it", @"Pinch the score to zoom", @"Double tap on the score to reset the zero location", nil];
    [image setImage:[UIImage imageNamed:self.images[self.slide]]];
    [text setText:self.texts[self.slide]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:true completion:^{}];
}

- (IBAction)next:(id)sender
{
    self.slide++;
    if (self.slide == 6) {
        [next setEnabled:false];
    }
    [image setImage:[UIImage imageNamed:self.images[self.slide]]];
    [text setText:self.texts[self.slide]];
    [prev setEnabled:true];
}

- (IBAction)prev:(id)sender
{
    self.slide--;
    if (self.slide == 0) {
        [prev setEnabled:false];
    }
    [image setImage:[UIImage imageNamed:self.images[self.slide]]];
    [text setText:self.texts[self.slide]];
    [next setEnabled:true];
}

@end
