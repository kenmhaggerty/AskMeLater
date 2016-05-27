//
//  PQUserToPQUserPolicy.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQUserToPQUserPolicy_A.h"
#import "AKDebugger.h"
#import "AKGenerics+CoreData.h"

//#import "PQUser.h"
#import "PQCoreDataController+PRIVATE.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQUserToPQUserPolicy_A ()
@end

@implementation PQUserToPQUserPolicy_A

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
    
    NSString *userId = attributeSourceValues[NSStringFromSelector(@selector(userId))];
    NSManagedObject *destinationInstance = [PQCoreDataController userWithUserId:userId inManagedObjectContext:manager.destinationContext];
    
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
    
//    NSMutableDictionary *<#class#>Lookup = [manager lookupWithKey:NSStringFromClass([<#Class#> class])];
//    NSString *<#uuid#> = [sInstance valueForKey:NSStringFromSelector(@selector(<#relationship#>))];
//    NSManagedObject *<#managedObject#> = [<#class#>Lookup  valueForKey:<#uuid#>];
//    if (!<#managedObject#>) {
//        // Create the author
//        <#class#>Lookup[<#uuid#>] = <#managedObject#>;
//    }
//    [destinationInstance performSelector:@selector(add<#Relationship#>Object:) withObject:<#managedObject#>];
    
    NSMutableDictionary *userLookup = [manager lookupWithKey:NSStringFromClass([PQUser class])];
    userLookup[userId] = destinationInstance;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end
