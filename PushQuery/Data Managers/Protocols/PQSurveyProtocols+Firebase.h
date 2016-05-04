//
//  PQSurveyProtocols+Firebase.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQSurveyIdWillChangeNotification @"kNotificationPQSurvey_SurveyIdWillChange"
#define PQSurveyAuthorIdWillChangeNotification @"kNotificationPQSurvey_AuthorIdWillChange"

#define PQSurveyIdDidChangeNotification @"kNotificationPQSurvey_SurveyIdDidChange"
#define PQSurveyAuthorIdDidChangeNotification @"kNotificationPQSurvey_AuthorIdDidChange"

#pragma mark - // PROTOCOL (PQSurvey_Firebase) //

@protocol PQSurvey_Firebase <PQSurvey>

- (BOOL)isDeleted;
- (NSString *)authorId;

@end
