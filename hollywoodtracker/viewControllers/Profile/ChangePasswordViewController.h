//
//  ChangePasswordViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BaseScrollViewController.h"
@class ChangePasswordViewController;

@protocol ChangePasswordDelegate <NSObject>

#pragma mark - Protocol Methods

@required

-(void)changePassWordViewController:(ChangePasswordViewController *)controller didChangePassword:(NSString *)password;

@end

@interface ChangePasswordViewController : BaseScrollViewController

#pragma mark - Properties

@property(strong,nonatomic)NSString *currentPassword;
@property(weak, nonatomic) id <ChangePasswordDelegate> delegate;

@end
