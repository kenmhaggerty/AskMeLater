//
//  AMLDataManager.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLDataManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLCoreDataController.h"
#import "AMLFirebaseController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLDataManager ()
@end

@implementation AMLDataManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [AMLFirebaseController setup];
}

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [AMLCoreDataController save];
}

+ (void)test {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    AMLFirebaseQuery *query = [AMLFirebaseQuery queryWithKey:@"hidden" relation:AMLKeyIsEqualTo value:@NO];
    [AMLFirebaseController getObjectsAtPath:@"users" withQueries:@[query] andCompletion:^(id result) {
        //
    }];
}

#pragma mark - // CATEGORY METHODS (Firebase) //

+ (BOOL)isConnectedToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:nil message:nil];
    
    return [AMLFirebaseController isConnected];
}

+ (void)connectToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [AMLFirebaseController connect];
}

+ (void)disconnectFromFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [AMLFirebaseController disconnect];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
