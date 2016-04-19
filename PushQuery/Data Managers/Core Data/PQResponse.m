//
//  PQResponse.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResponse.h"
#import "PQUser.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResponse ()
@end

@implementation PQResponse

#pragma mark - // SETTERS AND GETTERS //

- (void)setUser:(PQUser *)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQUser *primitiveUser = [self primitiveValueForKey:NSStringFromSelector(@selector(user))];
    
    if ([AKGenerics object:user isEqualToObject:primitiveUser]) {
        return;
    }
    
    NSDictionary *userInfo = [NSMutableDictionary dictionaryWithNullableObject:user forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    [self setPrimitiveValue:user forKey:NSStringFromSelector(@selector(user))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(user))];
    
    [AKGenerics postNotificationName:PQResponseUserDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [super willSave];
    
    if (!self.updated) {
        return;
    }
    
    [AKGenerics postNotificationName:PQResponseWillBeSavedNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.changedKeys) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(user))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.user forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQResponseUserDidSaveNotification object:self userInfo:userInfo];
        }
    }
    [AKGenerics postNotificationName:PQResponseWasSavedNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super prepareForDeletion];
    
    [AKGenerics postNotificationName:PQResponseWillBeDeletedNotification object:self userInfo:nil];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
