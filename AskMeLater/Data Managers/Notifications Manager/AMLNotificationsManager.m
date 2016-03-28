//
//  AMLNotificationsManager.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLNotificationsManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const NotificationPrimaryActionIdentifier = @"primaryAction";
NSString * const NotificationSecondaryActionIdentifier = @"secondaryAction";
NSString * const NotificationActionCategoryDefault = @"default";

@interface AMLNotificationsManager ()

// GENERAL //

+ (instancetype)sharedManager;

// RESPONDERS //

- (void)surveyEnabledDidChange:(NSNotification *)notification;

@end

@implementation AMLNotificationsManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self teardown];
}

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
    
    if (![AMLNotificationsManager sharedManager]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"Could not initialize %@", NSStringFromClass([AMLNotificationsManager class])]];
    }
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidChange:) name:AMLSurveyEnabledDidChangeNotification object:nil];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyEnabledDidChangeNotification object:nil];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    static AMLNotificationsManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[AMLNotificationsManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyEnabledDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLSurvey> survey = (id <AMLSurvey>)notification.object;
    BOOL enabled = ((NSNumber *)notification.userInfo[NOTIFICATION_OBJECT_KEY]).boolValue;
    
    if (!enabled) {
        return;
    }
    
    for (id <AMLQuestion> question in survey.questions) {
        
        id <AMLChoice> primaryChoice = [question.choices objectAtIndex:0];
        UIMutableUserNotificationAction *primaryAction = [[UIMutableUserNotificationAction alloc] init];
        [primaryAction setActivationMode:UIUserNotificationActivationModeBackground];
        [primaryAction setTitle:primaryChoice.text];
        [primaryAction setIdentifier:NotificationPrimaryActionIdentifier];
        [primaryAction setDestructive:NO];
//        [primaryAction setAuthenticationRequired:NO];
//        [primaryAction setBehavior:UIUserNotificationActionBehaviorDefault];
        
        id <AMLChoice> secondaryChoice = [question.choices objectAtIndex:1];
        UIMutableUserNotificationAction *secondaryAction = [[UIMutableUserNotificationAction alloc] init];
        [secondaryAction setActivationMode:UIUserNotificationActivationModeBackground];
        [secondaryAction setTitle:secondaryChoice.text];
        [secondaryAction setIdentifier:NotificationSecondaryActionIdentifier];
        [secondaryAction setDestructive:NO];
//        [secondaryAction setAuthenticationRequired:NO];
//        [secondaryAction setBehavior:UIUserNotificationActionBehaviorDefault];
        
        UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationActionCategoryDefault];
        [actionCategory setActions:@[primaryAction, secondaryAction] forContext:UIUserNotificationActionContextDefault];
        NSSet *categories = [NSSet setWithObject:actionCategory];
        
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        
        
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = survey.name;
        localNotification.alertBody = question.text;
        localNotification.category = ;
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
        localNotification.fireDate = survey.time;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        if (survey.repeat) {
            localNotification.repeatInterval = NSCalendarUnitDay;
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end
