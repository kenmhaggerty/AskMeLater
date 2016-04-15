//
//  PQDataManager.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#import "PQFirebaseProtocols.h"
#import "PQUserProtocols.h"
#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

#import "PQFirebaseNotifications.h"

@interface PQDataManager : NSObject <Firebase>

// GENERAL //

+ (void)setup;
+ (void)save;

// SURVEYS //

+ (id <PQSurvey_Editable>)survey;
+ (NSSet *)surveysAuthoredByUser:(id <PQUser>)user;
+ (void)deleteSurvey:(id <PQSurvey_Editable>)survey;

// QUESTIONS //

+ (id <PQQuestion>)questionWithId:(NSString *)uuid;
+ (id <PQQuestion_Editable>)questionForSurvey:(id <PQSurvey_Editable>)survey;
+ (void)deleteQuestion:(id <PQQuestion_Editable>)question;

// RESPONSES //

+ (void)addResponse:(NSString *)text forQuestion:(id <PQQuestion>)question;
+ (void)deleteResponse:(id <PQResponse>)response;

// DEBUGGING //

+ (void)test;

@end
