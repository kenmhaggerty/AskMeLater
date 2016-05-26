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
#define PQQuestionChoicesCountDidChangeNotification @"kNotificationPQQuestion_ChoicesCountDidChange"
#define PQQuestionChoicesWereAddedNotification @"kNotificationPQQuestion_ChoicesWereAdded"
#define PQQuestionChoicesWereReorderedNotification @"kNotificationPQQuestion_ChoicesWereReordered"
#define PQQuestionChoicesWereRemovedNotification @"kNotificationPQQuestion_ChoicesWereRemoved"

#define PQQuestionChoicesDidSaveNotification @"kNotificationPQQuestion_ChoicesDidSave"
#define PQQuestionChoicesOrderDidSaveNotification @"kNotificationPQQuestion_ChoicesOrderDidSave"

#define PQQuestionResponsesDidChangeNotification @"kNotificationPQQuestion_ResponsesDidChange"
#define PQQuestionResponsesCountDidChangeNotification @"kNotificationPQQuestion_ResponsesCountDidChange"
#define PQQuestionResponsesWereAddedNotification @"kNotificationPQQuestion_ResponsesWereAdded"
#define PQQuestionResponsesWereRemovedNotification @"kNotificationPQQuestion_ResponsesWereRemoved"

#define PQQuestionResponsesDidSaveNotification @"kNotificationPQQuestion_ResponsesDidSave"

//#define PQQuestionWillSaveNotification @"kNotificationPQQuestion_WillSave"
#define PQQuestionDidSaveNotification @"kNotificationPQQuestion_DidSave"
#define PQQuestionWillBeRemovedNotification @"kNotificationPQQuestion_WillBeRemoved"
#define PQQuestionWillBeDeletedNotification @"kNotificationPQQuestion_WillBeDeleted"

#pragma mark - // PROTOCOL (PQQuestion) //

@protocol PQQuestion <NSObject>

- (NSDate *)createdAt;
- (NSDate *)editedAt;
- (NSString *)questionId;
- (NSString *)text;
- (BOOL)secure;
- (NSOrderedSet <id <PQChoice>> *)choices;
- (NSSet <id <PQResponse>> *)responses;

@end

#pragma mark - // PROTOCOL (PQQuestion_Editable) //

@protocol PQQuestion_Editable <PQQuestion>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text choices:(NSArray <id <PQChoice>> *)choices;

// UPDATE //

- (void)updateText:(NSString *)text;
- (void)updateSecure:(BOOL)secure;

- (void)addChoice:(id <PQChoice>)choice;
- (void)insertChoice:(id <PQChoice>)choice atIndex:(NSUInteger)index;
- (void)moveChoice:(id <PQChoice>)choice toIndex:(NSUInteger)index;
- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeChoice:(id <PQChoice>)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;

@end

#pragma mark - // PROTOCOL (PQQuestion_PRIVATE) //

@protocol PQQuestion_PRIVATE <PQQuestion_Editable>

// SETTERS //

- (void)setCreatedAt:(NSDate *)createdAt;
- (void)setText:(NSString *)text;
- (void)setSecure:(BOOL)secure;
- (void)setChoices:(NSOrderedSet <id <PQChoice>> *)choices;

- (void)addResponse:(id <PQResponse>)response;
- (void)removeResponse:(id <PQResponse>)response;

@end

#pragma mark - // PROTOCOL (PQQuestion_Init) //

@protocol PQQuestion_Init <NSObject>

+ (id <PQQuestion_Editable>)questionWithText:(NSString *)text choices:(NSOrderedSet <id <PQChoice>> *)choices;

@end

#pragma mark - // PROTOCOL (PQQuestion_Init_PRIVATE) //

@protocol PQQuestion_Init_PRIVATE <PQQuestion_Init>

+ (id <PQQuestion_Editable>)questionWithQuestionId:(NSString *)questionId;

@end
