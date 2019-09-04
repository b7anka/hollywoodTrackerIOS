//
//  ImageDownloaderManager.h
//  hollywoodtracker
//
//  Created by Developer on 28/01/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "NetworkManager.h"

@class ImageManager;

@protocol ImageManagerDelegate <NSObject>

@optional
-(void)imageManager:(ImageManager *)controller didFinishiDownloadingImage:(UIImage *)image andIndexPath:(NSIndexPath *)indexPath;
-(void)imageManager:(ImageManager *)controller didFinishPickingImage:(UIImage *)image;

@end

@interface ImageManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

#pragma mark - Properties

@property(weak,nonatomic)id <ImageManagerDelegate> delegate;

#pragma mark - Class Methods

+(NSString *)encodeToBase64String:(UIImage *)image;


#pragma mark - Methods

-(void)downloadImageWithURL:(NSString *)imageURL andIndexPath:(NSIndexPath *)indexPath;
-(void)showActionSheetToGetPhotoWithViewController:(UIViewController *)controller andImageView:(UIImageView *)imageView;
- (void)getPhotoFrom:(UIImagePickerControllerSourceType)sourceType andController:(UIViewController *)controller;

@end

