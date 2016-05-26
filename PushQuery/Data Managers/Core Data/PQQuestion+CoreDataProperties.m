//
//  PQQuestion+CoreDataProperties.m
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

#import "PQQuestion+CoreDataProperties.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation PQQuestion (CoreDataProperties)

#pragma mark - // SETTERS AND GETTERS //

@dynamic questionId;
@dynamic secureValue;
@dynamic text;
@dynamic choiceIndices;
@dynamic choiceObjects;
@dynamic questionIndex;
@dynamic responses;
@dynamic survey;

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)insertObject:(PQChoiceIndex *)value inChoiceIndicesAtIndex:(NSUInteger)idx {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)removeObjectFromChoiceIndicesAtIndex:(NSUInteger)idx {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)insertChoiceIndices:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)removeChoiceIndicesAtIndexes:(NSIndexSet *)indexes {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)replaceObjectInChoiceIndicesAtIndex:(NSUInteger)idx withObject:(PQChoiceIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)replaceChoiceIndicesAtIndexes:(NSIndexSet *)indexes withChoiceIndices:(NSArray *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)addChoiceIndicesObject:(PQChoiceIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
}

- (void)removeChoiceIndicesObject:(PQChoiceIndex *)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    }
}

- (void)addChoiceIndices:(NSOrderedSet *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    }
}

- (void)removeChoiceIndices:(NSOrderedSet *)values {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(choiceIndices))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(choiceIndices))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(choiceIndices))];
    }
}

#pragma mark - // PRIVATE METHODS //

@end
