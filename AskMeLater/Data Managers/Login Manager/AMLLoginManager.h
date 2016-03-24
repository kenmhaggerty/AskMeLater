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

#import "AMLUserProtocols.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const CurrentUserDidChangeNotification;

@interface AMLLoginManager : NSObject
+ (BOOL)isLoggedIn;
+ (id <AMLUser_Editable>)currentUser;
+ (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock;
+ (void)logout;
@end
