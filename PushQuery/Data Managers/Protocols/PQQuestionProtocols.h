//
//  PQQuestionProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>
#import "PQChoiceProtocols.h"
#import "PQResponseProtocols.h"

#pragma mark - // DEFINITIONS //

#define PQQuestionTextDidChangeNotification @"kNotificationPQQuestion_TextDidChange"
#define PQQuestionSecureDidChangeNotification @"kNotificationPQQuestion_SecureDidChange"

#define PQQuestionTextDidSaveNotification @"kNotificationPQQuestion_TextDidSave"
#define PQQuestionSecureDidSaveNotification @"kNotificationPQQuestion_SecureDidSave"

#define PQQuestionChoicesDidChangeNotification @"kNotificationPQQuestion_ChoicesDidChange"
#define PQQuestionChoiceWasAddedNotification @"kNotificationPQQuestion_ChoiceWasAdded"
#define PQQuestionChoiceWasReorderedNotification @"kNotificationPQQuestion_ChoiceWasReordered"
#define PQQuestionChoiceAtIndexWasReplaced @"kNotificationPQQuestion_ChoiceAtIndexWasReplaced"
#define PQQuestionChoiceAtIndexWasRemovedNotification @"kNotificationPQQuestion_ChoiceAtIndexWasRemoved"

#define PQQuestionChoicesDidSaveNotification @"kNotificationPQQuestion_ChoicesDidSave"

#define PQQuestionResponsesDidChangeNotification @"kNotificationPQQuestion_ResponsesDidChange"
#define PQQuestionResponseWasAddedNotification @"kNotificationPQQuestion_ResponseWasAdded"
#define PQQuestionResponseWasRemovedNotification @"kNotificationPQQuestion_ResponseWasRemoved"
#define PQQuestionResponsesCountDidChangeNotification @"kNotificationPQQuestion_ResponsesCountDidChange"

#define PQQuestionResponsesDidSaveNotification @"kNotificationPQQuestion_ResponsesDidSave"

#define PQQuestionWillBeSavedNotification @"kNotificationPQQuestion_WillBeSaved"
#define PQQuestionWasSavedNotification @"kNotificationPQQuestion_WasSaved"
#define PQQuestionWillBeRemovedNotification @"kNotificationPQQuestion_WillBeRemoved"
#define PQQuestionWillBeDeletedNotification @"kNotificationPQQuestion_WillBeDeleted"

#pragma mark - // PROTOCOL (PQQuestion) //

@protocol PQQuestion <NSObject>

- (NSString *)text;
- (BOOL)secure;
- (NSOrderedSet <id <PQChoice>> *)choices;
- (NSSet <id <PQResponse>> *)responses;

@end

#pragma mark - // PROTOCOL (PQQuestion_Editable) //

@protocol PQQuestion_Editable <PQQuestion>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text choices:(NSArray <id <PQChoice>> *)choices;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setSecure:(BOOL)secure;
- (void)setChoices:(NSOrderedSet <id <PQChoice>> *)choices;

- (void)addChoice:(id <PQChoice>)choice;
- (void)insertChoice:(id <PQChoice>)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(id <PQChoice>)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(id <PQChoice>)choice;
- (void)removeChoice:(id <PQChoice>)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;

@end

#pragma mark - // PROTOCOL (PQQuestion_PRIVATE) //

@protocol PQQuestion_PRIVATE <PQQuestion_Editable>

- (NSString *)questionId;

- (void)addResponse:(id <PQResponse>)response;
- (void)removeResponse:(id <PQResponse>)response;

@end

#pragma mark - // PROTOCOL (PQQuestion_Init) //

@protocol PQQuestion_Init <NSObject>

+ (id <PQQuestion_Editable>)questionWithText:(NSString *)text choices:(NSOrderedSet <id <PQChoice>> *)choices;

@end
