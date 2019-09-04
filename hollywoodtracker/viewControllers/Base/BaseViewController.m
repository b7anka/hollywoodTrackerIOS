//
//  BaseViewController.m
//  hollywoodtracker
//
//  Created by Developer on 13/02/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

/**
 Hides the keyboard when the user taps on the scroll view
 
 @param sender Takes a uiGestureRecognizer as a parameter
 */
-(IBAction)dismissKeyboard:(UITapGestureRecognizer *)sender
{
    [self resignFirstResponder];
}

@end
