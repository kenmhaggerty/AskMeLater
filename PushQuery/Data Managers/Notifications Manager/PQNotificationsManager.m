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

#import "PQSurveyProtocols.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQNotificationActionString = @"respond";
NSTimeInterval const PQNotificationMinimumInterval = 0.5f;

@interface PQNotificationsManager ()

// GENERAL //

+ (instancetype)sharedManager;

// RESPONDERS //

- (void)surveyEnabledDidChange:(NSNotification *)notification;

// OTHER //

- (void)cancelNotificationsForSurvey:(id <PQSurvey>)survey;

@end

@implementation PQNotificationsManager

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
    
    if (![PQNotificationsManager sharedManager]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"Could not initialize %@", NSStringFromClass([PQNotificationsManager class])]];
    }
}

+ (UIMutableUserNotificationAction *)notificationActionWithTitle:(NSString *)title textInput:(BOOL)textInput destructive:(BOOL)destructive authentication:(BOOL)authentication {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    UIMutableUserNotificationAction *notificationAction = [[UIMutableUserNotificationAction alloc] init];
    [notificationAction setActivationMode:UIUserNotificationActivationModeBackground];
    [notificationAction setTitle:title];
    [notificationAction setIdentifier:title];
    [notificationAction setDestructive:destructive];
    [notificationAction setAuthenticationRequired:authentication];
    [notificationAction setBehavior:(textInput ? UIUserNotificationActionBehaviorTextInput : UIUserNotificationActionBehaviorDefault)];
    return notificationAction;
}

+ (void)setNotificationWithTitle:(NSString *)title body:(NSString *)body actions:(NSArray <UIMutableUserNotificationAction *> *)actions actionString:(NSString *)actionString uuid:(NSString *)uuid fireDate:(NSDate *)fireDate repeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:uuid];
    [actionCategory setActions:actions forContext:UIUserNotificationActionContextDefault];
    NSSet *categories = [NSSet setWithObject:actionCategory];
    
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = title;
    localNotification.alertBody = body;
    localNotification.userInfo = @{NOTIFICATION_OBJECT_KEY : uuid};
    localNotification.alertAction = actionString;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    localNotification.hasAction = YES;
    localNotification.category = uuid;
    localNotification.fireDate = [(fireDate ?: [NSDate date]) laterDate:[[NSDate date] dateByAddingTimeInterval:PQNotificationMinimumInterval]];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    if (repeat) {
        localNotification.repeatInterval = NSCalendarUnitDay;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidChange:) name:PQSurveyEnabledDidChangeNotification object:nil];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidChangeNotification object:nil];
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

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyEnabledDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)notification.object;
    BOOL enabled = ((NSNumber *)notification.userInfo[NOTIFICATION_OBJECT_KEY]).boolValue;
    
    if (!enabled) {
        [self cancelNotificationsForSurvey:survey];
        return;
    }
    
    id <PQQuestion_PRIVATE> question = (id <PQQuestion_PRIVATE>)survey.questions.firstObject;
    
    id <PQChoice> primaryChoice = [question.choices objectAtIndex:0];
    UIMutableUserNotificationAction *primaryAction = [PQNotificationsManager notificationActionWithTitle:primaryChoice.text textInput:NO destructive:NO authentication:NO];
    
    id <PQChoice> secondaryChoice = [question.choices objectAtIndex:1];
    UIMutableUserNotificationAction *secondaryAction = [PQNotificationsManager notificationActionWithTitle:secondaryChoice.text textInput:NO destructive:NO authentication:NO];
    
    [PQNotificationsManager setNotificationWithTitle:survey.name body:question.text actions:@[primaryAction, secondaryAction] actionString:PQNotificationActionString uuid:question.uuid fireDate:survey.time repeat:survey.repeat];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)cancelNotificationsForSurvey:(id<PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSMutableArray *questionIds = [NSMutableArray arrayWithCapacity:survey.questions.count];
    for (id <PQQuestion_PRIVATE> question in survey.questions) {
        [questionIds addObject: question.uuid];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    NSArray <UILocalNotification *> *scheduledNotifications = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSString *notificationId;
    for (int i = 0; i < scheduledNotifications.count; i++)
    {
        localNotification = scheduledNotifications[i];
        notificationId = localNotification.userInfo[NOTIFICATION_OBJECT_KEY];
        if ([questionIds containsObject:notificationId]) {
            [application cancelLocalNotification:localNotification];
        }
    }
}

@end
