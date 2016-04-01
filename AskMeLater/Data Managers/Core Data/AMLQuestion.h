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
#import "NSObject+Basics.h"

@class AMLResponse, AMLChoice, AMLSurvey;

#pragma mark - // PROTOCOLS //

#import "AMLQuestionProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLQuestion : NSManagedObject <AMLQuestion_PRIVATE>

- (BOOL)secure;
- (void)setSecure:(BOOL)secure;

- (void)addChoice:(AMLChoice *)choice;
- (void)insertChoice:(AMLChoice *)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(AMLChoice *)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(AMLChoice *)choice;
- (void)removeChoice:(AMLChoice *)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;

- (void)addResponse:(AMLResponse *)response;
- (void)removeResponse:(AMLResponse *)response;

@end

NS_ASSUME_NONNULL_END

#import "AMLQuestion+CoreDataProperties.h"
