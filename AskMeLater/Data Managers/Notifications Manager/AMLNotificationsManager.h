//
//  AMLNotificationsManager.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const NotificationPrimaryActionIdentifier;
extern NSString * const NotificationSecondaryActionIdentifier;
extern NSString * const NotificationActionCategoryDefault;

@interface AMLNotificationsManager : NSObject
+ (void)setup;
@end
