//
//  BaseViewController.m
//  hollywoodtracker
//
//  Created by Developer on 13/02/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "BaseScrollViewController.h"

@interface BaseScrollViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation BaseScrollViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addKeyboardObservers];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
}


/**
 Adds observers to the view window to check when the keyboard appears or disappears
 */
-(void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}


/**
 Removes de keyboard observers from the view window
 */
-(void)removeKeyboardObservers
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self.view.window];

}


/**
 Basically zeros out the scroll view insets when the keyboard disappears

 @param n Receives a nsnotification as a parameter that contains keyboard information, not used in this method
 */
- (void)keyboardWillHide:(NSNotification *)n
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}


/**
 This method is called when the keyboard appears in the screen and adjusts the scroll view content to accomodate the keyboard so that the content thats blocked by it can be seen by the user.

 @param n Takes an nsnotification as a parameter that contains information about the keyboard.
 */
- (void)keyboardWillShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
    }
}


/**
 Hides the keyboard when the user taps on the scroll view

 @param sender Takes a uiGestureRecognizer as a parameter
 */
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)sender
{
    [self.activeTextField resignFirstResponder];
}

@end
