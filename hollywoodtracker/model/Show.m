//
//  Show.m
//  hollywoodtracker
//
//  Created by Developer on 28/01/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "Show.h"

@implementation Show
-(instancetype)initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if(self)
    {
        _showId = dictionary[@"id"];
        _title = dictionary[@"title"];
        _season = dictionary[@"season"];
        _episode = dictionary[@"episode"];
        _type = dictionary[@"type"];
        _watchedTime = dictionary[@"timewatched"];
        _completed = dictionary[@"completed"];
        _thumbnail = dictionary[@"thumbnail"];
    }
    return self;
}
@end
