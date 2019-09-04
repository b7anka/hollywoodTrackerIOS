//
//  BuyPremiumViewController.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 06/08/2019.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "BuyPremiumViewController.h"
#import "ShowsOfflineManager.h"
#import "Constants.h"
#import "UserDefaultsManager.h"
#import "AlertManager.h"
#import "NetworkManager.h"
#import "interfaceAPI.h"
#import <StoreKit/StoreKit.h>

@interface BuyPremiumViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property(strong,nonnull)InterfaceAPI *apiManager;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) bool isRestoring;

@end

@implementation BuyPremiumViewController

SKPaymentQueue *defaultQueue;
SKProduct *product;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isRestoring = NO;
    [self enableOrDisableBuyButtonWithBoolean:NO andAlpha:0.25];
    self.apiManager = [InterfaceAPI new];
    defaultQueue = [SKPaymentQueue defaultQueue];
    [defaultQueue addTransactionObserver:self];
    [self checkPreviousPurchases];
}

-(void)enableOrDisableBuyButtonWithBoolean:(bool)value andAlpha:(CGFloat)alpha{
    [self.buyButton setEnabled:value];
    self.buyButton.alpha = alpha;
}

- (void) getProductInfo
{
    if ([SKPaymentQueue canMakePayments])
    {
        if([NetworkManager isInternetAvailable]){
            [self.activityIndicator startAnimating];
            NSSet *productID = [NSSet setWithObject:IN_APP_PURCHASE_ID];
            SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productID];
            request.delegate = self;
            [request start];
        }else {
            [AlertManager showNoInternetAlertWithViewController:self];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self updateUserPremium];
                [defaultQueue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [defaultQueue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [defaultQueue restoreCompletedTransactions];
                break;
            default:
                break;
        }
    }
    [self.activityIndicator stopAnimating];
}

-(void)updateUserPremium{
    User *user = [ShowsOfflineManager allUsers].firstObject;
    user.premium = [NSNumber numberWithInteger:1];
    [ShowsOfflineManager updateShowWithShow:nil orUser:user andEntity:@"User"];
    [UserDefaultsManager saveUserPremium:1];
    [UserDefaultsManager savePremiumWasBought:YES];
    [UserDefaultsManager saveUserProfileNeedsUpdating:YES];
    [self.apiManager buyPremiumWithCompletion:^(BOOL success, NSError *error, NSString *msg) {
        
        __weak BuyPremiumViewController *weakSelf = self;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            if(success){
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_btn", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                if(self.isRestoring){
                    [AlertManager showAlertWithTitle:NSLocalizedString(@"success_title", @"") message:NSLocalizedString(@"premium_restored_successfully", @"") actions:@[actionOk] andViewController:self];
                }else {
                    [AlertManager showAlertWithTitle:NSLocalizedString(@"success_title", @"") message:msg actions:@[actionOk] andViewController:weakSelf];
                }
            }else {
                [AlertManager showErrorAlertWithText:msg andViewController:weakSelf];
            }
        }];
    }];
    [self enableOrDisableBuyButtonWithBoolean:YES andAlpha:1.0];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    if ([products count] != 0)
    {
        product = [products objectAtIndex:0];
        [self.productTitleLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"product_title", @""), product.localizedTitle]];
        [self.productInfoLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"product_info", @""), product.localizedDescription]];
    }
    [self.buyButton setTitle:NSLocalizedString(@"buy_btn", @"") forState:UIControlStateNormal];
    [self enableOrDisableBuyButtonWithBoolean:YES andAlpha:1.0];
    [self.productInfoLabel setHidden:NO];
    [self.productTitleLabel setHidden:NO];
    [self.activityIndicator stopAnimating];
}

-(void)buyProduct{
    if (product)
    {
        if([NetworkManager isInternetAvailable]){
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [defaultQueue addPayment:payment];
            [self.activityIndicator startAnimating];
            [self enableOrDisableBuyButtonWithBoolean:NO andAlpha:0.25];
        }else {
            [AlertManager showNoInternetAlertWithViewController:self];
        }
    }
    else
    {
        [AlertManager showErrorAlertWithText:NSLocalizedString(@"in_app_purchases_not_available", @"") andViewController:self];
    }
}

- (IBAction)buyPremium:(UIButton *)sender {
    if(self.isRestoring){
        [self updateUserPremium];
    }else {
        [self buyProduct];
    }
}

-(void)checkPreviousPurchases{
    User *user = [ShowsOfflineManager allUsers].firstObject;
    if([NetworkManager isInternetAvailable]){
        [self.apiManager checkIfUserHasPreviouslyPurchasedPremium:user.email AndCompletion:^(int value, NSError *error) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                if(value == 1){
                    self.isRestoring = YES;
                    [self.buyButton setTitle:NSLocalizedString(@"restore_btn", @"") forState:UIControlStateNormal];
                    [self enableOrDisableBuyButtonWithBoolean:YES andAlpha:1.0];
                }else{
                    [self getProductInfo];
                }
                
            }];
        }];
    }
}


@end
