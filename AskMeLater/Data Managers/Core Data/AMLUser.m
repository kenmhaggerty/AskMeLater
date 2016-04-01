//
//  AMLUser.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLUser.h"
#import "AMLSurvey.h"
#import "AMLResponse.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLUser ()
@end

@implementation AMLUser

#pragma mark - // SETTERS AND GETTERS //

- (void)setUsername:(NSString *)username {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveUsername = [self primitiveValueForKey:NSStringFromSelector(@selector(username))];
    
    if ([AKGenerics object:username isEqualToObject:primitiveUsername]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (username) {
        userInfo[NOTIFICATION_OBJECT_KEY] = username;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(username))];
    [self setPrimitiveValue:username forKey:NSStringFromSelector(@selector(username))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(username))];
    
    [AKGenerics postNotificationName:AMLUserUsernameDidChangeNotification object:self userInfo:userInfo];
}

- (void)setAvatarData:(NSData *)avatarData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSData *primitiveAvatarData = [self primitiveValueForKey:NSStringFromSelector(@selector(avatarData))];
    
    if ([AKGenerics object:avatarData isEqualToObject:primitiveAvatarData]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (avatarData) {
        userInfo[NOTIFICATION_OBJECT_KEY] = [UIImage imageWithData:avatarData];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(avatarData))];
    [self setPrimitiveValue:avatarData forKey:NSStringFromSelector(@selector(avatarData))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(avatarData))];
    
    [AKGenerics postNotificationName:AMLUserAvatarDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEmail:(NSString *)email {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveEmail = [self primitiveValueForKey:NSStringFromSelector(@selector(email))];
    
    if ([AKGenerics object:email isEqualToObject:primitiveEmail]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (email) {
        userInfo[NOTIFICATION_OBJECT_KEY] = email;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(email))];
    [self setPrimitiveValue:email forKey:NSStringFromSelector(@selector(email))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(email))];
    
    [AKGenerics postNotificationName:AMLUserEmailDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:AMLUserWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

- (void)setAvatar:(UIImage *)avatar {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.avatarData = UIImagePNGRepresentation(avatar);
}

- (UIImage *)avatar {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [UIImage imageWithData:self.avatarData];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
