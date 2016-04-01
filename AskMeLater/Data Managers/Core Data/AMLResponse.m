//
//  AMLResponse.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLResponse.h"
#import "AMLUser.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLResponse ()
@end

@implementation AMLResponse

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [AKGenerics postNotificationName:AMLResponseWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
