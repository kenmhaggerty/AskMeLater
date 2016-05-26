//
//  PQNotificationsManager.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const PQNotificationActionString;

@interface PQNotificationsManager : NSObject
+ (void)setup;
+ (void)scheduleNotificationWithTitle:(NSString *)title body:(NSString *)body badge:(NSNumber *)badge actionString:(NSString *)actionString userInfo:(NSDictionary *)userInfo notificationId:(NSString *)notificationId fireDate:(NSDate *)fireDate interval:(NSCalendarUnit)interval;
+ (UIMutableUserNotificationAction *)notificationActionWithTitle:(NSString *)title textInput:(BOOL)textInput destructive:(BOOL)destructive authentication:(BOOL)authentication;
+ (void)cancelNotificationWithId:(NSString *)notificationId;

+ (void)setTitle:(NSString *)title forNotificationWithId:(NSString *)notificationId;
+ (void)setText:(NSString *)text forNotificationWithId:(NSString *)notificationId;
+ (void)setActions:(NSArray <UIMutableUserNotificationAction *> *)actions forNotificationWithId:(NSString *)notificationId;

@end
