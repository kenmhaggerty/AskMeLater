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
#import "PQQuestion.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQChoice ()
@end

@implementation PQChoice

#pragma mark - // SETTERS AND GETTERS //

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
    
    [AKGenerics postNotificationName:PQChoiceTextDidChangeNotification object:self userInfo:userInfo];
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
    
    [AKGenerics postNotificationName:PQChoiceTextInputDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)willSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [super willSave];
    
    if (!self.updated) {
        return;
    }
    
    [AKGenerics postNotificationName:PQChoiceWillBeSavedNotification object:self userInfo:@{NOTIFICATION_OBJECT_KEY : self.changedKeys}];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.changedKeys) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(text))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.text forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQChoiceTextDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(textInputValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.textInputValue forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQChoiceTextInputDidSaveNotification object:self userInfo:userInfo];
        }
    }
    [AKGenerics postNotificationName:PQChoiceWasSavedNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super prepareForDeletion];
    
    [AKGenerics postNotificationName:PQChoiceWillBeDeletedNotification object:self userInfo:nil];
}

#pragma mark - // PUBLIC METHODS //

- (void)setTextInput:(BOOL)textInput {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.textInputValue = [NSNumber numberWithBool:textInput];
}

- (BOOL)textInput {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.textInputValue.boolValue;
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
