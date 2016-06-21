//
//  PQResponse.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResponse.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQQuestion.h"
#import "PQUser.h"

#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResponse ()
@property (nullable, nonatomic, retain, readwrite) NSString *authorId;
@property (nullable, nonatomic, retain, readwrite) NSString *surveyId;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;

@property (nullable, nonatomic, retain, readwrite) PQQuestion *question;
@property (nullable, nonatomic, retain, readwrite) PQUser *user;

// OBSERVERS //

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;

// RESPONDERS //

- (void)questionAuthorIdDidChange:(NSNotification *)notification;
- (void)questionSurveyIdDidChange:(NSNotification *)notification;

@end

@implementation PQResponse

#pragma mark - // SETTERS AND GETTERS //

@dynamic authorId;
@dynamic surveyId;
@dynamic willBeDeleted;
@dynamic wasDeleted;

@dynamic question;
@dynamic user;

- (void)setAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveAuthorId = [self primitiveValueForKey:NSStringFromSelector(@selector(authorId))];
    
    if ([AKGenerics object:authorId isEqualToObject:primitiveAuthorId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:authorId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseAuthorIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    [self setPrimitiveValue:authorId forKey:NSStringFromSelector(@selector(authorId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseAuthorIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setDate:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedDate = [date dateRoundedToPrecision:6];
    
    NSDate *primitiveDate = [self primitiveValueForKey:NSStringFromSelector(@selector(date))];
    
    if ([AKGenerics object:roundedDate isEqualToObject:primitiveDate]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(date))];
    [self setPrimitiveValue:roundedDate forKey:NSStringFromSelector(@selector(date))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(date))];
}

- (void)setQuestionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveQuestionId = [self primitiveValueForKey:NSStringFromSelector(@selector(questionId))];
    
    if ([AKGenerics object:questionId isEqualToObject:primitiveQuestionId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:questionId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseQuestionIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    [self setPrimitiveValue:questionId forKey:NSStringFromSelector(@selector(questionId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseQuestionIdDidChangeNotification object:self userInfo:userInfo];
    
    self.question = questionId ? [PQCoreDataController getQuestionWithId:self.questionId] : nil;
}

- (void)setResponseId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveResponseId = [self primitiveValueForKey:NSStringFromSelector(@selector(responseId))];
    
    if ([AKGenerics object:responseId isEqualToObject:primitiveResponseId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:responseId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(responseId))];
    [self setPrimitiveValue:responseId forKey:NSStringFromSelector(@selector(responseId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(responseId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setSurveyId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveSurveyId = [self primitiveValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    if ([AKGenerics object:surveyId isEqualToObject:primitiveSurveyId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:surveyId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseSurveyIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    [self setPrimitiveValue:surveyId forKey:NSStringFromSelector(@selector(surveyId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseSurveyIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setUserId:(NSString *)userId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveUserId = [self primitiveValueForKey:NSStringFromSelector(@selector(userId))];
    
    if ([AKGenerics object:userId isEqualToObject:primitiveUserId]) {
        return;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(userId))];
    [self setPrimitiveValue:userId forKey:NSStringFromSelector(@selector(userId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(userId))];
    
    self.user = userId ? [PQCoreDataController getUserWithId:self.userId] : nil;
}

- (void)setQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQQuestion *primitiveQuestion = [self primitiveValueForKey:NSStringFromSelector(@selector(question))];
    
    if ([AKGenerics object:question isEqualToObject:primitiveQuestion]) {
        return;
    }
    
    BOOL questionIsDeleted = primitiveQuestion.isDeleted;
    
    if (primitiveQuestion) {
        [self removeObserversFromQuestion:primitiveQuestion];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(question))];
    [self setPrimitiveValue:question forKey:NSStringFromSelector(@selector(question))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(question))];
    
    if (question) {
        [self addObserversToQuestion:question];
    }
    
    if (!self.isDeleted && !questionIsDeleted) {
        self.questionId = question.questionId;
        self.authorId = question ? question.authorId : nil;
        self.surveyId = question ? question.surveyId : nil;
    }
}

- (void)setUser:(PQUser *)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQUser *primitiveUser = [self primitiveValueForKey:NSStringFromSelector(@selector(user))];
    
    if ([AKGenerics object:user isEqualToObject:primitiveUser]) {
        return;
    }
    
    BOOL userIsDeleted = primitiveUser.isDeleted;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:user forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    [self setPrimitiveValue:user forKey:NSStringFromSelector(@selector(user))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(user))];
    
    if (!self.isDeleted && !userIsDeleted) {
        self.userId = user.userId;
    }
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseUserDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
}

- (void)awakeFromInsert {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromInsert];
    
    [self setup];
}

- (void)awakeFromFetch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromFetch];
    
    [self setup];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (!self.changedKeys || self.isDeleted) {
        [NSNotificationCenter postNotificationToMainThread:PQResponseDidSaveNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    }
    
    if (self.changedKeys && !self.inserted) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(user))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.user forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQResponseUserDidSaveNotification object:self userInfo:userInfo];
        }
    }
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [NSNotificationCenter postNotificationToMainThread:PQResponseWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionAuthorIdDidChange:) name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionSurveyIdDidChange:) name:PQQuestionSurveyIdDidChangeNotification object:question];
}

- (void)removeObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionSurveyIdDidChangeNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionAuthorIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *authorId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.authorId = authorId;
}

- (void)questionSurveyIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *surveyId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.surveyId = surveyId;
}

@end
