//
//  PQChoiceIndex+CoreDataProperties.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQChoiceIndex.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQChoiceIndex (CoreDataProperties)

@property (nullable, nonatomic, retain) PQChoice *choice;
@property (nullable, nonatomic, retain) PQQuestion *question;

@end

NS_ASSUME_NONNULL_END
