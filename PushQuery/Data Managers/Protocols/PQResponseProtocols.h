//
//  PQResponseProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "PQUserProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQResponseUserDidChangeNotification @"kNotificationPQResponse_UserDidChange"
#define PQResponseUserDidSaveNotification @"kNotificationPQResponse_UserDidSave"

#define PQResponseWillBeSavedNotification @"kNotificationPQResponse_WillBeSaved"
#define PQResponseWasSavedNotification @"kNotificationPQResponse_WasSaved"
#define PQResponseWillBeRemovedNotification @"kNotificationPQResponse_WillBeRemoved"
#define PQResponseWillBeDeletedNotification @"kNotificationPQResponse_WillBeDeleted"

#pragma mark - // PROTOCOL (PQResponse) //

@protocol PQResponse <NSObject>

- (NSString *)text;
- (id <PQUser>)user;
- (NSDate *)date;

@end

#pragma mark - // PROTOCOL (PQResponse_Editable) //

@protocol PQResponse_Editable <PQResponse>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text user:(id <PQUser>)user date:(NSDate *)date;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setDate:(NSDate *)date;

@end

#pragma mark - // PROTOCOL (PQResponse_Init) //

@protocol PQResponse_Init <NSObject>

+ (id <PQResponse_Editable>)responseWithText:(NSString *)text user:(id <PQUser>)user date:(NSDate *)date;

@end
