//
//  AddShowViewController.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 01/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BaseScrollViewController.h"
#import "Show.h"

@class AddShowViewController;

@protocol AddShowDelegate <NSObject>

#pragma mark - Protocol Methods

@required

-(void)addShowControllerDidAddShow:(AddShowViewController *)controller;
-(void)addShowController:(AddShowViewController *)controller didUpdateShow:(Show *)show;

@end

@interface AddShowViewController : BaseScrollViewController

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UITextField *showTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *showWatchedTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *showSeasonTextField;
@property (weak, nonatomic) IBOutlet UITextField *showEpisodeTextField;

#pragma mark - Properties

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Show *show;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) BOOL isEditing;
@property (weak, nonatomic) id <AddShowDelegate> delegate;

@end
