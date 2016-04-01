//
//  AMLResponseProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "AMLUserProtocols.h"

#pragma mark - // DEFINITIONS //

#define AMLResponseWillBeRemovedNotification @"kNotificationAMLResponse_WillBeRemoved"

#define AMLResponseWillBeDeletedNotification @"kNotificationAMLResponse_WillBeDeleted"

#pragma mark - // PROTOCOL (AMLResponse) //

@protocol AMLResponse <NSObject>

- (NSString *)text;
- (id <AMLUser>)user;
- (NSDate *)date;

@end

#pragma mark - // PROTOCOL (AMLResponse_Editable) //

@protocol AMLResponse_Editable <AMLResponse>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text user:(id <AMLUser>)user date:(NSDate *)date;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setDate:(NSDate *)date;

@end

#pragma mark - // PROTOCOL (AMLResponse_Init) //

@protocol AMLResponse_Init <NSObject>

+ (id <AMLResponse_Editable>)responseWithText:(NSString *)text user:(id <AMLUser>)user date:(NSDate *)date;

@end
