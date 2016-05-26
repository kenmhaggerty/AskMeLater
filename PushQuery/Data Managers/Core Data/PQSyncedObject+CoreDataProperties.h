//
//  PQSyncedObject+CoreDataProperties.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQSyncedObject.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQSyncedObject (CoreDataProperties)
@property (nullable, nonatomic, retain) NSNumber *isUploadedValue;
@end

NS_ASSUME_NONNULL_END
