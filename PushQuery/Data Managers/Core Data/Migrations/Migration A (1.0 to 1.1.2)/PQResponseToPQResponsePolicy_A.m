//
//  PQResponseToPQResponsePolicy_A.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResponseToPQResponsePolicy_A.h"
#import "AKDebugger.h"
#import "AKGenerics+CoreData.h"

//#import "PQResponse.h"
#import "PQCoreDataController+PRIVATE.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResponseToPQResponsePolicy_A ()
@end

@implementation PQResponseToPQResponsePolicy_A

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
    
    NSString *responseId = attributeSourceValues[NSStringFromSelector(@selector(responseId))];
    NSManagedObject *destinationInstance = [PQCoreDataController responseWithResponseId:responseId inManagedObjectContext:manager.destinationContext];
    
    NSArray *attributeDestinationKeys = destinationInstance.entity.attributesByName.allKeys;
    for (NSString *key in attributeDestinationKeys) {
        id value = attributeSourceValues[key];
        if (value && ![value isEqual:[NSNull null]]) {
            [destinationInstance setValue:value forKey:key];
        }
    }
    
//    NSMutableDictionary *userLookup = [manager lookupWithKey:NSStringFromClass([PQUser class])];
//    NSString *userId = [sInstance valueForKey:NSStringFromSelector(@selector(userId))];
//    NSManagedObject *user = [userLookup valueForKey:userId];
//    if (!user) {
//        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQUser class]) inManagedObjectContext:manager.destinationContext];
//        user.userId = userId;
//        userLookup[userId] = user;
//    }
//    destinationInstance.user = user;
    
//    NSMutableDictionary *questionLookup = [manager lookupWithKey:NSStringFromClass([PQQuestion class])];
//    NSString *questionId = [sInstance valueForKey:NSStringFromSelector(@selector(questionId))];
//    NSManagedObject *question = [questionLookup valueForKey:questionId];
//    if (!question) {
//        NSString *surveyId = [sInstance valueForKey:NSStringFromSelector(@selector(surveyId))];
//        NSString *authorId = [sInstance valueForKey:NSStringFromSelector(@selector(authorId))];
//        
//        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:manager.destinationContext];
//        question.questionId = userId;
//        question.surveyId = surveyId;
//        question.authorId = authorId;
//        questionLookup[questionId] = question;
//    }
//    destinationInstance.question = question;
    
    NSMutableDictionary *responseLookup = [manager lookupWithKey:NSStringFromClass([PQResponse class])];
    responseLookup[responseId] = destinationInstance;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end
