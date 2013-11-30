//
//  MenuController.m
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 30/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import "MenuController.h"

@interface MenuController ()

@end

@implementation MenuController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnViewPhotos:(UIButton*)sender
{
    
    //viewPhotosTransition
    [self performSegueWithIdentifier:@"ViewPhotosTransition" sender:nil];
    
}

@end
