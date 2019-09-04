//
//  UploadThumbnailViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 03/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "UploadThumbnailViewController.h"
#import "SharedMethods.h"
#import "AlertManager.h"
#import "ValidateInputs.h"
#import "InterfaceAPI.h"
#import "NetworkManager.h"
#import "LocalNotificationsManager.h"
#import "ImageManager.h"

@interface UploadThumbnailViewController () <ImageManagerDelegate, UITextFieldDelegate>

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextField *originalTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

#pragma mark - Properties

@property (strong, nonatomic) NSString *base64ThumbnailString;
@property (strong, nonatomic) InterfaceAPI *interfaceAPI;
@property (strong, nonatomic) ImageManager *imageManager;

@end

@implementation UploadThumbnailViewController

#pragma mark - Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.originalTitleTextField becomeFirstResponder];
    self.interfaceAPI = [InterfaceAPI new];
    self.imageManager = [ImageManager new];
    self.originalTitleTextField.delegate = self;
    self.imageManager.delegate = self;
}


/**
 Validates all the user inputs to check if they are not empty and conform to the regexs in the ValidateInputs.h class and if they do it calls the method uploadThumbnailToServer
 */
-(void)validateInputs
{
    NSString *trimmedTitle = [self.originalTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localizedMessageForEmptyTitle = NSLocalizedString(@"on_empty_user_inputs", "");
    NSString *localizedMessageForTitleTooBig = NSLocalizedString(@"title_requirements", "");
    
    if([SharedMethods checkForEmptyUserInputs:@[trimmedTitle]])
    {
        [AlertManager showErrorAlertWithText:localizedMessageForEmptyTitle andViewController:self];
    }
    else if(![ValidateInputs validateTitleWithTitle:trimmedTitle])
    {
        [AlertManager showErrorAlertWithText:localizedMessageForTitleTooBig andViewController:self];
    }
    else
    {
        
        [self uploadThumbnailToServerWithTitle:trimmedTitle andThumbnail:[NSString stringWithFormat:@"data:image/jpg{base64,%@",self.base64ThumbnailString]];
        [self.selectButton setEnabled:NO];
    }
        
}



/**
 Calls the interfaceAPI to upload the thumbnail to the server if there's an internet connection available otherwise it will show an alert to the user informing him that there's no internet connection available

 @param title The show's title
 @param thumbnail The base64 nsString containing the image's data to be sent to the server
 */
-(void)uploadThumbnailToServerWithTitle:(NSString *)title andThumbnail:(NSString *)thumbnail
{
    NSString *localizedTitle = NSLocalizedString(@"thumbnail_uploaded", @"");
    if([NetworkManager isInternetAvailable])
    {
        __weak UploadThumbnailViewController *weakSelf = self;
        
        [weakSelf.activityIndicator startAnimating];
        
        [self.interfaceAPI uploadThumbnailToServerWithTitle:title thumbnail:thumbnail andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                [weakSelf.activityIndicator stopAnimating];
                if (error) {
                    [AlertManager showErrorAlertWithError:error andViewController:weakSelf];
                } else if(success){
                    [LocalNotificationsManager showNotificationWithMsg:msg andTitle:localizedTitle];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else
                {
                    [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
                }
            }];
            
        }];
    }
    else
    {
        [AlertManager showNoInternetAlertWithViewController:self];
    }
    
    [self.selectButton setEnabled:YES];
}

#pragma mark - Protocol Methods

-(void)imageManager:(ImageManager *)controller didFinishPickingImage:(UIImage *)image
{
    NSString *localizedButtonText = NSLocalizedString(@"upload_btn", @"");
    self.thumbnailImageView.image = image;
    self.base64ThumbnailString = [ImageManager encodeToBase64String:self.thumbnailImageView.image];
    [self.selectButton setTitle:localizedButtonText forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)selectButtonClicked:(UIButton *)sender
{
    if(!self.base64ThumbnailString)// if string is nil
    {
        [self.imageManager getPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary andController:self];//calls the imageManager to choose one
    }
    else
    {
        [self validateInputs];// else calls this method
    }
}

#pragma mark - Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.base64ThumbnailString) //if string not nil
    {
        [self validateInputs]; //then calls this method
    }
    
    [self.activeTextField resignFirstResponder];
    
    return YES;
}

@end
