//
//  BackgroundUserValidationManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 21/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceAPI.h"

@class BackgroundUserValidationManager;

@protocol BackgroundValidationDelegate <NSObject>

@required

#pragma mark - Protocol Methods

-(void)backgroundValidationManager:(BackgroundUserValidationManager *)manager didFinishCheckingUserValidity:(BOOL)success;

@end

@interface BackgroundUserValidationManager : NSObject

#pragma mark - Properties

@property(weak, nonatomic)id <BackgroundValidationDelegate> delegate;

#pragma mark - Methods

-(void)checkIfUserIsStillValid;

@end

