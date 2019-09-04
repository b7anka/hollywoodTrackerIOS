//
//  Show.h
//  hollywoodtracker
//
//  Created by Developer on 28/01/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject
@property(strong,nonatomic)NSNumber *showId;
@property(strong,nonatomic)NSString *title;
@property(strong,nonatomic)NSString *watchedTime;
@property(strong,nonatomic)NSString *season;
@property(strong,nonatomic)NSString *episode;
@property(strong,nonatomic)NSString *type;
@property(strong,nonatomic)NSString *thumbnail;
@property(strong,nonatomic)NSNumber *completed;

-(instancetype)initWithDictionary:(NSDictionary *) dictionary;

@end

