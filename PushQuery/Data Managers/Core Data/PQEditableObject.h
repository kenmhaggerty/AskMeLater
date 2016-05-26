//
//  PQEditableObject.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "PQSyncedObject.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQEditableObject : PQSyncedObject
@end

NS_ASSUME_NONNULL_END

#import "PQEditableObject+CoreDataProperties.h"
