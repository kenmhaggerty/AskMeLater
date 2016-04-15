//
//  PQSyncEngine.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSyncEngine.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQLoginManager.h"
#import "PQCoreDataController.h"
#import "PQFirebaseController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQFirebasePathSurveys = @"surveys";
NSString * const PQFirebasePathQuestions = @"questions";
NSString * const PQFirebasePathChoices = @"choices";
NSString * const PQFirebasePathResponses = @"responses";

NSString * const PQFirebasePathSurveyCreatedAt = @"createdAt";
NSString * const PQFirebasePathSurveyEditedAt = @"editedAt";
NSString * const PQFirebasePathSurveyEnabled = @"enabled";
NSString * const PQFirebasePathSurveyName = @"name";
NSString * const PQFirebasePathSurveyRepeat = @"repeat";
NSString * const PQFirebasePathSurveyTime = @"time";

NSString * const PQFirebasePathQuestionCreatedAt = @"createdAt";
NSString * const PQFirebasePathQuestionIndex = @"index";
NSString * const PQFirebasePathQuestionSecure = @"secure";
NSString * const PQFirebasePathQuestionText = @"text";

NSString * const PQFirebasePathChoiceText = @"text";
NSString * const PQFirebasePathChoiceTextInput = @"textInput";

NSString * const PQFirebasePathResponseDate = @"date";
NSString * const PQFirebasePathResponseText = @"text";
NSString * const PQFirebasePathResponseUser = @"user";

@interface PQSyncEngine ()

// GENERAL //

+ (instancetype)sharedEngine;

// OBSERVERS //

- (void)addObserversToCoreData;
- (void)removeObserversFromCoreData;

- (void)addObserversToSurvey:(PQSurvey *)survey;
- (void)removeObserversFromSurvey:(PQSurvey *)survey;

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;

- (void)addObserversToChoice:(PQChoice *)choice;
- (void)removeObserversFromChoice:(PQChoice *)choice;

- (void)addObserversToResponse:(PQResponse *)response;
- (void)removeObserversFromResponse:(PQResponse *)response;

// RESPONDERS //

- (void)managedObjectDidAppear:(NSNotification *)notification;
- (void)managedObjectWillBeDeallocated:(NSNotification *)notification;

- (void)surveyDidSave:(NSNotification *)notification;
- (void)surveyEditedAtDidSave:(NSNotification *)notification;
- (void)surveyEnabledDidSave:(NSNotification *)notification;
- (void)surveyNameDidSave:(NSNotification *)notification;
- (void)surveyRepeatDidSave:(NSNotification *)notification;
- (void)surveyTimeDidSave:(NSNotification *)notification;
- (void)surveyQuestionsDidSave:(NSNotification *)notification;
- (void)surveyAuthorDidSave:(NSNotification *)notification;

- (void)questionSecureDidSave:(NSNotification *)notification;
- (void)questionTextDidSave:(NSNotification *)notification;
- (void)questionChoicesDidSave:(NSNotification *)notification;
- (void)questionResponsesDidSave:(NSNotification *)notification;

- (void)choiceTextDidSave:(NSNotification *)notification;
- (void)choiceTextInputDidSave:(NSNotification *)notification;

- (void)responseUserDidSave:(NSNotification *)notification;

// CONVERTERS //

+ (NSDictionary *)convertSurvey:(PQSurvey *)survey;
+ (NSDictionary *)convertQuestion:(PQQuestion *)question;
+ (NSDictionary *)convertChoice:(PQChoice *)choice;
+ (NSDictionary *)convertResponse:(PQResponse *)response;
+ (NSString *)convertIndex:(NSUInteger)index;
+ (NSString *)convertDate:(NSDate *)date;

// OTHER //

+ (void)performBlockForCurrentUser:(void(^)(NSString *userId))block;

@end

@implementation PQSyncEngine

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
    
    if (![PQSyncEngine sharedEngine]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not instantiate %@", NSStringFromSelector(@selector(sharedEngine))]];
    }
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super setup];
    
    [self addObserversToCoreData];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self removeObserversFromCoreData];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedEngine {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static PQSyncEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[PQSyncEngine alloc] init];
    });
    return _sharedEngine;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCoreData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectDidAppear:) name:PQManagedObjectWasCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectDidAppear:) name:PQManagedObjectWasFetchedNotification object:nil];
}

- (void)removeObserversFromCoreData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQManagedObjectWasCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQManagedObjectWasFetchedNotification object:nil];
}

- (void)addObserversToSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyDidSave:) name:PQSurveyWasSavedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEditedAtDidSave:) name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidSave:) name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidSave:) name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyRepeatDidSave:) name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyTimeDidSave:) name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidSave:) name:PQSurveyQuestionsDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyAuthorDidSave:) name:PQSurveyAuthorDidSaveNotification object:survey];
}

- (void)removeObserversFromSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyWasSavedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyAuthorDidSaveNotification object:survey];
}

- (void)addObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionSecureDidSave:) name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidSave:) name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidSave:) name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidSave:) name:PQQuestionResponsesDidSaveNotification object:question];
}

- (void)removeObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesDidSaveNotification object:question];
}

- (void)addObserversToChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextDidSave:) name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextInputDidSave:) name:PQChoiceTextInputDidSaveNotification object:choice];
}

- (void)removeObserversFromChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextInputDidSaveNotification object:choice];
}

- (void)addObserversToResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseUserDidSave:) name:PQResponseUserDidSaveNotification object:response];
}

- (void)removeObserversFromResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQResponseUserDidSaveNotification object:response];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)managedObjectDidAppear:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *object = notification.object;
    if ([object isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)object;
        [self addObserversToSurvey:survey];
    }
    else if ([object isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)object;
        [self addObserversToQuestion:question];
    }
    else if ([object isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)object;
        [self addObserversToChoice:choice];
    }
}

- (void)managedObjectWillBeDeallocated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *object = notification.object;
    if ([object isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)object;
        [self removeObserversFromSurvey:survey];
    }
    else if ([object isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)object;
        [self removeObserversFromQuestion:question];
    }
    else if ([object isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)object;
        [self removeObserversFromChoice:choice];
    }
}

- (void)surveyDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    if (!survey.inserted && !survey.isDeleted) {
        return;
    }
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        // $userId/surveys/$surveyId
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
        NSDictionary *convertedSurvey = [PQSyncEngine convertSurvey:survey];
        [PQFirebaseController saveObject:convertedSurvey toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyEditedAtDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/editedAt
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
        NSDate *editedAt = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        NSString *convertedEditedAt = [PQSyncEngine convertDate:editedAt];
        [PQFirebaseController saveObject:convertedEditedAt toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyEnabledDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/enabled
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
        NSNumber *enabledValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:enabledValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyNameDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/name
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
        NSString *name = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:name toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyRepeatDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/repeat
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
        NSNumber *repeatValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:repeatValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyTimeDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/time
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
        NSDate *time = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        NSString *convertedTime = [PQSyncEngine convertDate:time];
        [PQFirebaseController saveObject:convertedTime toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyQuestionsDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQSurvey *survey = (PQSurvey *)notification.object;
        // $userId/surveys/$surveyId/questions
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
        NSOrderedSet *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionary];
        for (PQQuestion *question in questions) {
            convertedQuestions[question.uuid] = [PQSyncEngine convertQuestion:question];
        }
        [PQFirebaseController saveObject:convertedQuestions toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)surveyAuthorDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQUser *author = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    if (!author) {
        return;
    }
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        // $userId/surveys/$surveyId
        PQSurvey *survey = (PQSurvey *)notification.object;
        NSString *surveyId = survey.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
        NSDictionary *convertedSurvey = [PQSyncEngine convertSurvey:survey];
        [PQFirebaseController saveObject:convertedSurvey toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)questionSecureDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQQuestion *question = (PQQuestion *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/secure
        NSString *surveyId = question.survey.uuid;
        NSString *questionId = question.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
        NSNumber *secureValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:secureValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)questionTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQQuestion *question = (PQQuestion *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/text
        NSString *surveyId = question.survey.uuid;
        NSString *questionId = question.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
        NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:text toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)questionChoicesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    // Remove old PQChoice observers
    // Add new PQChoice observers
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQQuestion *question = (PQQuestion *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/choices
        NSString *surveyId = question.survey.uuid;
        NSString *questionId = question.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
        NSOrderedSet *choices = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
        NSUInteger index;
        NSString *key;
        for (PQChoice *choice in choices) {
            index = [choice.question.choices indexOfObject:choice];
            key = [PQSyncEngine convertIndex:index];
            convertedChoices[key] = [PQSyncEngine convertChoice:choice];
        }
        [PQFirebaseController saveObject:convertedChoices toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)questionResponsesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQQuestion *question = (PQQuestion *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/responses
        NSString *surveyId = question.survey.uuid;
        NSString *questionId = question.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
        NSSet *responses = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
        for (PQResponse *response in responses) {
            convertedResponses[response.uuid] = [PQSyncEngine convertResponse:response];
        }
        [PQFirebaseController saveObject:convertedResponses toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)choiceTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQChoice *choice = (PQChoice *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
        NSString *surveyId = choice.question.survey.uuid;
        NSString *questionId = choice.question.uuid;
        NSUInteger index = [choice.question.choices indexOfObject:choice];
        NSString *convertedIndex = [PQSyncEngine convertIndex:index];
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, convertedIndex, PQFirebasePathChoiceText]];
        NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:text toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)choiceTextInputDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQChoice *choice = (PQChoice *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
        NSString *surveyId = choice.question.survey.uuid;
        NSString *questionId = choice.question.uuid;
        NSUInteger index = [choice.question.choices indexOfObject:choice];
        NSString *convertedIndex = [PQSyncEngine convertIndex:index];
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, convertedIndex, PQFirebasePathChoiceTextInput]];
        NSNumber *textInputValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
        [PQFirebaseController saveObject:textInputValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

- (void)responseUserDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQUser *user = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    if (!user) {
        return;
    }
    
    [PQSyncEngine performBlockForCurrentUser:^(NSString *userId) {
        PQResponse *response = (PQResponse *)notification.object;
        // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId
        NSString *surveyId = response.question.survey.uuid;
        NSString *questionId = response.question.uuid;
        NSString *responseId = response.uuid;
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId]];
        NSDictionary *convertedResponse = [PQSyncEngine convertResponse:response];
        [PQFirebaseController saveObject:convertedResponse toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
        }];
    }];
}

#pragma mark - // PRIVATE METHODS (CONVERTERS) //

+ (NSDictionary *)convertSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if (survey.isDeleted) {
        return nil;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathSurveyCreatedAt] = [PQSyncEngine convertDate:survey.createdAt];
    dictionary[PQFirebasePathSurveyEditedAt] = [PQSyncEngine convertDate:survey.editedAt];
    dictionary[PQFirebasePathSurveyEnabled] = survey.enabledValue;
    dictionary[PQFirebasePathSurveyName] = survey.name;
    dictionary[PQFirebasePathSurveyRepeat] = survey.repeatValue;
    dictionary[PQFirebasePathSurveyTime] = [PQSyncEngine convertDate:survey.time];
    
    NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionary];
    for (PQQuestion *question in survey.questions) {
        convertedQuestions[question.uuid] = [PQSyncEngine convertQuestion:question];
    }
    dictionary[PQFirebasePathQuestions] = convertedQuestions;
    
    return dictionary;
}

+ (NSDictionary *)convertQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathQuestionCreatedAt] = [PQSyncEngine convertDate:question.createdAt];
    dictionary[PQFirebasePathQuestionIndex] = [NSNumber numberWithInteger:[question.survey.questions indexOfObject:question]];
    dictionary[PQFirebasePathQuestionSecure] = question.secureValue;
    dictionary[PQFirebasePathQuestionText] = question.text;
    
    NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
    NSUInteger index;
    NSString *key;
    for (PQChoice *choice in question.choices) {
        index = [choice.question.choices indexOfObject:choice];
        key = [PQSyncEngine convertIndex:index];
        convertedChoices[key] = [PQSyncEngine convertChoice:choice];
    }
    dictionary[PQFirebasePathChoices] = convertedChoices;
    
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (PQResponse *response in question.responses) {
        convertedResponses[response.uuid] = [PQSyncEngine convertResponse:response];
    }
    dictionary[PQFirebasePathResponses] = convertedResponses;
    
    return dictionary;
}

+ (NSDictionary *)convertChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathChoiceText] = choice.text;
    dictionary[PQFirebasePathChoiceTextInput] = choice.textInputValue;
    return dictionary;
}

+ (NSDictionary *)convertResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathResponseDate] = [PQSyncEngine convertDate:response.date];
    dictionary[PQFirebasePathResponseText] = response.text;
    dictionary[PQFirebasePathResponseUser] = response.user.userId;
    return dictionary;
}

+ (NSString *)convertIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    return [NSString stringWithFormat:@"%lu", index];
}

+ (NSString *)convertDate:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (!date) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
}

#pragma mark - // PRIVATE METHODS (OTHER) //

+ (void)performBlockForCurrentUser:(void(^)(NSString *userId))block {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    id <PQUser_PRIVATE> currentUser = (id <PQUser_PRIVATE>)[PQLoginManager currentUser];
    if (!currentUser) {
        return;
    }
    
    NSString *userId = currentUser.userId;
    block(userId);
}

@end
