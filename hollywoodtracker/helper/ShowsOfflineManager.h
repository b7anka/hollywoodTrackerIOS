//
//  ShowsOfflineManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieMO+CoreDataProperties.h"
#import "TvShowMO+CoreDataProperties.h"
#import "RecentMO+CoreDataProperties.h"
#import "UserMO+CoreDataProperties.h"
#import "OfflineChangesMO+CoreDataProperties.h"
#import "Show.h"
#import "User.h"

@interface ShowsOfflineManager : NSObject

#pragma mark - Class Methods

+(void)addShowToUser:(NSString *)type;
+(void)removeShowFromUser:(NSString *)type;
+ (BOOL)createShowWithShow:(Show *)show andEntity:(NSString *)entity;
+ (BOOL)createOfflineDataChangeWithId:(NSInteger)idToChange type:(NSString *)type andContent:(NSString *)content;
+ (BOOL)createUserWithUser:(User *)user;
+ (BOOL)updateShowWithShow:(Show *)show orUser:(User *)user andEntity:(NSString *)entity;
+ (NSString *)saveImage:(NSString *)imageURL orImage:(UIImage *)image;
+ (NSMutableArray<Show *> *)allResultsWithEntity:(NSString *)entity;
+ (NSMutableArray<User *> *)allUsers;
+ (NSArray<OfflineChangesMO *> *)allOfflineChanges;
+ (UIImage *)imageForShow:(Show *)show orUser:(User *)user;
+ (void)deleteAllObjects:(NSString *)entityName;
+ (void)deleteShow:(Show *)show withEntity:(NSString *)entity;
+(void)deleteOfflineChange:(OfflineChangesMO *)change;
+(NSString *)imageNameForShow:(Show *)show withEntity:(NSString *)entity;

@end

