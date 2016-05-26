//
//  PQQuestionProtocols+Firebase.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQQuestionProtocols.h"
#import "PQFirebaseObjectProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQQuestionIdWillChangeNotification @"kNotificationPQQuestion_QuestionIdWillChange"
#define PQQuestionAuthorIdWillChangeNotification @"kNotificationPQQuestion_AuthorIdWillChange"
#define PQQuestionSurveyIdWillChangeNotification @"kNotificationPQQuestion_SurveyIdWillChange"

#define PQQuestionIdDidChangeNotification @"kNotificationPQQuestion_QuestionIdDidChange"
#define PQQuestionAuthorIdDidChangeNotification @"kNotificationPQQuestion_AuthorIdDidChange"
#define PQQuestionSurveyIdDidChangeNotification @"kNotificationPQQuestion_SurveyIdDidChange"

#pragma mark - // PROTOCOL (PQQuestion_Firebase) //

@protocol PQQuestion_Firebase <PQQuestion, PQFirebaseObject>

- (NSString *)authorId;
- (NSString *)surveyId;

@end
