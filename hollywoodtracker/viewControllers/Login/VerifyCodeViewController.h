//
//  VerifyCodeViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 26/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BaseViewController.h"

@interface VerifyCodeViewController : BaseViewController

#pragma mark - Properties

@property(strong,nonatomic) NSNumber *userId;
@property(strong,nonatomic) NSString *code;

@end
