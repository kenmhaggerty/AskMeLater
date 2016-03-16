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

#pragma mark - // INITS AND LOADS //

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
