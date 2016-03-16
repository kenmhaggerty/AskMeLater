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

#pragma mark - // PROTOCOL (AMLChoice) //

@protocol AMLChoice <NSObject>

- (NSString *)text;
- (BOOL)textInput;

@end

#pragma mark - // PROTOCOL (AMLChoice_Editable) //

@protocol AMLChoice_Editable <AMLChoice>

// INITIALIZERS //

- (id)initWithText:(NSString *)text;

// SETTERS //

- (void)setText:(NSString *)text;
- (void)setTextInput:(BOOL)type;

@end
