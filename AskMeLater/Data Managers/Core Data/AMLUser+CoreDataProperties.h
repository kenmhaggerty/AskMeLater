//
//  AMLUser+CoreDataProperties.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "AMLUser.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *avatarData;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *username;

@end

@interface AMLUser (CoreDataGeneratedAccessors)

- (void)addSurveysObject:(AMLSurvey *)value;
- (void)removeSurveysObject:(AMLSurvey *)value;
- (void)addSurveys:(NSSet <AMLSurvey *> *)values;
- (void)removeSurveys:(NSSet <AMLSurvey *> *)values;

- (void)addResponsesObject:(AMLResponse *)value;
- (void)removeResponsesObject:(AMLResponse *)value;
- (void)addResponses:(NSSet <AMLResponse *> *)values;
- (void)removeResponses:(NSSet <AMLResponse *> *)values;

@end

NS_ASSUME_NONNULL_END
