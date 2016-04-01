//
//  AMLChoiceProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>

#pragma mark - // DEFINITIONS //

#define AMLChoiceTextDidChangeNotification @"kNotificationAMLChoice_TextDidChangeNotification"
#define AMLChoiceTextInputDidChangeNotification @"kNotificationAMLChoice_TextInputDidChangeNotification"

#define AMLChoiceWillBeRemovedNotification @"kNotificationAMLChoice_WillBeRemoved"

#define AMLChoiceWillBeDeletedNotification @"kNotificationAMLChoice_WillBeDeleted"

#pragma mark - // PROTOCOL (AMLChoice) //

@protocol AMLChoice <NSObject>

- (NSString *)text;
- (BOOL)textInput;

@end

#pragma mark - // PROTOCOL (AMLChoice_Editable) //

@protocol AMLChoice_Editable <AMLChoice>

// INITIALIZERS //

//- (id)initWithText:(NSString *)text;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setTextInput:(BOOL)textInput;

@end

#pragma mark - // PROTOCOL (AMLChoice_Init) //

@protocol AMLChoice_Init <NSObject>

+ (id <AMLChoice_Editable>)choiceWithText:(NSString *)text;

@end
