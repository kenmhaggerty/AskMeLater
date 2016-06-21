//
//  PQSyncEngine+Notifications.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/2/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQNotificationsSyncEngine.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import <objc/runtime.h>

#import "PQSurveyProtocols.h"
#import "PQChoiceProtocols.h"

#import "AKNotificationsManager.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQNotificationActionString = @"respond";
NSTimeInterval const PQNotificationMinimumInterval = 0.5f;

@interface PQNotificationsSyncEngine ()
@property (nonatomic, strong) NSMutableDictionary *observedSurveys;
@property (nonatomic, strong) NSMutableDictionary *observedQuestions;
@property (nonatomic, strong) NSMutableDictionary *observedChoices;

// GENERAL //

+ (instancetype)sharedEngine;

// OBSERVERS //

- (void)addObserversToSurvey:(id <PQSurvey>)survey;
- (void)removeObserversFromSurvey:(id <PQSurvey>)survey;

- (void)addObserversToQuestion:(id <PQQuestion>)question;
- (void)removeObserversFromQuestion:(id <PQQuestion>)question;

- (void)addObserversToChoice:(id <PQChoice>)choice;
- (void)removeObserversFromChoice:(id <PQChoice>)choice;

// RESPONDERS //

- (void)surveyEnabledDidChange:(NSNotification *)notification;
- (void)surveyNameDidChange:(NSNotification *)notification;
- (void)surveyQuestionsDidChange:(NSNotification *)notification;

- (void)questionTextDidChange:(NSNotification *)notification;
- (void)questionChoicesDidChange:(NSNotification *)notification;
- (void)questionWillBeRemoved:(NSNotification *)notification;

- (void)choiceDidChange:(NSNotification *)notification;

// OTHER //

+ (void)scheduleNotificationForQuestion:(id <PQQuestion>)question withTitle:(NSString *)title time:(NSDate *)time surveyId:(NSString *)surveyId repeat:(BOOL)repeat;
+ (void)setNotificationActionsForQuestion:(id <PQQuestion>)question forSurveyWithId:(NSString *)surveyId;
+ (void)cancelNotificationForSurvey:(id <PQSurvey>)survey;

+ (NSSet *)surveyIdsForQuestion:(id <PQQuestion>)question;

+ (void)addChoice:(id <PQChoice>)choice toQuestion:(id <PQQuestion>)question;
+ (void)removeChoice:(id <PQChoice>)choice fromQuestion:(id <PQQuestion>)question;
+ (id <PQQuestion>)questionForChoice:(id <PQChoice>)choice;

+ (void)scheduleNextQuestionForQuestion:(id <PQQuestion>)question;

@end

@implementation PQNotificationsSyncEngine

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

#pragma mark - // PUBLIC METHODS (Setup) //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [AKNotificationsManager setup];
    
    if (![PQNotificationsSyncEngine sharedEngine]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not instantiate %@", NSStringFromSelector(@selector(sharedEngine))]];
        return;
    }
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)didRespondToQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    for (id <PQChoice> choice in question.choices) {
        [PQNotificationsSyncEngine removeChoice:choice fromQuestion:question];
        [sharedEngine removeObserversFromChoice:choice];
    }
    [sharedEngine removeObserversFromQuestion:question];
    
    NSSet *surveyIds = [self surveyIdsForQuestion:question];
    id <PQSurvey_Editable> survey;
    for (NSString *surveyId in surveyIds) {
        survey = sharedEngine.observedSurveys[surveyId];
        if ([question isEqual:survey.questions.lastObject]) {
            [survey updateEnabled:survey.repeat];
            return;
        }
        
        [self scheduleNextQuestionForQuestion:question];
    }
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super setup];
    
    self.observedSurveys = [NSMutableDictionary dictionary];
    self.observedQuestions = [NSMutableDictionary dictionary];
    self.observedChoices = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidChange:) name:PQSurveyEnabledDidChangeNotification object:nil];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidChangeNotification object:nil];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedEngine {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static PQNotificationsSyncEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[PQNotificationsSyncEngine alloc] init];
    });
    return _sharedEngine;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidChange:) name:PQSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:PQSurveyQuestionsWereAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:PQSurveyQuestionsWereReorderedNotification object:survey];
}

- (void)removeObserversFromSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsWereAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsWereReorderedNotification object:survey];
}

- (void)addObserversToQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidChange:) name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidChange:) name:PQQuestionChoicesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidChange:) name:PQQuestionChoicesWereAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidChange:) name:PQQuestionChoicesWereReorderedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidChange:) name:PQQuestionChoicesWereRemovedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWillBeRemoved:) name:PQQuestionWillBeRemovedNotification object:question];
}

- (void)removeObserversFromQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesWereAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesWereReorderedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesWereRemovedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionWillBeRemovedNotification object:question];
}

- (void)addObserversToChoice:(id <PQChoice>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceDidChange:) name:PQChoiceTextDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceDidChange:) name:PQChoiceTextInputDidChangeNotification object:choice];
}

- (void)removeObserversFromChoice:(id <PQChoice>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextInputDidChangeNotification object:choice];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyEnabledDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey> survey = (id <PQSurvey_Editable>)notification.object;
    NSNumber *enabledValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    id <PQQuestion> question = survey.questions.firstObject;
    
    if (enabledValue.boolValue) {
        [PQNotificationsSyncEngine scheduleNotificationForQuestion:question withTitle:survey.name time:survey.time surveyId:survey.surveyId repeat:survey.repeat];
        [self addObserversToSurvey:survey];
        [self.observedSurveys setObject:survey forKey:survey.surveyId];
    }
    else {
        [self removeObserversFromSurvey:survey];
        [self.observedSurveys removeObjectForKey:survey.surveyId];
        [PQNotificationsSyncEngine cancelNotificationForSurvey:survey];
    }
}

- (void)surveyNameDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey> survey = notification.object;
    
    [AKNotificationsManager setTitle:survey.name forNotificationsWithId:survey.surveyId];
}

- (void)surveyQuestionsDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey> survey = notification.object;
    NSString *surveyId = survey.surveyId;
    
    id <PQQuestion> question = survey.questions[0];
    id <PQQuestion> observedQuestion = self.observedQuestions[surveyId];
    if ([question isEqual:observedQuestion]) {
        return;
    }
    
    for (id <PQChoice> choice in observedQuestion.choices) {
        [PQNotificationsSyncEngine removeChoice:choice fromQuestion:observedQuestion];
        [self removeObserversFromChoice:choice];
    }
    [self removeObserversFromQuestion:observedQuestion];
    
    if (!question) {
        [self removeObserversFromSurvey:survey];
        [self.observedSurveys removeObjectForKey:survey.surveyId];
        [PQNotificationsSyncEngine cancelNotificationForSurvey:survey];
        return;
    }
    
    [PQNotificationsSyncEngine scheduleNotificationForQuestion:question withTitle:survey.name time:survey.time surveyId:surveyId repeat:survey.repeat];
}

- (void)questionTextDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion> question = notification.object;
    
    NSSet *surveyIds = [PQNotificationsSyncEngine surveyIdsForQuestion:question];
    
    for (NSString *surveyId in surveyIds) {
        [AKNotificationsManager setText:question.text forNotificationsWithId:surveyId];
    }
}

- (void)questionChoicesDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion> question = notification.object;
    
    NSSet *surveyIds = [PQNotificationsSyncEngine surveyIdsForQuestion:question];
    
    for (NSString *surveyId in surveyIds) {
        [PQNotificationsSyncEngine setNotificationActionsForQuestion:question forSurveyWithId:surveyId];
    }
}

- (void)questionWillBeRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion> question = notification.object;
    
    for (id <PQChoice> choice in question.choices) {
        [PQNotificationsSyncEngine removeChoice:choice fromQuestion:question];
        [self removeObserversFromChoice:choice];
    }
    [self removeObserversFromQuestion:question];
    
#warning TO DO – Fix so notification is sent by PQSurvey, not PQQuestion!
    [PQNotificationsSyncEngine scheduleNextQuestionForQuestion:question];
}

- (void)choiceDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice> choice = notification.object;
    
    id <PQQuestion> question = [PQNotificationsSyncEngine questionForChoice:choice];
    
    NSSet *surveyIds = [PQNotificationsSyncEngine surveyIdsForQuestion:question];
    
    for (NSString *surveyId in surveyIds) {
        [PQNotificationsSyncEngine setNotificationActionsForQuestion:question forSurveyWithId:surveyId];
    }
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (void)scheduleNotificationForQuestion:(id <PQQuestion>)question withTitle:(NSString *)title time:(NSDate *)time surveyId:(NSString *)surveyId repeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [AKNotificationsManager cancelNotificationsWithId:surveyId];
    
    [PQNotificationsSyncEngine setNotificationActionsForQuestion:question forSurveyWithId:surveyId];
    [AKNotificationsManager scheduleNotificationWithTitle:title body:question.text badge:nil actionString:PQNotificationActionString userInfo:@{NOTIFICATION_OBJECT_KEY : question.questionId} notificationId:surveyId fireDate:time interval:(repeat ? NSCalendarUnitDay : 0)];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    if (![sharedEngine.observedQuestions.allValues containsObject:question]) {
        [sharedEngine addObserversToQuestion:question];
        for (id <PQChoice> choice in question.choices) {
            [sharedEngine addObserversToChoice:choice];
            [PQNotificationsSyncEngine addChoice:choice toQuestion:question];
        }
    }
    [sharedEngine.observedQuestions setObject:question forKey:surveyId];
}

+ (void)setNotificationActionsForQuestion:(id <PQQuestion>)question forSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    id <PQChoice> primaryChoice = [question.choices objectAtIndex:0];
    UIMutableUserNotificationAction *primaryAction = [AKNotificationsManager notificationActionWithTitle:primaryChoice.text textInput:primaryChoice.textInput destructive:NO authentication:question.secure];
    
    id <PQChoice> secondaryChoice = [question.choices objectAtIndex:1];
    UIMutableUserNotificationAction *secondaryAction = [AKNotificationsManager notificationActionWithTitle:secondaryChoice.text textInput:secondaryChoice.textInput destructive:NO authentication:question.secure];
    
    [AKNotificationsManager setActions:@[primaryAction, secondaryAction] forNotificationsWithId:surveyId];
}

+ (void)cancelNotificationForSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    id <PQQuestion> question = sharedEngine.observedQuestions[survey.surveyId];
    
    [sharedEngine.observedQuestions removeObjectForKey:survey.surveyId];
    
    if (![sharedEngine.observedQuestions.allValues containsObject:question]) {
        for (id <PQChoice> choice in question.choices) {
            [PQNotificationsSyncEngine removeChoice:choice fromQuestion:question];
            [sharedEngine removeObserversFromChoice:choice];
        }
        [sharedEngine removeObserversFromQuestion:question];
    }
    
    [AKNotificationsManager cancelNotificationsWithId:survey.surveyId];
}

+ (NSSet *)surveyIdsForQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    return [sharedEngine.observedQuestions keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL * stop) {
        return [obj isEqual:question];
    }];
}

+ (void)addChoice:(id <PQChoice>)choice toQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSString *questionId = question.questionId;
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    NSMutableSet *choices = sharedEngine.observedChoices[questionId];
    if (!choices) {
        choices = [NSMutableSet set];
    }
    [choices addObject:choice];
    sharedEngine.observedChoices[questionId] = choices;
}

+ (void)removeChoice:(id <PQChoice>)choice fromQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSString *questionId = question.questionId;
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    NSMutableSet *choices = sharedEngine.observedChoices[questionId];
    if (!choices || ![choices containsObject:choice]) {
        return;
    }
    [choices removeObject:choice];
    sharedEngine.observedChoices[questionId] = choices;
}

+ (id <PQQuestion>)questionForChoice:(id <PQChoice>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    NSSet *choices;
    for (NSString *questionId in sharedEngine.observedChoices.allKeys) {
        choices = sharedEngine.observedChoices[questionId];
        if ([choices containsObject:choice]) {
            id <PQQuestion> question;
            for (NSString *surveyId in sharedEngine.observedQuestions.allKeys) {
                question = sharedEngine.observedQuestions[surveyId];
                if ([question.questionId isEqualToString:questionId]) {
                    return question;
                }
            }
        }
    }
    
    return nil;
}

+ (void)scheduleNextQuestionForQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    PQNotificationsSyncEngine *sharedEngine = [PQNotificationsSyncEngine sharedEngine];
    
    NSSet *surveyIds = [self surveyIdsForQuestion:question];
    id <PQSurvey> survey;
    NSUInteger index;
    id <PQQuestion> nextQuestion;
    for (NSString *surveyId in surveyIds) {
        survey = sharedEngine.observedSurveys[surveyId];
        index = [survey.questions indexOfObject:question];
        if (index+1 >= survey.questions.count) {
            return;
        }
        
        nextQuestion = survey.questions[index+1];
        [PQNotificationsSyncEngine scheduleNotificationForQuestion:nextQuestion withTitle:survey.name time:survey.time surveyId:surveyId repeat:survey.repeat];
    }
}

@end
