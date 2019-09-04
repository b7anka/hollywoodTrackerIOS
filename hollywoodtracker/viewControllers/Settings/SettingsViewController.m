//
//  SettingsViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserDefaultsManager.h"
#import "SharedMethods.h"
#import "AlertManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIPickerView *homeScreenToUserPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *askToAddNextEpisodeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *touchOrFaceIDSwitch;

#pragma mark - Properties

@property (strong, nonatomic) NSArray <NSString *> *homeScreensArray;

@end

@implementation SettingsViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.homeScreenToUserPickerView.delegate = self;
    self.homeScreenToUserPickerView.dataSource = self;
    [self.askToAddNextEpisodeSwitch setOn:[UserDefaultsManager getAddNextEpisodeValue]];
    [self.touchOrFaceIDSwitch setOn:[UserDefaultsManager getUseTouchOrFaceIdValue]];
    self.homeScreensArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"movies", @""),NSLocalizedString(@"tvshows", @""),NSLocalizedString(@"recent", @""),NSLocalizedString(@"profile", @""), nil];//Data to populate the picker view
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     NSUInteger row = [UserDefaultsManager getHomeScreenToUse];//gets the default home screen saved by the user
    [self.homeScreenToUserPickerView selectRow:row inComponent:0 animated:YES]; //sets the picker view selected row to the row variable
}

-(void)checkIfDeviceSupportsBiometricAuthentication{
    if([UserDefaultsManager getAutoLoginPreference]){
        LAContext *context = [[LAContext alloc] init];
        NSError *authError = nil;
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [UserDefaultsManager saveUseTouchOrFaceIdValue:YES];
        }
        else {
            [self.touchOrFaceIDSwitch setOn:NO];
            if(authError){
                NSString *errorMesssage;
                if(authError.code == LAErrorBiometryNotAvailable){
                    errorMesssage = NSLocalizedString(@"device_does_not_support_biometric", @"");
                }
                else if(authError.code == LAErrorBiometryNotEnrolled){
                    errorMesssage = NSLocalizedString(@"biometric_not_enrolled", @"");
                }
                [AlertManager showErrorAlertWithText:errorMesssage andViewController:self];
            }
        }
    }else {
        [self.touchOrFaceIDSwitch setOn:NO];
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"check_remember_me_first_before_using_this_functionality", @"") andViewController:self];
    }
}

#pragma mark - DataSource Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.homeScreensArray.count;
}

#pragma mark - Delegate Methods

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.homeScreensArray[row];
}


- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    [UserDefaultsManager saveHomeScreenToUseWithIndex:row];//saves the index of the picker view wich is the home screen the user wants to see when the app launches
    [UserDefaultsManager saveHomeScreenChanged:YES];//saves the information that the home screen was changed so that it will be reloaded by the tab controller
}

#pragma mark - Actions

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender
{
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)askToAddNextEpisodeValueChanged:(UISwitch *)sender {
    [UserDefaultsManager saveAddNextEpisodeValue:sender.isOn];
}

- (IBAction)useTouchOrFaceIDValueChanged:(UISwitch *)sender {
    if(sender.isOn){
        [self checkIfDeviceSupportsBiometricAuthentication];
    }else {
        [UserDefaultsManager saveUseTouchOrFaceIdValue:NO];
    }
}


@end
