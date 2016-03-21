//
//  AKDebuggerRules.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 10/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKDebuggerRules.h"

#pragma mark - // DEFINITIONS (Private) //

// RULES (General) //

#define MASTER_ON NO

#define PRINT_CLASS_METHODS YES
#define PRINT_INSTANCE_METHODS YES

// RULES (AKLogType) //

#define PRINT_METHOD_NAMES YES
#define PRINT_INFOS YES
#define PRINT_DEBUGS YES
#define PRINT_NOTICES YES
#define PRINT_ALERTS YES
#define PRINT_WARNINGS YES
#define PRINT_ERRORS YES
#define PRINT_CRITICALS YES
#define PRINT_EMERGENCIES YES

// RULES (AKMethodType) //

#define PRINT_SETUPS YES
#define PRINT_SETTERS YES
#define PRINT_GETTERS YES
#define PRINT_CREATORS YES
#define PRINT_DELETORS YES
#define PRINT_ACTIONS YES
#define PRINT_VALIDATORS YES
#define PRINT_UNSPECIFIEDS YES

// RULES (Tags) //

#define TAGS_TO_PRINT nil
#define TAGS_TO_SKIP nil

// RULES (Classes) //

#define CLASSES_TO_PRINT nil
#define CLASSES_TO_SKIP nil

// RULES (Categories) //

#define PRINT_CATEGORIES YES
#define CATEGORIES_TO_PRINT nil
#define CATEGORIES_TO_SKIP nil

// RULES (Methods) //

#define METHODS_TO_PRINT nil
#define METHODS_TO_SKIP nil

// OTHER //

@implementation AKDebuggerRules

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (BOOL)masterOn
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return MASTER_ON;
}

+ (BOOL)printClassMethods
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CLASS_METHODS;
}

+ (BOOL)printInstanceMethods
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_INSTANCE_METHODS;
}

#pragma mark - // PUBLIC METHODS (AKLogType) //

+ (BOOL)printMethodNames
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_METHOD_NAMES;
}

+ (BOOL)printInfos
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_INFOS;
}

+ (BOOL)printDebugs
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_DEBUGS;
}

+ (BOOL)printNotices
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_NOTICES;
}

+ (BOOL)printAlerts
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_ALERTS;
}

+ (BOOL)printWarnings
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_WARNINGS;
}

+ (BOOL)printErrors
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_ERRORS;
}

+ (BOOL)printCriticals
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CRITICALS;
}

+ (BOOL)printEmergencies
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_EMERGENCIES;
}

#pragma mark - // PUBLIC METHODS (AKMethodType) //

+ (BOOL)printSetups
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_SETUPS;
}

+ (BOOL)printSetters
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_SETTERS;
}

+ (BOOL)printGetters
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_GETTERS;
}

+ (BOOL)printCreators
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CREATORS;
}

+ (BOOL)printDeletors
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_DELETORS;
}

+ (BOOL)printActions
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_ACTIONS;
}

+ (BOOL)printValidators
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_VALIDATORS;
}

+ (BOOL)printUnspecifieds
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_UNSPECIFIEDS;
}

#pragma mark - // PUBLIC METHODS (Tags) //

+ (nullable NSArray <NSString *> *)tagsToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return TAGS_TO_PRINT;
}

+ (nullable NSArray <NSString *> *)tagsToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return TAGS_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Classes) //

+ (nullable NSArray <NSString *> *)classesToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CLASSES_TO_PRINT;
}

+ (nullable NSArray <NSString *> *)classesToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CLASSES_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Categories) //

+ (BOOL)printCategories
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CATEGORIES;
}

+ (nullable NSArray <NSString *> *)categoriesToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CATEGORIES_TO_PRINT;
}

+ (nullable NSArray <NSString *> *)categoriesToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CATEGORIES_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Methods) //

+ (nullable NSArray <NSString *> *)methodsToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return METHODS_TO_PRINT;
}

+ (nullable NSArray <NSString *> *)methodsToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return METHODS_TO_SKIP;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end