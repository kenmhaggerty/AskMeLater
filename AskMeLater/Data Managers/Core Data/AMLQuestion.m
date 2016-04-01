//
//  AMLQuestion.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLQuestion.h"
#import "AMLResponse.h"
#import "AMLSurvey.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLQuestion ()

// OBSERVERS //

- (void)addObserversToChoice:(AMLChoice *)choice;
- (void)removeObserversFromChoice:(AMLChoice *)choice;
- (void)addObserversToResponse:(AMLResponse *)response;
- (void)removeObserversFromResponse:(AMLResponse *)response;

// RESPONDERS //

- (void)choiceWillBeDeleted:(NSNotification *)notification;
- (void)responseWillBeDeleted:(NSNotification *)notification;

@end

@implementation AMLQuestion

#pragma mark - // SETTERS AND GETTERS //

- (void)setChoices:(NSOrderedSet <AMLChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet <AMLChoice *> *primitiveChoices = [self primitiveValueForKey:NSStringFromSelector(@selector(choices))];
    
    if ([AKGenerics object:choices isEqualToObject:primitiveChoices]) {
        return;
    }
    
    for (AMLChoice *choice in primitiveChoices) {
        [self removeObserversFromChoice:choice];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(choices))];
    [self setPrimitiveValue:choices forKey:NSStringFromSelector(@selector(choices))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(choices))];
    
    for (AMLChoice *choice in choices) {
        [self addObserversToChoice:choice];
    }
}

- (void)setResponses:(NSSet <AMLResponse *> *)responses {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet <AMLResponse *> *primitiveResponses = [self primitiveValueForKey:NSStringFromSelector(@selector(responses))];
    
    if ([AKGenerics object:responses isEqualToObject:primitiveResponses]) {
        return;
    }
    
    for (AMLResponse *response in primitiveResponses) {
        [self removeObserversFromResponse:response];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(responses))];
    [self setPrimitiveValue:responses forKey:NSStringFromSelector(@selector(responses))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(responses))];
    
    for (AMLResponse *response in responses) {
        [self addObserversToResponse:response];
    }
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:AMLQuestionWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

- (BOOL)secure {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.secureValue.boolValue;
}

- (void)setSecure:(BOOL)secure {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.secureValue = [NSNumber numberWithBool:secure];
}

- (void)addChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self addChoicesObject:choice];
    
    [self addObserversToChoice:choice];
}

- (void)insertChoice:(AMLChoice *)choice atIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self insertObject:choice inChoicesAtIndex:index];
    
    [self addObserversToChoice:choice];
}

- (void)moveChoice:(AMLChoice *)choice toIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (![self.choices containsObject:choice]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is not in self.%@", stringFromVariable(choice), NSStringFromSelector(@selector(choices))]];
        return;
    }
    
    if (index == [self.choices indexOfObject:choice]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is alread at index %lu", stringFromVariable(choice), index]];
        return;
    }
    
    [self removeChoicesObject:choice];
    [self insertObject:choice inChoicesAtIndex:index];
}

- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (fromIndex == toIndex) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ (%lu) and %@ (%lu) are equal", stringFromVariable(fromIndex), fromIndex, stringFromVariable(toIndex), toIndex]];
        return;
    }
    
    AMLChoice *choice = self.choices[fromIndex];
    
    [self removeChoicesObject:choice];
    [self insertObject:choice inChoicesAtIndex:toIndex];
}

- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    AMLChoice *primitiveChoice = [self.choices objectAtIndex:index];
    
    if ([AKGenerics object:choice isEqualToObject:primitiveChoice]) {
        return;
    }
    
    [self replaceObjectInChoicesAtIndex:index withObject:choice];
}

- (void)removeChoiceAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    AMLChoice *choice = [self.choices objectAtIndex:index];
    
    [self removeChoice:choice];
}

- (void)removeChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObserversFromChoice:choice];
    
    [self removeChoicesObject:choice];
}

- (void)addResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OLD_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [self addResponsesObject:response];
    
    [self addObserversToResponse:response];
    
    userInfo[NOTIFICATION_OBJECT_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [AKGenerics postNotificationName:AMLQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

- (void)deleteResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObserversFromResponse:response];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OLD_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [self removeResponsesObject:response];
    
    userInfo[NOTIFICATION_OBJECT_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [AKGenerics postNotificationName:AMLQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    for (AMLChoice *choice in self.choices) {
        [self addObserversToChoice:choice];
    }
    for (AMLResponse *response in self.responses) {
        [self addObserversToResponse:response];
    }
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (AMLChoice *choice in self.choices) {
        [self removeObserversFromChoice:choice];
    }
    for (AMLResponse *response in self.responses) {
        [self removeObserversFromResponse:response];
    }
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceWillBeDeleted:) name:AMLChoiceWillBeDeletedNotification object:choice];
}

- (void)removeObserversFromChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLChoiceWillBeDeletedNotification object:choice];
}

- (void)addObserversToResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseWillBeDeleted:) name:AMLResponseWillBeDeletedNotification object:response];
}

- (void)removeObserversFromResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLResponseWillBeDeletedNotification object:response];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)choiceWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    AMLChoice *choice = notification.object;
    
    [self removeChoice:choice];
}

- (void)responseWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    AMLResponse *response = notification.object;
    
    [self removeResponse:response];
}

@end
