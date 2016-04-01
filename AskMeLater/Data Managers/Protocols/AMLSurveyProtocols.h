//
//  AMLSurveyProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "AMLQuestionProtocols.h"
#import "AMLUserProtocols.h"

#pragma mark - // DEFINITIONS //

#define AMLSurveyNamePlaceholder @"unnamed survey"

#define AMLSurveyNameDidChangeNotification @"kNotificationAMLSurvey_NameDidChange"
#define AMLSurveyEditedAtDidChangeNotification @"kNotificationAMLSurvey_EditedAtDidChange"
#define AMLSurveyTimeDidChangeNotification @"kNotificationAMLSurvey_TimeDidChange"
#define AMLSurveyRepeatDidChangeNotification @"kNotificationAMLSurvey_RepeatDidChange"
#define AMLSurveyEnabledDidChangeNotification @"kNotificationAMLSurvey_EnabledDidChange"

#define AMLSurveyQuestionsDidChangeNotification @"kNotificationAMLSurvey_QuestionsDidChange"
#define AMLSurveyQuestionWasAddedNotification @"kNotificationAMLSurvey_QuestionWasAdded"
#define AMLSurveyQuestionWasReorderedNotification @"kNotificationAMLSurvey_QuestionWasReordered"
//#define AMLSurveyQuestionWillBeRemoved @"kNotificationAMLSurvey_QuestionWillBeRemoved"
#define AMLSurveyQuestionAtIndexWasRemovedNotification @"kNotificationAMLSurvey_QuestionAtIndexWasRemoved"

#define AMLSurveyWillBeDeletedNotification @"kNotificationAMLSurvey_WillBeDeleted"

#pragma mark - // PROTOCOL (AMLSurvey) //

@protocol AMLSurvey <NSObject>

- (NSString *)name;
- (NSDate *)createdAt;
- (NSDate *)editedAt;
- (NSDate *)time;
- (BOOL)repeat;
- (BOOL)enabled;
- (NSOrderedSet <id <AMLQuestion>> *)questions;
- (id <AMLUser>)author;

@end

#pragma mark - // PROTOCOL (AMLSurvey_Editable) //

@protocol AMLSurvey_Editable <AMLSurvey>

// INITIALIZERS //

//- (id)initWithName:(NSString *)name author:(id <AMLUser>)author;

// SETTERS //

- (void)setName:(NSString *)name;
- (void)setEditedAt:(NSDate *)editedAt;
- (void)setTime:(NSDate *)time;
- (void)setRepeat:(BOOL)repeat;
- (void)setEnabled:(BOOL)enabled;
- (void)setQuestions:(NSOrderedSet <id <AMLQuestion>> *)questions;

- (void)addQuestion:(id <AMLQuestion>)question;
- (void)insertQuestion:(id <AMLQuestion>)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(id <AMLQuestion>)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeQuestion:(id <AMLQuestion>)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;

@end

#pragma mark - // PROTOCOL (AMLSurvey_Init) //

@protocol AMLSurvey_Init <NSObject>

+ (id <AMLSurvey_Editable>)surveyWithName:(NSString *)name author:(id <AMLUser>)author;

@end
