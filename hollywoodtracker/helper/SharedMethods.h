//
//  SharedMethods.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SharedMethods : NSObject

#pragma mark - Class Methods

+(void)toggleShowPasswords:(NSArray<UITextField *>*)fields;
+(BOOL)checkForEmptyUserInputs:(NSArray <NSString *>*)texts;
+(void)logoutFromViewController:(UIViewController *)controller;
+(void)deleteAllOfflineData;
+(NSString *)passwordGenerator;
+(long)getCurrentTimeStamp;
+(NSString *)getUserLocale;
+(void)openAppStoreAppPage;

@end

