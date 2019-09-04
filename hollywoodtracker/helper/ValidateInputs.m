//
//  ValidateInputs.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ValidateInputs.h"

@implementation ValidateInputs

const int MIN_LENGTH = 8;
const int FULL_NAME_SIZE = 2;
const int MAX_FULL_NAME_LENGTH = 80;
const int MAX_USER_NAME_LENGTH = 20;
const int MAX_EMAIL_LENGTH = 50;
const int MAX_TITLE_LENGTH = 60;
const int MAX_WATCHED_TIME_LENGTH = 8;
const int MAX_SEASON_AND_EPISODE_LENGTH = 2;

#pragma mark - Class Methods


/**
 This method verifies if a password is valid or not, to be a valid password it cannot contain a semi-colon, it's length must be at least equal to the MIN_LENGTH constant, it needs to have at least 1 lowercase character, 1 upper case character, 1 number and 1 symbol

 @param password The password to be veryfied
 @return Return yes if it's valid or no if it's invalid
 */
+(BOOL)checkPasswordEnforcementWithPassword:(NSString *)password
{
    if([password containsString:@";"])
    {
        return false;
    }
    
    BOOL hasMinLength = password.length >= MIN_LENGTH;
    
    BOOL hasUpperCaseLetter = NO;
    BOOL hasLowerCaseLetter = NO;
    BOOL hasDigit = NO;
    BOOL hasSymbol = NO;
    
    NSMutableArray *passwordArray = [NSMutableArray array];

    for (int i = 0; i < [password length]; i++) {
        NSString *letter = [password substringWithRange:NSMakeRange(i, 1)];
        [passwordArray addObject:letter];
    }

    
    for(int i = 0; i < passwordArray.count; i++)
    {
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[passwordArray[i] characterAtIndex:0]])
        {
            hasUpperCaseLetter = YES;
        }else if([[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[passwordArray[i] characterAtIndex:0]])
        {
            hasLowerCaseLetter = YES;
        }else if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[passwordArray[i] characterAtIndex:0]])
        {
            hasDigit = YES;
        }else if([[NSCharacterSet symbolCharacterSet] characterIsMember:[passwordArray[i] characterAtIndex:0]] || [passwordArray[i] isEqualToString:@"@"])
        {
            hasSymbol = YES;
        }else
        {
            continue;
        }
    }
    
    BOOL isValid = hasMinLength && hasUpperCaseLetter && hasLowerCaseLetter && hasDigit && hasSymbol;
    
    return isValid;
}


/**
 This method verifies if the full name is valid, to be a valid full name it needs to contain at least the same ammout of names as the FULL_NAME_SIZE constant, it's length cannot exceed the MAX_FULL_NAME_LENGTH constant and it needs to match the regex in the method

 @param fullname The sting containing the full name
 @return Returns yes if valid , and no if invalid
 */
+(BOOL)validateFullNameWithName:(NSString *)fullname
{
    NSArray *fullnameSize = [fullname componentsSeparatedByString:@" "];

    if(fullnameSize.count < FULL_NAME_SIZE)
    {
        return NO;
    }
    else if(fullname.length > MAX_FULL_NAME_LENGTH)
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"^[A-Za-záãâäàéêëèíîïìóõôöòúûüùçñÁÃÂÀÉÊÈÍÎÌÓÕÔÒÚÛÙÇÑ]+([\\s][A-Za-záãâäàéêëèíîïìóõôöòúûüùçñÁÃÂÀÉÊÈÍÎÌÓÕÔÒÚÛÙÇÑ]+)*$";//Accepts a-z upper or lower case letters, latin characters and a single space beetween words
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:fullname];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}


/**
 Validates if a given username is valid, to be valid it's length must be less than the MAX_USER_NAME_LENGTH and it needs to match the regex in the method

 @param username <#username description#>
 @return <#return value description#>
 */
+(BOOL)validateUserNameWithUserName:(NSString *)username
{
    if(username.length > MAX_USER_NAME_LENGTH)
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"^[A-Za-z0-9.-_]*$";//Accepts a-z lower and upper case characters and numbers
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:username];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}


/**
 Verifies if a given email address is valid or not, to be valid it's length cannot exceed the MAX_EMAIL_LENGTH constant and it needs to match the regex in the method

 @param email The email address to be verified
 @return Returns yes if valid and no if invalid
 */
+ (BOOL)validateEmailAddressWithEmailAddress:(NSString *)email
{
    if(email.length > MAX_EMAIL_LENGTH)
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"[0-9a-z._%+-]+@[a-z0-9.-]+\\.[a-z]{2,63}";//Accepts numbers, a-z lower case characters, dots, underscores, hifens followed by a @ symbol, then a-z lower case characters, numbers, dots, hifens followed by a dot, a-z lower case characters with min length of 2 and max of 63
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:email];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}


/**
 Verifies if a given title is valid or not, to be valid it's length cannot exceed the MAX_TITLE_LENGTH constant

 @param title The title to be verified
 @return Returns yes if valid, no if invalid
 */
+ (BOOL)validateTitleWithTitle:(NSString *)title
{
    return title.length < MAX_TITLE_LENGTH;
}


/**
 Verifies if a watched time is a valid time, to be a valid time it's length cannot exceed the MAX_WATCHED_TIME_LENGTH constant and it needs to match the regex in the method

 @param time The watched time to be verified
 @return Returns yes if valid, no if invalid
 */
+(BOOL)validateWatchedTimeWithTime:(NSString *)time
{
    if(time.length > MAX_WATCHED_TIME_LENGTH)
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"^0{1}[0-3]+:{1}[0-5]{1}[0-9]+:{1}[0-5]{1}[0-9]$";//Accepts 1 number zero and 1 number between 0 and 3 followed by a colon, then 1 number between 0 and 5 and a number between 0 and 9 followed by a colon, then then 1 number between 0 and 5 and a number between 0 and 9
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:time];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}


/**
 Verifies if a season, or episode length is valid, to be valid it cannot exceed the MAX_SEASON_AND_EPISODE_LENGTH constant

 @param content The content to be verified
 @return Return yes if invalid, no if valid
 */
+(BOOL)validateSeasonAndEpisodeLength:(NSString *)content
{
    return content.length > MAX_SEASON_AND_EPISODE_LENGTH;
}

/**
 Verifies if a given season is valid, to be valid it must be false in the ValidateSeasonAndEpisodeLength method and it needs to match the regex in the method

 @param season The season to be verified
 @return Return yes if valid, no if invalid
 */
+(BOOL)validateSeasonWithSeason:(NSString *)season
{
    if([self validateSeasonAndEpisodeLength:season])
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"^{1}[0-5]{1}[0-9]$";//accepts 1 number between 0 and 5 and 1 number between 0 and 9
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:season];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}


/**
 Verifies if a given episode is valid or not, to be valid it must be false in the ValidateSeasonAndEpisodeLength method and it needs to match the regex in the method

 @param episode The episode to be verified
 @return Return yes if valid, no if invalid
 */
+(BOOL)validateEpisodeWithEpisode:(NSString *)episode
{
    if([self validateSeasonAndEpisodeLength:episode])
    {
        return NO;
    }
    else
    {
        NSError  *error = nil;
        
        NSString *pattern = @"^{1}[0-7]{1}[0-9]$";//accepts 1 number between 0 and 7 and 1 number between 0 and 9
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL matches = [nameTest evaluateWithObject:episode];
        
        if(error)
        {
            return NO;
        }
        else
        {
            return matches;
        }
    }
}
@end
