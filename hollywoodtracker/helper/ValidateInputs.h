//
//  ValidateInputs.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidateInputs : NSObject

#pragma mark - Class Methods

+(BOOL)checkPasswordEnforcementWithPassword:(NSString *)password;
+(BOOL)validateFullNameWithName:(NSString *)fullname;
+(BOOL)validateUserNameWithUserName:(NSString *)username;
+(BOOL)validateEmailAddressWithEmailAddress:(NSString *)email;
+(BOOL)validateTitleWithTitle:(NSString *)title;
+(BOOL)validateWatchedTimeWithTime:(NSString *)time;
+(BOOL)validateSeasonAndEpisodeLength:(NSString *)content;
+(BOOL)validateSeasonWithSeason:(NSString *)season;
+(BOOL)validateEpisodeWithEpisode:(NSString *)episode;

@end
