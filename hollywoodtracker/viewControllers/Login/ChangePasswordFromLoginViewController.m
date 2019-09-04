//
//  ChangePasswordFromLoginViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ChangePasswordFromLoginViewController.h"
#import "SharedMethods.h"
#import "InterfaceAPI.h"
#import "ValidateInputs.h"
#import "UserDefaultsManager.h"
#import "NetworkManager.h"
#import "LocalNotificationsManager.h"
#import "AlertManager.h"

@interface ChangePasswordFromLoginViewController () <UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

#pragma mark - Properties

@property(strong,nonatomic) InterfaceAPI *interfaceApi;
@property(strong,nonatomic) UITextField *activeTextfield;
@end

@implementation ChangePasswordFromLoginViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordTextField.delegate = self;
    self.repeatPasswordTextField.delegate = self;
    [self.passwordTextField becomeFirstResponder];
    self.interfaceApi = [InterfaceAPI new];
}


/**
 This method validates all user's inputs to check if they are empty and if they conform to the regexs in the ValidateInputs.h class, if they do then it will call the method changePassword, otherwise it will display an alert telling the user what went wrong
 */
-(void)validateUserInputs
{
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedRepeatPassword = [self.repeatPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedEmptyUserInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    NSString *localizedPasswordsDontMatch = NSLocalizedString(@"Passwords_dont_match", @"");
    NSString *localizedPasswordRequirements = NSLocalizedString(@"password_requirements", @"");
    
    if(![SharedMethods checkForEmptyUserInputs:@[trimmedPassword,trimmedRepeatPassword]])
    {
        if([ValidateInputs checkPasswordEnforcementWithPassword:self.passwordTextField.text])
        {
            if([self.passwordTextField.text isEqualToString:self.repeatPasswordTextField.text])
            {
                [self changePasswordWith:trimmedPassword andUserId:self.userId];
            }
            else
            {
                [AlertManager showErrorAlertWithText:localizedPasswordsDontMatch andViewController:self];
            }
        }else
        {
            [AlertManager showErrorAlertWithText:localizedPasswordRequirements andViewController:self];
        }
    }
    else
    {
        [self.passwordTextField becomeFirstResponder];
        [AlertManager showErrorAlertWithText:localizedEmptyUserInputs andViewController:self];
    }
}


/**
 Calls the interfaceAPI if there's an internet connection telling the server to change the user's password, otherwise it will display an alert telling the user that there's no internet connection

 @param password The new password
 @param userId The user's id so that the server knows what user it must update
 */
-(void)changePasswordWith:(NSString *)password andUserId:(NSNumber *)userId
{
    if([NetworkManager isInternetAvailable])
    {
        __weak ChangePasswordFromLoginViewController *weakSelf = self;
        
        [weakSelf.activityIndicator startAnimating];
        
        NSString *localizedTitle = NSLocalizedString(@"password_changed", @"");
        
        [self.interfaceApi changePasswordWithPassword:password userId:userId andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:self];
                } else if(success){
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }else
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:self];
                }
                [weakSelf.activityIndicator stopAnimating];
            }];
        }];
    }
    else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}

#pragma mark - Actions

- (IBAction)showPasswordsValueChanged:(UISwitch *)sender {
    [SharedMethods toggleShowPasswords:@[self.passwordTextField,self.repeatPasswordTextField]];
}

- (IBAction)changePasswordButtonClicked:(UIButton *)sender {
    
    [self validateUserInputs];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextfield = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.passwordTextField)
    {
        [self.repeatPasswordTextField becomeFirstResponder];
    }
    else
    {
        [self.activeTextfield resignFirstResponder];
        self.activeTextfield = nil;
        [self validateUserInputs];
    }
    
    return YES;
}

@end
