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

#define PQSurveyNamePlaceholder @"unnamed survey"

#define PQSurveyNameDidChangeNotification @"kNotificationPQSurvey_NameDidChange"
#define PQSurveyEditedAtDidChangeNotification @"kNotificationPQSurvey_EditedAtDidChange"
#define PQSurveyTimeDidChangeNotification @"kNotificationPQSurvey_TimeDidChange"
#define PQSurveyRepeatDidChangeNotification @"kNotificationPQSurvey_RepeatDidChange"
#define PQSurveyEnabledDidChangeNotification @"kNotificationPQSurvey_EnabledDidChange"

#define PQSurveyNameDidSaveNotification @"kNotificationPQSurvey_NameDidSave"
#define PQSurveyEditedAtDidSaveNotification @"kNotificationPQSurvey_EditedAtDidSave"
#define PQSurveyTimeDidSaveNotification @"kNotificationPQSurvey_TimeDidSave"
#define PQSurveyRepeatDidSaveNotification @"kNotificationPQSurvey_RepeatDidSave"
#define PQSurveyEnabledDidSaveNotification @"kNotificationPQSurvey_EnabledDidSave"

#define PQSurveyQuestionsDidChangeNotification @"kNotificationPQSurvey_QuestionsDidChange"
#define PQSurveyQuestionWasAddedNotification @"kNotificationPQSurvey_QuestionWasAdded"
#define PQSurveyQuestionWasReorderedNotification @"kNotificationPQSurvey_QuestionWasReordered"
//#define PQSurveyQuestionWillBeRemoved @"kNotificationPQSurvey_QuestionWillBeRemoved"
#define PQSurveyQuestionAtIndexWasRemovedNotification @"kNotificationPQSurvey_QuestionAtIndexWasRemoved"

#define PQSurveyQuestionsDidSaveNotification @"kNotificationPQSurvey_QuestionsDidSave"

#define PQSurveyWillBeSavedNotification @"kNotificationPQSurvey_WillBeSaved"
#define PQSurveyWasSavedNotification @"kNotificationPQSurvey_WasSaved"
#define PQSurveyWillBeDeletedNotification @"kNotificationPQSurvey_WillBeDeleted"

#pragma mark - // PROTOCOL (PQSurvey) //

@protocol PQSurvey <NSObject>

- (NSString *)name;
- (NSDate *)createdAt;
- (NSDate *)editedAt;
- (NSDate *)time;
- (BOOL)repeat;
- (BOOL)enabled;
- (NSOrderedSet <id <PQQuestion>> *)questions;
- (id <PQUser>)author;

@end

#pragma mark - // PROTOCOL (PQSurvey_Editable) //

@protocol PQSurvey_Editable <PQSurvey>

// INITIALIZERS //

//- (id)initWithName:(NSString *)name author:(id <PQUser>)author;

// SETTERS //

- (void)setName:(NSString *)name;
- (void)setEditedAt:(NSDate *)editedAt;
- (void)setTime:(NSDate *)time;
- (void)setRepeat:(BOOL)repeat;
- (void)setEnabled:(BOOL)enabled;
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

+ (id <PQSurvey_Editable>)surveyWithName:(NSString *)name author:(id <PQUser>)author;

@end
