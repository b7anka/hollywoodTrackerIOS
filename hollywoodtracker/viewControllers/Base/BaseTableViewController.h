//
//  BaseTableViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 20/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdsManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BaseTableViewController : UITableViewController

#pragma mark - Properties

@property(strong, nonatomic) UITextField *activeTextField;
@property(strong,nonatomic)GADInterstitial *interstitial;
@property(strong,nonatomic)AdsManager *adsManager;
@property(strong,nonatomic)NSTimer *interstitialTimer;

#pragma mark - Methods

-(void)startRefreshControl;
-(void)showNoInternetAlert;
-(void)showAlertToTerminateUserSession;
-(void)checkAppVersion;

@end
