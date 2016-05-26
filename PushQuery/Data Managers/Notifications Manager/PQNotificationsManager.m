//
//  PQNotificationsManager.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQNotificationsManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQQuestionProtocols.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQNotificationsManager ()

// GENERAL //

+ (instancetype)sharedManager;

// OTHER //

+ (UILocalNotification *)getNotificationWithId:(NSString *)uuid;

@end

@implementation PQNotificationsManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - // PUBLIC METHODS //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (![PQNotificationsManager sharedManager]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"Could not initialize %@", NSStringFromClass([PQNotificationsManager class])]];
    }
}

+ (void)scheduleNotificationWithTitle:(NSString *)title body:(NSString *)body badge:(NSNumber *)badge actionString:(NSString *)actionString userInfo:(NSDictionary *)userInfo notificationId:(NSString *)notificationId fireDate:(NSDate *)fireDate interval:(NSCalendarUnit)interval {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = title;
    localNotification.alertBody = body;
    localNotification.alertAction = actionString;
    localNotification.userInfo = userInfo;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if (badge) {
        localNotification.applicationIconBadgeNumber = badge.integerValue;
    }
    localNotification.hasAction = YES;
    localNotification.category = notificationId;
    localNotification.fireDate = fireDate; //[(fireDate ?: [NSDate date]) laterDate:[[NSDate date] dateByAddingTimeInterval:PQNotificationMinimumInterval]];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval = interval;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+ (UIMutableUserNotificationAction *)notificationActionWithTitle:(NSString *)title textInput:(BOOL)textInput destructive:(BOOL)destructive authentication:(BOOL)authentication {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    UIMutableUserNotificationAction *notificationAction = [[UIMutableUserNotificationAction alloc] init];
    [notificationAction setActivationMode:UIUserNotificationActivationModeBackground];
    [notificationAction setTitle:title];
    [notificationAction setIdentifier:title];
    [notificationAction setDestructive:destructive];
    [notificationAction setAuthenticationRequired:authentication];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f) {
        [notificationAction setBehavior:(textInput ? UIUserNotificationActionBehaviorTextInput : UIUserNotificationActionBehaviorDefault)];
    }
    return notificationAction;
}

+ (void)cancelNotificationWithId:(NSString *)notificationId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    UILocalNotification *notification = [PQNotificationsManager getNotificationWithId:notificationId];
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

+ (void)setTitle:(NSString *)title forNotificationWithId:(NSString *)notificationId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    UILocalNotification *notification = [PQNotificationsManager getNotificationWithId:notificationId];
    notification.alertTitle = title;
}

+ (void)setText:(NSString *)text forNotificationWithId:(NSString *)notificationId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    UILocalNotification *notification = [PQNotificationsManager getNotificationWithId:notificationId];
    notification.alertBody = text;
}

+ (void)setActions:(NSArray <UIMutableUserNotificationAction *> *)actions forNotificationWithId:(NSString *)notificationId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:notificationId];
    [actionCategory setActions:actions forContext:UIUserNotificationActionContextDefault];
    
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound); // UIUserNotificationTypeBadge
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithObject:actionCategory]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    static PQNotificationsManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PQNotificationsManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (UILocalNotification *)getNotificationWithId:(NSString *)uuid {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if ([notification.category isEqualToString:uuid]) {
            return notification;
        }
    }
    
    return nil;
}

@end
