//
//  AMLSurvey+CoreDataProperties.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurvey+CoreDataProperties.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation AMLSurvey (CoreDataProperties)

#pragma mark - // SETTERS AND GETTERS //

@dynamic name;
@dynamic createdAt;
@dynamic editedAt;
@dynamic time;
@dynamic repeat;
@dynamic enabled;
@dynamic questions;
@dynamic author;

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)insertObject:(AMLQuestion *)value inQuestionsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)removeObjectFromQuestionsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)insertQuestions:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)removeQuestionsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)replaceObjectInQuestionsAtIndex:(NSUInteger)idx withObject:(AMLQuestion *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)replaceQuestionsAtIndexes:(NSIndexSet *)indexes withQuestions:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)addQuestionsObject:(AMLQuestion *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
}

- (void)removeQuestionsObject:(AMLQuestion *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    }
}

- (void)addQuestions:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    }
}

- (void)removeQuestions:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questions))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questions))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questions))];
    }
}

#pragma mark - // PRIVATE METHODS //

@end
