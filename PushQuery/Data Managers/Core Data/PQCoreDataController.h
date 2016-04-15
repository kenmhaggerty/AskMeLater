//
//  PQCoreDataController.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "PQUser.h"
#import "PQSurvey.h"
#import "PQQuestion.h"
#import "PQChoice.h"
#import "PQResponse.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQCoreDataController : NSObject <PQUser_Init, PQSurvey_Init, PQQuestion_Init, PQChoice_Init, PQResponse_Init>

// GENERAL //

+ (void)save;

// INITIALIZERS //

+ (PQUser *)userWithUserId:(NSString *)userId email:(NSString *)email;
+ (PQSurvey *)surveyWithName:(NSString *)name author:(PQUser *)author;
+ (PQQuestion *)questionWithText:(NSString *)text choices:(NSOrderedSet <PQChoice *> *)choices;
+ (PQChoice *)choiceWithText:(NSString *)text;
+ (PQResponse *)responseWithText:(NSString *)text user:(PQUser *)user date:(NSDate *)date;

// GETTERS //

+ (PQUser *)userWithUserId:(NSString *)userId;
+ (NSSet <PQSurvey *> *)surveysWithAuthor:(PQUser *)author;
+ (PQQuestion *)questionWithId:(NSString *)uuid;
+ (NSSet <PQResponse *> *)responsesWithUser:(PQUser *)user;

// DELETORS //

+ (void)deleteObject:(NSManagedObject *)object;

@end
