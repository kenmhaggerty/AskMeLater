//
//  PQUser.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQUser.h"
#import "PQSurvey.h"
#import "PQResponse.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQUser ()
@end

@implementation PQUser

#pragma mark - // SETTERS AND GETTERS //

- (void)setUsername:(NSString *)username {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveUsername = [self primitiveValueForKey:NSStringFromSelector(@selector(username))];
    
    if ([AKGenerics object:username isEqualToObject:primitiveUsername]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:username forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(username))];
    [self setPrimitiveValue:username forKey:NSStringFromSelector(@selector(username))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(username))];
    
    [AKGenerics postNotificationName:PQUserUsernameDidChangeNotification object:self userInfo:userInfo];
}

- (void)setAvatarData:(NSData *)avatarData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSData *primitiveAvatarData = [self primitiveValueForKey:NSStringFromSelector(@selector(avatarData))];
    
    if ([AKGenerics object:avatarData isEqualToObject:primitiveAvatarData]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:(avatarData ? [UIImage imageWithData:avatarData] : nil) forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(avatarData))];
    [self setPrimitiveValue:avatarData forKey:NSStringFromSelector(@selector(avatarData))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(avatarData))];
    
    [AKGenerics postNotificationName:PQUserAvatarDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEmail:(NSString *)email {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveEmail = [self primitiveValueForKey:NSStringFromSelector(@selector(email))];
    
    if ([AKGenerics object:email isEqualToObject:primitiveEmail]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:email forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(email))];
    [self setPrimitiveValue:email forKey:NSStringFromSelector(@selector(email))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(email))];
    
    [AKGenerics postNotificationName:PQUserEmailDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super willSave];
    
    if (!self.updated) {
        return;
    }
    
    [AKGenerics postNotificationName:PQUserWillBeSavedNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.changedKeys) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(avatarData))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.avatar forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQUserAvatarDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(email))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.email forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQUserEmailDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(username))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.username forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQUserUsernameDidSaveNotification object:self userInfo:userInfo];
        }
    }
    [AKGenerics postNotificationName:PQUserWasSavedNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super prepareForDeletion];
    
    [AKGenerics postNotificationName:PQUserWillBeDeletedNotification object:self userInfo:nil];
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
