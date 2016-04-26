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
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *questionId;
@property (nullable, nonatomic, retain) NSNumber *secureValue;
@property (nullable, nonatomic, retain) NSString *surveyId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSOrderedSet <PQChoice *> *choices;
@property (nullable, nonatomic, retain) NSSet <PQResponse *> *responses;
@property (nullable, nonatomic, retain, readonly) PQSurvey *survey;

@end

@interface PQQuestion (CoreDataGeneratedAccessors)

- (void)insertObject:(PQChoice *)value inChoicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChoicesAtIndex:(NSUInteger)idx;
- (void)insertChoices:(NSArray <PQChoice *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChoicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChoicesAtIndex:(NSUInteger)idx withObject:(PQChoice *)value;
- (void)replaceChoicesAtIndexes:(NSIndexSet *)indexes withChoices:(NSArray <PQChoice *> *)values;
- (void)addChoicesObject:(PQChoice *)value;
- (void)removeChoicesObject:(PQChoice *)value;
- (void)addChoices:(NSOrderedSet <PQChoice *> *)values;
- (void)removeChoices:(NSOrderedSet <PQChoice *> *)values;

- (void)addResponsesObject:(PQResponse *)value;
- (void)removeResponsesObject:(PQResponse *)value;
- (void)addResponses:(NSSet <PQResponse *> *)values;
- (void)removeResponses:(NSSet <PQResponse *> *)values;

@end

NS_ASSUME_NONNULL_END
