//
//  PQUser.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#warning TO DO – Notify PQUserSurveysWereAddedNotification
#warning TO DO – Notify PQUserSurveysWereRemovedNotification

#pragma mark - // IMPORTS (Private) //

#import "PQUser.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQResponse.h"
#import "PQSurvey.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQUser ()
@property (nullable, nonatomic, retain, readwrite) NSData *avatarData;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;

@property (nullable, nonatomic, retain, readwrite) NSSet <PQResponse *> *responses;
@property (nullable, nonatomic, retain, readwrite) NSSet <PQSurvey *> *surveys;

@end

@implementation PQUser

#pragma mark - // SETTERS AND GETTERS //

@dynamic avatarData;
@dynamic willBeDeleted;
@dynamic wasDeleted;

@dynamic responses;
@dynamic surveys;

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

- (void)setSurveys:(NSSet <PQSurvey *> *)surveys {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet *primitiveSurveys = [self primitiveValueForKey:NSStringFromSelector(@selector(surveys))];
    
    if ([AKGenerics object:surveys isEqualToObject:primitiveSurveys]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:surveys forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveys))];
    [self setPrimitiveValue:surveys forKey:NSStringFromSelector(@selector(surveys))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveys))];
    
    [AKGenerics postNotificationName:PQUserSurveysDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    [AKGenerics postNotificationName:PQUserDidSaveNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    
    if (self.changedKeys && !self.inserted) { // !self.isDeleted &&
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
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:PQUserWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS (Update) //

- (void)updateUsername:(NSString *)username {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:username isEqualToObject:self.username]) {
        return;
    }
    
    self.username = username;
    self.editedAt = [NSDate date];
}

- (void)updateEmail:(NSString *)email {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:email isEqualToObject:self.email]) {
        return;
    }
    
    self.email = email;
    self.editedAt = [NSDate date];
}

- (void)updateAvatar:(UIImage *)avatar {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:avatar isEqualToObject:self.avatar]) {
        return;
    }
    
    self.avatar = avatar;
    self.editedAt = [NSDate date];
}

#pragma mark - // PUBLIC METHODS (Getters) //

- (UIImage *)avatar {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [UIImage imageWithData:self.avatarData];
}

#pragma mark - // PUBLIC METHODS (Setters) //

- (void)setAvatar:(UIImage *)avatar {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.avatarData = UIImagePNGRepresentation(avatar);
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
