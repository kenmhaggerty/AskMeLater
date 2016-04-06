//
//  AKDebuggerRules.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 10/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "AKDebugger.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AKDebuggerRules : NSObject <AKDebuggerRules>

// General //

+ (BOOL)masterOn;

+ (BOOL)printClassMethods;
+ (BOOL)printInstanceMethods;

// AKLogType //

+ (BOOL)printMethodNames;
+ (BOOL)printInfos;
+ (BOOL)printDebugs;
+ (BOOL)printNotices;
+ (BOOL)printAlerts;
+ (BOOL)printWarnings;
+ (BOOL)printErrors;
+ (BOOL)printCriticals;
+ (BOOL)printEmergencies;

// AKMethodType //

+ (BOOL)printSetups;
+ (BOOL)printSetters;
+ (BOOL)printGetters;
+ (BOOL)printCreators;
+ (BOOL)printDeletors;
+ (BOOL)printActions;
+ (BOOL)printValidators;
+ (BOOL)printUnspecifieds;

// Tags //

+ (nullable NSArray <NSString *> *)tagsToPrint;
+ (nullable NSArray <NSString *> *)tagsToSkip;

// Classes //

+ (nullable NSArray <NSString *> *)classesToPrint;
+ (nullable NSArray <NSString *> *)classesToSkip;

// Categories //

+ (BOOL)printCategories;
+ (nullable NSArray <NSString *> *)categoriesToPrint;
+ (nullable NSArray <NSString *> *)categoriesToSkip;

// Methods //

+ (nullable NSArray <NSString *> *)methodsToPrint;
+ (nullable NSArray <NSString *> *)methodsToSkip;

@end