//
//  SettingsViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsDelegate <NSObject>

#pragma mark - Protocol Methods

@required
-(void)settingsController:(SettingsViewController *)controller didChangeHomeScreen:(NSUInteger)screen;
@end


@interface SettingsViewController : UIViewController

#pragma mark - Properties

@property (weak, nonatomic)id <SettingsDelegate> delegate;

@end
