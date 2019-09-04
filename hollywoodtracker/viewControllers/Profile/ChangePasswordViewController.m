//
//  ChangePasswordViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "SharedMethods.h"
#import "InterfaceAPI.h"
#import "NetworkManager.h"
#import "LocalNotificationsManager.h"
#import "ValidateInputs.h"
#import "AlertManager.h"
#import "UserDefaultsManager.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

#pragma mark - Properties

@property (strong, nonatomic) InterfaceAPI *interfaceAPI;

@end

@implementation ChangePasswordViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPasswordTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.repeatPasswordTextField.delegate = self;
    [self.currentPasswordTextField becomeFirstResponder];
    self.interfaceAPI = [InterfaceAPI new];
    
}


/**
 Validates all user's inputs to check if they are not empty and if they conform to the regexs in ValidateInputs.h class and if they do then it will call the changePassword method
 */
-(void)validateUserInputs
{
    NSString *trimmedCurrentPassword = [self.currentPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedRepeatPassword = [self.repeatPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedNewPasswordIsTheSameAsCurrentPassword = NSLocalizedString(@"new_password_equals_current", @"");
    NSString *localizedPasswordsDontMatch = NSLocalizedString(@"passwords_dont_match", @"");
    NSString *localizedPasswordsRequirements = NSLocalizedString(@"passwords_requirements", @"");
    NSString *localizedCurrentPasswordWrong = NSLocalizedString(@"current_password_wrong", @"");
    NSString *localizedEmptyInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    
    if(![SharedMethods checkForEmptyUserInputs:@[trimmedCurrentPassword,trimmedPassword,trimmedRepeatPassword]])
    {
        if([trimmedCurrentPassword isEqualToString:self.currentPassword])
        {
            if([ValidateInputs checkPasswordEnforcementWithPassword:trimmedPassword])
            {
                if([trimmedPassword isEqualToString:trimmedCurrentPassword])
                {
                    [AlertManager showErrorAlertWithText:localizedNewPasswordIsTheSameAsCurrentPassword andViewController:self];
                }
                else
                {
                    if([trimmedPassword isEqualToString:trimmedRepeatPassword])
                    {
                        [self changePasswordWith:trimmedPassword];
                        [self.saveButton setEnabled:NO];
                    }
                    else
                    {
                        [AlertManager showErrorAlertWithText:localizedPasswordsDontMatch andViewController:self];
                    }
                }
            }
            else
            {
                [AlertManager showErrorAlertWithText:localizedPasswordsRequirements andViewController:self];
            }
        }
        else
        {
            [AlertManager showErrorAlertWithText:localizedCurrentPasswordWrong andViewController:self];
        }
    }
    else
    {
        [self.currentPasswordTextField becomeFirstResponder];
        [AlertManager showErrorAlertWithText:localizedEmptyInputs andViewController:self];
    }
}



/**
 This method calls the didChangePassword method from it's delegate and then it calls the interfaceAPI if there's an internet connection available to inform the server to  update the user's password with the new password provided by the user, else it will display a local notification informing the user that the information was saved.

 @param password Takes a string as a parameter called password
 */
-(void)changePasswordWith:(NSString *)password
{
     [self.delegate changePassWordViewController:self didChangePassword:password];
    NSString *localizedTitle = NSLocalizedString(@"password_changed_title", @"");
    NSString *localizedMessage = NSLocalizedString(@"password_changed_successfully", @"");
    
    if([NetworkManager isInternetAvailable])
    {
        __weak ChangePasswordViewController *weakSelf = self;
        [weakSelf.activityIndicator startAnimating];
        [self.interfaceAPI changePasswordWithPassword:password userId:nil andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:self];
                } else if(success){
                    [weakSelf.activityIndicator stopAnimating];
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:self];
                }
                [weakSelf.saveButton setEnabled:YES];
            }];
        }];
    }else
    {
        [LocalNotificationsManager showNotificationWithMsg:localizedMessage andTitle:localizedTitle];
        [self.saveButton setEnabled:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions

- (IBAction)showPasswordsValueChanged:(UISwitch *)sender {
    
    [SharedMethods toggleShowPasswords:@[self.currentPasswordTextField,self.passwordTextField,self.repeatPasswordTextField]];
}
- (IBAction)saveButtonClicked:(UIButton *)sender
{
    [self validateUserInputs];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.currentPasswordTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }else if(textField == self.passwordTextField)
    {
        [self.repeatPasswordTextField becomeFirstResponder];
    }
    else
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
        [self validateUserInputs];
    }
    
    return YES;
}

@end
