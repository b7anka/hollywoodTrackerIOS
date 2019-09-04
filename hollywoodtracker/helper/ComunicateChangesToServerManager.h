//
//  ComunicateChangesToServerManager.h
//  hollywoodtracker
//
//  Created by Tiago Moreira on 10/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowsOfflineManager.h"
#import "NetworkManager.h"

@class ComunicateChangesToServerManager;

@protocol OfflineChangesDelegate <NSObject>

#pragma mark - Protocol Methods

@required

-(void)comunicateChangesToServer:(ComunicateChangesToServerManager *)controller didFinishInformingServer:(BOOL)success andChange:(OfflineChangesMO *)change;

@end

@interface ComunicateChangesToServerManager : NSObject

#pragma mark - Properties

@property(weak,nonatomic)id <OfflineChangesDelegate> delegate;

#pragma mark - Methods

-(BOOL)hasDataChanges;
-(void)communicateChangesToServer;
@end
