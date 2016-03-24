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
@property (nonatomic, strong) id <AMLUser_PRIVATE> currentUser;

// GENERAL //

+ (instancetype)sharedManager;
+ (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser;

// OTHER //

+ (id <AMLUser_Editable>)setCurrentUserUsingAuthData:(NSDictionary *)authData;
+ (void)updateUser:(id <AMLUser_Editable>)user withDictionary:(NSDictionary *)dictionary;

@end

@implementation AMLLoginManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser {
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

+ (id <AMLUser_Editable>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    NSDictionary *authData = [AMLFirebaseController authData];
    return [AMLLoginManager setCurrentUserUsingAuthData:authData];
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
        id <AMLUser_Editable> currentUser = [AMLLoginManager setCurrentUserUsingAuthData:userInfo];
        successBlock(currentUser);
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)logout {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController logout];
    [AMLLoginManager setCurrentUser:nil];
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

+ (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLLoginManager sharedManager].currentUser = currentUser;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (id <AMLUser_Editable>)setCurrentUserUsingAuthData:(NSDictionary *)authData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if (!authData) {
        [AMLLoginManager setCurrentUser:nil];
        return nil;
    }
    
    NSString *userId = authData[FirebaseAuthKeyUID];
    
    id <AMLUser_PRIVATE> currentUser = [AMLLoginManager sharedManager].currentUser;
    if (currentUser && [currentUser.userId isEqualToString:userId]) {
        return currentUser;
    }
    
    currentUser = [AMLCoreDataController userWithUserId:userId];
    if (!currentUser) {
        NSString *email = authData[FirebaseAuthKeyEmail];
        currentUser = [AMLCoreDataController userWithUserId:userId email:email];
    }
    [AMLLoginManager updateUser:currentUser withDictionary:authData];
    [AMLCoreDataController save];
    [AMLLoginManager setCurrentUser:currentUser];
    return currentUser;
}

+ (void)updateUser:(id <AMLUser_Editable>)user withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *email = dictionary[FirebaseAuthKeyEmail];
//    NSString *username;
    NSString *profileImageURL = dictionary[FirebaseAuthKeyProfileImageURL];
    
    user.email = email;
//    user.username = username;
    if (profileImageURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImageURL]];
            user.avatar = [UIImage imageWithData:imageData];
        });
    }
}

@end
