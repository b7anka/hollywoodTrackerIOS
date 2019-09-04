//
//  LocalNotificationsManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 11/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "LocalNotificationsManager.h"

@implementation LocalNotificationsManager

BOOL isGranted;

#pragma mark - Class Methods


/**
 This method will ask the user for permissions to display local notifications

 @return Returns the isGranted variable
 */
+(BOOL)askForNotificationsPermissions
{
    UNUserNotificationCenter *center = [LocalNotificationsManager defaultNotificationCenter];
    UNAuthorizationOptions option = UNAuthorizationOptionAlert;
    
    [center requestAuthorizationWithOptions:option completionHandler:^(BOOL granted, NSError * _Nullable error) {
        isGranted = granted;
    }];
    
    return isGranted;
}


/**
 This method will show a notification with a custom message and a custom title

 @param msg The message to be showed
 @param title The title to be used
 */
+(void)showNotificationWithMsg:(NSString *)msg andTitle:(NSString *)title
{
    if(isGranted)
    {
        UNUserNotificationCenter *center = [LocalNotificationsManager defaultNotificationCenter];
        
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = title;
        content.body = msg;
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"UILocalNotification" content:content trigger:nil];
        
        [center addNotificationRequest:request withCompletionHandler:nil];
    }
}


/**
 This method returns the default user notification center

 @return Returns current notification center
 */
+(UNUserNotificationCenter *)defaultNotificationCenter
{
    return [UNUserNotificationCenter currentNotificationCenter];
}

@end
