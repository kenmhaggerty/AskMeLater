//
//  AMLResponse+CoreDataProperties.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "AMLResponse.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLResponse (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *response;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) AMLUser *user;
@property (nullable, nonatomic, retain) AMLQuestion *question;

@end

NS_ASSUME_NONNULL_END
