//
//  PQCentralDispatch+Delegates.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQCentralDispatch.h"

#pragma mark - // PROTOCOLS //

@protocol PQLoginDelegate <NSObject>
- (void)requestLoginWithCompletion:(void(^)(id <PQUser> user))completionBlock;
- (void)requestLogoutWithCompletion:(void(^)(BOOL success))completionBlock;
@end

@protocol PQAccountDelegate <NSObject>
+ (id <PQUser>)currentUser;
@end

#pragma mark - // DEFINITIONS //

@interface PQCentralDispatch (Delegates)
+ (void)setLoginDelegate:(id <PQLoginDelegate>)loginDelegate;
@end
