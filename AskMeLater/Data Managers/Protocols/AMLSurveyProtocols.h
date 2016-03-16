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

#pragma mark - // PROTOCOL (AMLSurvey) //

@protocol AMLSurvey <NSObject>

- (NSString *)name;
- (NSOrderedSet <id <AMLQuestion>> *)questions;
- (id <AMLUser>)author;
- (NSDate *)editedAt;
- (NSDate *)time;
- (BOOL)repeat;
- (BOOL)enabled;

@end

#pragma mark - // PROTOCOL (AMLSurvey_Editable) //

@protocol AMLSurvey_Editable <NSObject>

// INITIALIZERS //

//- (id)initWithName:(NSString *)name author:(id <AMLUser>)author;

// SETTERS //

- (void)setName:(NSString *)name;
- (void)setQuestions:(NSOrderedSet <id <AMLQuestion>> *)questions;
- (void)addQuestion:(id <AMLQuestion>)question;
- (void)insertQuestion:(id <AMLQuestion>)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(id <AMLQuestion>)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)index toIndex:(NSUInteger)index;
- (void)removeQuestion:(id <AMLQuestion>)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;
- (void)setEditedAt:(NSDate *)editedAt;
- (void)setTime:(NSDate *)time;
- (void)setRepeat:(BOOL)repeat;
- (void)setEnabled:(BOOL)enabled;

@end

#pragma mark - // PROTOCOL (AMLSurvey_Init) //

@protocol AMLSurvey_Init <NSObject>

+ (id <AMLSurvey_Editable>)surveyWithName:(NSString *)name author:(id <AMLUser>)author;

@end
