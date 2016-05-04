//
//  PQResponseProtocols+Firebase.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQResponseProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQResponseIdWillChangeNotification @"kNotificationPQResponse_ResponseIdWillChange"
#define PQResponseAuthorIdWillChangeNotification @"kNotificationPQResponse_AuthorIdWillChange"
#define PQResponseSurveyIdWillChangeNotification @"kNotificationPQResponse_SurveyIdWillChange"
#define PQResponseQuestionIdWillChangeNotification @"kNotificationPQResponse_QuestionIdWillChange"

#define PQResponseIdDidChangeNotification @"kNotificationPQResponse_ResponseIdDidChange"
#define PQResponseAuthorIdDidChangeNotification @"kNotificationPQResponse_AuthorIdDidChange"
#define PQResponseSurveyIdDidChangeNotification @"kNotificationPQResponse_SurveyIdDidChange"
#define PQResponseQuestionIdDidChangeNotification @"kNotificationPQResponse_QuestionIdDidChange"

#pragma mark - // PROTOCOL (PQResponse_Firebase) //

@protocol PQResponse_Firebase <PQResponse>

- (BOOL)isDeleted;
- (NSString *)authorId;
- (NSString *)surveyId;
- (NSString *)questionId;

@end
