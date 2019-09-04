//
//  InterfaceAPI.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 24/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Show.h"

@interface InterfaceAPI : NSObject

#pragma mark - Methods

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password andCompletion:(void (^)(User *user, NSError *error, NSString *msg))completion;
- (void)loginWithUserGoogleEmail:(NSString *)email andCompletion:(void (^)(User *user, NSError *error, NSString *msg, NSNumber *errorCode))completion;
- (void)UpdateGoogleAccountWithEmail:(NSString *)email value:(BOOL)value andCompletion:(void (^)(NSError *error, NSString *msg))completion;
- (void)registerWithFullname:(NSString *)fullname username:(NSString *)username email:(NSString *)email password:(NSString *)password thumbnail:(NSString *)base64Thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)registerWithGoogleWithFullname:(NSString *)fullname username:(NSString *)username email:(NSString *)email password:(NSString *)password thumbnail:(NSString *)thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)forgotPasswordWith:(NSString *)email andCompletion:(void (^)(NSString *response, NSError *error, NSString *msg))completion;
- (void)changePasswordWithPassword:(NSString *)password userId:(NSNumber *)userId andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)getUserData:(NSString *)type andCompletion:(void (^)(NSMutableArray <Show *> *data, NSError *error))completion;
- (void)getUserProfileWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)updateUserDataWith:(NSString *)type userID:(NSNumber *)userId content:(NSString *)content andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)deleteUserAccountWithCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)sendBugReportWithTitle:(NSString *)title fullname:(NSString *)fullname email:(NSString *)email content:(NSString *)content andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)saveUserDataWithType:(NSString *)type title:(NSString *)title watchedTime:(NSString *)watchedTime season:(NSString *)season episode:(NSString *)episode completed:(NSNumber *)completed andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)deleteUserDataWithId:(NSNumber *)dataId type:(NSString *)type andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
- (void)uploadThumbnailToServerWithTitle:(NSString *)title thumbnail:(NSString *)thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
-(void)checkIfUserIsStillValidWithCompletion:(void (^)(BOOL, NSError *, NSString *, NSNumber *))completion;
- (void)getTotalWatchedVideosFromServer:(bool)isSaving AndValue:(int)value AndCompletion:(void (^)(int value, bool success, int errorCode, NSError *error))completion;
- (void)buyPremiumWithCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion;
-(void)checkAppVersionWithCompletion:(void (^)(NSNumber *version))completion;
-(void)checkIfAppWasApprovedForAppStore:(void (^)(NSNumber *status))completion;
- (void)checkIfUserHasPreviouslyPurchasedPremium:(NSString *)email AndCompletion:(void (^)(int value, NSError *error))completion;

@end
