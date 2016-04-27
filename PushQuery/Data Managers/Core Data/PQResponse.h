//
//  PQResponse.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PQManagedObject.h"

@class PQUser, PQQuestion;

#pragma mark - // PROTOCOLS //

#import "PQResponseProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const PQResponseIdDidChangeNotification;
extern NSString * const PQResponseAuthorIdDidChangeNotification;
extern NSString * const PQResponseSurveyIdDidChangeNotification;
extern NSString * const PQResponseQuestionIdDidChangeNotification;
extern NSString * const PQResponseUserIdDidChangeNotification;

NS_ASSUME_NONNULL_BEGIN

@interface PQResponse : PQManagedObject <PQResponse_Editable>
@end

NS_ASSUME_NONNULL_END

#import "PQResponse+CoreDataProperties.h"
