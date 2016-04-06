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
#import "NSObject+Basics.h"

@class PQResponse, PQChoice, PQSurvey;

#pragma mark - // PROTOCOLS //

#import "PQQuestionProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQQuestion : NSManagedObject <PQQuestion_PRIVATE>

- (BOOL)secure;
- (void)setSecure:(BOOL)secure;

- (void)addChoice:(PQChoice *)choice;
- (void)insertChoice:(PQChoice *)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(PQChoice *)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(PQChoice *)choice;
- (void)removeChoice:(PQChoice *)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;

- (void)addResponse:(PQResponse *)response;
- (void)removeResponse:(PQResponse *)response;

@end

NS_ASSUME_NONNULL_END

#import "PQQuestion+CoreDataProperties.h"
