//
//  CITViewController.m
//  CITest
//
//  Created by Dariusz Rybicki on 29.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "CITViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface CITViewController ()

@end

@implementation CITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crashButtonAction:(id)sender
{
    [[Crashlytics sharedInstance] crash];
}

@end
