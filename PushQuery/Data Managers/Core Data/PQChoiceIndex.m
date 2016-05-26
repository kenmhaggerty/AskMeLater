//
//  PQChoiceIndex.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQChoiceIndex.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQChoice.h"
#import "PQQuestion.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQChoiceIndex ()
@end

@implementation PQChoiceIndex

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (Setter) //

- (void)setIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.choice.index = index;
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
