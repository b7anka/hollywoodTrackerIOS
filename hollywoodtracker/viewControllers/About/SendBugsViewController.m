//
//  SendBugsViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 01/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "SendBugsViewController.h"
#import "InterfaceAPI.h"
#import "ValidateInputs.h"
#import "ShowsOfflineManager.h"
#import "SharedMethods.h"
#import "NetworkManager.h"
#import "UserDefaultsManager.h"
#import "LocalNotificationsManager.h"
#import "AlertManager.h"

@interface SendBugsViewController () <UITextFieldDelegate, UITextViewDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UITextField *bugTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *bugContentTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

#pragma mark - Properties

@property (strong, nonatomic) InterfaceAPI *interfaceAPI;

@end

@implementation SendBugsViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    self.bugTitleTextField.delegate = self;
    self.fullnameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.bugContentTextView.delegate = self;
    [self.bugTitleTextField becomeFirstResponder];
   
}



/**
 Validates all the user inputs to check if they are not empty and conform to the regexs in the ValidateInputs.h class and if they do then it calls the method sendBugReport
 */
-(void)validateInputs
{
    NSString *trimmedFullname = [self.fullnameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedBugTitle = [self.bugTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedEmail = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedBugContent = [self.bugContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *localizedAlertText = NSLocalizedString(@"on_empty_user_inputs", @"");
    NSString *localizedFullNameRequirements = NSLocalizedString(@"fullname_requirements", @"");
    NSString *localizedEmailRequirements = NSLocalizedString(@"email_requirements", @"");
    NSString *localizedTitleRequirements = NSLocalizedString(@"title_requirements", @"");
    
    if([SharedMethods checkForEmptyUserInputs:@[trimmedEmail,trimmedFullname,trimmedBugTitle,trimmedBugContent]])
    {
        [self.bugTitleTextField becomeFirstResponder];
        [AlertManager showErrorAlertWithText:localizedAlertText andViewController:self];
    }
    else
    {
        if(![ValidateInputs validateFullNameWithName:trimmedFullname])
        {
            [AlertManager showErrorAlertWithText:localizedFullNameRequirements andViewController:self];
        }else if(![ValidateInputs validateEmailAddressWithEmailAddress:trimmedEmail])
        {
            [AlertManager showErrorAlertWithText:localizedEmailRequirements andViewController:self];
        }else if(![ValidateInputs validateTitleWithTitle:trimmedBugTitle])
        {
            [AlertManager showErrorAlertWithText:localizedTitleRequirements andViewController:self];
        }
        else
        {
            [self sendBugReportWithTitle:trimmedBugTitle fullname:trimmedFullname email:trimmedEmail andContent:trimmedBugContent];
            [self.sendButton setEnabled:NO];
            [self.activityIndicator startAnimating];
        }
    }
}



/**
 Calls the interfaceAPI to send the bug report to the server if there's an internet connection active otherwise it will save the information in core data to be sent to the server later when there's internet available

 @param title The title of the bug
 @param fullname The user's full name
 @param email The user's email address
 @param content The fully detailed bug if possible
 */
-(void)sendBugReportWithTitle:(NSString *)title fullname:(NSString *)fullname email:(NSString *)email andContent:(NSString *)content
{
    NSString *localizedTitle = NSLocalizedString(@"bug_report_sent_title", @"");
    if([NetworkManager isInternetAvailable])
    {
        __weak SendBugsViewController *weakSelf = self;
        
        [self.interfaceAPI sendBugReportWithTitle:title fullname:fullname email:email content:content andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(!success){
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }else
                {
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }];
        [weakSelf.activityIndicator stopAnimating];
    }else
    {
        NSString *localizedTitle = NSLocalizedString(@"bug_report_saved_title", @"");
        NSString *localizedMessage = NSLocalizedString(@"bug_report_saved_successfully", @"");
        
        [ShowsOfflineManager createOfflineDataChangeWithId:0 type:BUG_REPORT andContent:[NSString stringWithFormat:@"%@;%@;%@;%@",title,fullname,email,content]];
        [LocalNotificationsManager showNotificationWithMsg:localizedMessage andTitle:localizedTitle];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self.sendButton setEnabled:YES];
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(UIButton *)sender
{
    [self validateInputs];
    [self.bugContentTextView resignFirstResponder];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.bugTitleTextField)
    {
        [self.fullnameTextField becomeFirstResponder];
    }else if(textField == self.fullnameTextField)
    {
        [self.emailTextField becomeFirstResponder];
    }else if(textField == self.emailTextField)
    {
        [self.bugContentTextView becomeFirstResponder];
        self.activeTextField = nil;
    }
    
    return YES;
}

@end
