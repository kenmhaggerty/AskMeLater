//
//  PQChoiceProtocols+Firebase.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQChoiceProtocols.h"
#import "PQFirebaseObjectProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQChoiceAuthorIdWillChangeNotification @"kNotificationPQChoice_AuthorIdWillChange"
#define PQChoiceSurveyIdWillChangeNotification @"kNotificationPQChoice_SurveyIdWillChange"
#define PQChoiceQuestionIdWillChangeNotification @"kNotificationPQChoice_QuestionIdWillChange"
#define PQChoiceIndexWillChangeNotification @"kNotificationPQChoice_IndexWillChange"

#define PQChoiceAuthorIdDidChangeNotification @"kNotificationPQChoice_AuthorIdDidChange"
#define PQChoiceSurveyIdDidChangeNotification @"kNotificationPQChoice_SurveyIdDidChange"
#define PQChoiceQuestionIdDidChangeNotification @"kNotificationPQChoice_QuestionIdDidChange"
#define PQChoiceIndexDidChangeNotification @"kNotificationPQChoice_IndexDidChange"

#pragma mark - // PROTOCOL (PQChoice_Firebase) //

@protocol PQChoice_Firebase <PQChoice, PQFirebaseObject>

- (NSString *)authorId;
- (NSString *)surveyId;
- (NSString *)questionId;
- (NSNumber *)indexValue;

@end
