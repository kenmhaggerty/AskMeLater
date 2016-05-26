//
//  PQManagedObject.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const _Nonnull PQManagedObjectWillBeDeallocatedNotification;
extern NSString * const _Nonnull PQManagedObjectWasCreatedNotification;
extern NSString * const _Nonnull PQManagedObjectWasFetchedNotification;
extern NSString * const _Nonnull PQManagedObjectWillSaveNotification;
extern NSString * const _Nonnull PQManagedObjectDidSaveNotification;
extern NSString * const _Nonnull PQManagedObjectWillBeDeletedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface PQManagedObject : NSManagedObject
@property (nonatomic, strong, nullable) NSSet *changedKeys;
@property (nonatomic, readonly) BOOL isSaving;
@property (nonatomic, readonly) BOOL willBeDeleted;
@property (nonatomic, readonly) BOOL wasDeleted;
@property (nonatomic) BOOL parentIsDeleted;
@end

NS_ASSUME_NONNULL_END

#import "PQManagedObject+CoreDataProperties.h"
