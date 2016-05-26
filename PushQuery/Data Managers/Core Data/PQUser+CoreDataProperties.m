//
//  PQUser+CoreDataProperties.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQUser+CoreDataProperties.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation PQUser (CoreDataProperties)

#pragma mark - // SETTERS AND GETTERS //

@dynamic avatarData;
@dynamic email;
@dynamic userId;
@dynamic username;
@dynamic responses;
@dynamic surveys;

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)addSurveysObject:(PQSurvey *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableSet *primitiveSurveys = [self primitiveValueForKey:NSStringFromSelector(@selector(surveys))];
    if ([primitiveSurveys containsObject:value]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSSet setWithObject:value] forKey:NOTIFICATION_OBJECT_KEY];
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [primitiveSurveys addObject:value];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [AKGenerics postNotificationName:PQUserSurveysWereAddedNotification object:self userInfo:userInfo];
}

- (void)removeSurveysObject:(PQSurvey *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableSet *primitiveSurveys = [self primitiveValueForKey:NSStringFromSelector(@selector(surveys))];
    if (![primitiveSurveys containsObject:value]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSSet setWithObject:value] forKey:NOTIFICATION_OBJECT_KEY];
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [primitiveSurveys removeObject:value];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [AKGenerics postNotificationName:PQUserSurveysWereRemovedNotification object:self userInfo:userInfo];
}

- (void)addSurveys:(NSSet <PQSurvey *> *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableSet *primitiveSurveys = [self primitiveValueForKey:NSStringFromSelector(@selector(surveys))];
    NSMutableSet *newSurveys = [NSMutableSet set];
    for (PQSurvey *value in values) {
        if (![primitiveSurveys containsObject:value]) {
            [newSurveys addObject:value];
        }
    }
    if (!newSurveys.count) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSSet setWithSet:newSurveys] forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [primitiveSurveys unionSet:values];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
    [AKGenerics postNotificationName:PQUserSurveysWereAddedNotification object:self userInfo:userInfo];
}

- (void)removeSurveys:(NSSet <PQSurvey *> *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableSet *primitiveSurveys = [self primitiveValueForKey:NSStringFromSelector(@selector(surveys))];
    NSMutableSet *removedSurveys = [NSMutableSet set];
    for (PQSurvey *value in values) {
        if ([primitiveSurveys containsObject:value]) {
            [removedSurveys addObject:value];
        }
    }
    if (!removedSurveys.count) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSSet setWithSet:removedSurveys] forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:NSStringFromSelector(@selector(surveys))] minusSet:values];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveys)) withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    
    [AKGenerics postNotificationName:PQUserSurveysWereRemovedNotification object:self userInfo:userInfo];
}


#pragma mark - // PRIVATE METHODS //

@end
