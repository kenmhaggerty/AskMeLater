//
//  PQChoice.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQChoice.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQChoiceIndex.h"
#import "PQQuestion.h"

#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQChoice ()
@property (nullable, nonatomic, retain, readwrite) NSString *authorId;
@property (nullable, nonatomic, retain, readwrite) NSString *questionId;
@property (nullable, nonatomic, retain, readwrite) NSString *surveyId;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;

@property (nullable, nonatomic, retain, readwrite) PQQuestion *question;

// OBSERVERS //

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;

// RESPONDERS //

- (void)questionIdDidChange:(NSNotification *)notification;
- (void)questionAuthorIdDidChange:(NSNotification *)notification;
- (void)questionSurveyIdDidChange:(NSNotification *)notification;

@end

@implementation PQChoice

#pragma mark - // SETTERS AND GETTERS //

@dynamic authorId;
@dynamic questionId;
@dynamic surveyId;
@dynamic willBeDeleted;
@dynamic wasDeleted;

@dynamic question;

- (void)setAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveAuthorId = [self primitiveValueForKey:NSStringFromSelector(@selector(authorId))];
    
    if ([AKGenerics object:authorId isEqualToObject:primitiveAuthorId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:authorId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceAuthorIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    [self setPrimitiveValue:authorId forKey:NSStringFromSelector(@selector(authorId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceAuthorIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setIndexValue:(NSNumber *)indexValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveIndexValue = [self primitiveValueForKey:NSStringFromSelector(@selector(indexValue))];
    
    if ([AKGenerics object:indexValue isEqualToObject:primitiveIndexValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:indexValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceIndexWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(indexValue))];
    [self setPrimitiveValue:indexValue forKey:NSStringFromSelector(@selector(indexValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(indexValue))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceIndexDidChangeNotification object:self userInfo:userInfo];
}

- (void)setQuestionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveQuestionId = [self primitiveValueForKey:NSStringFromSelector(@selector(questionId))];
    
    if ([AKGenerics object:questionId isEqualToObject:primitiveQuestionId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:questionId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceQuestionIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    [self setPrimitiveValue:questionId forKey:NSStringFromSelector(@selector(questionId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceQuestionIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setSurveyId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveSurveyId = [self primitiveValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    if ([AKGenerics object:surveyId isEqualToObject:primitiveSurveyId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:surveyId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceSurveyIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    [self setPrimitiveValue:surveyId forKey:NSStringFromSelector(@selector(surveyId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceSurveyIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveText = [self primitiveValueForKey:NSStringFromSelector(@selector(text))];
    
    if ([AKGenerics object:text isEqualToObject:primitiveText]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:text forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(text))];
    [self setPrimitiveValue:text forKey:NSStringFromSelector(@selector(text))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(text))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceTextDidChangeNotification object:self userInfo:userInfo];
}

- (void)setTextInputValue:(NSNumber *)textInputValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveTextInputValue = [self primitiveValueForKey:NSStringFromSelector(@selector(textInputValue))];
    
    if ([AKGenerics object:textInputValue isEqualToObject:primitiveTextInputValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:textInputValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(textInputValue))];
    [self setPrimitiveValue:textInputValue forKey:NSStringFromSelector(@selector(textInputValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(textInputValue))];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceTextInputDidChangeNotification object:self userInfo:userInfo];
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
        self.authorId = question ? question.authorId : nil;
        self.questionId = question ? question.questionId : nil;
        self.surveyId = question ? question.surveyId : nil;
    }
}

#pragma mark - // INITS AND LOADS //

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (!self.changedKeys || self.isDeleted) {
        [NSNotificationCenter postNotificationToMainThread:PQChoiceDidSaveNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    }
    
    if (self.changedKeys && !self.inserted) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(text))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.text forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQChoiceTextDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(textInputValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.textInputValue forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQChoiceTextInputDidSaveNotification object:self userInfo:userInfo];
        }
    }
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [NSNotificationCenter postNotificationToMainThread:PQChoiceWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS (Update) //

- (void)updateText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:text isEqualToObject:self.text]) {
        return;
    }
    
    self.text = text;
    self.question.editedAt = [NSDate date];
}

- (void)updateTextInput:(BOOL)textInput {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (textInput == self.textInput) {
        return;
    }
    
    self.textInput = textInput;
    self.question.editedAt = [NSDate date];
}

#pragma mark - // PUBLIC METHODS (Getters) //

- (NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.indexValue.integerValue;
}

- (BOOL)textInput {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.textInputValue.boolValue;
}

#pragma mark - // PUBLIC METHODS (Setters) //

- (void)setIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.indexValue = [NSNumber numberWithInteger:index];
}

- (void)setTextInput:(BOOL)textInput {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.textInputValue = [NSNumber numberWithBool:textInput];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionIdDidChange:) name:PQQuestionIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionAuthorIdDidChange:) name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionSurveyIdDidChange:) name:PQQuestionSurveyIdDidChangeNotification object:question];
}

- (void)removeObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionSurveyIdDidChangeNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *questionId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.questionId = questionId;
}

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
