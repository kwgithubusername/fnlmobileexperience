//
//  FLFAboutViewController.m
//  FNLApp
//
//  Created by Woudini on 4/17/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFAboutViewController.h"

@interface FLFAboutViewController ()

@end

@implementation FLFAboutViewController

- (IBAction)backButtonClicked:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make the textView begin at the top
    [self.textView setContentOffset: CGPointMake(0,-300) animated:NO];
}

@end
