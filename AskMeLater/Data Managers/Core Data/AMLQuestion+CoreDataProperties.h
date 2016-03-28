//
//  AMLQuestion+CoreDataProperties.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "AMLQuestion.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLQuestion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *secure;
@property (nullable, nonatomic, retain) NSSet <AMLResponse *> *responses;
@property (nullable, nonatomic, retain) NSOrderedSet <AMLChoice *> *choices;
@property (nullable, nonatomic, retain) AMLSurvey *survey;

@end

@interface AMLQuestion (CoreDataGeneratedAccessors)

- (void)addResponsesObject:(AMLResponse *)value;
- (void)removeResponsesObject:(AMLResponse *)value;
- (void)addResponses:(NSSet <AMLResponse *> *)values;
- (void)removeResponses:(NSSet <AMLResponse *> *)values;

- (void)insertObject:(AMLChoice *)value inChoicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChoicesAtIndex:(NSUInteger)idx;
- (void)insertChoices:(NSArray <AMLChoice *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChoicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChoicesAtIndex:(NSUInteger)idx withObject:(AMLChoice *)value;
- (void)replaceChoicesAtIndexes:(NSIndexSet *)indexes withChoices:(NSArray <AMLChoice *> *)values;
- (void)addChoicesObject:(AMLChoice *)value;
- (void)removeChoicesObject:(AMLChoice *)value;
- (void)addChoices:(NSOrderedSet <AMLChoice *> *)values;
- (void)removeChoices:(NSOrderedSet <AMLChoice *> *)values;

@end

NS_ASSUME_NONNULL_END
