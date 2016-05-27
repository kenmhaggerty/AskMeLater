//
//  PQCentralDispatch.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "PQUserProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const PQCentralDispatchUpdatesDidBegin;
extern NSString * const PQCentralDispatchUpdatesProgressDidChange;
extern NSString * const PQCentralDispatchUpdatesDidFinish;

@interface PQCentralDispatch : NSObject

// SETUP //

+ (BOOL)requiresUpdates;
+ (void)startUpdates;

// ACCOUNTS //

+ (id <PQUser>)currentUser;
+ (void)requestLoginWithCompletion:(void(^)(id <PQUser> user))completionBlock;
+ (void)requestLogoutWithCompletion:(void(^)(BOOL success))completionBlock;

@end
