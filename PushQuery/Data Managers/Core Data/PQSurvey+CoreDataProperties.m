//
//  PQSurvey+CoreDataProperties.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurvey+CoreDataProperties.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation PQSurvey (CoreDataProperties)

#pragma mark - // SETTERS AND GETTERS //

@dynamic authorId;
@dynamic enabledValue;
@dynamic name;
@dynamic repeatValue;
@dynamic surveyId;
@dynamic time;
@dynamic author;
@dynamic questionIndices;
@dynamic questionObjects;

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)insertObject:(PQQuestionIndex *)value inQuestionIndicesAtIndex:(NSUInteger)idx {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)removeObjectFromQuestionIndicesAtIndex:(NSUInteger)idx {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)insertQuestionIndices:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)removeQuestionIndicesAtIndexes:(NSIndexSet *)indexes {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)replaceObjectInQuestionIndicesAtIndex:(NSUInteger)idx withObject:(PQQuestionIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)replaceQuestionIndicesAtIndexes:(NSIndexSet *)indexes withQuestionIndices:(NSArray *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)addQuestionIndicesObject:(PQQuestionIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
}

- (void)removeQuestionIndicesObject:(PQQuestionIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    }
}

- (void)addQuestionIndices:(NSOrderedSet *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    }
}

- (void)removeQuestionIndices:(NSOrderedSet *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(questionIndices))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(questionIndices))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(questionIndices))];
    }
}

#pragma mark - // PRIVATE METHODS //

@end
