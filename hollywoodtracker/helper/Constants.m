//
//  Constants.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 25/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "Constants.h"

@implementation Constants
NSString *const MOVIES = @"movies";
NSString *const TV_SHOWS = @"tvshows";
NSString *const RECENTLY_WATCHED = @"recentlywatched";
NSString *const PROFILE = @"profile";
NSString *const LOGIN = @"login";
NSString *const ABOUT = @"about";
NSString *const THUMBNAIL = @"thumb";
NSString *const SEASON = @"season";
NSString *const EPISODE = @"episode";
NSString *const DEVICE_IOS = @"ios";
NSString *const PREMIUM_DETAILS = @"premiumDetails";
NSString *const AUTO_LOGIN_KEY = @"autoLogin";
NSString *const IS_GOOGLE_ACCOUNT = @"isGoogleAccount";
NSString *const DEFAULT_FULL_NAME = @"John Doe";
NSString *const PROFILE_NEEDS_UPDATING = @"profileUpdate";
NSString *const RECENT_NEEDS_UPDATING = @"recentUpdate";
NSString *const HOME_SCREEN_NEEDS_UPDATING = @"homescreeenUpdate";
NSString *const OFFLINE_MODE_KEY = @"offline";
NSString *const DELETE_CONTENT = @"delete";
NSString *const CONTENT_COMPLETED = @"completed;";
NSString *const BUG_REPORT = @"bugs";
NSString *const BEGINNING_WATCH_TIME = @"00:00:00";
NSString *const CREDENTIALS = @"credentials";
NSString *const USERNAME = @"user";
NSString *const PASSWORD = @"pass";
NSString *const ID_USER = @"id";
NSString *const PREMIUM_USER = @"premium";
NSString *const HOME_SCREEN_TO_USE = @"home";
NSString *const LOGIN_SEGUE = @"SegueLogin";
NSString *const HOME_SEGUE = @"SegueHome";
NSString *const BANNER_ID_TEST = @"YOUR_BANNER_ID"; //ca-app-pub-3940256099942544/2934735716 - Test ID
NSString *const INTERSTITIAL_ID_TEST = @"YOUR_INTERSTITIAL_ID"; //ca-app-pub-3940256099942544/4411468910 - Test ID
NSString *const REWARDED_AD_ID_TEST = @"YOUR_REWARDED_VIDEO_ID"; //ca-app-pub-3940256099942544/1712485313 - Test ID
NSString *const SETTINGS = @"settings";
NSString *const TIME_STAMP = @"timeStamp";
NSString *const BASE_URL = @"https://api.hollywoodtracker.eu/";
NSString *const TOTAL_WATCHED_VIDEOS = @"totalVideos";
NSString *const ADD_NEXT_EPISODE = @"addNextEpisode";
NSString *const USE_TOUCH_OR_FACE_ID = @"useTouchOrFaceId";
NSString *const APPROVED_FOR_APP_STORE = @"approvedForAppStore";
NSString *const PREMIUM_WAS_BOUGHT = @"premiumWasBought";
NSString *const IN_APP_PURCHASE_ID = @"com.b7anka.hollyT.Premium";
NSString *const LAST_VIDEO_WATCHED_TIMESTAMP = @"lastVideoTimeStamp";
NSString *const APP_STORE_APP_ID = @"1477875665";
const long FIVE_MINUTES_IN_MILLIS = 300000;
const int SAVED_SUCCESSFULLY = 200;
const int NOT_COMPLETED = 0;
const long BELOW_TEN = 10;
const BOOL AUTO_LOGIN_TRUE = YES;
const BOOL AUTO_LOGIN_FALSE = NO;
@end
