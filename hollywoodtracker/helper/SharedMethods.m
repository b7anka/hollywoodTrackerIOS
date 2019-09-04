//
//  SharedMethods.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "SharedMethods.h"
#import "UserDefaultsManager.h"
#import "ShowsOfflineManager.h"

@implementation SharedMethods

#pragma mark - Class Methods


/**
 This method takes an array of UITextFields as parameter and loops through it checking if the secureTextEntry property is on, if so it will turn it off, otherwise it will turn it on

 @param fields The textfields' array to be looped through
 */
+(void)toggleShowPasswords:(NSArray<UITextField *>*)fields
{
    for (UITextField *field in fields) {
        if([field isSecureTextEntry])
        {
            field.secureTextEntry = NO;
        }
        else{
            field.secureTextEntry = YES;
        }
    }
}

+(NSString *)passwordGenerator
{
    int len = 8;
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyz:&#!@$ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}


/**
 This method takes an array of strings and loops through it checking if any of those are empty

 @param texts The array containing the strings to be looped through
 @return Returns YES if any of the strings is empty and NO if there is no empty string
 */
+(BOOL)checkForEmptyUserInputs:(NSArray<NSString *> *)texts
{
    for (NSString *string in texts) {
        if([string isEqualToString:@""])
        {
            return YES;
        }
    }
    
    return NO;
}


/**
 Logs out the user taking him back to the login screen, saves the auto login information to no.

 @param controller The controller that requested the logout
 */
+(void)logoutFromViewController:(UIViewController *)controller
{
    [UserDefaultsManager saveAutoLoginPreference:NO];
    
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


/**
 This method is very clear it deletes all information in core data
 */
+(void)deleteAllOfflineData
{
    [ShowsOfflineManager deleteAllObjects:@"Movie"];
    [ShowsOfflineManager deleteAllObjects:@"TvShow"];
    [ShowsOfflineManager deleteAllObjects:@"Recent"];
    [ShowsOfflineManager deleteAllObjects:@"User"];
    [ShowsOfflineManager deleteAllObjects:@"OfflineChanges"];
}

+(NSString *)getUserLocale{
    NSString *tempLocale = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *locale = [tempLocale stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    return locale;
}

+(long)getCurrentTimeStamp{
    long timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return timeStamp;
}

+(void)openAppStoreAppPage{
    NSArray<NSString *> *locale = [[SharedMethods getUserLocale] componentsSeparatedByString:@"_"];
    NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://apps.apple.com/%@/app/apple-store/id%@?mt=8", locale.firstObject, APP_STORE_APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:nil];
}

@end
