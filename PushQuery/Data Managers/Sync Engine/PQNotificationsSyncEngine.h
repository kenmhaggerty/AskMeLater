//
//  PQSyncEngine+Notifications.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/2/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "PQQuestionProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQNotificationsSyncEngine : NSObject

// SETUP //

+ (void)setup;

// GENERAL //

+ (void)didRespondToQuestion:(id <PQQuestion>)question;

@end
