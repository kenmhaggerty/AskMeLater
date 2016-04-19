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

- (void)setEditedAt:(NSDate *)editedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveEditedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    if ([AKGenerics object:editedAt isEqualToObject:primitiveEditedAt]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:editedAt forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    [self setPrimitiveValue:editedAt forKey:NSStringFromSelector(@selector(editedAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    [AKGenerics postNotificationName:PQSurveyEditedAtDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEnabledValue:(NSNumber *)enabledValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveEnabledValue = [self primitiveValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    if ([AKGenerics object:enabledValue isEqualToObject:primitiveEnabledValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:enabledValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    [self setPrimitiveValue:enabledValue forKey:NSStringFromSelector(@selector(enabledValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    [AKGenerics postNotificationName:PQSurveyEnabledDidChangeNotification object:self userInfo:userInfo];
}

- (void)setName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveName = [self primitiveValueForKey:NSStringFromSelector(@selector(name))];
    
    if ([AKGenerics object:name isEqualToObject:primitiveName]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:name forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(name))];
    [self setPrimitiveValue:name forKey:NSStringFromSelector(@selector(name))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(name))];
    
    [AKGenerics postNotificationName:PQSurveyNameDidChangeNotification object:self userInfo:userInfo];
}

- (void)setRepeatValue:(NSNumber *)repeatValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveRepeatValue = [self primitiveValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    if ([AKGenerics object:repeatValue isEqualToObject:primitiveRepeatValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:repeatValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    [self setPrimitiveValue:repeatValue forKey:NSStringFromSelector(@selector(repeatValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    [AKGenerics postNotificationName:PQSurveyRepeatDidChangeNotification object:self userInfo:userInfo];
}

- (void)setTime:(NSDate *)time {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *primitiveTime = [self primitiveValueForKey:NSStringFromSelector(@selector(time))];
    
    if ([AKGenerics object:time isEqualToObject:primitiveTime]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:time forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(time))];
    [self setPrimitiveValue:time forKey:NSStringFromSelector(@selector(time))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(time))];
    
    [AKGenerics postNotificationName:PQSurveyTimeDidChangeNotification object:self userInfo:userInfo];
}

- (void)setQuestions:(NSOrderedSet <PQQuestion *> *)questions {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveQuestions = [self primitiveValueForKey:NSStringFromSelector(@selector(questions))];
    
    if ([AKGenerics object:questions isEqualToObject:primitiveQuestions]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:questions forKey:NOTIFICATION_OBJECT_KEY];
    
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

- (void)setAuthor:(PQUser *)author {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQUser *primitiveAuthor = [self primitiveValueForKey:NSStringFromSelector(@selector(author))];
    
    if ([AKGenerics object:author isEqualToObject:primitiveAuthor]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:author forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(author))];
    [self setPrimitiveValue:author forKey:NSStringFromSelector(@selector(author))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(author))];
    
    [AKGenerics postNotificationName:PQSurveyAuthorDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super willSave];
    
    if (!self.updated) {
        return;
    }
    
    [AKGenerics postNotificationName:PQSurveyWillBeSavedNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.changedKeys) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(editedAt))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.editedAt forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyEditedAtDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(enabledValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.enabledValue forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyEnabledDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(name))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.name forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyNameDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(repeatValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.repeatValue forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyRepeatDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(time))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.time forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyTimeDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(author))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.author forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQSurveyAuthorDidSaveNotification object:self userInfo:userInfo];
        }
    }
    [AKGenerics postNotificationName:PQSurveyWasSavedNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super prepareForDeletion];
    
    [AKGenerics postNotificationName:PQUserWillBeDeletedNotification object:self userInfo:nil];
}

#pragma mark - // PUBLIC METHODS //

- (BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.enabledValue.boolValue;
}

- (void)setEnabled:(BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.enabledValue = [NSNumber numberWithBool:enabled];
}

- (BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.repeatValue.boolValue;
}

- (void)setRepeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.repeatValue = [NSNumber numberWithBool:repeat];
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
