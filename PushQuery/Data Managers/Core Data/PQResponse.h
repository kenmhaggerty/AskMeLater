//
//  PQResponse.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQSyncedObject.h"

@class PQQuestion, PQUser;

#pragma mark - // PROTOCOLS //

#import "PQResponseProtocols+Firebase.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQResponse : PQSyncedObject <PQResponse_PRIVATE, PQResponse_Firebase>
@end

NS_ASSUME_NONNULL_END

#import "PQResponse+CoreDataProperties.h"
