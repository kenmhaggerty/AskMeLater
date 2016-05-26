//
//  PQEditableObject.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQEditableObject.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQEditableObject ()
@end

@implementation PQEditableObject

#pragma mark - // SETTERS AND GETTERS //

- (void)setCreatedAt:(NSDate *)createdAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedCreatedAt = [createdAt dateRoundedToPrecision:6];
    
    NSDate *primitiveCreatedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(createdAt))];
    
    if ([AKGenerics object:roundedCreatedAt isEqualToObject:primitiveCreatedAt]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(createdAt))];
    [self setPrimitiveValue:roundedCreatedAt forKey:NSStringFromSelector(@selector(createdAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(createdAt))];
}

- (void)setEditedAt:(NSDate *)editedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedEditedAt = [editedAt dateRoundedToPrecision:6];
    
    NSDate *primitiveEditedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    if ([AKGenerics object:roundedEditedAt isEqualToObject:primitiveEditedAt]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    [self setPrimitiveValue:roundedEditedAt forKey:NSStringFromSelector(@selector(editedAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
}

- (void)setLastSyncDate:(NSDate *)lastSyncDate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedLastSyncDate = [lastSyncDate dateRoundedToPrecision:6];
    
    NSDate *primitiveLastSyncDate = [self primitiveValueForKey:NSStringFromSelector(@selector(lastSyncDate))];
    
    if ([AKGenerics object:roundedLastSyncDate isEqualToObject:primitiveLastSyncDate]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(lastSyncDate))];
    [self setPrimitiveValue:roundedLastSyncDate forKey:NSStringFromSelector(@selector(lastSyncDate))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(lastSyncDate))];
}

- (void)setUpdatedAt:(NSDate *)updatedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedUpdatedAt = [updatedAt dateRoundedToPrecision:6];
    
    NSDate *primitiveUpdatedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(updatedAt))];
    
    if ([AKGenerics object:roundedUpdatedAt isEqualToObject:primitiveUpdatedAt]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(updatedAt))];
    [self setPrimitiveValue:roundedUpdatedAt forKey:NSStringFromSelector(@selector(updatedAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(updatedAt))];
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
