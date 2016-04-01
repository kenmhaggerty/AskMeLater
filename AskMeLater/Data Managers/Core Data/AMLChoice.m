//
//  AMLChoice.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLChoice.h"
#import "AMLQuestion.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLChoice ()
@end

@implementation AMLChoice

#pragma mark - // SETTERS AND GETTERS //

- (void)setText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveText = [self primitiveValueForKey:NSStringFromSelector(@selector(text))];
    
    if ([AKGenerics object:text isEqualToObject:primitiveText]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (text) {
        userInfo[NOTIFICATION_OBJECT_KEY] = text;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(text))];
    [self setPrimitiveValue:text forKey:NSStringFromSelector(@selector(text))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(text))];
    
    [AKGenerics postNotificationName:AMLChoiceTextDidChangeNotification object:self userInfo:userInfo];
}

- (void)setTextInputValue:(NSNumber *)textInputValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveTextInputValue = [self primitiveValueForKey:NSStringFromSelector(@selector(textInputValue))];
    
    if ([AKGenerics object:textInputValue isEqualToObject:primitiveTextInputValue]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = textInputValue;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(textInputValue))];
    [self setPrimitiveValue:textInputValue forKey:NSStringFromSelector(@selector(textInputValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(textInputValue))];
    
    [AKGenerics postNotificationName:AMLChoiceTextInputDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:AMLChoiceWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
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
