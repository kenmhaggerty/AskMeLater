//
//  PQSurveyProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "PQQuestionProtocols.h"
#import "PQUserProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQSurveyCanBeEnabledDidChangeNotification @"kNotificationPQSurvey_CanBeEnabledDidChange"

#define PQSurveyEditedAtDidChangeNotification @"kNotificationPQSurvey_EditedAtDidChange"
#define PQSurveyEnabledDidChangeNotification @"kNotificationPQSurvey_EnabledDidChange"
#define PQSurveyNameDidChangeNotification @"kNotificationPQSurvey_NameDidChange"
#define PQSurveyRepeatDidChangeNotification @"kNotificationPQSurvey_RepeatDidChange"
#define PQSurveyTimeDidChangeNotification @"kNotificationPQSurvey_TimeDidChange"

#define PQSurveyEditedAtDidSaveNotification @"kNotificationPQSurvey_EditedAtDidSave"
#define PQSurveyEnabledDidSaveNotification @"kNotificationPQSurvey_EnabledDidSave"
#define PQSurveyNameDidSaveNotification @"kNotificationPQSurvey_NameDidSave"
#define PQSurveyRepeatDidSaveNotification @"kNotificationPQSurvey_RepeatDidSave"
#define PQSurveyTimeDidSaveNotification @"kNotificationPQSurvey_TimeDidSave"

#define PQSurveyAuthorDidChangeNotification @"kNotificationPQSurvey_AuthorDidChange"
#define PQSurveyAuthorDidSaveNotification @"kNotificationPQSurvey_AuthorDidSave"

#define PQSurveyQuestionsDidChangeNotification @"kNotificationPQSurvey_QuestionsDidChange"
#define PQSurveyQuestionsCountDidChangeNotification @"kNotificationPQSurvey_QuestionsCountDidChange"
#define PQSurveyQuestionWasAddedNotification @"kNotificationPQSurvey_QuestionWasAdded"
#define PQSurveyQuestionWasReorderedNotification @"kNotificationPQSurvey_QuestionWasReordered"
#define PQSurveyQuestionAtIndexWasRemovedNotification @"kNotificationPQSurvey_QuestionAtIndexWasRemoved"
#define PQSurveyQuestionsDidSaveNotification @"kNotificationPQSurvey_QuestionsDidSave"

#define PQSurveyWillBeSavedNotification @"kNotificationPQSurvey_WillBeSaved"
#define PQSurveyWasSavedNotification @"kNotificationPQSurvey_WasSaved"
#define PQSurveyWillBeDeletedNotification @"kNotificationPQSurvey_WillBeDeleted"

#pragma mark - // PROTOCOL (PQSurvey) //

@protocol PQSurvey <NSObject>

- (BOOL)canBeEnabled;
- (NSDate *)createdAt;
- (NSDate *)editedAt;
- (BOOL)enabled;
- (NSString *)name;
- (BOOL)repeat;
- (NSDate *)time;
- (NSOrderedSet <id <PQQuestion>> *)questions;
- (id <PQUser>)author;

@end

#pragma mark - // PROTOCOL (PQSurvey_Editable) //

@protocol PQSurvey_Editable <PQSurvey>

// INITIALIZERS //

//- (id)initWithName:(NSString *)name author:(id <PQUser>)author;

// SETTERS //

- (void)setEditedAt:(NSDate *)editedAt;
- (void)setEnabled:(BOOL)enabled;
- (void)setName:(NSString *)name;
- (void)setRepeat:(BOOL)repeat;
- (void)setTime:(NSDate *)time;
- (void)setQuestions:(NSOrderedSet <id <PQQuestion>> *)questions;

- (void)addQuestion:(id <PQQuestion>)question;
- (void)insertQuestion:(id <PQQuestion>)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(id <PQQuestion>)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeQuestion:(id <PQQuestion>)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;

@end

#pragma mark - // PROTOCOL (PQSurvey_Init) //

@protocol PQSurvey_Init <NSObject>

+ (id <PQSurvey_Editable>)surveyWithName:(NSString *)name authorId:(NSString *)authorId;

@end
