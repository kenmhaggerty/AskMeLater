//
//  PQSyncedObject.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "PQManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQSyncedObject : PQManagedObject
@property (nonatomic) BOOL isDownloaded;
- (BOOL)isUploaded;
- (void)setIsUploaded:(BOOL)isUploaded;
@end

NS_ASSUME_NONNULL_END

#import "PQSyncedObject+CoreDataProperties.h"
