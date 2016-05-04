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

#define PQUserAvatarDidChangeNotification @"kNotificationPQUser_AvatarDidChange"
#define PQUserEmailDidChangeNotification @"kNotificationPQUser_EmailDidChange"
#define PQUserUsernameDidChangeNotification @"kNotificationPQUser_UsernameDidChange"

#define PQUserAvatarDidSaveNotification @"kNotificationPQUser_AvatarDidSave"
#define PQUserEmailDidSaveNotification @"kNotificationPQUser_EmailDidSave"
#define PQUserUsernameDidSaveNotification @"kNotificationPQUser_UsernameDidSave"

#define PQUserDidSaveNotification @"kNotificationPQUser_DidSave"
#define PQUserWillBeDeletedNotification @"kNotificationPQUser_WillBeDeleted"

#pragma mark - // PROTOCOL (PQUser) //

@protocol PQUser <NSObject>

- (NSString *)userId;
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

- (void)setUserId:(NSString *)userId;

@end

#pragma mark - // PROTOCOL (PQUser_Init) //

@protocol PQUser_Init <NSObject>

+ (id <PQUser_Editable>)userWithUserId:(NSString *)userId email:(NSString *)email;

@end

#pragma mark - // PROTOCOL (PQUser_Init_PRIVATE) //

@protocol PQUser_Init_PRIVATE <PQUser_Init>

// INITIALIZERS //

+ (id <PQUser_Editable>)userWithUserId:(NSString *)userId;

@end
