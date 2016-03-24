//
//  AMLUser.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AMLSurvey, AMLResponse;

#pragma mark - // PROTOCOLS //

#import "AMLUserProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLUser : NSManagedObject <AMLUser_PRIVATE>

- (void)setAvatar:(UIImage *)avatar;
- (UIImage *)avatar;

@end

NS_ASSUME_NONNULL_END

#import "AMLUser+CoreDataProperties.h"
