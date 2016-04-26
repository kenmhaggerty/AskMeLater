//
//  PQResponse+CoreDataProperties.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQResponse.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface PQResponse (CoreDataProperties)

@property (nullable, nonatomic, retain, readonly) NSString *authorId;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *questionId;
@property (nullable, nonatomic, retain) NSString *responseId;
@property (nullable, nonatomic, retain, readonly) NSString *surveyId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain, readonly) PQQuestion *question;
@property (nullable, nonatomic, retain, readonly) PQUser *user;

@end

NS_ASSUME_NONNULL_END
