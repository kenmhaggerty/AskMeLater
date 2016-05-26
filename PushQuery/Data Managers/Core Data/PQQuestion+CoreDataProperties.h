//
//  PQQuestion+CoreDataProperties.h
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

#import "PQQuestion.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQQuestion (CoreDataProperties)

@property (nullable, nonatomic, retain, readonly) NSString *authorId;
@property (nullable, nonatomic, retain) NSString *questionId;
@property (nullable, nonatomic, retain, readonly) NSNumber *secureValue;
@property (nullable, nonatomic, retain, readonly) NSString *surveyId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain, readonly) NSOrderedSet <PQChoiceIndex *> *choiceIndices;
@property (nullable, nonatomic, retain, readonly) NSSet <PQChoice *> *choiceObjects;
@property (nullable, nonatomic, retain) PQQuestionIndex *questionIndex;
@property (nullable, nonatomic, retain) NSSet <PQResponse *> *responses;
@property (nullable, nonatomic, retain, readonly) PQSurvey *survey;

@end

@interface PQQuestion (CoreDataGeneratedAccessors)

- (void)insertObject:(PQChoiceIndex *)value inChoiceIndicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChoiceIndicesAtIndex:(NSUInteger)idx;
- (void)insertChoiceIndices:(NSArray <PQChoiceIndex *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChoiceIndicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChoiceIndicesAtIndex:(NSUInteger)idx withObject:(PQChoiceIndex *)value;
- (void)replaceChoiceIndicesAtIndexes:(NSIndexSet *)indexes withChoiceIndices:(NSArray <PQChoiceIndex *> *)values;
- (void)addChoiceIndicesObject:(PQChoiceIndex *)value;
- (void)removeChoiceIndicesObject:(PQChoiceIndex *)value;
- (void)addChoiceIndices:(NSOrderedSet <PQChoiceIndex *> *)values;
- (void)removeChoiceIndices:(NSOrderedSet <PQChoiceIndex *> *)values;

- (void)addChoiceObjectsObject:(PQChoice *)value;
- (void)removeChoiceObjectsObject:(PQChoice *)value;
- (void)addChoiceObjects:(NSSet <PQChoice *> *)values;
- (void)removeChoiceObjects:(NSSet <PQChoice *> *)values;

- (void)addResponsesObject:(PQResponse *)value;
- (void)removeResponsesObject:(PQResponse *)value;
- (void)addResponses:(NSSet <PQResponse *> *)values;
- (void)removeResponses:(NSSet <PQResponse *> *)values;

@end

NS_ASSUME_NONNULL_END
