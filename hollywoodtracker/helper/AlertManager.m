//
//  AlertManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 30/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "AlertManager.h"
#import "SharedMethods.h"

@implementation AlertManager

#pragma mark - Class Methods


/**
 This method presents the user an alert with an error information

 @param error The error to be showed
 @param controller The controller on wich this alert should be presented
 */
+(void)showErrorAlertWithError:(NSError *)error andViewController:(UIViewController *)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will display an error alert to the user with a string as it's message

 @param text The string to be displayed
 @param controller The controller on which this should be presented
 */
+(void)showErrorAlertWithText:(NSString *)text andViewController:(UIViewController *)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will display an alert telling the user that there is no internet connection available

 @param controller The controller on wich this should be presented
 */
+(void)showNoInternetAlertWithViewController:(UIViewController *)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:NSLocalizedString(@"no_internet", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}

/**
 This method will display an alert to the user with a custom image and a default action that will dismiss the view controller on wich this method is called

 @param msg The message to be showed
 @param controller The controller on wich this method should be called
 */
+ (void)showInfoAlertWithText:(NSString *)msg andViewController:(UIViewController *)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"information", @"") message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}

/**
 This method displays an alert with a custom title, custom message and with actions

 @param title The title to be used
 @param message The message to be displayed
 @param actions The actions to be added to the alert
 @param controller The controller on wich this should be presented
 */
+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray <UIAlertAction *> *)actions andViewController:(UIViewController *)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}
@end
