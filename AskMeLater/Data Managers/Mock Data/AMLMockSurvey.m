//
//  AMLMockSurvey.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/21/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLMockSurvey.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLMockSurvey ()
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@end

@implementation AMLMockSurvey

#pragma mark - // SETTERS AND GETTERS //

- (void)setName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    if ([AKGenerics object:name isEqualToObject:_name]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (name) {
        userInfo[NOTIFICATION_OBJECT_KEY] = name;
    }
    
    _name = name;
    
    [AKGenerics postNotificationName:NOTIFICATION_AMLSURVEY_NAME_DID_CHANGE object:self userInfo:userInfo];
}

- (void)setEditedAt:(NSDate *)editedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    if ([AKGenerics object:editedAt isEqualToObject:_editedAt]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = editedAt;
    
    _editedAt = editedAt;
    
    [AKGenerics postNotificationName:NOTIFICATION_AMLSURVEY_EDITEDAT_DID_CHANGE object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [self teardown];
}

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    return [self initWithName:@"My Survey"];
}

- (id)initWithName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    self = [super init];
    if (self) {
        [self setup];
        _name = name;
        _createdAt = [NSDate date];
        _editedAt = [NSDate date];
    }
    return self;
}

- (void)awakeFromNib {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
