//
//  ComunicateChangesToServerManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 10/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ComunicateChangesToServerManager.h"
#import "InterfaceAPI.h"
#import "Constants.h"

@implementation ComunicateChangesToServerManager

#pragma mark - Methods



/**
 This method checks if there is offline changes

 @return Returns yes if count is higher than 0, otherwise returns no
 */
-(BOOL)hasDataChanges
{
    return [ShowsOfflineManager allOfflineChanges].count > 0;
}


/**
 This method communicates the changes to the server, and depending on the type or content it will call the appropriate methods
 */
-(void)communicateChangesToServer
{
    NSArray *changes = [ShowsOfflineManager allOfflineChanges];
    
    for(OfflineChangesMO *change in changes)
    {
        if([change.content isEqualToString:DELETE_CONTENT])
        {
            [self deleteUserDataWithId:change.idChange andType:change.type andChange:change];
        }else
        {
            if([change.type isEqualToString:BUG_REPORT])
            {
                [self sendBugReportsWithContent:change.content andChange:change];
            }else
            {
                [self updateUserDataWithId:change.idChange type:change.type andContent:change.content andChange:change];
            }
        }
    }
}


/**
 This method will call the interfaceAPI to update an object to the server if there is internet connection, then it will call the didFinishInformingServer method on it's delegate passing the boolean success and the offline change object as parameters

 @param idToUpdate The object's id
 @param type The type of the object (So the server knows where to update)
 @param content The content to update
 @param change The offline change object
 */
-(void)updateUserDataWithId:(NSInteger)idToUpdate type:(NSString *)type andContent:(NSString *)content andChange:(OfflineChangesMO *)change
{
    if([NetworkManager isInternetAvailable])
    {
        InterfaceAPI *interfaceAPI = [InterfaceAPI new];
        [interfaceAPI updateUserDataWith:type userID:[NSNumber numberWithInteger:idToUpdate] content:content andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                [self.delegate comunicateChangesToServer:self didFinishInformingServer:success andChange:change];
                
            }];
        }];
    }
}


/**
 This method will call the interfaceAPI to send a bug report to the server, then it will call the didFinishInformingServer method on it's delegate passing the boolean success and the offline change object as parameters

 @param content The content of the change
 @param change The offline change object
 */
-(void)sendBugReportsWithContent:(NSString *)content andChange:(OfflineChangesMO *)change
{
    if([NetworkManager isInternetAvailable])
    {
        NSArray *temp = [content componentsSeparatedByString:@";"];
        InterfaceAPI *interfaceAPI = [InterfaceAPI new];
        [interfaceAPI sendBugReportWithTitle:temp[0] fullname:temp[1] email:temp[2] content:temp[3] andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                [self.delegate comunicateChangesToServer:self didFinishInformingServer:success andChange:change];

            }];
            
        }];
    }
}


/**
 This method will call the interfaceAPI to tell the server to delete user data, then it will call the didFinishInformingServer method on it's delegate passing the boolean success and the offline change object as parameters

 @param idToDelete The id of data to delete
 @param type The type of the data to delete
 @param change The offline change object
 */
-(void)deleteUserDataWithId:(NSInteger)idToDelete andType:(NSString *)type andChange:(OfflineChangesMO *)change
{
    if([NetworkManager isInternetAvailable])
    {
        InterfaceAPI *interfaceAPI = [InterfaceAPI new];
        [interfaceAPI deleteUserDataWithId:[NSNumber numberWithInteger:idToDelete] type:type andCompletion:^(BOOL success, NSError *error, NSString *msg) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                
                [self.delegate comunicateChangesToServer:self didFinishInformingServer:success andChange:change];
                
            }];
        }];
    }
}


@end





