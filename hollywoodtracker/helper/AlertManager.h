//
//  AlertManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 30/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertManager : NSObject

#pragma mark - Class Methods

+(void)showErrorAlertWithError:(NSError *)error andViewController:(UIViewController *)controller;
+(void)showErrorAlertWithText:(NSString *)text andViewController:(UIViewController *)controller;
+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray <UIAlertAction *> *)actions andViewController:(UIViewController *)controller;
+(void)showInfoAlertWithText:(NSString *)msg andViewController:(UIViewController *)controller;
+(void)showNoInternetAlertWithViewController:(UIViewController *)controller;
@end

