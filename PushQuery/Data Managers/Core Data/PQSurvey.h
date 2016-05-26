//
//  PQSurvey.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQEditableObject.h"

@class PQUser, PQQuestionIndex, PQQuestion;

#pragma mark - // PROTOCOLS //

#import "PQSurveyProtocols+Firebase.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQSurvey : PQEditableObject <PQSurvey_PRIVATE, PQSurvey_Firebase>

// UPDATE //

- (void)updateEnabled:(BOOL)enabled;
- (void)updateName:(NSString *)name;
- (void)updateRepeat:(BOOL)repeat;
- (void)updateTime:(NSDate *)time;

- (void)addQuestion:(PQQuestion *)question;
- (void)insertQuestion:(PQQuestion *)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(PQQuestion *)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeQuestion:(PQQuestion *)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;

// GETTERS //

- (BOOL)canBeEnabled;
- (BOOL)enabled;
- (BOOL)repeat;
- (NSOrderedSet <PQQuestion *> *)questions;

// SETTERS //

- (void)setEnabled:(BOOL)enabled;
- (void)setRepeat:(BOOL)repeat;
- (void)setQuestions:(NSOrderedSet <PQQuestion *> *)questions;

@end

NS_ASSUME_NONNULL_END

#import "PQSurvey+CoreDataProperties.h"
