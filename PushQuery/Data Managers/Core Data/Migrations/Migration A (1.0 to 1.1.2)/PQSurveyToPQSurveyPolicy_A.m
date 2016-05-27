//
//  PQSurveyToPQSurveyPolicy_A.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurveyToPQSurveyPolicy_A.h"
#import "AKDebugger.h"
#import "AKGenerics+CoreData.h"

//#import "PQSurvey.h"
#import "PQCoreDataController+PRIVATE.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSurveyToPQSurveyPolicy_A ()
@end

@implementation PQSurveyToPQSurveyPolicy_A

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
    
    NSString *surveyId = attributeSourceValues[NSStringFromSelector(@selector(surveyId))];
    NSString *authorId = attributeSourceValues[NSStringFromSelector(@selector(authorId))];
    NSDate *createdAt = attributeSourceValues[NSStringFromSelector(@selector(createdAt))];
    NSManagedObject *destinationInstance = [PQCoreDataController surveyWithSurveyId:surveyId authorId:authorId createdAt:createdAt inManagedObjectContext:manager.destinationContext];
    
    NSArray *attributeDestinationKeys = destinationInstance.entity.attributesByName.allKeys;
    for (NSString *key in attributeDestinationKeys) {
        if ([key isEqualToString:NSStringFromSelector(@selector(updatedAt))]) {
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
    
//    NSMutableDictionary *userLookup = [manager lookupWithKey:NSStringFromClass([PQUser class])];
//    NSString *userId = [sInstance valueForKey:NSStringFromSelector(@selector(authorId))];
//    NSManagedObject *user = [userLookup  valueForKey:userId];
//    if (!user) {
//        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQUser class]) inManagedObjectContext:manager.destinationContext];
//        user.userId = userId;
//        userLookup[userId] = user;
//    }
//    destinationInstance.author = user;
    
    NSMutableDictionary *surveyLookup = [manager lookupWithKey:NSStringFromClass([PQSurvey class])];
    surveyLookup[surveyId] = destinationInstance;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end
