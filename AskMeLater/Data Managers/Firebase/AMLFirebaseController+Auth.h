//
//  AMLFirebaseController+Auth.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "AMLFirebaseController.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS //

extern NSString * const FirebaseAPIAuthKeyUID;
extern NSString * const FirebaseAPIAuthKeyToken;
extern NSString * const FirebaseAPIAuthKeyProfileImageURL;

@interface AMLFirebaseController (Auth)
+ (BOOL)isAuthenticated;
+ (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)loginUserWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)logout;
@end
