//
//  PQUser.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQEditableObject.h"

@class PQResponse, PQSurvey;

#pragma mark - // PROTOCOLS //

#import "PQUserProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQUser : PQEditableObject <PQUser_PRIVATE>

// UPDATE //

- (void)updateUsername:(NSString *)username;
- (void)updateEmail:(NSString *)email;
- (void)updateAvatar:(UIImage *)avatar;

// GETTERS //

- (UIImage *)avatar;

// SETTERS //

- (void)setAvatar:(UIImage *)avatar;

@end

NS_ASSUME_NONNULL_END

#import "PQUser+CoreDataProperties.h"
