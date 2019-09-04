//
//  LocalNotificationsManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 11/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface LocalNotificationsManager : NSObject

#pragma mark - Class Methods

+(BOOL)askForNotificationsPermissions;
+(void)showNotificationWithMsg:(NSString *)msg andTitle:(NSString *)title;

@end
