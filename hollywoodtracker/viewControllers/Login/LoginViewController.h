//
//  LoginViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseScrollViewController.h"
#import "User.h"

@interface LoginViewController : BaseScrollViewController

#pragma mark - Properties

@property(weak,nonatomic) User *user;

@end
