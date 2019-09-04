//
//  UserDefaultsManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 25/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "UserDefaultsManager.h"
#import "SharedMethods.h"

@implementation UserDefaultsManager

#pragma mark - Class Methods


/**
 Saves the auto login information

 @param state The boolean to be saved
 */
+ (void)saveAutoLoginPreference:(BOOL)state{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:AUTO_LOGIN_KEY];
    [userDefaults synchronize];
}

+ (BOOL)getGoogleAccountState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL preference = [userDefaults boolForKey:IS_GOOGLE_ACCOUNT];
    return preference;
}

+ (void)saveGoogleAccountState:(BOOL)state
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:IS_GOOGLE_ACCOUNT];
    [userDefaults synchronize];
}


+ (void)saveTimeStamp:(long)timeStamp{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:timeStamp forKey:TIME_STAMP];
    [userDefaults synchronize];
}

+ (long)getTimeStamp {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    long preference = [userDefaults integerForKey:TIME_STAMP];
    return preference;
}

+ (void)saveLastVideoWatchedTimeStamp:(long)timeStamp{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:timeStamp forKey:LAST_VIDEO_WATCHED_TIMESTAMP];
    [userDefaults synchronize];
}

+ (long)getLastVideoWatchedTimeStamp {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    long preference = [userDefaults integerForKey:LAST_VIDEO_WATCHED_TIMESTAMP];
    return preference;
}

+ (void)saveUserId:(NSInteger)userId{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:userId forKey:ID_USER];
    [userDefaults synchronize];
}

+ (NSInteger)getUserId {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger preference = [userDefaults integerForKey:ID_USER];
    return preference;
}

+ (void)saveAddNextEpisodeValue:(bool)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:ADD_NEXT_EPISODE];
    [userDefaults synchronize];
}

+ (bool)getAddNextEpisodeValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool preference = [userDefaults boolForKey:ADD_NEXT_EPISODE];
    return preference;
}

+ (void)saveUseTouchOrFaceIdValue:(bool)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:USE_TOUCH_OR_FACE_ID];
    [userDefaults synchronize];
}

+ (bool)getUseTouchOrFaceIdValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool preference = [userDefaults boolForKey:USE_TOUCH_OR_FACE_ID];
    return preference;
}

+ (bool)getAppWasApprovedForAppStore{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool preference = [userDefaults boolForKey:APPROVED_FOR_APP_STORE];
    return preference;
}

+ (void)saveAppWasApprovedForAppStore:(bool)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:APPROVED_FOR_APP_STORE];
    [userDefaults synchronize];
}

+ (bool)getPremiumWasBought{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool preference = [userDefaults boolForKey:PREMIUM_WAS_BOUGHT];
    return preference;
}

+ (void)savePremiumWasBought:(bool)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:PREMIUM_WAS_BOUGHT];
    [userDefaults synchronize];
}


+ (void)saveUserPremium:(NSInteger)premium{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:premium forKey:PREMIUM_USER];
    [userDefaults synchronize];
}

+ (NSInteger)getUserPremium {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger preference = [userDefaults integerForKey:PREMIUM_USER];
    return preference;
}

/**
 Gets the auto login information

 @return Returns the auto login information
 */
+ (BOOL)getAutoLoginPreference {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL preference = [userDefaults boolForKey:AUTO_LOGIN_KEY];
    return preference;
}


/**
 Saves if the user profile needs to be updated

 @param state Boolean telling, yes or no
 */
+ (void)saveUserProfileNeedsUpdating:(BOOL)state{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:PROFILE_NEEDS_UPDATING];
    [userDefaults synchronize];
}


/**
 Gets the profile needs updating information

 @return Return yes, or no
 */
+ (BOOL)getProfileNeedsUpdating {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL preference = [userDefaults boolForKey:PROFILE_NEEDS_UPDATING];
    return preference;
}

/**
 Saves if the user recently watched needs to be updated
 
 @param state Boolean telling, yes or no
 */
+ (void)saveRecentNeedsUpdating:(BOOL)state
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:RECENT_NEEDS_UPDATING];
    [userDefaults synchronize];
}


+ (void)saveTotalVideosWatched:(NSInteger)videos{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:videos forKey:TOTAL_WATCHED_VIDEOS];
    [userDefaults synchronize];
}

+ (NSInteger)getTotalVideosWatched {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger preference = [userDefaults integerForKey:PROFILE_NEEDS_UPDATING];
    return preference;
}


/**
 Gets the user needs updating information

 @return Returns yes, no
 */
+ (BOOL)getRecentNeedsUpdating
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL preference = [userDefaults boolForKey:RECENT_NEEDS_UPDATING];
    return preference;
}


/**
 Saves the HomeScreenChanged information

 @param state Boolean, telling yes or no
 */
+ (void)saveHomeScreenChanged:(BOOL)state{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:HOME_SCREEN_NEEDS_UPDATING];
    [userDefaults synchronize];
}


/**
 Gets the home screen changed information

 @return Return yes, or no
 */
+ (BOOL)getHomeScreenChanged {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL preference = [userDefaults boolForKey:HOME_SCREEN_NEEDS_UPDATING];
    return preference;
}


/**
 Saves the index that matches a home screen in the app

 @param index Takes an NSUInteger as parameter
 */
+(void)saveHomeScreenToUseWithIndex:(NSUInteger)index
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:index forKey:HOME_SCREEN_TO_USE];
    [userDefaults synchronize];
}


/**
 Gets the index saved that matches a home screen in the app

 @return Retuns the index, if there is one otherwise it will return 0
 */
+ (NSUInteger)getHomeScreenToUse
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger preference = [userDefaults integerForKey:HOME_SCREEN_TO_USE];
    if(!preference)
    {
        preference = 0;
    }
    return preference;
}


@end
