//
//  AboutViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "AboutViewController.h"
#import "UserDefaultsManager.h"
#import "Constants.h"
#import "SharedMethods.h"
#import "AlertManager.h"
#import "NetworkManager.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Actions

- (IBAction)logoutButtonClicked:(UIBarButtonItem *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)rateMyApp:(UIButton *)sender {
    if([NetworkManager isInternetAvailable]){
        [SharedMethods openAppStoreAppPage];
    }else {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}


@end
