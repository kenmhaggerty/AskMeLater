//
//  AMLSurvey.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AMLUser, AMLQuestion;

#pragma mark - // PROTOCOLS //

#import "AMLSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Public) //

NS_ASSUME_NONNULL_BEGIN

@interface AMLSurvey : NSManagedObject <AMLSurvey_Editable>

- (void)addQuestion:(AMLQuestion *)question;
- (void)insertQuestion:(AMLQuestion *)question atIndex:(NSUInteger)index;
- (void)moveQuestion:(AMLQuestion *)question toIndex:(NSUInteger)index;
- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeQuestion:(AMLQuestion *)question;
- (void)removeQuestionAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END

#import "AMLSurvey+CoreDataProperties.h"
