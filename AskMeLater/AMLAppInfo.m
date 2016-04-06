//
//  AMLAppInfo.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 4/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLAppInfo.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const AMLTutorialEnabled = @"tutorialEnabled";

@interface AMLAppInfo ()
@end

@implementation AMLAppInfo

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

+ (BOOL)showTutorial {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *showTutorial = [defaults objectForKey:AMLTutorialEnabled];
    if (showTutorial) {
        return showTutorial.boolValue;
    }
    
    return YES;
}

+ (void)enableTutorial {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:AMLTutorialEnabled];
    [defaults synchronize];
}

+ (void)disableTutorial {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:AMLTutorialEnabled];
    [defaults synchronize];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
