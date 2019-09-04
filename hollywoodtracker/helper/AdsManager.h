//
//  AdsManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/08/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdsManager : NSObject

-(void)showBannerAdOnBannerView:(GADBannerView *)bannerView;
-(GADInterstitial *)showInterstitialAdOnInterstitial;

@end
