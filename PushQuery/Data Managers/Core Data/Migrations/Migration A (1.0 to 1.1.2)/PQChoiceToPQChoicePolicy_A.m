//
//  PQChoiceToPQChoicePolicy_A.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQChoiceToPQChoicePolicy_A.h"
#import "AKDebugger.h"
#import "AKGenerics+CoreData.h"

//#import "PQChoice.h"
#import "PQCoreDataController+PRIVATE.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQChoiceToPQChoicePolicy_A ()
@end

@implementation PQChoiceToPQChoicePolicy_A

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError * _Nullable *)error {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
//    NSManagedObject *destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:mapping.destinationEntityName inManagedObjectContext:manager.destinationContext];
    
    NSMutableArray *attributeSourceKeys = [NSMutableArray arrayWithArray:sInstance.entity.attributesByName.allKeys];
    NSDictionary *attributeSourceValues = [sInstance dictionaryWithValuesForKeys:attributeSourceKeys];
    
    NSManagedObject *destinationInstance = [PQCoreDataController choiceIndexInManagedObjectContext:manager.destinationContext];
    
//    NSManagedObject *choiceIndex = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQChoiceIndex class]) inManagedObjectContext:manager.destinationContext];
//    destinationInstance.choiceIndex = choiceIndex;
    
    NSArray *attributeDestinationKeys = destinationInstance.entity.attributesByName.allKeys;
    for (NSString *key in attributeDestinationKeys) {
        id value = attributeSourceValues[key];
        if (value && ![value isEqual:[NSNull null]]) {
            [destinationInstance setValue:value forKey:key];
        }
    }
    
//    NSMutableDictionary *questionLookup = [manager lookupWithKey:NSStringFromClass([PQQuestion class])];
//    NSString *questionId = [sInstance valueForKey:NSStringFromSelector(@selector(questionId))];
//    NSManagedObject *question = [questionLookup valueForKey:questionId];
//    if (!question) {
//        NSString *surveyId = [sInstance valueForKey:NSStringFromSelector(@selector(surveyId))];
//        NSString *authorId = [sInstance valueForKey:NSStringFromSelector(@selector(authorId))];
//        
//        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:manager.destinationContext];
//        question.questionId = questionId;
//        question.surveyId = surveyId;
//        question.authorId = authorId;
//        questionLookup[questionId] = question;
//    }
//    destinationInstance.question = question;
    
    NSMutableDictionary *choiceLookup = [manager lookupWithKey:NSStringFromClass([PQChoice class])];
    NSNumber *indexValue = [sInstance valueForKey:NSStringFromSelector(@selector(indexValue))];
    NSString *questionId = [sInstance valueForKey:NSStringFromSelector(@selector(surveyId))];
    choiceLookup[questionId][indexValue] = destinationInstance;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end
