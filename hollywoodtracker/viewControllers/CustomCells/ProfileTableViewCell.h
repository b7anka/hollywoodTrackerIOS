//
//  ProfileTableViewCell.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 19/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "DataTableViewCell.h"

@interface ProfileTableViewCell : DataTableViewCell

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *tapImageToChangeItLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *moviesLabel;
@property (weak, nonatomic) IBOutlet UILabel *tvShowsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *premiumUserLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *recentLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

