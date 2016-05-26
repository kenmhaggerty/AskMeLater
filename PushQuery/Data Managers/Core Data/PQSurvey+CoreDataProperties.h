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

@property (nullable, nonatomic, retain) NSString *authorId;
@property (nullable, nonatomic, retain, readonly) NSNumber *enabledValue;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain, readonly) NSNumber *repeatValue;
@property (nullable, nonatomic, retain) NSString *surveyId;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain, readonly) PQUser *author;
@property (nullable, nonatomic, retain, readonly) NSOrderedSet <PQQuestionIndex *> *questionIndices;
@property (nullable, nonatomic, retain, readonly) NSSet <PQQuestion *> *questionObjects;

@end

@interface PQSurvey (CoreDataGeneratedAccessors)

- (void)insertObject:(PQQuestionIndex *)value inQuestionIndicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromQuestionIndicesAtIndex:(NSUInteger)idx;
- (void)insertQuestionIndices:(NSArray <PQQuestionIndex *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeQuestionIndicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInQuestionIndicesAtIndex:(NSUInteger)idx withObject:(PQQuestionIndex *)value;
- (void)replaceQuestionIndicesAtIndexes:(NSIndexSet *)indexes withQuestionIndices:(NSArray <PQQuestionIndex *> *)values;
- (void)addQuestionIndicesObject:(PQQuestionIndex *)value;
- (void)removeQuestionIndicesObject:(PQQuestionIndex *)value;
- (void)addQuestionIndices:(NSOrderedSet <PQQuestionIndex *> *)values;
- (void)removeQuestionIndices:(NSOrderedSet <PQQuestionIndex *> *)values;

- (void)addQuestionObjectsObject:(PQQuestion *)value;
- (void)removeQuestionObjectsObject:(PQQuestion *)value;
- (void)addQuestionObjects:(NSSet <PQQuestion *> *)values;
- (void)removeQuestionObjects:(NSSet <PQQuestion *> *)values;

@end

NS_ASSUME_NONNULL_END
