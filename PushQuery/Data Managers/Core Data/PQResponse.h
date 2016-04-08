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

@class PQUser, PQQuestion;

#pragma mark - // PROTOCOLS //

#import "PQResponseProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQResponse : NSManagedObject <PQResponse_Editable>

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "PQResponse+CoreDataProperties.h"