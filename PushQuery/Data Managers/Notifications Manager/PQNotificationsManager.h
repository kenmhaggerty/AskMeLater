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
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const PQNotificationActionString;

@interface PQNotificationsManager : NSObject
+ (void)setup;
+ (UIMutableUserNotificationAction *)notificationActionWithTitle:(NSString *)title textInput:(BOOL)textInput destructive:(BOOL)destructive authentication:(BOOL)authentication;
+ (void)setNotificationWithTitle:(NSString *)title body:(NSString *)body actions:(NSArray <UIMutableUserNotificationAction *> *)actions actionString:(NSString *)actionString uuid:(NSString *)uuid fireDate:(NSDate *)fireDate repeat:(BOOL)repeat;
@end
