//
//  AdsManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/08/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "AdsManager.h"
#import "Constants.h"

@implementation AdsManager 

- (void)showBannerAdOnBannerView:(GADBannerView *)bannerView{
    GADRequest *request = [self getRequest];
    bannerView.adUnitID = BANNER_ID_TEST;
    [bannerView loadRequest:request];
}

-(GADInterstitial *)showInterstitialAdOnInterstitial{
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:INTERSTITIAL_ID_TEST];
    GADRequest *request = [self getRequest];
    [interstitial loadRequest:request];
    return interstitial;
}

-(GADRequest *)getRequest{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    return request;
}

@end
