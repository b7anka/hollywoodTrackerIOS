//
//  RegisterViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BaseScrollViewController.h"

@interface RegisterViewController : BaseScrollViewController

#pragma mark - Properties

@property(weak,nonatomic) User *response;

@end

