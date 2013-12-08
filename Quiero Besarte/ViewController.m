//
//  ViewController.m
//  Quiero Besarte
//
//  Created by José Manuel Roldán Marín on 04/11/13.
//  Copyright (c) 2013 José Manuel Roldán Marín. All rights reserved.
//

#import "ViewController.h"
#import "API.h"
@interface ViewController ()

@end

@implementation ViewController

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

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
    [self login];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_idWedding isFirstResponder] && [touch view] != _idWedding) {
        [_idWedding resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

-(IBAction)btnLoginRegisterTapped:(UIButton*)sender
{
    
    
    [self login];
    
}



-(void) login
{
    //create indicator to show loading...
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator setFrame:self.view.frame];
    
    [indicator.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
    [indicator layer].cornerRadius = 8.0;
    [indicator layer].masksToBounds = YES;
    indicator.transform = CGAffineTransformMakeScale(1.75, 1.75);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    
    
    //form fields validation
    if (_idWedding.text.length == 0) {
        [indicator stopAnimating];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                     message:[NSString stringWithFormat:@"Introduce una clave por favor :)"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        [[API sharedInstance] login:_idWedding.text onCompletion:^(NSDictionary *json) {
            //handle the response
            
            //if json has just one value, some problem...
            if([json count] == 1)
            {
                NSString *jsonObject = [json objectForKey: @"RESULT"];
                NSString *message;
                if([jsonObject isEqualToString:@"426"])
                {
                    message = @"Por favor actualice la aplicación en la Apple Store";
                }
                else if([jsonObject isEqualToString:@"204"])
                {
                    message = @"No existe ninguna boda con esa clave";
                }
                else
                {
                    message = @"Ha habido un error. Disculpe las molestias";
                }
                [indicator stopAnimating];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            //Everything was fine
            else
            {
                NSString *jsonObject = [json objectForKey: @"Id"];
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                
                if (standardUserDefaults) {
                    [standardUserDefaults setObject:jsonObject forKey:@"idWedding"];
                    [standardUserDefaults synchronize];                    
                }
                [indicator stopAnimating];
                //menuTransition
                [self performSegueWithIdentifier:@"menuTransition" sender:nil];
            }
            
            
            
            NSLog(@"JSON: %@", [json description]);
            
        }];
    }
}

-(IBAction)facebook:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"fb://profile/281514515307124"];
    [[UIApplication sharedApplication] openURL:url];
}

-(IBAction)twitter:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"twitter:///user?screen_name=quierobesarte.es"];
    [[UIApplication sharedApplication] openURL:url];
    
}

-(IBAction)vimeo:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://vimeo.com/quierobesarte"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
