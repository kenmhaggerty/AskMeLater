//
//  PQSurvey+CoreDataProperties.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQSurvey.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQSurvey (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDate *editedAt;
@property (nullable, nonatomic, retain) NSNumber *enabledValue;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *repeatValue;
@property (nullable, nonatomic, retain) NSNumber *secureValue;
@property (nullable, nonatomic, retain) NSString *surveyId;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSOrderedSet <PQQuestion *> *questions;
@property (nullable, nonatomic, retain) PQUser *author;

@end

@interface PQSurvey (CoreDataGeneratedAccessors)

- (void)insertObject:(PQQuestion *)value inQuestionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx;
- (void)insertQuestions:(NSArray <PQQuestion *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(PQQuestion *)value;
- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray <PQQuestion *> *)values;
- (void)addQuestionsObject:(PQQuestion *)value;
- (void)removeQuestionsObject:(PQQuestion *)value;
- (void)addQuestions:(NSOrderedSet <PQQuestion *> *)values;
- (void)removeQuestions:(NSOrderedSet <PQQuestion *> *)values;

@end

NS_ASSUME_NONNULL_END
