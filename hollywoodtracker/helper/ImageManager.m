//
//  ImageDownloaderManager.m
//  hollywoodtracker
//
//  Created by Developer on 28/01/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ImageManager.h"
#import "AlertManager.h"

@implementation ImageManager

#pragma mark - Class Methods


/**
 This method takes an UIImage as a parameter an encodes it to base64

 @param image The image to be encoded
 @return Return the base64 string
 */
+(NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


#pragma mark - Methods


/**
 This method downloads an image from an url, after download it calls the didFinishDownloadingImage on it's delegate passing the download image and the indexPath

 @param imageURL The url of the image to be downloaded
 @param indexPath The indexPath that this image belongs to (it can be nil)
 */
-(void)downloadImageWithURL:(NSString *)imageURL andIndexPath:(NSIndexPath *)indexPath
{
    NSOperationQueue *newQueue = [NSOperationQueue new];
    
    [newQueue addOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:imageURL];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if([self.delegate respondsToSelector:@selector(imageManager:didFinishiDownloadingImage:andIndexPath:)])
            {
                [self.delegate imageManager:self didFinishiDownloadingImage:image andIndexPath:indexPath];
            }
        }];
    }];
}


/**
 This method call the getPhotoFrom passing the UIImagePickerControllerSourceTypeCamera as a parameter, if the camera does not exist or it is broken than it will display an alert to the user with that information

 @param controller The controller on wich this method should be called
 */
- (void)openCameraWithViewController:(UIViewController *)controller {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self getPhotoFrom:UIImagePickerControllerSourceTypeCamera andController:controller];
        
    } else {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"no_camera", @"") andViewController:controller];
    }
}


/**
 This method will ask the system to present the camera app or the library based on the sourceType received as a parameter so that the user can take a photo or pick an image to be used in this app

 @param sourceType The source type to be used
 @param controller The controller that this should be called on
 */
- (void)getPhotoFrom:(UIImagePickerControllerSourceType)sourceType andController:(UIViewController *)controller {
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = YES;
    
    [controller presentViewController:imagePicker animated:YES completion:nil];
}


/**
 This method will present an action sheet to the user asking him if he wants to open the camera or the library

 @param controller The controller on wich this method should be called
 */
-(void)showActionSheetToGetPhotoWithViewController:(UIViewController *)controller andImageView:(UIImageView *)imageView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"information", @"") message:NSLocalizedString(@"camera_or_library", @"") preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:NSLocalizedString(@"camera_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraWithViewController:controller];
    }];
    
    UIAlertAction *actionLibrary = [UIAlertAction actionWithTitle:NSLocalizedString(@"library_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary andController:controller];
    }];
    
    [alertController addAction:actionCamera];
    [alertController addAction:actionLibrary];
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = imageView;
    popPresenter.sourceRect = imageView.bounds;
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Delegate Methods

/**
 When this method is called it will call the didFinishPickingImage on it's delegate passing itself as a parameter and the image picked as the other parameter
 
 @param picker The image picker controller that picked the image
 @param info The info containing the image
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if([self.delegate respondsToSelector:@selector(imageManager:didFinishPickingImage:)])
    {
        [self.delegate imageManager:self didFinishPickingImage:image];
    }
}


@end
