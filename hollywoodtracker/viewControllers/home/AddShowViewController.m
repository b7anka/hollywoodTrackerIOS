//
//  AddShowViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 01/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "AddShowViewController.h"
#import "SharedMethods.h"
#import "ValidateInputs.h"
#import "InterfaceAPI.h"
#import "NetworkManager.h"
#import "ShowsOfflineManager.h"
#import "LocalNotificationsManager.h"
#import "UserDefaultsManager.h"
#import "AlertManager.h"
#import "Constants.h"

@interface AddShowViewController () <UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UISwitch *isBeginningSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

#pragma mark - Properties

@property (strong, nonatomic) InterfaceAPI *interfaceAPI;

@end

@implementation AddShowViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    [self.showTitleTextField becomeFirstResponder];
    self.showTitleTextField.delegate = self;
    self.showWatchedTimeTextField.delegate = self;
    if([self.type isEqualToString:TV_SHOWS])
    {
        [self.showSeasonTextField setHidden:NO];
        [self.showEpisodeTextField setHidden:NO];
        self.showSeasonTextField.delegate = self;
        self.showEpisodeTextField.delegate = self;
    }
    
    if(self.isEditing)
    {
        [self populateFieldsToEditShow];
    }
}

/**
 This method validates the title and the watched time of a show

 @param title The title to be validate
 @param watchedTime The watched time to be validated
 @return Returns yes if both are valid, no if any one of them is invalid
 */
-(BOOL)validateTitleAndWatchedTimeWithTitle:(NSString *)title andWatchedTime:(NSString *)watchedTime
{
    if(![ValidateInputs validateTitleWithTitle:title])
    {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"title_requirements", @"") andViewController:self];
        return NO;
    }else if(![ValidateInputs validateWatchedTimeWithTime:watchedTime])
    {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"watched_time_requirements", @"") andViewController:self];
        return NO;
    }
    
    return YES;
}

/**
 This method validates all user's inputs to check if they are empty or not and if they comply with the regexs in the ValidateInputs.h class and if they do it will call the updateUserData method or saveUserData method based on the boolean isEditing. if isEditing is true then it will also call the method updateOfflineData
 */
-(void)validateInputs
{
    NSString *content;
    
    NSString *trimmedTitle =[self.showTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedWtachedTime = [self.showWatchedTimeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSNumber *completed = [NSNumber numberWithInteger:NOT_COMPLETED];
    
    if([self.type isEqualToString:TV_SHOWS])
    {
        NSString *trimmedSeason = [self.showSeasonTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *trimmedEpisode = [self.showEpisodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if([SharedMethods checkForEmptyUserInputs:@[trimmedTitle,trimmedWtachedTime,trimmedSeason,trimmedEpisode]])
        {
            [AlertManager showErrorAlertWithText:NSLocalizedString(@"on_empty_user_inputs", @"") andViewController:self];
        }
        else
        {
            long season = [trimmedSeason integerValue];
            long episode = [trimmedEpisode integerValue];
            
            if(season < BELOW_TEN)
            {
                trimmedSeason = [NSString stringWithFormat:@"0%ld",season];
                self.showSeasonTextField.text = trimmedSeason;
            }
            
            if(episode < BELOW_TEN)
            {
                trimmedEpisode = [NSString stringWithFormat:@"0%ld",episode];
                self.showEpisodeTextField.text = trimmedEpisode;
            }
            
            if([self validateTitleAndWatchedTimeWithTitle:trimmedTitle andWatchedTime:trimmedWtachedTime])
            {
                if(![ValidateInputs validateSeasonWithSeason:trimmedSeason])
                {
                    [AlertManager showErrorAlertWithText:NSLocalizedString(@"season_requirements", @"") andViewController:self];
                }else if(![ValidateInputs validateEpisodeWithEpisode:trimmedEpisode])
                {
                    [AlertManager showErrorAlertWithText:NSLocalizedString(@"episode_requirements", @"") andViewController:self];
                }else
                {
                    if(self.isEditing)
                    {
                        self.show.title = trimmedTitle;
                        self.show.watchedTime = trimmedWtachedTime;
                        self.show.season = [NSString stringWithFormat:@"%ld",season];
                        self.show.episode = [NSString stringWithFormat:@"%ld",episode ];
                        self.show.completed = completed;
                        content = [NSString stringWithFormat:@"%@;%@;%@;%@;%@",trimmedTitle,trimmedSeason,trimmedEpisode,trimmedWtachedTime,completed];
                        if([NetworkManager isInternetAvailable])
                        {
                            [self updateUserDataWithId:self.show.showId type:self.type andContent:content];
                        }
                        [self updateOfflineDataWithShow:self.show type:self.type andContent:content];
                    }
                    else
                    {
                        [self saveUserDataWithType:self.type tittle:trimmedTitle watchedTime:trimmedWtachedTime season:trimmedSeason episode:trimmedEpisode andCompleted:completed];
                    }
                    [self.saveButton setEnabled:NO];
                }
            }
        }
    }
    else
    {
        if([SharedMethods checkForEmptyUserInputs:@[trimmedTitle,trimmedWtachedTime]])
        {
            [AlertManager showErrorAlertWithText:NSLocalizedString(@"on_empty_user_inputs", @"") andViewController:self];
        }
        else
        {
            if([self validateTitleAndWatchedTimeWithTitle:trimmedTitle andWatchedTime:trimmedWtachedTime])
            {
                if(self.isEditing)
                {
                    self.show.title = trimmedTitle;
                    self.show.watchedTime = trimmedWtachedTime;
                    self.show.completed = completed;
                    content = [NSString stringWithFormat:@"%@;%@;%@",trimmedTitle,trimmedWtachedTime,completed];
                    if([NetworkManager isInternetAvailable])
                    {
                        [self updateUserDataWithId:self.show.showId type:self.type andContent:content];
                    }
                    [self updateOfflineDataWithShow:self.show type:self.type andContent:content];
                }
                else
                {
                    [self saveUserDataWithType:self.type tittle:trimmedTitle watchedTime:trimmedWtachedTime season:@"0" episode:@"0" andCompleted:completed];
                }
                [self.saveButton setEnabled:NO];
            }
        }
    }
}

/**
 This method will update the show in core data and if no internet connection is found it will save the updated information in core data to be communicated to the server later

 @param show The updated show
 @param type The show's type
 @param content The updated content
 */
-(void)updateOfflineDataWithShow:(Show *)show type:(NSString *)type andContent:(NSString *)content
{
    NSString *entity = [type isEqualToString:MOVIES] ? @"Movie" : @"TvShow";
    NSString *notificationTitle = [show.type isEqualToString:@"movie"] ? NSLocalizedString(@"movie", @"") : NSLocalizedString(@"episode", @"");

    [ShowsOfflineManager updateShowWithShow:show orUser:nil andEntity:entity];
    [self.delegate addShowController:self didUpdateShow:show];
    
  if(![NetworkManager isInternetAvailable])
  {
      [ShowsOfflineManager createOfflineDataChangeWithId:show.showId.integerValue type:type andContent:content];
      [LocalNotificationsManager showNotificationWithMsg:NSLocalizedString(@"offline_changes_message", @"") andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle,NSLocalizedString(@"updated", @"")]];
  }
    [self.saveButton setEnabled:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 
 This method will call the interfaceAPI saveUserData to tell the server to create a show with this information for this user if there's internet connection available and it will save in user defaults the information that the user profile needs to be updated, sums 1 to the user's tvshows or movies property based on the type parameter and calls the method DidAddShow on it's delegate, otherwise it will display an alert telling the user that there is no internet connection available

 @param type The show's type
 @param title The show's title
 @param watchedTime The show's watched time
 @param season The show's season
 @param episode The show's episode
 @param completed The show's completed state
 */
-(void)saveUserDataWithType:(NSString *)type tittle:(NSString *)title watchedTime:(NSString *)watchedTime season:(NSString *)season episode:(NSString *)episode andCompleted:(NSNumber *)completed
{
    if([NetworkManager isInternetAvailable])
    {
        [self.activityIndicator startAnimating];
        
        __weak AddShowViewController *weakSelf = self;
        
        [self.interfaceAPI saveUserDataWithType:type title:title watchedTime:watchedTime season:season episode:episode completed:completed andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                [weakSelf.saveButton setEnabled:YES];
                [weakSelf.activityIndicator stopAnimating];
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(success){
                    [weakSelf.delegate addShowControllerDidAddShow:self];
                    NSString *notificationTitle = [type isEqualToString:MOVIES] ? NSLocalizedString(@"movie", @"") : NSLocalizedString(@"episode", @"");
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle,NSLocalizedString(@"added", @"")]];
                    [UserDefaultsManager saveUserProfileNeedsUpdating:YES];
                    [ShowsOfflineManager addShowToUser:type];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
            }];
            
        }];
    }else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
    [self.saveButton setEnabled:YES];
    [self.activityIndicator stopAnimating];
}

/**
 This method will call the interfaceAPI updateUserData to inform the server to update the show, it will then call the DidCompletedShow method or the DidUpdateShow method on it's delegate based on the completed variable

 @param idToUpdate The show's id to be updated
 @param type The show's type
 @param content The content to be updated
 */
-(void)updateUserDataWithId:(NSNumber *)idToUpdate type:(NSString *)type andContent:(NSString *)content
{
    [self.activityIndicator startAnimating];
    
    __weak AddShowViewController *weakSelf = self;
    
    [self.interfaceAPI updateUserDataWith:type userID:idToUpdate content:content andCompletion:^(BOOL success, NSError *error, NSString *msg) {
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (error) {
                [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
            } else if(success){

                [weakSelf.delegate addShowController:weakSelf didUpdateShow:weakSelf.show];
                
                NSString *notificationTitle = [type isEqualToString:MOVIES] ? NSLocalizedString(@"movie", @"") : NSLocalizedString(@"episode", @"");
                [LocalNotificationsManager showNotificationWithMsg:msg andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle, NSLocalizedString(@"updated", @"")]];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else
            {
                [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
            }
            [weakSelf.saveButton setEnabled:YES];
            [weakSelf.activityIndicator stopAnimating];
        }];
        
    }];
}

/**
 This method populates the textfields with the show's information if the isEditing property is true
 */
-(void)populateFieldsToEditShow
{
    self.showTitleTextField.text = self.show.title;
    self.showWatchedTimeTextField.text = self.show.watchedTime;
    
    if([self.type isEqualToString:TV_SHOWS])
    {
        self.showSeasonTextField.text = self.show.season;
        self.showEpisodeTextField.text = self.show.episode;
    }
}

#pragma mark - Actions

- (IBAction)isBeginningSwitchValueChnaged:(UISwitch *)sender
{
    if(sender.isOn)
    {
        self.showWatchedTimeTextField.text = BEGINNING_WATCH_TIME;
        [self.showWatchedTimeTextField setEnabled:NO];
        if([self.type isEqualToString:TV_SHOWS])
        {
            [self.showSeasonTextField becomeFirstResponder];
        }
    }
    else
    {;
        self.showWatchedTimeTextField.text = @"";
        [self.showWatchedTimeTextField setEnabled:YES];
    }
}
- (IBAction)saveButtonClicked:(UIButton *)sender
{
    [self validateInputs];
}

#pragma mark - Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.showTitleTextField)
    {
        [self.showWatchedTimeTextField becomeFirstResponder];
    }else if(textField == self.showWatchedTimeTextField && [self.type isEqualToString:TV_SHOWS])
    {
        [self.showSeasonTextField becomeFirstResponder];
    }
    else if(textField == self.showSeasonTextField && [self.type isEqualToString:TV_SHOWS])
    {
        [self.showEpisodeTextField becomeFirstResponder];
    }
    else
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
        [self validateInputs];
    }
    return YES;
}
@end
