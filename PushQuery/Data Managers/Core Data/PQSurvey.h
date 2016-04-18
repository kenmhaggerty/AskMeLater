//
//  PQSurvey.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQManagedObject.h"
#import "NSObject+Basics.h"

@class PQUser, PQQuestion;

#pragma mark - // PROTOCOLS //

#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQSurvey : PQManagedObject <PQSurvey_Editable>

- (BOOL)enabled;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)repeat;
- (void)setRepeat:(BOOL)repeat;

- (void)addQuestion:(PQQuestion *)question;
- (void)insertQuestion:(PQQuestion *)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(PQQuestion *)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeQuestion:(PQQuestion *)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END

#import "PQSurvey+CoreDataProperties.h"
