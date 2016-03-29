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
@end

@implementation AMLQuestion

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

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

- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self replaceObjectInChoicesAtIndex:index withObject:choice];
}

- (void)removeChoiceAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObjectFromChoicesAtIndex:index];
}

- (void)removeChoice:(AMLChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeChoicesObject:choice];
}

- (void)addResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OLD_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [self addResponsesObject:response];
    
    userInfo[NOTIFICATION_OBJECT_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [AKGenerics postNotificationName:AMLQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

- (void)deleteResponse:(AMLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OLD_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [self removeResponsesObject:response];
    
    userInfo[NOTIFICATION_OBJECT_KEY] = [NSNumber numberWithInteger:self.responses.count];
    
    [AKGenerics postNotificationName:AMLQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
