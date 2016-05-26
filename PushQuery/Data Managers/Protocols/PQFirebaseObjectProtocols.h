//
//  PQFirebaseObjectProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // DEFINITIONS (Public) //

#pragma mark - // PROTOCOLS //

@protocol PQFirebaseObject <NSObject>

- (BOOL)isDeleted;
- (BOOL)wasDeleted;
- (BOOL)parentIsDeleted;

- (BOOL)isDownloaded;
- (void)setIsDownloaded:(BOOL)isDownloaded;
- (BOOL)isUploaded;
- (void)setIsUploaded:(BOOL)isUploaded;

@end
