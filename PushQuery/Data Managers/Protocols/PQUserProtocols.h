//
//  PQUserProtocols.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES //

#pragma mark - // IMPORTS //

#import <UIKit/UIKit.h>

#pragma mark - // DEFINITIONS //

#define PQUserUsernameDidChangeNotification @"kNotificationPQUser_UsernameDidChange"
#define PQUserAvatarDidChangeNotification @"kNotificationPQUser_AvatarDidChange"
#define PQUserEmailDidChangeNotification @"kNotificationPQUser_EmailDidChange"

#define PQUserWillBeDeletedNotification @"kNotificationPQUser_WillBeDeleted"

#pragma mark - // PROTOCOL (PQUser) //

@protocol PQUser <NSObject>

- (NSString *)username;
@optional
- (UIImage *)avatar;

@end

#pragma mark - // PROTOCOL (PQUser_Editable) //

@protocol PQUser_Editable <PQUser>

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

#pragma mark - // PROTOCOL (PQUser_PRIVATE) //

@protocol PQUser_PRIVATE <PQUser_Editable>

// GETTERS //

- (NSString *)userId;

// SETTERS //

- (void)setUserId:(NSString *)userId;

@end

#pragma mark - // PROTOCOL (PQUser_Init) //

@protocol PQUser_Init <NSObject>

// INITIALIZERS //

+ (id <PQUser_Editable>)userWithUserId:(NSString *)userId email:(NSString *)email;

@end
