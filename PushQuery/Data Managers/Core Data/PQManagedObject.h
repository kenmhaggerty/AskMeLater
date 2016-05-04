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

extern NSString * const _Nullable PQManagedObjectWillBeDeallocatedNotification;
extern NSString * const _Nullable PQManagedObjectWasCreatedNotification;
extern NSString * const _Nullable PQManagedObjectWasFetchedNotification;
extern NSString * const _Nullable PQManagedObjectDidSaveNotification;
extern NSString * const _Nullable PQManagedObjectWillBeDeletedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface PQManagedObject : NSManagedObject
@property (nonatomic, strong, nullable) NSSet *changedKeys;
@end

NS_ASSUME_NONNULL_END

#import "PQManagedObject+CoreDataProperties.h"
