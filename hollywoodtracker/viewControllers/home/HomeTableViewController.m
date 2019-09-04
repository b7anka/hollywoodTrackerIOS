//
//  HomeTableViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 25/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "HomeTableViewController.h"
#import "SharedMethods.h"
#import "DataTableViewCell.h"
#import "InterfaceAPI.h"
#import "AlertManager.h"
#import "Constants.h"
#import "AddShowViewController.h"
#import "ComunicateChangesToServerManager.h"
#import "ShowsOfflineManager.h"
#import "UserDefaultsManager.h"
#import "SettingsViewController.h"
#import "LocalNotificationsManager.h"
#import "BackgroundUserValidationManager.h"
#import "ImageManager.h"
#import "NetworkManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AdsManager.h"

@interface HomeTableViewController () <AddShowDelegate, OfflineChangesDelegate, ImageManagerDelegate, BackgroundValidationDelegate>

#pragma mark - Properties

@property(strong,nonatomic)InterfaceAPI *interfaceAPI;
@property(strong,nonatomic)NSNumber *userId;
@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *password;
@property(strong,nonatomic)NSMutableArray <Show *> *showsArray;
@property(strong,nonatomic)ComunicateChangesToServerManager *offlineManager;
@property(nonatomic)NSInteger offlineChangesCounter;
@property(strong,nonatomic) User *user;
@property(strong,nonatomic) NSString* type;
@property(strong,nonatomic)ImageManager *imageManager;
@property(strong,nonatomic)BackgroundUserValidationManager *backgroundValidationManager;

#pragma mark - Outlets

@property (strong, nonatomic) IBOutlet UIBarButtonItem *buyPremiumButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *getPremiumForFreeButton;

@end

@implementation HomeTableViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [ShowsOfflineManager allUsers].firstObject;
    
    if(self.tabBarController.selectedIndex == 0)
    {
        self.type = MOVIES;
    }else if(self.tabBarController.selectedIndex == 1)
    {
        self.type = TV_SHOWS;
    }else
    {
        self.type = RECENTLY_WATCHED;
    }
    
    self.interfaceAPI = [InterfaceAPI new];
    self.showsArray = [NSMutableArray new];
    self.offlineManager = [ComunicateChangesToServerManager new];
    self.offlineManager.delegate = self;
    self.imageManager = [ImageManager new];
    self.imageManager.delegate = self;
    self.backgroundValidationManager = [BackgroundUserValidationManager new];
    self.backgroundValidationManager.delegate = self;
    self.userId  = self.user.userId;
    self.username = self.user.userName;
    self.password = self.user.password;
    [self hideGetPremiumForFreeButton];
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UserDefaultsManager getRecentNeedsUpdating] && [self.type isEqualToString:RECENTLY_WATCHED])
    {
        [UserDefaultsManager saveRecentNeedsUpdating:NO];
        self.showsArray = [ShowsOfflineManager allResultsWithEntity:@"Recent"];
        [self.tableView reloadData];
        [self checkIfArrayIsEmpty:self.showsArray];
    }
    [self checkAppVersion];
    [self checkIfUserIsPremium];
    [self addOrientationObservers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeOrientationObserver];
}

-(void)addOrientationObservers
{
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChangedWithNotification:) name:UIDeviceOrientationDidChangeNotification object:UIDevice.currentDevice];
}

-(void)removeOrientationObserver
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:UIDevice.currentDevice];
}

-(void)orientationChangedWithNotification:(NSNotification *)notification
{
    [self updateUI];
}

-(void)checkIfUserIsPremium
{
    if([UserDefaultsManager getUserPremium] == 1)
    {
        [self hideGetPremiumForFreeButton];
        if([UserDefaultsManager getPremiumWasBought]){
            [self hideBuyPremiumButton];
        }else {
             [self showBuyPremiumButton];
        }
    }
    else
    {
        [self showBuyPremiumButton];
        if([UserDefaultsManager getAppWasApprovedForAppStore]){
            [self showGetPremiumForFreeButton];
        }else {
            [self checkIfAppWasApprovedForAppStore];
        }
        
    }
    [self updateUI];
}

-(void)hideGetPremiumForFreeButton
{
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:self.getPremiumForFreeButton];
    [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
}

-(void)showGetPremiumForFreeButton
{
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    // This is how you add the button to the toolbar and animate it
    if (![toolbarButtons containsObject:self.getPremiumForFreeButton]) {
        [toolbarButtons addObject:self.getPremiumForFreeButton];
        [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    }
}

-(void)hideBuyPremiumButton
{
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.navigationItem.leftBarButtonItems mutableCopy];
    
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:self.buyPremiumButton];
    [self.navigationItem setLeftBarButtonItems:toolbarButtons animated:YES];
}

-(void)showBuyPremiumButton
{
    NSMutableArray *toolbarButtons = [self.navigationItem.leftBarButtonItems mutableCopy];
    
    // This is how you add the button to the toolbar and animate it
    if (![toolbarButtons containsObject:self.buyPremiumButton]) {
        [toolbarButtons addObject:self.buyPremiumButton];
        [self.navigationItem setLeftBarButtonItems:toolbarButtons animated:YES];
    }
}

/**
 When this method is called if there is internet connection available it will call a method that checks for any offline changes made by the user so that it informs the server before it will ask the server to get the user shows, otherwise it will get the user's shows from the core data based on the self.type property
 */
-(void)updateUI
{
    if([NetworkManager isInternetAvailable])
    {
        [self startRefreshControl];
        if([UserDefaultsManager getAutoLoginPreference])
        {
            [self.backgroundValidationManager checkIfUserIsStillValid];
        }
        else
        {
            [self checkForOfflineChanges];
        }
    }
    else
    {
        if([self.type isEqualToString:MOVIES])
        {
            self.showsArray = [ShowsOfflineManager allResultsWithEntity:@"Movie"];
        }else if([self.type isEqualToString:TV_SHOWS])
        {
            self.showsArray = [ShowsOfflineManager allResultsWithEntity:@"TvShow"];
        }else
        {
            self.showsArray = [ShowsOfflineManager allResultsWithEntity:@"Recent"];
        }
        
        [self checkIfArrayIsEmpty:self.showsArray];
    }
}

- (void)checkIfAppWasApprovedForAppStore{
    if([NetworkManager isInternetAvailable]){
        [self.interfaceAPI checkIfAppWasApprovedForAppStore:^(NSNumber *status) {

            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if(status.intValue == 1){
                    [UserDefaultsManager saveAppWasApprovedForAppStore:YES];
                    [self showGetPremiumForFreeButton];
                }else {
                    [self hideGetPremiumForFreeButton];
                }
            }];
        }];
    }else {
        
    }
}

/**
 This method will check if there are any offline changes made by the user, if so then it will communicate them to the server, otherwise it will get the user's shows from the server
 */
-(void)checkForOfflineChanges
{
    if([self.offlineManager hasDataChanges])
    {
        self.offlineChangesCounter = [ShowsOfflineManager allOfflineChanges].count;
        [self.offlineManager communicateChangesToServer];
    }
    else
    {
        [self getDataWithType:self.type];
    }
}

/**
 This method will call the interfaceAPI to ask the server for the user data based on the type sent, then it will assing the response to the self.showsArray property and after that loops the response and creates a show in core data for every show in the response array. It stops the refresh control as well

 @param type The shows type
 */
-(void)getDataWithType:(NSString *)type
{
    __weak HomeTableViewController *weakSelf = self;
    
    [self.interfaceAPI getUserData:type andCompletion:^(NSMutableArray<Show *> *data, NSError *error) {
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (error) {
                [AlertManager showErrorAlertWithError:error andViewController:self];
            } else {
                weakSelf.showsArray = data;
                [weakSelf checkIfArrayIsEmpty:weakSelf.showsArray];
                for (Show *show in data) {
                    if([self.type isEqualToString:MOVIES])
                    {
                        [ShowsOfflineManager createShowWithShow:show andEntity:@"Movie"];
                        NSUInteger index = [weakSelf.showsArray indexOfObject:show];
                        Show *tempShow = [weakSelf.showsArray objectAtIndex:index];
                        tempShow.thumbnail = [ShowsOfflineManager imageNameForShow:show withEntity:@"Movie"];
                    }else if([self.type isEqualToString:TV_SHOWS])
                    {
                        [ShowsOfflineManager createShowWithShow:show andEntity:@"TvShow"];
                        NSUInteger index = [weakSelf.showsArray indexOfObject:show];
                        Show *tempShow = [weakSelf.showsArray objectAtIndex:index];
                        tempShow.thumbnail = [ShowsOfflineManager imageNameForShow:show withEntity:@"TvShow"];
                    }else
                    {
                        [ShowsOfflineManager createShowWithShow:show andEntity:@"Recent"];
                        NSUInteger index = [weakSelf.showsArray indexOfObject:show];
                        Show *tempShow = [weakSelf.showsArray objectAtIndex:index];
                        tempShow.thumbnail = [ShowsOfflineManager imageNameForShow:show withEntity:@"Recent"];
                    }
                }
                [weakSelf.refreshControl endRefreshing];
            }
           
        }];
    }];
}


/**
 This method will check if the array received is empty or not, if empty it will call a method that sets the tableViewBackgroundView to a message label else it will remove it

 @param array The array to be checked
 */
-(void)checkIfArrayIsEmpty:(NSMutableArray <Show *> *)array
{
    if(array.count > 0)
    {
        self.tableView.backgroundView = nil;
    }
    else
    {
        [self setMessageToTableViewBackground];
    }
}

/**
 This is an override to the self.showsArray's setter that after assign it the new showsArray will reload the data in the tableView

 @param showsArray The new showsArray
 */
-(void)setShowsArray:(NSMutableArray<Show *> *)showsArray
{
    _showsArray = showsArray;
    [self.tableView reloadData];
}


/**
 This method sets the background view of the table view to this uilabel
 */
-(void)setMessageToTableViewBackground
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.type isEqualToString:MOVIES])
    {
        messageLabel.text = NSLocalizedString(@"not_watching_movies", @"");
    }else if([self.type isEqualToString:TV_SHOWS])
    {
        messageLabel.text = NSLocalizedString(@"not_watching_tvshows", @"");
    }else
    {
        messageLabel.text = NSLocalizedString(@"no_recent_to_show", @"");
    }
    
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    
    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SegueAddTvShow"] && [segue.destinationViewController isKindOfClass:[AddShowViewController class]])
    {
        AddShowViewController *controller = segue.destinationViewController;
        controller.type = self.type;
        controller.user = self.user;
        controller.isEditing = NO;
        controller.delegate = self;
        controller.navigationItem.title = NSLocalizedString(@"add_tvshow", @"");
    }else if([segue.identifier isEqualToString:@"SegueAddMovie"] && [segue.destinationViewController isKindOfClass:[AddShowViewController class]])
    {
        AddShowViewController *controller = segue.destinationViewController;
        controller.type = self.type;
        controller.user = self.user;
        controller.isEditing = NO;
        controller.delegate = self;
        controller.navigationItem.title = NSLocalizedString(@"add_movie", @"");
    }else if([segue.identifier isEqualToString:@"SegueEditMovie"] && [segue.destinationViewController isKindOfClass:[AddShowViewController class]] && [sender isKindOfClass:[NSIndexPath class]])
    {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        AddShowViewController *controller = segue.destinationViewController;
        controller.type = self.type;
        controller.user = self.user;
        controller.show = self.showsArray[indexPath.row];
        controller.isEditing = YES;
        controller.delegate = self;
        controller.navigationItem.title = NSLocalizedString(@"edit_movie", @"");
    }else if([segue.identifier isEqualToString:@"SegueEditTvShow"] && [segue.destinationViewController isKindOfClass:[AddShowViewController class]] && [sender isKindOfClass:[NSIndexPath class]])
    {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        AddShowViewController *controller = segue.destinationViewController;
        controller.type = self.type;
        controller.user = self.user;
        controller.show = self.showsArray[indexPath.row];
        controller.isEditing = YES;
        controller.delegate = self;
        controller.navigationItem.title = NSLocalizedString(@"edit_tvshow", @"");
    }
                                                                     
}


/**
 This method will display an alert to the user asking him if he really wants to delete the show, if positive then it will call the deleteUserData method

 @param show The show to be deleted
 */
-(void)showAlertToConfirmDataDeletionWithShow:(Show *)show
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"warning", @"") message:NSLocalizedString(@"you_sure_delete_title", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteUserDataWithData:show deleteEverything:false];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will display an alert asking the user if he has finished watching the show, if positive then it will call the userHasFinishedWatchingTheShow method, else it will call the showAlertToAskUserIfHeWantsToEditTheShow method

 @param show The show to be asked about
 @param indexPath The show's indexPath
 */
-(void)showAlertToAskUserIfHeHasFinishedWatchingTheShow:(Show *)show andIndexPath:(NSIndexPath *)indexPath
{
    NSString *temp = [self.type isEqualToString:MOVIES] ? NSLocalizedString(@"mov", @"") : NSLocalizedString(@"tv", @"") ;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"information", @"") message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"ask_if_user_has_finished_watching_the_show", @""), temp] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self userHasFinishedWatchingTheShow:show];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showAlertToAskUserIfHeWantsToEditTheShowWithIndexPath:indexPath];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_btn", @"") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will display an alert asking the user if he wants to edit the show at a given indexPath, if positive it will perform a segue to edit the passing the indexPath based on the self.type property

 @param indexPath The show's indexPath
 */
-(void)showAlertToAskUserIfHeWantsToEditTheShowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *temp = [self.type isEqualToString:MOVIES] ? NSLocalizedString(@"mov", @"") : NSLocalizedString(@"tv", @"") ;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"information", @"") message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"ask_if_user_wants_to_edit_show", @""),temp] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([self.type isEqualToString:MOVIES])
        {
            [self performSegueWithIdentifier:@"SegueEditMovie" sender:indexPath];
        }
        else if([self.type isEqualToString:TV_SHOWS])
        {
            [self performSegueWithIdentifier:@"SegueEditTvShow" sender:indexPath];
        }
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will display an alert asking the user if he wants to delete everything from the recents screen, if positive it will call the deleteEverything method
 */
-(void)showAlertToAskUserIfHeWantsToDeleteEverything
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"warning", @"") message:NSLocalizedString(@"ask_user_to_delete_everything", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteEverything];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 This method will delete every show in the array and for each one it will call the method deleteUserData to delete it from the server and as well from core data, then it reloads the tableView and shows and alert informing the user that everything was succesfully deleted
 */
-(void)deleteEverything
{
    for (Show *show in self.showsArray)
    {
        [self deleteUserDataWithData:show deleteEverything:true];
    }
    
    [self.showsArray removeAllObjects];
    [self.tableView reloadData];
    [self checkIfArrayIsEmpty:self.showsArray];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    
    [AlertManager showAlertWithTitle:NSLocalizedString(@"success", @"") message:NSLocalizedString(@"everything_deleted_successfully", @"") actions:@[actionOk] andViewController:self];
}


/**
 This method will update the completed property of the show to 1, then it will remove the object from the showsArray property, reloads the tableView and then it deletes the show from core data subtracts 1 to the user's tvshow or movies properties based on the self.type property, adds 1 to the user's recent property then updates the show in core data and saves the user defaults properties for the profile needs to be updated as well as the recent needs updating and after all that it will call the InterfaceAPI updateUserData method to inform the server of this changes if there's internet connection available, otherwise it will save that changes in core data to be communicated to the server later

 @param show The show to be updated
 */
-(void)userHasFinishedWatchingTheShow:(Show *)show
{
    show.completed = @(1);
    NSString *notificationTitle = [show.type isEqualToString:@"movie"] ? NSLocalizedString(@"movie", @"") : NSLocalizedString(@"episode", @"");
    NSString *entity = [self.type isEqualToString:MOVIES] ? @"Movie" : @"TvShow";
    
    [self.showsArray removeObject:show];
    [self.tableView reloadData];
    [self checkIfArrayIsEmpty:self.showsArray];
    [ShowsOfflineManager deleteShow:show withEntity:entity];
    [ShowsOfflineManager removeShowFromUser:self.type];
    [ShowsOfflineManager addShowToUser:RECENTLY_WATCHED];
    [ShowsOfflineManager createShowWithShow:show andEntity:@"Recent"];
    [UserDefaultsManager saveUserProfileNeedsUpdating:YES];
    [UserDefaultsManager saveRecentNeedsUpdating:YES];
    
    if([NetworkManager isInternetAvailable])
    {
        __weak HomeTableViewController *weakSelf = self;
        
        [self.interfaceAPI updateUserDataWith:self.type userID:show.showId content:CONTENT_COMPLETED andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(!success){
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }else
                {
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle, NSLocalizedString(@"updated", @"")]];
                }
            }];
            
        }];
        
        if([UserDefaultsManager getAddNextEpisodeValue] && [show.type isEqualToString:@"tvshow"]){
            [weakSelf askUserIfHeWantsToAddNextEpisodeWithShow:show];
        }
    }
    else
    {
        [ShowsOfflineManager createOfflineDataChangeWithId:show.showId.integerValue type:self.type andContent:CONTENT_COMPLETED];
        [LocalNotificationsManager showNotificationWithMsg:NSLocalizedString(@"offline_changes_message", @"") andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle, NSLocalizedString(@"updated", @"")]];
    }
}

-(void)askUserIfHeWantsToAddNextEpisodeWithShow:(Show *)show{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"information", @"") message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"ask_if_user_wants_to_add_next_episode", @""),show.title] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveUserDataWithShow:show];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 
 This method will call the interfaceAPI saveUserData to tell the server to create a show with this information for this user if there's internet connection available and it will save in user defaults the information that the user profile needs to be updated, sums 1 to the user's tvshows or movies property based on the type parameter and calls the method DidAddShow on it's delegate, otherwise it will display an alert telling the user that there is no internet connection available
 
 @param show The show to create
 */
-(void)saveUserDataWithShow:(Show *)show
{
    if([NetworkManager isInternetAvailable])
    {
        [self.refreshControl beginRefreshing];
        int episode = [show.episode intValue] + 1;
        
        __weak HomeTableViewController *weakSelf = self;
        
        [self.interfaceAPI saveUserDataWithType:self.type title:show.title watchedTime:BEGINNING_WATCH_TIME season:show.season episode:[NSString stringWithFormat:@"%d", episode] completed:0 andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                [self.refreshControl endRefreshing];
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(success){
                    NSString *notificationTitle = NSLocalizedString(@"episode", @"");
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:[NSString stringWithFormat:@"%@ %@",notificationTitle,NSLocalizedString(@"added", @"")]];
                    [UserDefaultsManager saveUserProfileNeedsUpdating:YES];
                    [ShowsOfflineManager addShowToUser:self.type];
                    [weakSelf updateUI];
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
    [self.refreshControl endRefreshing];
}


/**
 This method will delete the show it receives from core data, subtacts 1 to the user's recent property, saves in user defaults that the user profile needs to be updated and then if the boolean everything is no then it will remove the show from the showsArray property and reload the tableView after that it will call the interfaceAPI deleteUserData method to inform the server to delete that show as well if there is internet connection available, otherwise it will save that information in core data to be communicated to the server later

 @param show The show to be deleted
 @param everything A boolean to inform the method if the user is deleting everything or not
 */
-(void)deleteUserDataWithData:(Show *)show deleteEverything:(BOOL)everything
{
    NSString *type = [show.type isEqualToString:@"movie"] ? MOVIES : TV_SHOWS;
    
    [ShowsOfflineManager deleteShow:show withEntity:@"Recent"];
    [ShowsOfflineManager removeShowFromUser:RECENTLY_WATCHED];
    [UserDefaultsManager saveUserProfileNeedsUpdating:YES];
    
    if(!everything)
    {
        [self.showsArray removeObject:show];
        [self.tableView reloadData];
        [self checkIfArrayIsEmpty:self.showsArray];
    }
    
    if([NetworkManager isInternetAvailable])
    {
        __weak HomeTableViewController *weakSelf = self;
        [self.interfaceAPI deleteUserDataWithId:show.showId type:type andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(!success){
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }else
                {
                    if(!everything)
                    {
                        [LocalNotificationsManager showNotificationWithMsg:msg andTitle:NSLocalizedString(@"show_deleted", @"")];
                    }
                }
            }];
        }];
    }else
    {
        if(!everything)
        {
            [LocalNotificationsManager showNotificationWithMsg:NSLocalizedString(@"offline_changes_message", @"") andTitle:NSLocalizedString(@"show_deleted", @"")];
        }
        [ShowsOfflineManager createOfflineDataChangeWithId:show.showId.integerValue type:type andContent:DELETE_CONTENT];
    }
}

#pragma mark - DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([UserDefaultsManager getUserPremium] == 0){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([UserDefaultsManager getUserPremium] == 0){
        if(section == 0){
            return 1;
        }else {
            return self.showsArray.count;
        }
    }
    return self.showsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataTableViewCell *cell;
    if([UserDefaultsManager getUserPremium] == 0){
            if(indexPath.section == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AdCell" forIndexPath:indexPath];
                if([UserDefaultsManager getUserPremium] == 0){
                    self.tableView.rowHeight = 60.0;
                    [cell.bannerView setHidden:NO];
                    cell.bannerView.rootViewController = self;
                    [self.adsManager showBannerAdOnBannerView:cell.bannerView];
                }else {
                    [cell.bannerView setHidden:YES];
                }
            }else {
                self.tableView.rowHeight = 180.0;
                cell = [tableView dequeueReusableCellWithIdentifier:@"DataCell" forIndexPath:indexPath];
                if([self.showsArray[indexPath.row].thumbnail containsString:@"http"])
                {
                    
                    [self.imageManager downloadImageWithURL:self.showsArray[indexPath.row].thumbnail andIndexPath:indexPath];
                }else
                {
                    cell.thumbnailImageView.image = [ShowsOfflineManager imageForShow:self.showsArray[indexPath.row] orUser:nil];
                }
                
                cell.titleLabel.text = self.showsArray[indexPath.row].title;
                cell.watchedTimeLabel.text = self.showsArray[indexPath.row].watchedTime;
                if([self.showsArray[indexPath.row].type isEqualToString:@"tvshow"])
                {
                    long season = self.showsArray[indexPath.row].season.integerValue;
                    long episode = self.showsArray[indexPath.row].episode.integerValue;
                    
                    if(season < BELOW_TEN)
                    {
                        cell.seasonLabel.text = [NSString stringWithFormat:@"%@: 0%@",NSLocalizedString(@"season", @""),self.showsArray[indexPath.row].season];
                    }
                    else
                    {
                        cell.seasonLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"season", @""),self.showsArray[indexPath.row].season];
                    }
                    
                    if(episode < BELOW_TEN)
                    {
                        cell.episodeLabel.text = [NSString stringWithFormat:@"%@: 0%@",NSLocalizedString(@"episode", @""),self.showsArray[indexPath.row].episode];
                    }
                    else
                    {
                        cell.episodeLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"episode", @""),self.showsArray[indexPath.row].episode];
                    }
                }
                else
                {
                    cell.seasonLabel.text = @"";
                    cell.episodeLabel.text = @"";
                }
                if([self.showsArray[indexPath.row].completed  isEqual:@(1)])
                {
                    cell.completedLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"completed", @""), NSLocalizedString(@"yes_btn", @"")];
                }else
                {
                    cell.completedLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"completed", @""), NSLocalizedString(@"no_btn", @"")];
                }
            }
    }else {
        self.tableView.rowHeight = 180.0;
        cell = [tableView dequeueReusableCellWithIdentifier:@"DataCell" forIndexPath:indexPath];
        if([self.showsArray[indexPath.row].thumbnail containsString:@"http"])
        {
            
            [self.imageManager downloadImageWithURL:self.showsArray[indexPath.row].thumbnail andIndexPath:indexPath];
        }else
        {
            cell.thumbnailImageView.image = [ShowsOfflineManager imageForShow:self.showsArray[indexPath.row] orUser:nil];
        }
        
        cell.titleLabel.text = self.showsArray[indexPath.row].title;
        cell.watchedTimeLabel.text = self.showsArray[indexPath.row].watchedTime;
        if([self.showsArray[indexPath.row].type isEqualToString:@"tvshow"])
        {
            long season = self.showsArray[indexPath.row].season.integerValue;
            long episode = self.showsArray[indexPath.row].episode.integerValue;
            
            if(season < BELOW_TEN)
            {
                cell.seasonLabel.text = [NSString stringWithFormat:@"%@: 0%@",NSLocalizedString(@"season", @""),self.showsArray[indexPath.row].season];
            }
            else
            {
                cell.seasonLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"season", @""),self.showsArray[indexPath.row].season];
            }
            
            if(episode < BELOW_TEN)
            {
                cell.episodeLabel.text = [NSString stringWithFormat:@"%@: 0%@",NSLocalizedString(@"episode", @""),self.showsArray[indexPath.row].episode];
            }
            else
            {
                cell.episodeLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"episode", @""),self.showsArray[indexPath.row].episode];
            }
        }
        else
        {
            cell.seasonLabel.text = @"";
            cell.episodeLabel.text = @"";
        }
        if([self.showsArray[indexPath.row].completed  isEqual:@(1)])
        {
            cell.completedLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"completed", @""), NSLocalizedString(@"yes_btn", @"")];
        }else
        {
            cell.completedLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"completed", @""), NSLocalizedString(@"no_btn", @"")];
        }
    }
    return cell;
}

#pragma mark - Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.type isEqualToString:MOVIES] || [self.type isEqualToString:TV_SHOWS])
    {
        [self showAlertToAskUserIfHeHasFinishedWatchingTheShow:self.showsArray[indexPath.row] andIndexPath:indexPath];
    }
    else
    {
        [self showAlertToConfirmDataDeletionWithShow:self.showsArray[indexPath.row]];
    }
}


#pragma mark - Protocol Methods


/**
 When this method is called it will ask the server again for the user data so that the new show can have a thumbnail

 @param controller The controller that added the show
 */
- (void)addShowControllerDidAddShow:(AddShowViewController *)controller
{
    [self checkForOfflineChanges];
}

/**
 When this method is called it will replace the object in the array with the one that it receives and then it reloads the tableView data

 @param controller The controller that updated the show
 @param show The updated show
 */
- (void)addShowController:(AddShowViewController *)controller didUpdateShow:(Show *)show
{
    NSUInteger showIndex = [self.showsArray indexOfObject:show];
    [self.showsArray replaceObjectAtIndex:showIndex withObject:show];
    [self.tableView reloadData];
}

/**
 This method checks if the change communicated to the server was successfully or not using the success parameter if yes then it will subtract 1 to the self.offlineChangesCounter and it will delete that change from core data, after that it will check if the self.offlineChangesCounter equals zero if so it will call the method getDataWithType
 
 @param controller The controller that communicated the change to the server
 @param success A boolean parameter that informs if the change was properly informed to the server
 @param change The change that was communicated
 */
-(void)comunicateChangesToServer:(ComunicateChangesToServerManager *)controller didFinishInformingServer:(BOOL)success andChange:(OfflineChangesMO *)change
{
    if(success)
    {
        self.offlineChangesCounter--;
        [ShowsOfflineManager deleteOfflineChange:change];
    }
    
    if(self.offlineChangesCounter == 0)
    {
        [self getDataWithType:self.type];
    }
}

/**
 This method will set the cell.thumbnailImageView to the one it receives as parameter if the cell is visible using the indexPath
 
 @param controller The controller that downloaded the image
 @param image The downloaded image
 @param indexPath The cell's indexPath that the image should be assign to. (it can be nil if you want to download an image and not use it in a cell)
 */
-(void)imageManager:(ImageManager *)controller didFinishiDownloadingImage:(UIImage *)image andIndexPath:(NSIndexPath *)indexPath
{
    if([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
    {
        DataTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.thumbnailImageView.image = image;
    }
}

-(void)backgroundValidationManager:(BackgroundUserValidationManager *)manager didFinishCheckingUserValidity:(BOOL)success
{
    if(success)
    {
        [self checkForOfflineChanges];
    }
    else
    {
        [self showAlertToTerminateUserSession];
    }
}

#pragma mark - Actions


- (IBAction)showinterstitialAd:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"BuyPremiumSegue" sender:nil];
}


- (IBAction)addButtonClicked:(UIBarButtonItem *)sender
{
    if([NetworkManager isInternetAvailable])
    {
        if([self.type isEqualToString:TV_SHOWS])
        {
            [self performSegueWithIdentifier:@"SegueAddTvShow" sender:nil];
        }else
        {
            [self performSegueWithIdentifier:@"SegueAddMovie" sender:nil];
        }
    }else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}

- (IBAction)logoutButtonClicked:(UIBarButtonItem *)sender {
    [SharedMethods logoutFromViewController:self];
}

-(IBAction)refreshData:(UIRefreshControl *)sender
{
    if([NetworkManager isInternetAvailable])
    {
        if(sender.isRefreshing)
        {
            if([UserDefaultsManager getAutoLoginPreference])
            {
                [self.backgroundValidationManager checkIfUserIsStillValid];
            }
            else
            {
                [self checkForOfflineChanges];
            }
        }
        
    }
    else
    {
        [self showNoInternetAlert];
    }
}

- (IBAction)deleteAllButtonClicked:(UIBarButtonItem *)sender
{
  
    if(self.showsArray.count > 0)
    {
        [self showAlertToAskUserIfHeWantsToDeleteEverything];
    }
    else
    {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"nothing_to_delete", @"") andViewController:self];
    }
 
}

- (IBAction)settingsButtonClickd:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"SegueSettings" sender:nil];
}

@end
