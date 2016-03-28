//
//  AMLDataManager.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#import "AMLFirebaseProtocols.h"
#import "AMLUserProtocols.h"
#import "AMLSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

#import "AMLFirebaseNotifications.h"

@interface AMLDataManager : NSObject <Firebase>

// GENERAL //

+ (void)setup;
+ (void)save;

// SURVEYS //

+ (id <AMLSurvey_Editable>)survey;
+ (NSSet *)surveysAuthoredByUser:(id <AMLUser>)user;
+ (void)deleteSurvey:(id <AMLSurvey_Editable>)survey;

// QUESTIONS //

+ (id <AMLQuestion_Editable>)questionForSurvey:(id <AMLSurvey_Editable>)survey;
+ (void)deleteQuestion:(id <AMLQuestion_Editable>)question;

// DEBUGGING //

+ (void)test;

@end
