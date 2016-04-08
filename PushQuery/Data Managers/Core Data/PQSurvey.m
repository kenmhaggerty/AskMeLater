//
//  PQSurvey.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurvey.h"
#import "PQUser.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSurvey ()

// OBSERVERS //

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;

// RESPONDERS //

- (void)questionWillBeDeleted:(NSNotification *)notification;

@end

@implementation PQSurvey

#pragma mark - // SETTERS AND GETTERS //

- (void)setName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveName = [self primitiveValueForKey:NSStringFromSelector(@selector(name))];
    
    if ([AKGenerics object:name isEqualToObject:primitiveName]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (name) {
        userInfo[NOTIFICATION_OBJECT_KEY] = name;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(name))];
    [self setPrimitiveValue:name forKey:NSStringFromSelector(@selector(name))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(name))];
    
    [AKGenerics postNotificationName:PQSurveyNameDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEditedAt:(NSDate *)editedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveEditedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    if ([AKGenerics object:editedAt isEqualToObject:primitiveEditedAt]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = editedAt;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    [self setPrimitiveValue:editedAt forKey:NSStringFromSelector(@selector(editedAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    [AKGenerics postNotificationName:PQSurveyEditedAtDidChangeNotification object:self userInfo:userInfo];
}

- (void)setTime:(NSDate *)time {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *primitiveTime = [self primitiveValueForKey:NSStringFromSelector(@selector(time))];
    
    if ([AKGenerics object:time isEqualToObject:primitiveTime]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = time;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(time))];
    [self setPrimitiveValue:time forKey:NSStringFromSelector(@selector(time))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(time))];
    
    [AKGenerics postNotificationName:PQSurveyTimeDidChangeNotification object:self userInfo:userInfo];
}

- (void)setRepeatValue:(NSNumber *)repeatValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveRepeatValue = [self primitiveValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    if ([AKGenerics object:repeatValue isEqualToObject:primitiveRepeatValue]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = repeatValue;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    [self setPrimitiveValue:repeatValue forKey:NSStringFromSelector(@selector(repeatValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    [AKGenerics postNotificationName:PQSurveyRepeatDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEnabledValue:(NSNumber *)enabledValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveEnabledValue = [self primitiveValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    if ([AKGenerics object:enabledValue isEqualToObject:primitiveEnabledValue]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = enabledValue;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    [self setPrimitiveValue:enabledValue forKey:NSStringFromSelector(@selector(enabledValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    [AKGenerics postNotificationName:PQSurveyEnabledDidChangeNotification object:self userInfo:userInfo];
}

- (void)setQuestions:(NSOrderedSet <PQQuestion *> *)questions {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveQuestions = [self primitiveValueForKey:NSStringFromSelector(@selector(questions))];
    
    if ([AKGenerics object:questions isEqualToObject:primitiveQuestions]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = questions;
    
    for (PQQuestion *question in primitiveQuestions) {
        [self removeObserversFromQuestion:question];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questions))];
    [self setPrimitiveValue:questions forKey:NSStringFromSelector(@selector(questions))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questions))];
    
    for (PQQuestion *question in questions) {
        [self addObserversToQuestion:question];
    }
    
    [AKGenerics postNotificationName:PQSurveyQuestionsDidChangeNotification object:self userInfo:userInfo];
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

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:PQSurveyWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

- (BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.repeatValue.boolValue;
}

- (void)setRepeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.repeatValue = [NSNumber numberWithBool:repeat];
}

- (BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.enabledValue.boolValue;
}

- (void)setEnabled:(BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.enabledValue = [NSNumber numberWithBool:enabled];
}

- (void)addQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = question;
    
    [self addQuestionsObject:question];
    
    [self addObserversToQuestion:question];
    
    [AKGenerics postNotificationName:PQSurveyQuestionWasAddedNotification object:self userInfo:userInfo];
}

- (void)insertQuestion:(PQQuestion *)question atIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = question;
    
    [self insertObject:question inQuestionsAtIndex:index];
    
    [self addObserversToQuestion:question];
    
    [AKGenerics postNotificationName:PQSurveyQuestionWasAddedNotification object:self userInfo:userInfo];
}

- (void)moveQuestion:(PQQuestion *)question toIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (![self.questions containsObject:question]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is not in self.%@", stringFromVariable(question), NSStringFromSelector(@selector(questions))]];
        return;
    }
    
    if (index == [self.questions indexOfObject:question]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is alread at index %lu", stringFromVariable(question), (unsigned long)index]];
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = question;
    userInfo[NOTIFICATION_SECONDARY_KEY] = [NSNumber numberWithInteger:[self.questions indexOfObject:question]];
    
    [self removeQuestionsObject:question];
    [self insertObject:question inQuestionsAtIndex:index];
    
    [AKGenerics postNotificationName:PQSurveyQuestionWasReorderedNotification object:self userInfo:userInfo];
}

- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (fromIndex == toIndex) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ (%lu) and %@ (%lu) are equal", stringFromVariable(fromIndex), (unsigned long)fromIndex, stringFromVariable(toIndex), (unsigned long)toIndex]];
        return;
    }
    
    PQQuestion *question = self.questions[fromIndex];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = question;
    userInfo[NOTIFICATION_SECONDARY_KEY] = [NSNumber numberWithInteger:[self.questions indexOfObject:question]];
    
    [self removeQuestionsObject:question];
    [self insertObject:question inQuestionsAtIndex:toIndex];
    
    [AKGenerics postNotificationName:PQSurveyQuestionWasReorderedNotification object:self userInfo:userInfo];
}

- (void)removeQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObserversFromQuestion:question];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = question;
    
//    [AKGenerics postNotificationName:PQSurveyQuestionWillBeRemoved object:self userInfo:userInfo];
    [AKGenerics postNotificationName:PQQuestionWillBeRemovedNotification object:question userInfo:nil];
    
    userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = [NSNumber numberWithInteger:[self.questions indexOfObject:question]];
    
    [self removeQuestionsObject:question];
    
    [AKGenerics postNotificationName:PQSurveyQuestionAtIndexWasRemovedNotification object:self userInfo:userInfo];
}

- (void)removeQuestionAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    PQQuestion *question = [self.questions objectAtIndex:index];
    [self removeQuestion:question];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    for (PQQuestion *question in self.questions) {
        [self addObserversToQuestion:question];
    }
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (PQQuestion *question in self.questions) {
        [self removeObserversFromQuestion:question];
    }
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWillBeDeleted:) name:PQQuestionWillBeDeletedNotification object:question];
}

- (void)removeObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionWillBeDeletedNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = notification.object;
    
    [self removeQuestion:question];
}

@end
