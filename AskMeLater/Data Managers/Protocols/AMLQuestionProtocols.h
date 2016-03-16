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

#pragma mark - // PROTOCOL (AMLQuestion) //

@protocol AMLQuestion <NSObject>

- (NSString *)text;
- (NSArray <id <AMLChoice>> *)choices;
- (BOOL)secure;
- (NSSet <id <AMLResponse>> *)responses;

@end

#pragma mark - // PROTOCOL (AMLQuestion_Editable) //

@protocol AMLQuestion_Editable <AMLQuestion>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text choices:(NSArray <id <AMLChoice>> *)choices;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setChoices:(NSArray <id <AMLChoice>> *)choices;
- (void)replaceChoiceAtIndex:(NSUInteger)index withChoice:(id <AMLChoice>)choice;
- (void)removeChoiceAtIndex:(NSUInteger)index;
- (void)removeChoice:(id <AMLChoice>)choice;
- (void)setSecure:(BOOL)secure;
- (void)deleteResponse:(id <AMLResponse>)response;

@end

#pragma mark - // PROTOCOL (AMLQuestion_PRIVATE) //

@protocol AMLQuestion_PRIVATE <AMLQuestion_Editable>

- (void)addResponse:(id <AMLResponse>)response;

@end

#pragma mark - // PROTOCOL (AMLQuestion_Init) //

@protocol AMLQuestion_Init <NSObject>

+ (id <AMLQuestion_Editable>)questionWithText:(NSString *)text choices:(NSOrderedSet <id <AMLChoice>> *)choices;

@end
