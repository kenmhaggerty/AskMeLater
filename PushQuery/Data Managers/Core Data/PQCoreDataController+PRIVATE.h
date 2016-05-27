//
//  PQCoreDataController+PRIVATE.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/20/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQCoreDataController.h"

#import "PQQuestionIndex.h"
#import "PQChoiceIndex.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS //

@interface PQCoreDataController (PRIVATE) <PQUser_Init_PRIVATE, PQSurvey_Init_PRIVATE, PQQuestion_Init_PRIVATE, PQChoice_Init_PRIVATE, PQResponse_Init_PRIVATE>

+ (PQUser *)userWithUserId:(NSString *)userId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;
+ (PQSurvey *)surveyWithSurveyId:(NSString *)surveyId authorId:(NSString *)authorId createdAt:(NSDate *)createdAt inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;
+ (PQQuestion *)questionWithQuestionId:(NSString *)questionId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;
+ (PQChoice *)choiceInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;
+ (PQResponse *)responseWithResponseId:(NSString *)responseId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;

+ (PQQuestionIndex *)questionIndexInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;
+ (PQChoiceIndex *)choiceIndexInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil;

@end
