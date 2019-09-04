//
//  VerifyCodeViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "SharedMethods.h"
#import "ChangePasswordFromLoginViewController.h"
#import "AlertManager.h"

@interface VerifyCodeViewController () <UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;

@end

@implementation VerifyCodeViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verifyCodeTextField.delegate = self;
    [self.verifyCodeTextField becomeFirstResponder];
}

/**
 This method validates the user input to check if it is empty, if so then it will display an alert informing the user that he needs to write something before tapping the button, otherwise it will verify if the inputed code is the same as self.code property, if yes then it will perform a segue to another screen, otherwise it will inform the user that the code he entered is wrong.
 */
-(void)validateCode
{
    NSString *localizedEmptyUserInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    NSString *localizedCodeWrong = NSLocalizedString(@"code_wrong", @"");
    
    if(![SharedMethods checkForEmptyUserInputs:@[self.verifyCodeTextField.text]])
    {
        if([self.verifyCodeTextField.text isEqualToString:self.code])
        {
            [self performSegueWithIdentifier:@"SegueChangePassFromVerifyCode" sender:nil];
        }
        else
        {
            [AlertManager showErrorAlertWithText:localizedCodeWrong andViewController:self];
        }
    }
    else
    {
        [self.verifyCodeTextField becomeFirstResponder];
        [AlertManager showErrorAlertWithText:localizedEmptyUserInputs andViewController:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SegueChangePassFromVerifyCode"] && [segue.destinationViewController isKindOfClass:[ChangePasswordFromLoginViewController class]])
    {
        ChangePasswordFromLoginViewController *controller = segue.destinationViewController;
        controller.userId = self.userId;
    }
}

#pragma mark - Actions

- (IBAction)verifyButtonClicked:(UIButton *)sender
{
    [self validateCode];
}

#pragma mark - Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self validateCode];
    
    return YES;
}

@end
