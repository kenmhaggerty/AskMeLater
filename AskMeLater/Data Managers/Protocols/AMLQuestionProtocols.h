//
//  AMLQuestionProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "AMLChoiceProtocols.h"
#import "AMLResponseProtocols.h"

#pragma mark - // DEFINITIONS //

#define AMLQuestionTextDidChangeNotification @"kNotificationAMLQuestion_TextDidChange"
#define AMLQuestionSecureDidChangeNotification @"kNotificationAMLQuestion_SecureDidChange"

#define AMLQuestionChoicesDidChangeNotification @"kNotificationAMLQuestion_ChoicesDidChange"
#define AMLQuestionChoiceWasAddedNotification @"kNotificationAMLQuestion_ChoiceWasAdded"
#define AMLQuestionChoiceWasReorderedNotification @"kNotificationAMLQuestion_ChoiceWasReordered"
#define AMLQuestionChoiceAtIndexWasReplaced @"kNotificationAMLQuestion_ChoiceAtIndexWasReplaced"
//#define AMLQuestionChoiceWillBeRemovedNotification @"kNotificationAMLQuestion_ChoiceWillBeRemoved"
#define AMLQuestionChoiceAtIndexWasRemovedNotification @"kNotificationAMLQuestion_ChoiceAtIndexWasRemoved"

#define AMLQuestionResponsesDidChangeNotification @"kNotificationAMLQuestion_ResponsesDidChange"
#define AMLQuestionResponseWasAddedNotification @"kNotificationAMLQuestion_ResponseWasAdded"
//#define AMLQuestionResponseWillBeRemovedNotification @"kNotificationAMLQuestion_ResponseWillBeRemoved"
#define AMLQuestionResponseWasRemovedNotification @"kNotificationAMLQuestion_ResponseWasRemoved"
#define AMLQuestionResponsesCountDidChangeNotification @"kNotificationAMLQuestion_ResponsesCountDidChange"

#define AMLQuestionWillBeRemovedNotification @"kNotificationAMLQuestion_WillBeRemoved"

#define AMLQuestionWillBeDeletedNotification @"kNotificationAMLQuestion_WillBeDeleted"

#pragma mark - // PROTOCOL (AMLQuestion) //

@protocol AMLQuestion <NSObject>

- (NSString *)text;
- (BOOL)secure;
- (NSOrderedSet <id <AMLChoice>> *)choices;
- (NSSet <id <AMLResponse>> *)responses;

@end

#pragma mark - // PROTOCOL (AMLQuestion_Editable) //

@protocol AMLQuestion_Editable <AMLQuestion>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text choices:(NSArray <id <AMLChoice>> *)choices;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setSecure:(BOOL)secure;
- (void)setChoices:(NSOrderedSet <id <AMLChoice>> *)choices;

- (void)addChoice:(id <AMLChoice>)choice;
- (void)insertChoice:(id <AMLChoice>)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(id <AMLChoice>)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(id <AMLChoice>)choice;
- (void)removeChoice:(id <AMLChoice>)choice;
- (void)deleteResponse:(id <AMLResponse>)response;
- (void)removeChoiceAtIndex:(NSUInteger)index;

@end

#pragma mark - // PROTOCOL (AMLQuestion_PRIVATE) //

@protocol AMLQuestion_PRIVATE <AMLQuestion_Editable>

- (NSString *)uuid;
- (void)addResponse:(id <AMLResponse>)response;

@end

#pragma mark - // PROTOCOL (AMLQuestion_Init) //

@protocol AMLQuestion_Init <NSObject>

+ (id <AMLQuestion_Editable>)questionWithText:(NSString *)text choices:(NSOrderedSet <id <AMLChoice>> *)choices;

@end
