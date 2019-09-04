//
//  BackgroundUserValidationManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 21/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "BackgroundUserValidationManager.h"


@implementation BackgroundUserValidationManager

#pragma mark - Methods

- (void)checkIfUserIsStillValid
{
    InterfaceAPI *interfaceAPI = [InterfaceAPI new];
    
    __weak BackgroundUserValidationManager *weakSelf = self;
    
    [interfaceAPI checkIfUserIsStillValidWithCompletion:^(BOOL success, NSError *error, NSString *msg, NSNumber *timeStamp) {
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (error) {
                [weakSelf.delegate backgroundValidationManager:weakSelf didFinishCheckingUserValidity:NO];
            } else {
                [weakSelf.delegate backgroundValidationManager:weakSelf didFinishCheckingUserValidity:success];
            }
            
        }];
    }];
}

@end
