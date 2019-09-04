//
//  LoginViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "LoginViewController.h"
#import "InterfaceAPI.h"
#import "SharedMethods.h"
#import "UserDefaultsManager.h"
#import "HomeTableViewController.h"
#import "LocalNotificationsManager.h"
#import "AlertManager.h"
#import "HomeTabBarController.h"
#import "ShowsOfflineManager.h"
#import "NetworkManager.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface LoginViewController () <GIDSignInDelegate, GIDSignInUIDelegate, UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *loginWithGoogleButton;


#pragma mark - Properties

@property(strong, nonatomic) InterfaceAPI *interfaceAPI;
@property(strong, nonatomic) NSString *passwordFromGoogle;
@property(strong, nonatomic) NSString *emailFromGoogle;
@property(strong, nonatomic) NSString *fullNameFromGoogle;
@property(strong, nonatomic) NSString *userNameFromGoogle;
@property(strong, nonatomic) NSString *thumbnailURLFromGoogle;

@end

@implementation LoginViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    GIDSignIn.sharedInstance.clientID = @"200517552905-174hc6gsntngu0p74ssig420o7gacjjb.apps.googleusercontent.com";
    GIDSignIn.sharedInstance.delegate = self;
    GIDSignIn.sharedInstance.uiDelegate = self;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if(error != nil)
    {
        [self enableLoginButtons];
    }
    else
    {
        self.fullNameFromGoogle = user.profile.name ? user.profile.name : DEFAULT_FULL_NAME;
        self.emailFromGoogle = user.profile.email;
        NSArray *temp = [self.emailFromGoogle componentsSeparatedByString:@"@"];
        self.userNameFromGoogle = temp[0];
        self.thumbnailURLFromGoogle = [user.profile imageURLWithDimension:100].absoluteString ? [user.profile imageURLWithDimension:100].absoluteString : @"";
        
        [self loginUserWithGoogleEmail:self.emailFromGoogle];
    }
}


/**
 This method validates all user's inputs to check if they are not empty and if they conform to the regexs in the ValidateInputs.h class if they do then it will call the loginUser method if there's an internet connection available, otherwise it will display an alert to the user informing him that there is no internet connection
 */
-(void)validateInputs
{
    NSString *trimmedUsername = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedEmptyUserInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    
    if(![SharedMethods checkForEmptyUserInputs:@[trimmedUsername,trimmedPassword]])
    {

        if([NetworkManager isInternetAvailable])
        {
            [self loginUserWithUsername:trimmedUsername andPassword:trimmedPassword];
            [self disableLoginButtons];
        }
        else
        {
            [AlertManager showNoInternetAlertWithViewController:self];
        }
      
    }
    else
    {
        [AlertManager showErrorAlertWithText:localizedEmptyUserInputs andViewController:self];
    }
}

-(void)disableLoginButtons
{
    [self.loginButton setEnabled:NO];
    [self.loginWithGoogleButton setUserInteractionEnabled:NO];
}

-(void)enableLoginButtons
{
    [self.loginButton setEnabled:YES];
    [self.loginWithGoogleButton setUserInteractionEnabled:YES];
}


/**
 Calls the interfaceAPI to tell the server to login the user with the information provided, if the server response is successfully it will first assign the self.user object to be the same one sent by the server, then it will assing that same user object the password provided in the passwordTextField and finally it will save the user object in core data and then it will perform a segue that will take the user to the HomeTableViewController, else it will display an alert informing him what went wrong. If the remember me switch is on it will save that information in user defaults.

 @param username The user's username
 @param password The user's password
 */
-(void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password
{
    __weak LoginViewController *weakSelf = self;
    [weakSelf.activityIndicator startAnimating];
    
    [self.interfaceAPI loginWithUserName:username password:password andCompletion:^(User *user, NSError *error, NSString *msg) {
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if(user)
            {
                [UserDefaultsManager saveGoogleAccountState:NO];
            }
            
            [weakSelf handleLoginResultWith:user error:error message:msg andPassword:password];
        }];
        
    }];
}

-(void)handleLoginResultWith:(User *)user error:(NSError *)error message:(NSString *)msg andPassword:(NSString *)password
{
    NSString *localizedTitle = NSLocalizedString(@"logged_in", @"");
    if (error) {
        [AlertManager showErrorAlertWithError:error andViewController:self];
    } else if(user) {
        self.user = user;
        self.user.password = password;
        if(self.rememberMeSwitch.isOn)
        {
            [UserDefaultsManager saveAutoLoginPreference:YES];
        }
        [UserDefaultsManager saveUserId:user.userId.integerValue];
        [UserDefaultsManager saveUserPremium:user.premium.integerValue];
        [ShowsOfflineManager createUserWithUser:user];
        [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
        [self performSegueWithIdentifier:@"SegueHomeFromLogin" sender:user];
    }else
    {
        [AlertManager showErrorAlertWithText:msg andViewController:self];
    }
    [self enableLoginButtons];
    [self.activityIndicator stopAnimating];
}

-(void)loginUserWithGoogleEmail:(NSString *)email
{
    __weak LoginViewController *weakSelf = self;
    [weakSelf.activityIndicator startAnimating];
    
    [self.interfaceAPI loginWithUserGoogleEmail:email andCompletion:^(User *user, NSError *error, NSString *msg, NSNumber *errorCode) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if(user)
            {
                [UserDefaultsManager saveGoogleAccountState:YES];
            }
            
            if(errorCode != nil)
            {
                switch (errorCode.integerValue) {
                    case 403:
                        [weakSelf askIfUserWantsToLinkHisGoogleAccount];
                        break;
                    case 401:
                        [weakSelf registerUserWithGoogle];
                        break;
                    default:
                        [weakSelf enableLoginButtons];
                        [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                        break;
                }
            }
            else
            {
                [weakSelf handleLoginResultWith:user error:error message:msg andPassword:weakSelf.passwordFromGoogle];
            }
        }];
    }];
}

-(void)askIfUserWantsToLinkHisGoogleAccount
{
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak LoginViewController *weakSelf = self;
        [self.interfaceAPI UpdateGoogleAccountWithEmail:self.emailFromGoogle value:YES andCompletion:^(NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if(error != nil)
                {
                    [weakSelf enableLoginButtons];
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
                else
                {
                    [weakSelf loginUserWithGoogleEmail:weakSelf.emailFromGoogle];
                }
            }];
        }];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.activityIndicator stopAnimating];
        [self enableLoginButtons];
    }];
    
    [AlertManager showAlertWithTitle:NSLocalizedString(@"user_already_registered", @"") message:NSLocalizedString(@"ask_user_if_he_wants_to_link_his_google_account", @"") actions:@[actionYes, actionNo] andViewController:self];
}

-(void)registerUserWithGoogle
{
    if([NetworkManager isInternetAvailable])
    {
        self.passwordFromGoogle = [SharedMethods passwordGenerator];
        __weak LoginViewController *weakSelf = self;
        [self.interfaceAPI registerWithGoogleWithFullname:self.fullNameFromGoogle username:self.userNameFromGoogle email:self.emailFromGoogle password:self.passwordFromGoogle thumbnail:self.thumbnailURLFromGoogle andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if(error != nil)
                {
                    [weakSelf enableLoginButtons];
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
                else if(success)
                {
                    [weakSelf loginUserWithGoogleEmail:self.emailFromGoogle];
                }
                else
                {
                    [weakSelf enableLoginButtons];
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
            }];
        }];
    }
    else
    {
        [self enableLoginButtons];
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}


#pragma mark - Actions

- (IBAction)showPasswordValueChanged:(UISwitch *)sender
{
    [SharedMethods toggleShowPasswords:@[self.passwordTextField]];
}

- (IBAction)loginButtonClicked:(UIButton *)sender
{
    [self validateInputs];
}

- (IBAction)forgotPasswordButtonClicked:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"SegueForgotPassword" sender:nil];
}

- (IBAction)loginWithGoogleButtonPressed:(UILabel *)sender
{
    if([NetworkManager isInternetAvailable])
    {
        [self disableLoginButtons];
        [GIDSignIn.sharedInstance signIn];
    }
    else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
        [self validateInputs];
    }
    
    return YES;
}

@end
