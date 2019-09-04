//
//  User.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 24/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface User : NSObject

@property(strong,nonatomic)NSString *userName;
@property(strong,nonatomic)NSString *password;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *fullName;
@property(strong,nonatomic)NSString *thumbnail;
@property(strong,nonatomic)NSNumber *userId;
@property(strong,nonatomic)NSNumber *premium;
@property(strong,nonatomic)NSNumber *recentlyWatched;
@property(strong,nonatomic)NSNumber *movies;
@property(strong,nonatomic)NSNumber *tvShows;
@property(strong,nonatomic)NSNumber *total;

-(instancetype)initWithDictionary:(NSDictionary *) dictionary;

@end
