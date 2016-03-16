//
//  AMLQuestion.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AMLResponse, AMLChoice, AMLSurvey;

#pragma mark - // PROTOCOLS //

#import "AMLQuestionProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLQuestion : NSManagedObject <AMLQuestion_PRIVATE>

- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(AMLChoice *)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;
- (void)removeChoice:(AMLChoice *)choice;
- (void)addResponse:(AMLResponse *)response;
- (void)deleteResponse:(AMLResponse *)response;

@end

NS_ASSUME_NONNULL_END

#import "AMLQuestion+CoreDataProperties.h"
