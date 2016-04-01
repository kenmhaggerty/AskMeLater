//
//  AMLLoginManager.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "NSObject+Basics.h"

#import "AMLUserProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const AMLLoginManagerCurrentUserDidChangeNotification;
extern NSString * const AMLLoginManagerEmailDidChangeNotification;

@interface AMLLoginManager : NSObject
+ (id <AMLUser_Editable>)currentUser;
+ (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)updateEmail:(NSString *)email password:(NSString *)password withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock;
+ (void)updatePassword:(NSString *)oldPassword toPassword:(NSString *)newPassword withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock;
+ (void)logout;
@end
