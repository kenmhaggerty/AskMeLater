//
//  PQChoice.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQSyncedObject.h"

@class PQChoiceIndex, PQQuestion;

#pragma mark - // PROTOCOLS //

#import "PQChoiceProtocols+Firebase.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQChoice : PQSyncedObject <PQChoice_PRIVATE, PQChoice_Firebase>

// UPDATE //

- (void)updateText:(NSString *)text;
- (void)updateTextInput:(BOOL)textInput;

// GETTERS //

- (NSUInteger)index;
- (BOOL)textInput;

// SETTERS //

- (void)setIndex:(NSUInteger)index;
- (void)setTextInput:(BOOL)textInput;

@end

NS_ASSUME_NONNULL_END

#import "PQChoice+CoreDataProperties.h"
