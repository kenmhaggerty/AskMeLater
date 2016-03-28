//
//  AMLSurvey.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurvey.h"
#import "AMLUser.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLSurvey ()
@end

@implementation AMLSurvey

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
    
    [AKGenerics postNotificationName:AMLSurveyNameDidChangeNotification object:self userInfo:userInfo];
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
    
    [AKGenerics postNotificationName:AMLSurveyEditedAtDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:AMLSurveyWillBeDeletedNotification object:self userInfo:nil];
}

#pragma mark - // PUBLIC METHODS //

- (void)addQuestion:(AMLQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self addQuestionsObject:question];
}

- (void)insertQuestion:(AMLQuestion *)question atIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self insertObject:question inQuestionsAtIndex:index];
}

- (void)moveQuestion:(AMLQuestion *)question toIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (![self.questions containsObject:question]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is not in self.%@", stringFromVariable(question), NSStringFromSelector(@selector(questions))]];
        return;
    }
    
    if (index == [self.questions indexOfObject:question]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is alread at index %lu", stringFromVariable(question), index]];
        return;
    }
    
    [self removeQuestionsObject:question];
    [self insertObject:question inQuestionsAtIndex:index];
}

- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (fromIndex == toIndex) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ (%lu) and %@ (%lu) are equal", stringFromVariable(fromIndex), fromIndex, stringFromVariable(toIndex), toIndex]];
        return;
    }
    
    AMLQuestion *question = self.questions[fromIndex];
    [self removeQuestionsObject:question];
    [self insertObject:question inQuestionsAtIndex:toIndex];
}

- (void)removeQuestion:(AMLQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeQuestionsObject:question];
}

- (void)removeQuestionAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObjectFromQuestionsAtIndex:index];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
