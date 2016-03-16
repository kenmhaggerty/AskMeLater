//
//  AMLSurvey+CoreDataProperties.h
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

#import "AMLSurvey.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLSurvey (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDate *editedAt;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSNumber *repeat;
@property (nullable, nonatomic, retain) NSNumber *enabled;
@property (nullable, nonatomic, retain) NSOrderedSet <AMLQuestion *> *questions;
@property (nullable, nonatomic, retain) AMLUser *author;

@end

@interface AMLSurvey (CoreDataGeneratedAccessors)

- (void)insertObject:(AMLQuestion *)value inQuestionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx;
- (void)insertQuestions:(NSArray<AMLQuestion *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(AMLQuestion *)value;
- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray<AMLQuestion *> *)values;
- (void)addQuestionsObject:(AMLQuestion *)value;
- (void)removeQuestionsObject:(AMLQuestion *)value;
- (void)addQuestions:(NSOrderedSet<AMLQuestion *> *)values;
- (void)removeQuestions:(NSOrderedSet<AMLQuestion *> *)values;

@end

NS_ASSUME_NONNULL_END
