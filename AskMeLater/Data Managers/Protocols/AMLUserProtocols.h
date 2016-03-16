//
//  AMLUserProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <Foundation/Foundation.h>

#pragma mark - // DEFINITIONS //

#pragma mark - // PROTOCOL (AMLUser) //

@protocol AMLUser <NSObject>

- (NSString *)username;

@end

#pragma mark - // PROTOCOL (AMLUser_Editable) //

@protocol AMLUser_Editable <AMLUser>

// INITIALIZERS //

- (id)initWithUsername:(NSString *)username email:(NSString *)email;

// SETTERS //

- (void)setUsername:(NSString *)username;
- (NSString *)email;
- (void)setEmail:(NSString *)email;

@end
