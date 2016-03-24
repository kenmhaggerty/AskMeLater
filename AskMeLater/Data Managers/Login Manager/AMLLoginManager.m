//
//  AMLLoginManager.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLLoginManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLFirebaseController+Auth.h"
#import "AMLCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const CurrentUserDidChangeNotification = @"kNotificationCurrentUserDidChange";

@interface AMLLoginManager ()
@property (nonatomic, strong) id <AMLUser_Editable> currentUser;

// GENERAL //

+ (instancetype)sharedManager;
+ (void)setCurrentUser:(id <AMLUser_Editable>)currentUser;

@end

@implementation AMLLoginManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(id <AMLUser_Editable>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    if ([AKGenerics object:currentUser isEqualToObject:_currentUser]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentUser) {
        [userInfo setObject:currentUser forKey:NOTIFICATION_OBJECT_KEY];
    }
    
    _currentUser = currentUser;
    
    [AKGenerics postNotificationName:CurrentUserDidChangeNotification object:nil userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

+ (BOOL)isLoggedIn {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_ACCOUNTS] message:nil];
    
    return [AMLFirebaseController isAuthenticated];
}

+ (id <AMLUser_Editable>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [AMLLoginManager sharedManager].currentUser;
}

+ (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController signUpWithEmail:email password:password success:^(NSDictionary *result) {
        
        [AMLLoginManager loginWithEmail:email password:password success:successBlock failure:failureBlock];
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController loginUserWithEmail:email password:password success:^(NSDictionary *userInfo) {
        
        id <AMLUser_Editable> currentUser = (id <AMLUser_Editable>)[AMLCoreDataController userWithEmail:email];
        [AMLLoginManager setCurrentUser:currentUser];
        successBlock(currentUser);
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)logout {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController logout];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    static AMLLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[AMLLoginManager alloc] init];
    });
    return _sharedManager;
}

+ (void)setCurrentUser:(id <AMLUser_Editable>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLLoginManager sharedManager].currentUser = currentUser;
}

@end
