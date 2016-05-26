//
//  PQQuestion.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQEditableObject.h"

@class PQChoiceIndex, PQChoice, PQQuestionIndex, PQResponse, PQSurvey;

#pragma mark - // PROTOCOLS //

#import "PQQuestionProtocols+Firebase.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQQuestion : PQEditableObject <PQQuestion_PRIVATE, PQQuestion_Firebase>

// UPDATE //

- (void)updateText:(NSString *)text;
- (void)updateSecure:(BOOL)secure;

- (void)addChoice:(PQChoice *)choice;
- (void)insertChoice:(PQChoice *)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(PQChoice *)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeChoice:(PQChoice *)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;

// GETTERS //

- (BOOL)secure;
- (NSOrderedSet <PQChoice *> *)choices;

// SETTERS //

- (void)setSecure:(BOOL)secure;
- (void)setChoices:(NSOrderedSet <PQChoice *> *)choices;

- (void)addResponse:(PQResponse *)response;
- (void)removeResponse:(PQResponse *)response;

@end

NS_ASSUME_NONNULL_END

#import "PQQuestion+CoreDataProperties.h"
