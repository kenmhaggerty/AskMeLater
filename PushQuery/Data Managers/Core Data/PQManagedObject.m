//
//  PQManagedObject.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQManagedObject.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQManagedObjectWillBeDeallocatedNotification = @"kNotificationPQManagedObject_WillBeDeallocated";
NSString * const PQManagedObjectWasCreatedNotification = @"kNotificationPQManagedObject_WasCreated";
NSString * const PQManagedObjectWasFetchedNotification = @"kNotificationPQManagedObject_WasFetched";
NSString * const PQManagedObjectDidSaveNotification = @"kNotificationPQManagedObject_DidSave";
NSString * const PQManagedObjectWillBeDeletedNotification = @"kNotificationPQManagedObject_WillBeDeleted";

@interface PQManagedObject ()
@end

@implementation PQManagedObject

#pragma mark - // SETTERS AND GETTERS //

@synthesize changedKeys = _changedKeys;

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:PQManagedObjectWillBeDeallocatedNotification object:self userInfo:nil];
}

- (void)awakeFromInsert {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromInsert];
    
    [AKGenerics postNotificationName:PQManagedObjectWasCreatedNotification object:self userInfo:nil];
}

- (void)awakeFromFetch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromFetch];
    
    [AKGenerics postNotificationName:PQManagedObjectWasFetchedNotification object:self userInfo:nil];
}

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super willSave];
    
    if (!self.updated && !self.inserted) {
        self.changedKeys = [NSMutableSet setWithArray:self.changedValues.allKeys];
    }
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super didSave];
    
    if (self.changedKeys) {
        [AKGenerics postNotificationName:PQManagedObjectDidSaveNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
        self.changedKeys = nil;
    }
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:PQManagedObjectWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
