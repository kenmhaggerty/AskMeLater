//
//  AMLCoreDataController.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#import "AMLUser.h"
#import "AMLSurvey.h"
#import "AMLQuestion.h"
#import "AMLChoice.h"
#import "AMLResponse.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AMLCoreDataController : NSObject <AMLUser_Init, AMLSurvey_Init, AMLQuestion_Init, AMLChoice_Init, AMLResponse_Init>

// GENERAL //

+ (void)save;

// INITIALIZERS //

+ (AMLUser *)userWithUserId:(NSString *)userId email:(NSString *)email;
+ (AMLSurvey *)surveyWithName:(NSString *)name author:(AMLUser *)author;
+ (AMLQuestion *)questionWithText:(NSString *)text choices:(NSOrderedSet <AMLChoice *> *)choices;
+ (AMLChoice *)choiceWithText:(NSString *)text;
+ (AMLResponse *)responseWithText:(NSString *)text user:(AMLUser *)user date:(NSDate *)date;

// GETTERS //

+ (AMLUser *)userWithUserId:(NSString *)userId;
+ (NSSet <AMLSurvey *> *)surveysWithAuthor:(AMLUser *)author;

// DELETORS //

+ (void)deleteObject:(NSManagedObject *)object;

@end
