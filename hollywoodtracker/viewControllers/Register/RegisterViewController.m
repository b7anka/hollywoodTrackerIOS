//
//  RegisterViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "RegisterViewController.h"
#import "SharedMethods.h"
#import "AlertManager.h"
#import "ValidateInputs.h"
#import "InterfaceAPI.h"
#import "NetworkManager.h"
#import "ImageManager.h"

@interface RegisterViewController () <ImageManagerDelegate, UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

#pragma mark - Properties

@property (strong, nonatomic) NSString *base64ImageString;
@property (strong, nonatomic) InterfaceAPI *interfaceAPI;
@property (strong, nonatomic) ImageManager *imageManager;

@end

@implementation RegisterViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fullNameTextField becomeFirstResponder];
    self.interfaceAPI = [InterfaceAPI new];
    self.imageManager = [ImageManager new];
    self.imageManager.delegate = self;
    self.fullNameTextField.delegate = self;
    self.userNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.repeatPasswordTextField.delegate = self;
}


/**
 This method validates all user's inputs to check if they are not empty and if they conform to the regexs in the ValidateInputs.h class if they do then it will call the method registerUser if there's an internet connection available, otherwise it will show an alert informing the use that there is no internet connection available
 */
-(void)validateUserInputs
{
    NSString *trimmedFullname = [self.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedUsername = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedEmail = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedRepeatPassword = [self.repeatPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedEmptyUserInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    NSString *localizedFullNameRequirements = NSLocalizedString(@"fullname_requirements", @"");
    NSString *localizedUserNameRequirements = NSLocalizedString(@"username_requirements", @"");
    NSString *localizedEmailRequirements = NSLocalizedString(@"email_requirements", @"");
    NSString *localizedPasswordRequirements = NSLocalizedString(@"password_requirements", @"");
    NSString *localizedPasswordsDontMatch = NSLocalizedString(@"passwords_dont_match", @"");
    
    if([SharedMethods checkForEmptyUserInputs:@[trimmedFullname,trimmedUsername,trimmedEmail,trimmedPassword,trimmedRepeatPassword]])
    {
        [AlertManager showErrorAlertWithText:localizedEmptyUserInputs andViewController:self];
    }else if(![ValidateInputs validateFullNameWithName:trimmedFullname])
    {
        [AlertManager showErrorAlertWithText:localizedFullNameRequirements andViewController:self];
    }else if(![ValidateInputs validateUserNameWithUserName:trimmedUsername])
    {
        [AlertManager showErrorAlertWithText:localizedUserNameRequirements andViewController:self];
    }else if(![ValidateInputs validateEmailAddressWithEmailAddress:trimmedEmail])
    {
        [AlertManager showErrorAlertWithText:localizedEmailRequirements andViewController:self];
    }else if(![ValidateInputs checkPasswordEnforcementWithPassword:trimmedPassword])
    {
         [AlertManager showErrorAlertWithText:localizedPasswordRequirements andViewController:self];
    }else if(![trimmedRepeatPassword isEqualToString:trimmedPassword])
    {
        [AlertManager showErrorAlertWithText:localizedPasswordsDontMatch andViewController:self];
    }
    else
    {
        if([NetworkManager isInternetAvailable])
        {
            [self.activityIndicator startAnimating];
            [self registerUserWithFullname:trimmedFullname username:trimmedUsername email:trimmedEmail password:trimmedPassword andThumbnail:self.base64ImageString ? [NSString stringWithFormat:@"data:image/jpg{base64,%@",self.base64ImageString] : @""];
            [self.registerButton setEnabled:NO];
        }
        else
        {
            [AlertManager showNoInternetAlertWithViewController:self];
        }
    }
}


/**
 Calls the interfaceAPI to register the user on the server with the information provided

 @param fullname The user's full name
 @param username The user's username
 @param email The user's email address
 @param password The user's password
 @param thumbnail The user's thumbnail (it can be nil, if it's nil the server will assign the user the default avatar)
 */
-(void)registerUserWithFullname:(NSString *)fullname username:(NSString *)username email:(NSString *)email password:(NSString *)password andThumbnail:(NSString *)thumbnail
{
    __weak RegisterViewController *weakSelf = self;
    
    [self.interfaceAPI registerWithFullname:fullname username:username email:email password:password thumbnail:thumbnail andCompletion:^(BOOL success, NSError *error, NSString *msg) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (error) {
                [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
            } else if(success){
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }];
                [AlertManager showAlertWithTitle:NSLocalizedString(@"information", @"") message:msg actions:@[action] andViewController:weakSelf];
            }else
            {
               [AlertManager showInfoAlertWithText:msg andViewController:weakSelf];
            }
            [weakSelf.registerButton setEnabled:YES];
            [weakSelf.activityIndicator stopAnimating];
        }];
    }];
}

#pragma mark - Actions

- (IBAction)showPasswordsValueChanged:(UISwitch *)sender {
    [SharedMethods toggleShowPasswords:@[self.passwordTextField,self.repeatPasswordTextField]];
}

- (IBAction)changeImage:(UITapGestureRecognizer *)sender
{
    [self.imageManager showActionSheetToGetPhotoWithViewController:self andImageView:self.thumbnailImageView];
}

- (IBAction)registerButtonClicked:(UIButton *)sender
{
    [self validateUserInputs];
}

/**
 This method sets the self.thumbnailImageView.image to the one it receives as parameter, after the user chooses it from the library or the camera, and encodes that image to a base64 string assigning it to the self.base64ImageString property to be sent to the server
 
 @param controller The controller that picked the image
 @param image The received image
 */
#pragma mark - Protocol Methods

-(void)imageManager:(ImageManager *)controller didFinishPickingImage:(UIImage *)image
{
    self.thumbnailImageView.image = image;
    self.base64ImageString = [ImageManager encodeToBase64String:self.thumbnailImageView.image];
}


#pragma mark - Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.fullNameTextField)
    {
        [self.userNameTextField becomeFirstResponder];
    }
    else if(textField == self.userNameTextField)
    {
        [self.emailTextField becomeFirstResponder];
    }
    else if(textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField == self.passwordTextField)
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
