//
//  GetPremiumForFreeViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/08/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "GetPremiumForFreeViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Constants.h"
#import "AlertManager.h"
#import "InterfaceAPI.h"
#import "LocalNotificationsManager.h"
#import "ShowsOfflineManager.h"
#import "SharedMethods.h"
#import "NetworkManager.h"
#import "UserDefaultsManager.h"

@interface GetPremiumForFreeViewController () <GADRewardBasedVideoAdDelegate>

@property(strong,nonatomic)AlertManager *alertManager;
@property(strong,nonatomic)InterfaceAPI *interfaceAPI;
@property(nonatomic)int videosWatched;

@property (weak, nonatomic) IBOutlet UILabel *totalVideosWatchedLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchVideoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GetPremiumForFreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeVariables];
    [self getTotalVideosWatchedFromServerWithValue:0 andIsSaving:NO];
    [self enableOrDisableWatchVideoButtonWithBool:NO andAlpha:0.25];
    [self loadRewardedAd];
}

-(void)initializeVariables{
    self.interfaceAPI = [InterfaceAPI new];
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    self.alertManager = [AlertManager new];
    self.videosWatched = (int)[UserDefaultsManager getTotalVideosWatched];
}

- (void)loadRewardedAd{
        GADRequest *request = [GADRequest request];
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                        withAdUnitID:REWARDED_AD_ID_TEST];
}

-(void)getTotalVideosWatchedFromServerWithValue:(int) value andIsSaving:(bool)isSaving{
    [self.activityIndicator startAnimating];
    [self.interfaceAPI getTotalWatchedVideosFromServer:isSaving AndValue:value AndCompletion:^(int value, bool success, int errorCode, NSError *error) {
        
        __weak GetPremiumForFreeViewController *weakSelf = self;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (success) {
                weakSelf.videosWatched = value;
                [weakSelf updateUI];
                [self updateUserToPremium];
            } else {
                switch (errorCode) {
                    case 200:
                        weakSelf.videosWatched = value;
                        [weakSelf updateUI];
                        [LocalNotificationsManager showNotificationWithMsg:NSLocalizedString(@"total_videos_watched_saved", @"") andTitle:NSLocalizedString(@"success_title", @"")];
                        break;
                        
                    default:
                        weakSelf.videosWatched = value;
                        [weakSelf updateUI];
                        break;
                }
                
            }
            [weakSelf.activityIndicator stopAnimating];
        }];
    }];
}

-(void)updateUserToPremium{
    User * user = [ShowsOfflineManager allUsers].firstObject;
    user.premium = [NSNumber numberWithInteger:1];
    [ShowsOfflineManager updateShowWithShow:nil orUser:user andEntity:@"User"];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [UserDefaultsManager saveUserPremium:user.premium.intValue];
    [UserDefaultsManager saveTotalVideosWatched:0];
    [AlertManager showAlertWithTitle:NSLocalizedString(@"success_title", @"") message:NSLocalizedString(@"updated_to_premium_successfully", @"") actions:@[actionOk] andViewController:self];
}

-(void)updateUI{
    [self.totalVideosWatchedLabel setText:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"total_videos_watched", @""), self.videosWatched]];
}

-(void)enableOrDisableWatchVideoButtonWithBool:(bool) value andAlpha:(CGFloat)alpha{
    [self.watchVideoButton setEnabled:value];
    self.watchVideoButton.alpha = alpha;
}

- (IBAction)showVideo:(UIButton *)sender {
    long now = [SharedMethods getCurrentTimeStamp] - FIVE_MINUTES_IN_MILLIS;
    if([UserDefaultsManager getLastVideoWatchedTimeStamp] < now){
        if([NetworkManager isInternetAvailable]){
            if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
                [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
            }
            else {
                [self loadRewardedAd];
            }
        }else {
            [AlertManager showNoInternetAlertWithViewController:self];
        }
    }else {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"wait_to_watch_video_again", "") andViewController:self];
    }
}


- (void)rewardBasedVideoAd:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(nonnull GADAdReward *)reward {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.videosWatched++;
    [UserDefaultsManager saveTotalVideosWatched:self.videosWatched];
    [UserDefaultsManager saveLastVideoWatchedTimeStamp:[SharedMethods getCurrentTimeStamp]];
    [self getTotalVideosWatchedFromServerWithValue:self.videosWatched andIsSaving:YES];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    [self enableOrDisableWatchVideoButtonWithBool:YES andAlpha:1.0];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    [self enableOrDisableWatchVideoButtonWithBool:NO andAlpha:0.25];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    [self loadRewardedAd];
}

@end
