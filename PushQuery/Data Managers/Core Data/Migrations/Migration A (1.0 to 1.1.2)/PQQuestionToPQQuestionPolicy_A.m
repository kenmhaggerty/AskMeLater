//
//  PQQuestionToPQQuestionPolicy_A.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQQuestionToPQQuestionPolicy_A.h"
#import "AKDebugger.h"
#import "AKGenerics+CoreData.h"

//#import "PQQuestion.h"
#import "PQCoreDataController+PRIVATE.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQQuestionToPQQuestionPolicy_A ()
@end

@implementation PQQuestionToPQQuestionPolicy_A

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
    
    NSString *questionId = attributeSourceValues[NSStringFromSelector(@selector(questionId))];
    NSManagedObject *destinationInstance = [PQCoreDataController questionWithQuestionId:questionId inManagedObjectContext:manager.destinationContext];
    
//    NSManagedObject *questionIndex = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestionIndex class]) inManagedObjectContext:manager.destinationContext];
//    destinationInstance.questionIndex = questionIndex;
    
    NSArray *attributeDestinationKeys = destinationInstance.entity.attributesByName.allKeys;
    for (NSString *key in attributeDestinationKeys) {
        if ([key isEqualToString:NSStringFromSelector(@selector(editedAt))]) {
            NSDate *createdAt = attributeSourceValues[NSStringFromSelector(@selector(createdAt))];
            [destinationInstance setValue:createdAt forKey:key];
        }
        else if ([key isEqualToString:NSStringFromSelector(@selector(updatedAt))]) {
            NSDate *updatedAt = [NSDate date];
            [destinationInstance setValue:updatedAt forKey:key];
        }
        else {
            id value = attributeSourceValues[key];
            if (value && ![value isEqual:[NSNull null]]) {
                [destinationInstance setValue:value forKey:key];
            }
        }
    }
    
//    NSMutableDictionary *surveyLookup = [manager lookupWithKey:NSStringFromClass([PQSurvey class])];
//    NSString *surveyId = [sInstance valueForKey:NSStringFromSelector(@selector(surveyId))];
//    NSManagedObject *survey = [surveyLookup valueForKey:surveyId];
//    if (!survey) {
//        NSString *authorId = [sInstance valueForKey:NSStringFromSelector(@selector(authorId))];
//        
//        survey = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQSurvey class]) inManagedObjectContext:manager.destinationContext];
//        survey.surveyId = surveyId;
//        survey.authorId = authorId;
//        surveyLookup[surveyId] = survey;
//    }
//    destinationInstance.survey = survey;
    
    NSMutableDictionary *questionLookup = [manager lookupWithKey:NSStringFromClass([PQQuestion class])];
    questionLookup[questionId] = destinationInstance;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end
