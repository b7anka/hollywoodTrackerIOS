//
//  UserDefaultsManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 25/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDefaultsManager : NSObject

#pragma mark - Class Methods

+ (void)saveAutoLoginPreference:(BOOL)state;
+ (BOOL)getAutoLoginPreference;
+ (void)saveHomeScreenToUseWithIndex:(NSUInteger)index;
+ (NSUInteger)getHomeScreenToUse;
+ (BOOL)getProfileNeedsUpdating;
+ (void)saveUserProfileNeedsUpdating:(BOOL)state;
+ (BOOL)getHomeScreenChanged;
+ (BOOL)getGoogleAccountState;
+ (void)saveGoogleAccountState:(BOOL)state;
+ (void)saveHomeScreenChanged:(BOOL)state;
+ (void)saveRecentNeedsUpdating:(BOOL)state;
+ (BOOL)getRecentNeedsUpdating;
+ (void)saveTimeStamp:(long)timeStamp;
+ (long)getTimeStamp;
+ (NSInteger)getUserId;
+ (void)saveUserId:(NSInteger)userId;
+ (void)saveUserPremium:(NSInteger)premium;
+ (void)saveTotalVideosWatched:(NSInteger)videos;
+ (NSInteger)getUserPremium;
+ (NSInteger)getTotalVideosWatched;
+ (void)saveLastVideoWatchedTimeStamp:(long)timeStamp;
+ (long)getLastVideoWatchedTimeStamp;
+ (void)saveAddNextEpisodeValue:(bool)value;
+ (bool)getAddNextEpisodeValue;
+ (void)saveUseTouchOrFaceIdValue:(bool)value;
+ (bool)getUseTouchOrFaceIdValue;
+ (void)saveAppWasApprovedForAppStore:(bool)value;
+ (bool)getAppWasApprovedForAppStore;
+ (void)savePremiumWasBought:(bool)value;
+ (bool)getPremiumWasBought;
@end
