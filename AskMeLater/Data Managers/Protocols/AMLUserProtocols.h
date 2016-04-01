//
//  AMLUserProtocols.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <UIKit/UIKit.h>

#pragma mark - // DEFINITIONS //

#define AMLUserUsernameDidChangeNotification @"kNotificationAMLUser_UsernameDidChange"
#define AMLUserAvatarDidChangeNotification @"kNotificationAMLUser_AvatarDidChange"
#define AMLUserEmailDidChangeNotification @"kNotificationAMLUser_EmailDidChange"

#define AMLUserWillBeDeletedNotification @"kNotificationAMLUser_WillBeDeleted"

#pragma mark - // PROTOCOL (AMLUser) //

@protocol AMLUser <NSObject>

- (NSString *)username;
@optional
- (UIImage *)avatar;

@end

#pragma mark - // PROTOCOL (AMLUser_Editable) //

@protocol AMLUser_Editable <AMLUser>

// INITIALIZERS //

//- (id)initWithUserId:(NSString *)userId email:(NSString *)email;

// GETTERS //

- (NSString *)email;

// SETTERS //

- (void)setUsername:(NSString *)username;
- (void)setEmail:(NSString *)email;
@optional
- (void)setAvatar:(UIImage *)avatar;

@end

#pragma mark - // PROTOCOL (AMLUser_PRIVATE) //

@protocol AMLUser_PRIVATE <AMLUser_Editable>

// GETTERS //

- (NSString *)userId;

// SETTERS //

- (void)setUserId:(NSString *)userId;

@end

#pragma mark - // PROTOCOL (AMLUser_Init) //

@protocol AMLUser_Init <NSObject>

// INITIALIZERS //

+ (id <AMLUser_Editable>)userWithUserId:(NSString *)userId email:(NSString *)email;

@end
