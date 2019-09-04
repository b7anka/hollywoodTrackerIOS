//
//  User.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 24/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "User.h"

@implementation User
-(instancetype)initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if(self)
    {
        _userId = dictionary[@"id"];
        _userName = dictionary[@"username"];
        _fullName = dictionary[@"fullname"];
        _email = dictionary[@"email"];
        _thumbnail = dictionary[@"thumbnail"];
        _premium = dictionary[@"premium"];
        _recentlyWatched = dictionary[@"recentlywatched"];
        _movies = dictionary[@"movies"];
        _tvShows = dictionary[@"tvshows"];
        _total = dictionary[@"total"];
    }
    return self;
}
@end
