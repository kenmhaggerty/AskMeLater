//
//  PQUser+CoreDataProperties.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQUser.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *avatarData;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *username;

@end

@interface PQUser (CoreDataGeneratedAccessors)

- (void)addSurveysObject:(PQSurvey *)value;
- (void)removeSurveysObject:(PQSurvey *)value;
- (void)addSurveys:(NSSet <PQSurvey *> *)values;
- (void)removeSurveys:(NSSet <PQSurvey *> *)values;

- (void)addResponsesObject:(PQResponse *)value;
- (void)removeResponsesObject:(PQResponse *)value;
- (void)addResponses:(NSSet <PQResponse *> *)values;
- (void)removeResponses:(NSSet <PQResponse *> *)values;

@end

NS_ASSUME_NONNULL_END
