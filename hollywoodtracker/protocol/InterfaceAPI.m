//
//  InterfaceAPI.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 24/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "InterfaceAPI.h"
#import "Constants.h"
#import "ShowsOfflineManager.h"
#import "SharedMethods.h"
#import "UserDefaultsManager.h"

@implementation InterfaceAPI

#pragma mark - Methods


/**
 This method will post a json containing the username, password and language to the server so the user can be logged into the app, then if the response is successfully it will create the user object and then calls the completion block passing it the user, otherwise it will call the completion block with the errors

 @param userName The username to be posted
 @param password The password to be posted
 @param completion The block to be executed
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password andCompletion:(void (^)(User *user, NSError *error, NSString *msg))completion
{
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:userName forKey:@"username"];
    [dataToPost setValue:password forKey:@"pass"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@login.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];

    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                NSArray *resultsFromApi = response[@"results"];
                NSMutableArray <User *> *users = [NSMutableArray new];
                if(success.boolValue)
                {
                    for (NSDictionary *dictionary in resultsFromApi) {
                        User *user = [[User alloc]initWithDictionary:dictionary];
                        [users addObject:user];
                    }
                    
                    completion(users.firstObject, nil, msg);
                }
                else
                {
                    completion(nil, nil, msg);
                }
            }
        }
    }];
    
    [task resume];
}

- (void)loginWithUserGoogleEmail:(NSString *)email andCompletion:(void (^)(User *user, NSError *error, NSString *msg, NSNumber *errorCode))completion
{
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@loginwithgoogle.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                NSNumber *errorCode = response[@"error"];
                NSArray *resultsFromApi = response[@"results"];
                NSMutableArray <User *> *users = [NSMutableArray new];
                if(success.boolValue)
                {
                    for (NSDictionary *dictionary in resultsFromApi) {
                        User *user = [[User alloc]initWithDictionary:dictionary];
                        [users addObject:user];
                    }
                    
                    completion(users.firstObject, nil, msg, nil);
                }
                else
                {
                    completion(nil, nil, msg, errorCode);
                }
            }
        }
    }];
    
    [task resume];
}

- (void)UpdateGoogleAccountWithEmail:(NSString *)email value:(BOOL)value andCompletion:(void (^)(NSError *error, NSString *msg))completion
{
    NSString* code = [self getLanguageCode];
    NSString *valueOfBoolean;
    
    if(value)
    {
        valueOfBoolean = @"true";
    }
    else
    {
        valueOfBoolean = @"false";
    }

    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:valueOfBoolean forKey:@"value"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@managegoogleaccount.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(jsonError, nil);
            } else {
                
                NSString *msg = response[@"msg"];
                
                completion(nil, msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method will post a json to the server containing the information to register a user onto the system, then it will call the completion block passing it the parameters

 @param fullname The user's full name
 @param username The user's username
 @param email The user's email address
 @param password The user's password
 @param base64Thumbnail The base64 string containing the user's image
 @param completion The completion block
 */
- (void)registerWithFullname:(NSString *)fullname username:(NSString *)username email:(NSString *)email password:(NSString *)password thumbnail:(NSString *)base64Thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:username forKey:@"username"];
    [dataToPost setValue:password forKey:@"pass"];
    [dataToPost setValue:fullname forKey:@"fullname"];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:base64Thumbnail forKey:@"thumbnail"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@register.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}

- (void)registerWithGoogleWithFullname:(NSString *)fullname username:(NSString *)username email:(NSString *)email password:(NSString *)password thumbnail:(NSString *)thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:username forKey:@"username"];
    [dataToPost setValue:password forKey:@"pass"];
    [dataToPost setValue:fullname forKey:@"fullname"];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:thumbnail forKey:@"thumbnail"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@registerwithgoogle.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method will post a json to the sever containing the information needed to change the password, then it calls the completion block passing it the parameters

 @param email The user's email address
 @param completion The completion block
 */
- (void)forgotPasswordWith:(NSString *)email andCompletion:(void (^)(NSString *response, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@iforgot.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError,nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                NSArray *resultsFromApi = response[@"results"];
                
                if(success.boolValue)
                {
                    NSDictionary *dictionary = resultsFromApi.firstObject;
                    NSNumber *userId = dictionary[@"id"];
                    NSString *code = dictionary[@"code"];
                    completion([NSString stringWithFormat:@"%@;%@",userId,code], nil, msg);        
                }
                else
                {
                    completion(nil, nil, msg);
                }
            }
        }
    }];
    
    [task resume];
}


/**
 This method will post a json to the server containing the userId and a new password so the server updates it, then it will call the completion block passing it the parameters

 @param password The new password
 @param userId The userId (it can be nil)
 @param completion The completion block
 */
- (void)changePasswordWithPassword:(NSString *)password userId:(NSNumber *)userId andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSNumber *idToPost = userId ? userId : [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:idToPost forKey:@"id"];
    [dataToPost setValue:PROFILE forKey:@"type"];
    [dataToPost setValue:[NSString stringWithFormat:@"%@;",password] forKey:@"content"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@updatedata.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method makes a get resquest with the necessary information to get the user data from the server, it then calls the completion block passing it the parameters

 @param type The type to be fetched from the server, ex: profile, movies, tvshows or recent
 @param completion The completion block
 */
- (void)getUserData:(NSString *)type andCompletion:(void (^)(NSMutableArray <Show *> *data, NSError *error))completion
{
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@getdata.php?idUser=%@&type=%@&lang=%@&time=%ld",BASE_URL,userId,type,code,[self getTimeStamp]];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError);
            } else {
                
                NSNumber *success = response[@"success"];
                NSArray *resultsFromApi = response[@"results"];
                NSMutableArray <Show *> *shows = [NSMutableArray new];
                if(success.boolValue)
                {
                    for (NSDictionary *dictionary in resultsFromApi) {
                        Show *show = [[Show alloc] initWithDictionary:dictionary];
                        [shows addObject:show];
                    }
                    
                    completion(shows, nil);
                }
                else
                {
                    completion(nil,nil);
                }
                
            }
        }
    }];
    
    [task resume];
}


- (void)getTotalWatchedVideosFromServer:(bool)isSaving AndValue:(int)value AndCompletion:(void (^)(int value, bool success, int errorCode, NSError *error))completion
{
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSString* boolToSend = isSaving ? @"true" : @"false";
    
    NSString *stringURL = [NSString stringWithFormat:@"%@rewardedvideos.php?idUser=%@&isSaving=%@&value=%d&lang=%@",BASE_URL,userId,boolToSend,value,code];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(0, NO, 0, error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(0, NO, 0, jsonError);
            } else {
                
                NSNumber *success = response[@"success"];
                NSNumber *videosWatched = response[@"videos_watched"];
                NSNumber *errorCode = response[@"error"];
                
                completion(videosWatched.intValue, success.boolValue, errorCode.intValue, error);
                
            }
        }
    }];
    
    [task resume];
}


/**
 This method makes a get call to the server to fetch the user profile, then it calls the completion block

 @param completion The completion block
 */
- (void)getUserProfileWithCompletion:(void (^)(User *user, NSError *error))completion
{
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@getdata.php?idUser=%@&type=%@&lang=%@",BASE_URL,userId,PROFILE,code];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError);
            } else {
                
                NSNumber *success = response[@"success"];
                NSArray *resultsFromApi = response[@"results"];
                NSMutableArray <User *> *users = [NSMutableArray new];
                if(success.boolValue)
                {
                    for (NSDictionary *dictionary in resultsFromApi) {
                        User *user = [[User alloc] initWithDictionary:dictionary];
                        [users addObject:user];
                    }
                    
                    completion(users.firstObject, nil);
                }
                else
                {
                    completion(nil,nil);
                }
                
            }
        }
    }];
    
    [task resume];
}


/**
 This method posts a json to the server with the information to update an object, it can be a tvshow a movie, a recent or a user profile

 @param type The type of the object to be updated
 @param userId The data id of the object to update (it can be a tv show id, a movie id or a user id)
 @param content The content to be updated
 @param completion The completion block
 */
- (void)updateUserDataWith:(NSString *)type userID:(NSNumber *)userId content:(NSString *)content andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:userId forKey:@"id"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld", (long)[UserDefaultsManager getUserId] ]forKey:@"idUser"];
    [dataToPost setValue:type forKey:@"type"];
    [dataToPost setValue:content forKey:@"content"];
    [dataToPost setValue:code forKey:@"lang"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld", [self getTimeStamp]] forKey:@"time"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@updatedata.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method posts a json with an user id to the server so it deletes it's account and all the information belonging to it, then it calls the completion block

 @param completion The completion block
 */
- (void)deleteUserAccountWithCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;

    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:userId forKey:@"id"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@deleteuser.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method posts a json to the server to delete an object, then it calls the completion block passing it the parameters

 @param dataId The object id to be deleted
 @param type The type of the object
 @param completion The completion block
 */
- (void)deleteUserDataWithId:(NSNumber *)dataId type:(NSString *)type andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:dataId forKey:@"id"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld", [UserDefaultsManager getUserId]] forKey:@"idUser"];
    [dataToPost setValue:type forKey:@"type"];
    [dataToPost setValue:code forKey:@"lang"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld", [self getTimeStamp]] forKey:@"time"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@deletedata.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method will post a json to the server containing the infromation to add a thumbanail to a show, then it calls the completion block passing it the parameters

 @param title The original title of the show
 @param thumbnail The base64 string containing the image data
 @param completion The completion block
 */
- (void)uploadThumbnailToServerWithTitle:(NSString *)title thumbnail:(NSString *)thumbnail andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:title forKey:@"title"];
    [dataToPost setValue:thumbnail forKey:@"thumb"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@savethumbnail.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}

/**
 This method will post to the server a json containing the information for a bug, then it calls the completion block passing it the parameters

 @param title The bug title
 @param fullname The user's full name
 @param email The user's email address
 @param content The full bug description if possible
 @param completion The completion block
 */
- (void)sendBugReportWithTitle:(NSString *)title fullname:(NSString *)fullname email:(NSString *)email content:(NSString *)content andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:title forKey:@"title"];
    [dataToPost setValue:fullname forKey:@"name"];
    [dataToPost setValue:email forKey:@"email"];
    [dataToPost setValue:content forKey:@"body"];
    [dataToPost setValue:code forKey:@"lang"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@bugreport.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue, nil,msg);
            }
        }
    }];
    
    [task resume];
}


/**
 This method will post a json to the server containing the information to add a show to an user, then it calls the completion block passing it the parameters

 @param type The type of the show
 @param title The show's title
 @param watchedTime The show's watched time
 @param season The show's season
 @param episode The show's episode
 @param completed The show's completed state
 @param completion The completion block
 */
- (void)saveUserDataWithType:(NSString *)type title:(NSString *)title watchedTime:(NSString *)watchedTime season:(NSString *)season episode:(NSString *)episode completed:(NSNumber *)completed andCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:userId forKey:@"idUser"];
    [dataToPost setValue:type forKey:@"type"];
    [dataToPost setValue:title forKey:@"title"];
    [dataToPost setValue:watchedTime forKey:@"watchedtime"];
    [dataToPost setValue:season forKey:@"season"];
    [dataToPost setValue:episode forKey:@"episode"];
    [dataToPost setValue:completed forKey:@"completed"];
    [dataToPost setValue:code forKey:@"lang"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld",[self getTimeStamp]] forKey:@"time"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@savedata.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue,nil,msg);
            }
        }
    }];
    
    [task resume];
}

- (void)buyPremiumWithCompletion:(void (^)(BOOL success, NSError *error, NSString *msg))completion
{
    
    NSNumber *userId = [ShowsOfflineManager allUsers].firstObject.userId;
    
    NSString* code = [self getLanguageCode];
    
    NSMutableDictionary *dataToPost = [NSMutableDictionary new];
    [dataToPost setValue:userId forKey:@"idUser"];
    [dataToPost setValue:DEVICE_IOS forKey:@"device"];
    [dataToPost setValue:code forKey:@"lang"];
    [dataToPost setValue:[NSString stringWithFormat:@"%ld",[self getTimeStamp]] forKey:@"time"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToPost options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@premium.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                completion(success.boolValue,nil,msg);
            }
        }
    }];
    
    [task resume];
}

-(void)checkAppVersionWithCompletion:(void (^)(NSNumber *version))completion
{
    NSString *stringURL = [NSString stringWithFormat:@"%@checkappversion.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil);
            } else {
                
                NSNumber *version = response[@"versionIOS"];
                completion(version);
            }
        }
    }];
    
    [task resume];
}

-(void)checkIfAppWasApprovedForAppStore:(void (^)(NSNumber *))completion
{
    NSString *stringURL = [NSString stringWithFormat:@"%@checkifappwasapprovedforappstore.php",BASE_URL];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil);
            } else {
                
                NSNumber *wasApproved = response[@"was_approved"];
                completion(wasApproved);
            }
        }
    }];
    
    [task resume];
}

- (void)checkIfUserHasPreviouslyPurchasedPremium:(NSString *)email AndCompletion:(void (^)(int value, NSError *error))completion
{
    
    NSString *stringURL = [NSString stringWithFormat:@"%@transactions.php?email=%@",BASE_URL,email];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(0,error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(0,jsonError);
            } else {
                
                NSNumber *status = response[@"has_previously_purchased"];
                
                completion(status.intValue, nil);
                
            }
        }
    }];
    
    [task resume];
}

/**
 This method will check in the background if the user is still a valid user if there is internet connection, after that will it call the completion block passing it the arguments

 @param completion The completion block to be executed
 */
-(void)checkIfUserIsStillValidWithCompletion:(void (^)(BOOL, NSError *, NSString *, NSNumber *))completion
{
    NSString *username = [ShowsOfflineManager allUsers].firstObject.userName;
    NSString* code = [self getLanguageCode];

    NSString *stringURL = [NSString stringWithFormat:@"%@checkuser.php?username=%@&lang=%@",BASE_URL,username,code];
    // URL
    NSURL *url = [NSURL URLWithString:stringURL];
    
    // Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    // Session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            completion(nil, error, nil, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonError != nil) {
                completion(nil, jsonError, nil, nil);
            } else {
                
                NSNumber *success = response[@"success"];
                NSString *msg = response[@"msg"];
                NSNumber *timeStamp = response[@"last_activity"];
                completion(success.boolValue, nil,msg,timeStamp);
            }
        }
    }];
    
    [task resume];
}


/**
 This method gets the preffered language from the user's system

 @return Returns a string with language code
 */
-(NSString *)getLanguageCode
{
    return [SharedMethods getUserLocale];
}

-(long)getTimeStamp
{
    long timeStamp = [SharedMethods getCurrentTimeStamp];
    [UserDefaultsManager saveTimeStamp:timeStamp];
    return timeStamp;
}

@end
