//
//  ForgotPasswordViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "User.h"
#import "SharedMethods.h"
#import "VerifyCodeViewController.h"
#import "NetworkManager.h"
#import "LocalNotificationsManager.h"
#import "InterfaceAPI.h"
#import "AlertManager.h"

@interface ForgotPasswordViewController () <UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

#pragma mark - Properties

@property(strong, nonatomic) InterfaceAPI *interfaceAPI;

@end

@implementation ForgotPasswordViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    self.emailTextField.delegate = self;
    [self.emailTextField becomeFirstResponder];
}


/**
 This method will validate all the user's inputs to check if they are not empty and if they conform to the regexs in the ValidateInputs class, if they do then it will call the forgotPassword method
 */
-(void)validateInputs
{
    NSString *trimmedEmail = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedMessage = NSLocalizedString(@"on_empty_user_inputs", @"");
    
    if(![SharedMethods checkForEmptyUserInputs:@[trimmedEmail]])
    {
        [self forgotPasswordWithEmail:trimmedEmail];
    }
    else
    {
        [self.emailTextField becomeFirstResponder];
        [AlertManager showErrorAlertWithText:localizedMessage andViewController:self];
    }
}


/**
 Calls the interfaceAPI to tell the server to send a verification code to the email address provided, if successfully it will perform a segue, otherwise it will display an alert informing the user what went wrong

 @param email The email address provided by the user
 */
-(void)forgotPasswordWithEmail:(NSString *)email
{
    if([NetworkManager isInternetAvailable])
    {
        __weak ForgotPasswordViewController *weakSelf = self;
        [weakSelf.activityIndicator startAnimating];
        NSString *localizedTitle = NSLocalizedString(@"email_sent", @"");
        
        [self.interfaceAPI forgotPasswordWith:email andCompletion:^(NSString *response, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:self];
                } else if(response){
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                    [weakSelf performSegueWithIdentifier:@"SegueVerifyCode" sender:response];
                }else
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:self];
                    weakSelf.emailTextField.text = @"";
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SegueVerifyCode"] && [segue.destinationViewController isKindOfClass:[VerifyCodeViewController class]] && [sender isKindOfClass:[NSString class]])
    {
        NSArray *temp = [sender componentsSeparatedByString:@";"];
        VerifyCodeViewController *controller = segue.destinationViewController;
        controller.userId = temp[0];
        controller.code = temp[1];
    }
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(UIButton *)sender
{
    [self validateInputs];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self validateInputs];
    return YES;
}

@end
