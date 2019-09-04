//
//  ProfileViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 22/01/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ProfileViewController.h"
#import "InterfaceAPI.h"
#import "AlertManager.h"
#import "SharedMethods.h"
#import "SettingsViewController.h"
#import "ValidateInputs.h"
#import "ChangePasswordViewController.h"
#import "ShowsOfflineManager.h"
#import "UserDefaultsManager.h"
#import "ComunicateChangesToServerManager.h"
#import "ProfileTableViewCell.h"
#import "NetworkManager.h"
#import "LocalNotificationsManager.h"
#import "ImageManager.h"
#import "BackgroundUserValidationManager.h"
#import <GoogleSignIn/GoogleSignIn.h>
@interface ProfileViewController () <ChangePasswordDelegate,OfflineChangesDelegate, ImageManagerDelegate,BackgroundValidationDelegate, UITextFieldDelegate>

#pragma mark - Properties

@property (strong, nonatomic) NSString *currentPassword;
@property (strong, nonatomic) NSString *previousThumbnail;
@property (strong, nonatomic) NSString *base64thumbnailString;
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong,nonatomic) InterfaceAPI *interfaceAPI;
@property (strong,nonatomic) ComunicateChangesToServerManager *offlineManager;
@property (nonatomic) NSInteger offlineChangesCounter;
@property (strong,nonatomic)ImageManager *imageManager;
@property (strong,nonatomic)BackgroundUserValidationManager *backgroundValidationManager;
@property(strong, nonatomic) NSMutableArray <User *> *usersArray;
@property(strong,nonatomic) NSIndexPath *indexPath;
@property(strong,nonatomic) UIButton *editButton;

#pragma mark - Outlets

@property (strong, nonatomic) IBOutlet UIBarButtonItem *buyPremiumButton;

@end

@implementation ProfileViewController

#pragma mark - Actions


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

- (IBAction)editButtonClicked:(UIButton *)sender
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    self.editButton = cell.saveButton;
    self.thumbnailImageView = cell.profileThumbnailImageView;
    NSString *localizedButtonText = NSLocalizedString(@"edit_profile_btn", @"");
    
    if([cell.saveButton.titleLabel.text isEqualToString:localizedButtonText])
    {
        [self showActionSheetToAskUserWhatHeWantsToDo];
    }else
    {
        [self validateUserInputsWithIndexPath:self.indexPath];
    }
}
- (IBAction)changeAvatar:(UITapGestureRecognizer *)sender
{
     [self.imageManager showActionSheetToGetPhotoWithViewController:self andImageView:self.thumbnailImageView];
}

- (IBAction)settingsButtonClicked:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"SegueSettings" sender:nil];
}

- (IBAction)logoutButtonClicked:(UIBarButtonItem *)sender {
    [SharedMethods logoutFromViewController:self];
}

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interfaceAPI = [InterfaceAPI new];
    self.offlineManager = [ComunicateChangesToServerManager new];
    self.offlineManager.delegate = self;
    self.backgroundValidationManager = [BackgroundUserValidationManager new];
    self.backgroundValidationManager.delegate = self;
    self.imageManager = [ImageManager new];
    self.imageManager.delegate = self;
    self.tableView.rowHeight = self.view.bounds.size.height;
    self.currentPassword = [ShowsOfflineManager allUsers].firstObject.password;//gets the password from the user's core data to be validated in case the user wants to change it
    self.previousThumbnail = [ShowsOfflineManager allUsers].firstObject.thumbnail;
    [self updateUI];
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

- (void)editProfileWithIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *localizedButtonText = NSLocalizedString(@"save_btn", @"");
    
    if(![cell.fullnameTextField isEnabled])
    {
        if([NetworkManager isInternetAvailable])//if internet exists then
        {
            [cell.usernameTextField setEnabled:YES];//it will allow the user to change this data (internet is needed to ask the server if there is already a username like this)
            [cell.emailTextField setEnabled:YES];//it will allow the user to change this data (internet is needed to ask the server if there is already an email like this)
        }
        [cell.profileThumbnailImageView setUserInteractionEnabled:YES];
        [cell.fullnameTextField setEnabled:YES];
        [cell.saveButton setHidden:NO];
        cell.usernameTextField.isEnabled ? [cell.usernameTextField becomeFirstResponder] : [cell.fullnameTextField becomeFirstResponder];
        [cell.tapImageToChangeItLabel setHidden:NO];
        [cell.saveButton setTitle:localizedButtonText forState:UIControlStateNormal];
    }
    else
    {
        [self validateUserInputsWithIndexPath:indexPath];
    }
}

-(void)showActionSheetToAskUserWhatHeWantsToDo
{
    NSString *localizedAlertTitle = NSLocalizedString(@"ask_what_user_wants_to_do", @"");
    NSString *localizedActionInfo = NSLocalizedString(@"edit_information", @"");
    NSString *localizedActionChangePass = NSLocalizedString(@"change_password", @"");
    NSString *localizedActionDeleteAccount = NSLocalizedString(@"delete_account", @"");
    NSString *localizedActionToUnLinkGoogleAccount = NSLocalizedString(@"unlink_google_account", @"");
    NSString *localizedCancelButtonText = NSLocalizedString(@"cancel_btn", @"");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localizedAlertTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionUnlinkGoogleAccount = [UIAlertAction actionWithTitle:localizedActionToUnLinkGoogleAccount style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self unlinkGoogleAccount];
    }];
    
    UIAlertAction *actionInformation = [UIAlertAction actionWithTitle:localizedActionInfo style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self editProfileWithIndexPath:self.indexPath];
    }];
    
    UIAlertAction *actionPassword = [UIAlertAction actionWithTitle:localizedActionChangePass style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       [self performSegueWithIdentifier:@"SegueChangePassword" sender:nil];
    }];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:localizedActionDeleteAccount style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showAlertToDeleteAccount];
    }];
    
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = self.editButton;
    popPresenter.sourceRect = self.editButton.bounds;
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:localizedCancelButtonText style:UIAlertActionStyleCancel handler:nil];
    
    if([UserDefaultsManager getGoogleAccountState])
    {
        [alertController addAction:actionUnlinkGoogleAccount];
    }
    [alertController addAction:actionInformation];
    [alertController addAction:actionPassword];
    [alertController addAction:actionDelete];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)checkIfUserIsPremium
{
    if([UserDefaultsManager getUserPremium] == 1)
    {
        if([UserDefaultsManager getPremiumWasBought]){
            [self hideGetPremiumForFreeButton];
        }else {
            [self showGetPremiumForFreeButton];
        }
    }
    else
    {
        [self showGetPremiumForFreeButton];
    }
}

-(void)hideGetPremiumForFreeButton
{
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.navigationItem.leftBarButtonItems mutableCopy];
    
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:self.buyPremiumButton];
    [self.navigationItem setLeftBarButtonItems:toolbarButtons animated:YES];
}

-(void)showGetPremiumForFreeButton
{
    NSMutableArray *toolbarButtons = [self.navigationItem.leftBarButtonItems mutableCopy];
    
    // This is how you add the button to the toolbar and animate it
    if (![toolbarButtons containsObject:self.buyPremiumButton]) {
        [toolbarButtons addObject:self.buyPremiumButton];
        [self.navigationItem setLeftBarButtonItems:toolbarButtons animated:YES];
    }
}


-(void)unlinkGoogleAccount
{
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak ProfileViewController *weakSelf = self;
        [self.interfaceAPI UpdateGoogleAccountWithEmail:self.usersArray.firstObject.email value:NO andCompletion:^(NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if(error != nil)
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
                else
                {
                    [LocalNotificationsManager showNotificationWithMsg:NSLocalizedString(@"successfully_unliked_google_account", @"") andTitle:NSLocalizedString(@"google_account_updated", @"")];
                    [UserDefaultsManager saveGoogleAccountState:NO];
                    [GIDSignIn.sharedInstance disconnect];
                }
            }];
        }];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:NSLocalizedString(@"no_btn", @"") style:UIAlertActionStyleDefault handler:nil];
    
    [AlertManager showAlertWithTitle:NSLocalizedString(@"are_you_sure", @"") message:NSLocalizedString(@"ask_user_if_he_wants_to_unlink_his_google_account", @"") actions:@[actionYes, actionNo] andViewController:self];
}


- (void)deleteAccountButtonClicked
{
    if([NetworkManager isInternetAvailable])
    {
        [self showAlertToDeleteAccount];
    }
    else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
}


/**
 When this method is called if there is internet connection available it will first check if there is any offline change made by the user so that it informs the server before it will ask the server to refresh the user's profile , otherwise it will refresh the user's profile from the core data through the populateUserProfile method
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
    }else
    {
        self.usersArray = [ShowsOfflineManager allUsers];
    }
}

-(void)checkForOfflineChanges
{
    if([self.offlineManager hasDataChanges])
    {
        self.offlineChangesCounter = [ShowsOfflineManager allOfflineChanges].count;
        [self.offlineManager communicateChangesToServer];
    }
    else
    {
        [self getUserProfile];
    }
}

- (void)setUsersArray:(NSMutableArray<User *> *)usersArray
{
    _usersArray = usersArray;
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UserDefaultsManager getProfileNeedsUpdating])//checks if the user's profile need to be updated
    {
        [UserDefaultsManager saveUserProfileNeedsUpdating:NO];//if so then it sets the flag to no
        self.usersArray = [ShowsOfflineManager allUsers];//gets the user profile from the core data
    }
    
    [self checkIfUserIsPremium];
    [self checkAppVersion];
    [self addOrientationObservers];
}



/**
 Calls the interfaceAPI to get the user's profile from the server
 */
-(void)getUserProfile
{
    __weak ProfileViewController *weakSelf = self;
    [self.interfaceAPI getUserProfileWithCompletion:^(User *user, NSError *error) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if (error) {
                [AlertManager showErrorAlertWithError:error andViewController:self];
            } else {
                
                NSMutableArray <User *> *newUsersArray = [NSMutableArray new];
                user.password = self.currentPassword;
                [newUsersArray addObject:user];
                weakSelf.usersArray = newUsersArray;
                [weakSelf.refreshControl endRefreshing];
                [ShowsOfflineManager createUserWithUser:user];
                [UserDefaultsManager saveUserPremium:user.premium.integerValue];
            }
            
        }];
    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SegueChangePassword"] && [segue.destinationViewController isKindOfClass:[ChangePasswordViewController class]])
    {
        ChangePasswordViewController *controller = segue.destinationViewController;
        controller.currentPassword = self.currentPassword;
        controller.delegate = self;
    }
}


/**
 Validates all the user inputs to check if they are not empty and if they conform to the regexs in the ValidateInputs.h class and if they do it calls the updateUserProfile method
 */
-(void)validateUserInputsWithIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *localizedEmptyInputs = NSLocalizedString(@"on_empty_user_inputs", @"");
    NSString *localizedFullnameRequirements = NSLocalizedString(@"fullname_requirements", @"");
    NSString *localizedUsernameRequirements = NSLocalizedString(@"username_requirements", @"");
    NSString *localizedEmailRequirements = NSLocalizedString(@"email_requirements", @"");
    
    NSString *trimmedFullname = [cell.fullnameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedUsername = [cell.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedEmail = [cell.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([SharedMethods checkForEmptyUserInputs:@[trimmedFullname,trimmedUsername,trimmedEmail]])
    {
        [AlertManager showErrorAlertWithText:localizedEmptyInputs andViewController:self];
    }else if(![ValidateInputs validateFullNameWithName:trimmedFullname])
    {
        [AlertManager showErrorAlertWithText:localizedFullnameRequirements andViewController:self];
    }else if(![ValidateInputs validateUserNameWithUserName:trimmedUsername])
    {
        [AlertManager showErrorAlertWithText:localizedUsernameRequirements andViewController:self];
    }else if(![ValidateInputs validateEmailAddressWithEmailAddress:trimmedEmail])
    {
        [AlertManager showErrorAlertWithText:localizedEmailRequirements andViewController:self];
    }
    else
    {
        [cell.usernameTextField setEnabled:NO];
        [cell.fullnameTextField setEnabled:NO];
        [cell.emailTextField setEnabled:NO];
        [cell.saveButton setEnabled:NO];
        [cell.profileThumbnailImageView setUserInteractionEnabled:NO];
        
        NSString *thumbnail = self.base64thumbnailString ? [NSString stringWithFormat:@"data:image/jpg{base64,%@",self.base64thumbnailString] : @"";
        
        NSString *content = [NSString stringWithFormat:@"%@;%@;%@;%@",trimmedUsername,trimmedFullname,trimmedEmail,thumbnail];
        
        
        [self updateUserDataWithType:PROFILE userId:self.usersArray.firstObject.userId content:content andImageView:cell.profileThumbnailImageView];

       
    }
}

/**
 This method updates the core data user profile with the information provided by the user, then it calls the interfaceAPI if there's internet connection available to update the user information on the server, otherwise it will save the information in core data to be communicated to the server later

 @param type The type of the content whether it's movies, tvshows or profile (Constants in the Constanst.h file) needed to inform the server where to update the information
 @param userId Although this parameter it's called userId it is actually the data id the user wants to update whether its a tvshow, a movie or the user itself (needed so the server knows what object the user wants to update)
 @param content It's a semi-colon separated nsString to be sent to the server where it will be separated by the semi-colons creating an array and then used by the server to update the object.
 */
-(void)updateUserDataWithType:(NSString *)type userId:(NSNumber *)userId content:(NSString *)content andImageView:(UIImageView *)imageView
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    NSString *localizedButtonText = NSLocalizedString(@"edit_profile_btn", @"");
    NSString *localizedNotificationTitle = NSLocalizedString(@"profile_updated_title", @"");
    NSString *localizedNotificationMessage = NSLocalizedString(@"profile_saved_successfully", @"");
    
    NSArray *temp = [content componentsSeparatedByString:@";"];
    [cell.saveButton setEnabled:NO];
    [cell.saveButton setTitle:localizedButtonText forState:UIControlStateNormal];
    [cell.tapImageToChangeItLabel setHidden:YES];
    self.usersArray.firstObject.userName = temp[0];
    self.usersArray.firstObject.fullName = temp[1];
    self.usersArray.firstObject.password = self.currentPassword;
    self.usersArray.firstObject.email = temp[2];
    self.usersArray.firstObject.thumbnail = self.base64thumbnailString != nil ? [ShowsOfflineManager saveImage:nil orImage:imageView.image] : self.previousThumbnail;
    self.previousThumbnail = self.usersArray.firstObject.thumbnail;
    [ShowsOfflineManager updateShowWithShow:nil orUser:self.usersArray.firstObject andEntity:@"User"];
    
    if([NetworkManager isInternetAvailable])
    {
        
        __weak ProfileViewController *weakSelf = self;
        
        [self.interfaceAPI updateUserDataWith:type userID:userId content:content andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(!success){
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }else
                {
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedNotificationTitle];
                }
            }];
        }];
        [cell.saveButton setEnabled:YES];
    }else
    {
        [ShowsOfflineManager createOfflineDataChangeWithId:self.usersArray.firstObject.userId.integerValue type:PROFILE andContent:content];
        [LocalNotificationsManager showNotificationWithMsg:localizedNotificationMessage andTitle:localizedNotificationTitle];
        [cell.saveButton setEnabled:YES];
    }
}


/**
 This method shows an alert to the user asking him to confirm if he really wants to delete his account, if yes it calls the deleteUserAccount method
 */
-(void)showAlertToDeleteAccount
{
    NSString *localizedAlertTitle = NSLocalizedString(@"warning", @"");
    NSString *localizedAlertMessage = NSLocalizedString(@"ask_user_to_delete_account", @"");
    NSString *localizedYesButton = NSLocalizedString(@"yes_btn", @"");
    NSString *localizedNoButton = NSLocalizedString(@"no_btn", @"");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localizedAlertTitle message:localizedAlertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:localizedYesButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteUserAccount];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:localizedNoButton style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 Calls the interfaceAPI if there's an internet connection available and tells the server to delete this user account and all the information regarding it, and then it logs the user out of the application forcing him to go to the login screen, else it will display an alert informing the user that there is no internet connection available
 */
-(void)deleteUserAccount
{
    NSString *localizedTitle = NSLocalizedString(@"account_deleted", @"");
    
    __weak ProfileViewController *weakSelf = self;
    
    [self.interfaceAPI deleteUserAccountWithCompletion:^(BOOL success, NSError *error, NSString *msg) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if (error) {
                [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
            } else if(!success){
                [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
            }else
            {
                [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                [SharedMethods logoutFromViewController:self];
            }
            
        }];
    }];
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
            return 1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell *cell;
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
        }else  {
            self.indexPath = indexPath;
            self.tableView.rowHeight = 344.0;
            cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
            if([self.usersArray[indexPath.row].thumbnail containsString:@"http"])
            {
                [self.imageManager downloadImageWithURL:self.usersArray[indexPath.row].thumbnail andIndexPath:indexPath];
            }
            else
            {
                cell.profileThumbnailImageView.image = [ShowsOfflineManager imageForShow:nil orUser:self.usersArray[indexPath.row]];
                self.previousThumbnail = self.usersArray[indexPath.row].thumbnail;
            }
            
            NSString *premiumString;
            cell.usernameTextField.text = self.usersArray[indexPath.row].userName;
            cell.fullnameTextField.text = self.usersArray[indexPath.row].fullName;
            cell.emailTextField.text = self.usersArray[indexPath.row].email;
            BOOL premium = self.usersArray[indexPath.row].premium.boolValue;
            if(premium)
            {
                premiumString = NSLocalizedString(@"yes_btn", @"");
            }else
            {
                premiumString = NSLocalizedString(@"no_btn", @"");
            }
            cell.premiumUserLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"premium_user", @""), premiumString];
            cell.moviesLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"movies", @""),self.usersArray[indexPath.row].movies];
            cell.tvShowsLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"tvshows", @""),self.usersArray[indexPath.row].tvShows];
            cell.recentLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"recent", @""),self.usersArray[indexPath.row].recentlyWatched];
            cell.totalLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"total", @""),self.usersArray[indexPath.row].total];
            
            cell.usernameTextField.delegate = self;
            cell.fullnameTextField.delegate = self;
            cell.emailTextField.delegate = self;
            
            [cell.saveButton setEnabled:YES];
            [cell.saveButton setTitle:NSLocalizedString(@"edit_profile_btn", @"") forState:UIControlStateNormal];
        }
    }else {
        self.indexPath = indexPath;
        self.tableView.rowHeight = 344.0;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        if([self.usersArray[indexPath.row].thumbnail containsString:@"http"])
        {
            [self.imageManager downloadImageWithURL:self.usersArray[indexPath.row].thumbnail andIndexPath:indexPath];
        }
        else
        {
            cell.profileThumbnailImageView.image = [ShowsOfflineManager imageForShow:nil orUser:self.usersArray[indexPath.row]];
            self.previousThumbnail = self.usersArray[indexPath.row].thumbnail;
        }
        
        NSString *premiumString;
        cell.usernameTextField.text = self.usersArray[indexPath.row].userName;
        cell.fullnameTextField.text = self.usersArray[indexPath.row].fullName;
        cell.emailTextField.text = self.usersArray[indexPath.row].email;
        BOOL premium = self.usersArray[indexPath.row].premium.boolValue;
        if(premium)
        {
            premiumString = NSLocalizedString(@"yes_btn", @"");
        }else
        {
            premiumString = NSLocalizedString(@"no_btn", @"");
        }
        cell.premiumUserLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"premium_user", @""), premiumString];
        cell.moviesLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"movies", @""),self.usersArray[indexPath.row].movies];
        cell.tvShowsLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"tvshows", @""),self.usersArray[indexPath.row].tvShows];
        cell.recentLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"recent", @""),self.usersArray[indexPath.row].recentlyWatched];
        cell.totalLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"total", @""),self.usersArray[indexPath.row].total];
        
        cell.usernameTextField.delegate = self;
        cell.fullnameTextField.delegate = self;
        cell.emailTextField.delegate = self;
        
        [cell.saveButton setEnabled:YES];
        [cell.saveButton setTitle:NSLocalizedString(@"edit_profile_btn", @"") forState:UIControlStateNormal];
    }
    return cell;
}

#pragma mark - Protocol Methods

/**
 This method will set the self.currentPassword property to be the same one it receives as parameter, then it will set the self.user.password property to be the same as the self.currentPassword property then it will update the core data user profile with the self.user object. After that if an internet connection cannot be found then it will save the information in core data to be communicated to the server later

 @param controller The controller that changed the password
 @param password The new password received as parameter
 */
-(void)changePassWordViewController:(ChangePasswordViewController *)controller didChangePassword:(NSString *)password
{
    self.currentPassword = password;
    
    self.usersArray.firstObject.password = self.currentPassword;

    [ShowsOfflineManager updateShowWithShow:nil orUser:self.usersArray.firstObject andEntity:@"User"];
    
    if(![NetworkManager isInternetAvailable])
    {
        [ShowsOfflineManager createOfflineDataChangeWithId:self.usersArray.firstObject.userId.integerValue type:PROFILE andContent:[NSString stringWithFormat:@"%@;",self.usersArray.firstObject.password]];
    }
    
    
}


/**
 This method checks if the change communicated to the server was successfully or not using the success parameter if yes then it will subtract 1 to the self.offlineChangesCounter and it will delete that change from core data, after that it will check if the self.offlineChangesCounter equals zero if so it will call the method getUserProfile

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
       [self getUserProfile];
    }
}


/**
 This method will set the self.profileThumbnailImageView.image to the one it receives as parameter

 @param controller The controller that downloaded the image
 @param image The downloaded image
 @param indexPath The cell's indexPath that the image should be assign to. (it can be nil if you want to download an image and not use it in a cell)
 */
- (void)imageManager:(ImageManager *)controller didFinishiDownloadingImage:(UIImage *)image andIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.profileThumbnailImageView.image = image;
}


/**
 This method sets the self.profileThumbnailImageView.image to the one it receives as parameter, after the user chooses it from the library or the camera, and encodes that image to a base64 string assigning it to the self.base64String property to be sent to the server

 @param controller The controller that picked the image
 @param image The received image
 */
-(void)imageManager:(ImageManager *)controller didFinishPickingImage:(UIImage *)image
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    cell.profileThumbnailImageView.image = image;
    self.base64thumbnailString = [ImageManager encodeToBase64String:cell.profileThumbnailImageView.image];
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


#pragma mark - Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ProfileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    if(textField == cell.usernameTextField)
    {
        [cell.fullnameTextField becomeFirstResponder];
    }else if(textField == cell.fullnameTextField)
    {
        [cell.emailTextField becomeFirstResponder];
    }
    else
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
        [self validateUserInputsWithIndexPath:self.indexPath];
    }
    
    return YES;
}

-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if(!error)
    {
        [UserDefaultsManager saveGoogleAccountState:NO];
    }
}

@end
