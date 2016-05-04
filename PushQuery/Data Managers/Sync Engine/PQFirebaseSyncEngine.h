//
//  PQFirebaseSyncEngine.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "NSObject+Basics.h"

#import "PQSurveyProtocols+Firebase.h"
#import "PQQuestionProtocols+Firebase.h"
#import "PQChoiceProtocols+Firebase.h"
#import "PQResponseProtocols+Firebase.h"

#pragma mark - // PROTOCOLS //

@protocol FirebaseSyncDelegate <NSObject>

+ (void)saveSurveyToLocalWithDictionary:(NSDictionary *)dictionary;
+ (void)saveCreatedAt:(NSDate *)createdAt toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveEditedAt:(NSDate *)editedAt toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveEnabled:(BOOL)enabled toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveName:(NSString *)name toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveRepeat:(BOOL)repeat toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveTime:(NSDate *)time toLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveQuestions:(NSOrderedSet *)questionDictionaries toLocalSurveyWithId:(NSString *)surveyId;
+ (void)insertQuestion:(NSDictionary *)questionDictionary withId:(NSString *)questionId atIndex:(NSUInteger)index forLocalSurveyWithId:(NSString *)surveyId;
+ (void)saveOrder:(NSOrderedSet *)questionIds forLocalSurveyWithId:(NSString *)surveyId;
+ (void)deleteSurveyFromLocalWithId:(NSString *)surveyId;

+ (void)saveCreatedAt:(NSDate *)createdAt toLocalQuestionWithId:(NSString *)questionId;
+ (void)saveSecure:(BOOL)secure toLocalQuestionWithId:(NSString *)questionId;
+ (void)saveText:(NSString *)text toLocalQuestionWithId:(NSString *)questionId;
+ (void)saveChoices:(NSOrderedSet *)choiceDictionaries toLocalQuestionWithId:(NSString *)questionId;
+ (void)insertChoice:(NSDictionary *)choiceDictionary atIndex:(NSUInteger)index forLocalQuestionWithId:(NSString *)questionId;
+ (void)saveResponse:(NSDictionary *)responseDictionary toLocalQuestionWithId:(NSString *)questionId;
+ (void)deleteQuestionFromLocalWithId:(NSString *)questionId;

+ (void)saveText:(NSString *)text toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId;
+ (void)saveTextInput:(BOOL)textInput toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId;
+ (void)deleteChoiceFromLocalWithIndex:(NSUInteger)index questionId:questionId;

+ (void)saveDate:(NSDate *)date toLocalResponseWithId:(NSString *)responseId;
+ (void)saveText:(NSString *)text toLocalResponseWithId:(NSString *)responseId;
+ (void)saveUserId:(NSString *)userId toLocalResponseWithId:(NSString *)responseId;
+ (void)deleteResponseFromLocalWithId:(NSString *)responseId;

@end

#pragma mark - // DEFINITIONS (Public) //

@interface PQFirebaseSyncEngine : NSObject

// SETUP //

+ (void)setupWithDelegate:(Class <FirebaseSyncDelegate>)delegate;

// GENERAL //

+ (void)fetchSurveysFromFirebaseWithAuthorId:(NSString *)authorId synchronization:(void(^)(NSDictionary *surveyDictionary))synchronizationBlock completion:(void(^)(BOOL success))completionBlock;
+ (void)saveSurveyToFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;

// OBSERVERS //

+ (void)addFirebaseObserversToSurvey:(id <PQSurvey_Firebase>)survey;
+ (void)removeFirebaseObserversFromSurvey:(id <PQSurvey_Firebase>)survey;

+ (void)addFirebaseObserversToQuestion:(id <PQQuestion_Firebase>)question;
+ (void)removeFirebaseObserversFromQuestion:(id <PQQuestion_Firebase>)question;

+ (void)addFirebaseObserversToChoice:(id <PQChoice_Firebase>)choice;
+ (void)removeFirebaseObserversFromChoice:(id <PQChoice_Firebase>)choice;

+ (void)addFirebaseObserversToResponse:(id <PQResponse_Firebase>)response;
+ (void)removeFirebaseObserversFromResponse:(id <PQResponse_Firebase>)response;

@end
