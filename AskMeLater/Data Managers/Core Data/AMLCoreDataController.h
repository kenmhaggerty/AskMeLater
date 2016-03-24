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

#pragma mark - // PROTOCOLS //

#import "AMLUserProtocols.h"
#import "AMLSurveyProtocols.h"
#import "AMLQuestionProtocols.h"
#import "AMLChoiceProtocols.h"
#import "AMLResponseProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

@interface AMLCoreDataController : NSObject <AMLUser_Init, AMLSurvey_Init, AMLQuestion_Init, AMLChoice_Init, AMLResponse_Init>

// GENERAL //

+ (void)save;

// INITIALIZERS //

+ (id <AMLUser_PRIVATE>)userWithUserId:(NSString *)userId email:(NSString *)email;
+ (id <AMLSurvey_Editable>)surveyWithName:(NSString *)name author:(id <AMLUser>)author;
+ (id <AMLQuestion_Editable>)questionWithText:(NSString *)text choices:(NSOrderedSet <id <AMLChoice>> *)choices;
+ (id <AMLChoice_Editable>)choiceWithText:(NSString *)text;
+ (id <AMLResponse_Editable>)responseWithText:(NSString *)text user:(id <AMLUser>)user date:(NSDate *)date;

// GETTERS //

+ (id <AMLUser_PRIVATE>)userWithUserId:(NSString *)userId;

@end
