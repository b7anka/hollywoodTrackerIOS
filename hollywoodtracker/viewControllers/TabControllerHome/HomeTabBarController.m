//
//  HomeTabBarController.m
//  hollywoodtracker
//
//  Created by Developer on 28/01/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "HomeTabBarController.h"
#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "UserDefaultsManager.h"
#import "Constants.h"

@interface HomeTabBarController () 


@end

@implementation HomeTabBarController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self selectedHomeScreen];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UserDefaultsManager getHomeScreenChanged])
    {
        [UserDefaultsManager saveHomeScreenChanged:NO];
        [self selectedHomeScreen];
    }
}



/**
 Sets the tab bar item to the index saved by the user
 */
-(void)selectedHomeScreen
{
    [self setSelectedIndex:[UserDefaultsManager getHomeScreenToUse]];
}



@end
