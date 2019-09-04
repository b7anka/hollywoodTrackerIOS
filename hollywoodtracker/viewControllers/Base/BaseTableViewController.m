//
//  BaseTableViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 20/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AlertManager.h"
#import "NetworkManager.h"
#import "InterfaceAPI.h"
#import "UserDefaultsManager.h"
#import "SharedMethods.h"

@interface BaseTableViewController ()

@property(strong, nonatomic) InterfaceAPI *interfaceAPI;

@end

@implementation BaseTableViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    self.adsManager = [AdsManager new];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(showInterstitial) userInfo:nil repeats:YES];
    [self createAndLoadInterstitial];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.interstitialTimer invalidate];
    self.interstitialTimer = nil;
}

-(void)createAndLoadInterstitial{
    self.interstitial = [self.adsManager showInterstitialAdOnInterstitial];
}

-(void)showInterstitial{
    if([self.interstitial isReady]){
        if([UserDefaultsManager getUserPremium] == 0){
            [self.interstitial presentFromRootViewController:self];
            [self createAndLoadInterstitial];
        }
    }else {
        [AlertManager showInfoAlertWithText:@"Add wasn't ready!" andViewController:self];
    }
}

/**
 This is a simple method that starts the refresh control on the table view controller
 */
-(void)startRefreshControl
{
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
}


-(void)showNoInternetAlert
{
    NSString *localizedTitle = NSLocalizedString(@"error", @"");
    NSString *localizedMessage = NSLocalizedString(@"no_internet", @"");
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.refreshControl endRefreshing];
    }];
    [AlertManager showAlertWithTitle:localizedTitle message:localizedMessage actions:@[actionOk] andViewController:self];
}

-(void)showAlertToTerminateUserSession
{
    [self.refreshControl endRefreshing];
    
    NSString *localizedTitle = NSLocalizedString(@"error", @"");
    NSString *localizedMessage = NSLocalizedString(@"user_is_invalid", @"");
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SharedMethods logoutFromViewController:self];
    }];
    [AlertManager showAlertWithTitle:localizedTitle message:localizedMessage actions:@[actionOk] andViewController:self];
}

- (void)checkAppVersion{
    if([NetworkManager isInternetAvailable]){
        [self.interfaceAPI checkAppVersionWithCompletion:^(NSNumber *version) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                float serverVersion = version.floatValue;
                NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
                float appVersion = [version floatValue];
                
                if(serverVersion > appVersion){
                    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [SharedMethods openAppStoreAppPage];
                    }];
                    
                    [AlertManager showAlertWithTitle:NSLocalizedString(@"information", @"") message:NSLocalizedString(@"app_needs_updating", @"") actions:@[actionOk] andViewController:self];
                }
                
            }];
        }];
    }else {
        
    }
}

#pragma mark - Actions

-(IBAction)dismissKeyboard:(id)sender
{
    [self.activeTextField resignFirstResponder];
}

@end
