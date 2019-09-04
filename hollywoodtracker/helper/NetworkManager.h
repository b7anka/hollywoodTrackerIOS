//
//  NetworkManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkManager : NSObject

#pragma mark - Class Methods

+(BOOL)isInternetAvailable;

@end

