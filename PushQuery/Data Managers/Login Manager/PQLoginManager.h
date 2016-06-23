//
//  PQLoginManager.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "PQUserProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const PQLoginManagerCurrentUserDidChangeNotification;
extern NSString * const PQLoginManagerEmailDidChangeNotification;

@interface PQLoginManager : NSObject
+ (void)setup;
+ (id <PQUser_PRIVATE>)currentUser;
+ (void)signUpAndLogInWithEmail:(NSString *)email password:(NSString *)password failure:(void (^)(NSError *))failureBlock;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password failure:(void (^)(NSError *))failureBlock;
+ (void)resetPasswordForEmail:(NSString *)email success:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock;
+ (void)updateEmailForCurrentUser:(NSString *)email withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock;
+ (void)updatePasswordForCurrentUser:(NSString *)password withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock;
+ (void)logoutWithCompletion:(void (^)(NSError *error))completionBlock;
@end
