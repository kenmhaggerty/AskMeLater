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

#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQManagedObjectWillBeDeallocatedNotification = @"kNotificationPQManagedObject_WillBeDeallocated";
NSString * const PQManagedObjectWasCreatedNotification = @"kNotificationPQManagedObject_WasCreated";
NSString * const PQManagedObjectWasFetchedNotification = @"kNotificationPQManagedObject_WasFetched";
NSString * const PQManagedObjectWillSaveNotification = @"kNotificationPQManagedObject_WillSave";
NSString * const PQManagedObjectDidSaveNotification = @"kNotificationPQManagedObject_DidSave";
NSString * const PQManagedObjectWillBeDeletedNotification = @"kNotificationPQManagedObject_WillBeDeleted";

@interface PQManagedObject ()
@property (nonatomic, readwrite) BOOL isSaving;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;
@end

@implementation PQManagedObject

#pragma mark - // SETTERS AND GETTERS //

@synthesize changedKeys = _changedKeys;
@synthesize isSaving = _isSaving;
@synthesize willBeDeleted = _willBeDeleted;
@synthesize wasDeleted = _wasDeleted;
@synthesize parentIsDeleted = _parentIsDeleted;

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [NSNotificationCenter postNotificationToMainThread:PQManagedObjectWillBeDeallocatedNotification object:self userInfo:nil];
}

- (void)awakeFromInsert {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromInsert];
    
    [NSNotificationCenter postNotificationToMainThread:PQManagedObjectWasCreatedNotification object:self userInfo:nil];
}

- (void)awakeFromFetch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromFetch];
    
    [NSNotificationCenter postNotificationToMainThread:PQManagedObjectWasFetchedNotification object:self userInfo:nil];
}

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    self.isSaving = YES;
    
    [super willSave];
    
    if (self.isUpdated && !self.isInserted) {
        self.changedKeys = [NSMutableSet setWithArray:self.changedValues.allKeys];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY];
    [NSNotificationCenter postNotificationToMainThread:PQManagedObjectWillSaveNotification object:self userInfo:userInfo];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (self.changedKeys && !self.inserted) { // !self.isDeleted &&
        [NSNotificationCenter postNotificationToMainThread:PQManagedObjectDidSaveNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
        self.changedKeys = nil;
    }
    
    [super didSave];
    
    self.isSaving = NO;
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    self.willBeDeleted = YES;
    
    [NSNotificationCenter postNotificationToMainThread:PQManagedObjectWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    self.isSaving = NO;
    self.wasDeleted = NO;
    self.parentIsDeleted = NO;
}

#pragma mark - // PRIVATE METHODS //

@end
