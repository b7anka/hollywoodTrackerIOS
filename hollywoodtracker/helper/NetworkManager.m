//
//  NetworkManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

#pragma mark - Class Methods


/**
 This method checks if there is an internet connection available using an implementation of apple's reachability class

 @return Return the network status
 */
+(BOOL)isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
