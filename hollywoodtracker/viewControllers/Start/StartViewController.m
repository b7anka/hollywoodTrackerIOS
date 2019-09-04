//
//  StartViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 24/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "StartViewController.h"
#import "UserDefaultsManager.h"
#import "HomeTableViewController.h"
#import "HomeTabBarController.h"
#import "AlertManager.h"
#import "User.h"
#import "DataTableViewCell.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface StartViewController ()

#pragma mark - Properties

@property(nonatomic)BOOL autoLogin;
@property(strong,nonatomic)NSString *userCredentials;
@end

@implementation StartViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [LocalNotificationsManager askForNotificationsPermissions]; //Ask for user permissions to show local notifications
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.autoLogin = [UserDefaultsManager getAutoLoginPreference]; //checks if auto login is enabled
    if(self.autoLogin)
    {
        if([UserDefaultsManager getUseTouchOrFaceIdValue]){
            [self startTouchOrFaceIdAuthentication];
        }else {
            [self loginIntoTheApp];
        }
    }
    else
    {
        [self performSegueWithIdentifier:@"SegueLogin" sender:nil]; // otherwise it performs this one
    }
}

-(void)startTouchOrFaceIdAuthentication{
    
    LAContext *context = [[LAContext alloc] init];
    NSError *authError = nil;
    
    NSString *myLocalizedReasonString = NSLocalizedString(@"place_fingerprint_in_sensor", @"");
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [self loginIntoTheApp];
                }
                else {
                    [self startTouchOrFaceIdAuthentication]; // recursive call
                }
        }];
     }
}
                                                

-(void)loginIntoTheApp{
    
    NSString *localizedMessaged = NSLocalizedString(@"welcome", @"");
    NSString *localizedTitle = NSLocalizedString(@"logged_in", @"");
    
    [LocalNotificationsManager showNotificationWithMsg:localizedMessaged andTitle:localizedTitle];
    [self performSegueWithIdentifier:@"SegueHome" sender:self.userCredentials]; // if so it performs this segue
}

@end
