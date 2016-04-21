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
#import "PQCoreDataController+PRIVATE.h"
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
NSString * const PQFirebasePathSurveyOrder = @"questionIds";
NSString * const PQFirebasePathSurveyRepeat = @"repeat";
NSString * const PQFirebasePathSurveyTime = @"time";

NSString * const PQFirebasePathQuestionCreatedAt = @"createdAt";
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

- (void)addObserversToLoginManager;
- (void)removeObserversFromLoginManager;

+ (void)addFirebaseObserversToUser:(PQUser *)user;
+ (void)removeFirebaseObserversFromUser:(PQUser *)user;

- (void)addObserversToCoreData;
- (void)removeObserversFromCoreData;

- (void)addObserversToManagedObject:(NSManagedObject *)managedObject;
- (void)removeObserversFromManagedObject:(NSManagedObject *)managedObject;

- (void)addObserversToSurvey:(PQSurvey *)survey;
- (void)removeObserversFromSurvey:(PQSurvey *)survey;
+ (void)addFirebaseObserversToSurvey:(PQSurvey *)survey;
+ (void)removeFirebaseObserversFromSurvey:(PQSurvey *)survey;

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;
+ (void)addFirebaseObserversToQuestion:(PQQuestion *)question;
+ (void)removeFirebaseObserversFromQuestion:(PQQuestion *)question;

- (void)addObserversToChoice:(PQChoice *)choice;
- (void)removeObserversFromChoice:(PQChoice *)choice;
+ (void)addFirebaseObserversToChoice:(PQChoice *)choice;
+ (void)removeFirebaseObserversFromChoice:(PQChoice *)choice;

- (void)addObserversToResponse:(PQResponse *)response;
- (void)removeObserversFromResponse:(PQResponse *)response;
+ (void)addFirebaseObserversToResponse:(PQResponse *)response;
+ (void)removeFirebaseObserversFromResponse:(PQResponse *)response;

// RESPONDERS //

- (void)managedObjectDidAppear:(NSNotification *)notification;
- (void)managedObjectWillBeDeallocated:(NSNotification *)notification;

- (void)currentUserDidChange:(NSNotification *)notification;

- (void)surveyDidSave:(NSNotification *)notification;
- (void)surveyEditedAtDidSave:(NSNotification *)notification;
- (void)surveyEnabledDidSave:(NSNotification *)notification;
- (void)surveyNameDidSave:(NSNotification *)notification;
- (void)surveyRepeatDidSave:(NSNotification *)notification;
- (void)surveyTimeDidSave:(NSNotification *)notification;
- (void)surveyQuestionsDidSave:(NSNotification *)notification;
- (void)surveyAuthorDidSave:(NSNotification *)notification;

- (void)questionDidSave:(NSNotification *)notification;
- (void)questionSecureDidSave:(NSNotification *)notification;
- (void)questionTextDidSave:(NSNotification *)notification;
- (void)questionChoicesDidSave:(NSNotification *)notification;
- (void)questionResponsesDidSave:(NSNotification *)notification;

- (void)choiceDidSave:(NSNotification *)notification;
- (void)choiceTextDidSave:(NSNotification *)notification;
- (void)choiceTextInputDidSave:(NSNotification *)notification;

- (void)responseDidSave:(NSNotification *)notification;
- (void)responseUserDidSave:(NSNotification *)notification;

// CONVERTERS //

+ (NSDictionary *)convertSurvey:(PQSurvey *)survey;
+ (NSDictionary *)convertQuestion:(PQQuestion *)question;
+ (NSDictionary *)convertChoice:(PQChoice *)choice;
+ (NSDictionary *)convertResponse:(PQResponse *)response;
+ (NSString *)convertInteger:(NSUInteger)integer;
+ (NSString *)convertDate:(NSDate *)date;
+ (NSDate *)convertDateString:(NSString *)dateString;

// SYNC //

+ (void)saveSurveyToRemote:(PQSurvey *)survey withAuthorId:(NSString *)authorId;
+ (void)synchronizeSurveyWithId:(NSString *)surveyId authorId:(NSString *)authorId dictionary:(NSDictionary *)dictionary;
+ (void)saveSurveyToLocalWithId:(NSString *)surveyId authorId:(NSString *)authorId dictionary:(NSDictionary *)dictionary;
+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteChoicesForQuestion:(PQQuestion *)question withDictionaries:(NSArray <NSDictionary *> *)choiceDictionaries;
+ (void)saveResponseToLocalWithId:(NSString *)responseId question:(PQQuestion *)question dictionary:(NSDictionary *)dictionary;

// OTHER //

+ (PQUser *)userWithId:(NSString *)userId;

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

+ (void)fetchSurveysWithCompletion:(void(^)(void))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    PQUser *currentUser = (PQUser *)[PQLoginManager currentUser];
    if (!currentUser) {
        completionBlock();
        return;
    }
    
    // $userId/surveys/
    NSString *userId = currentUser.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [PQFirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(id result) {
        NSDictionary *dictionary = (NSDictionary *)result;
        NSArray *surveyIds = dictionary.allKeys;
        NSDictionary *surveyDictionary;
        for (NSString *surveyId in surveyIds) {
            surveyDictionary = dictionary[surveyId];
            [PQSyncEngine synchronizeSurveyWithId:surveyId authorId:userId dictionary:surveyDictionary];
        }
        for (PQSurvey *survey in currentUser.surveys) {
            if (![surveyIds containsObject:survey.surveyId]) {
                [PQCoreDataController deleteObject:survey];
            }
        }
        [PQCoreDataController save];
        completionBlock();
    }];
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

- (void)addObserversToLoginManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange:) name:PQLoginManagerCurrentUserDidChangeNotification object:nil];
}

- (void)removeObserversFromLoginManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQLoginManagerCurrentUserDidChangeNotification object:nil];
}

+ (void)addFirebaseObserversToUser:(PQUser *)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!user.userId) {
        return;
    }
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *dictionary = (NSDictionary *)child;
        NSString *surveyId = dictionary.allKeys.firstObject;
        NSDictionary *surveyDictionary = dictionary[surveyId];
        [PQSyncEngine saveSurveyToLocalWithId:surveyId authorId:userId dictionary:surveyDictionary];
        [PQCoreDataController save];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *dictionary = (NSDictionary *)child;
        NSString *surveyId = dictionary.allKeys.firstObject;
        PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
        if (survey) {
            [PQCoreDataController deleteObject:survey];
            [PQCoreDataController save];
        }
    }];
}

+ (void)removeFirebaseObserversFromUser:(PQUser *)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [PQFirebaseController removeChildAddedObserverAtPath:url.relativeString];
    [PQFirebaseController removeChildRemovedObserverAtPath:url.relativeString];
}

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

- (void)addObserversToManagedObject:(NSManagedObject *)managedObject {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectWillBeDeallocated:) name:PQManagedObjectWillBeDeallocatedNotification object:managedObject];
    
    if ([managedObject isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)managedObject;
        [self addObserversToSurvey:survey];
    }
    else if ([managedObject isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)managedObject;
        [self addObserversToQuestion:question];
    }
    else if ([managedObject isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)managedObject;
        [self addObserversToChoice:choice];
    }
    else if ([managedObject isKindOfClass:[PQResponse class]]) {
        PQResponse *response = (PQResponse *)managedObject;
        [self addObserversToResponse:response];
    }
}

- (void)removeObserversFromManagedObject:(NSManagedObject *)managedObject {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    if ([managedObject isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)managedObject;
        [self removeObserversFromSurvey:survey];
//        [PQSyncEngine removeFirebaseObserversFromSurvey:survey];
    }
    else if ([managedObject isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)managedObject;
        [self removeObserversFromQuestion:question];
//        [PQSyncEngine removeFirebaseObserversFromQuestion:question];
    }
    else if ([managedObject isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)managedObject;
        [self removeObserversFromChoice:choice];
//        [PQSyncEngine removeFirebaseObserversFromChoice:choice];
    }
    else if ([managedObject isKindOfClass:[PQResponse class]]) {
        PQResponse *response = (PQResponse *)managedObject;
        [self removeObserversFromResponse:response];
//        [PQSyncEngine removeFirebaseObserversFromResponse:response];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQManagedObjectWillBeDeallocatedNotification object:managedObject];
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

+ (void)addFirebaseObserversToSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!survey.author || !survey.surveyId) {
        return;
    }
    
    // $userId/surveys/$surveyId/createdAt
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyCreatedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        survey.createdAt = [PQSyncEngine convertDateString:dateString];
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/editedAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        survey.editedAt = [PQSyncEngine convertDateString:dateString];
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/enabled
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *enabledValue = (NSNumber *)value;
        survey.enabledValue = enabledValue;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/name
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *name = (NSString *)value;
        survey.name = name;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/repeat
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *repeatValue = (NSNumber *)value;
        survey.repeatValue = repeatValue;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/time
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        survey.time = [PQSyncEngine convertDateString:dateString];
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questionIds
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSArray *questionIds = (NSArray *)value;
        NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:questionIds.count];
        NSString *questionId;
        __block PQQuestion *question;
        for (int i = 0; i < questionIds.count; i++) {
            questionId = questionIds[i];
            question = [PQCoreDataController getQuestionWithId:questionId];
            if (!question) {
                // $userId/surveys/$surveyId/questions/$questionId
                NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId]];
                [PQFirebaseController getObjectAtPath:url.relativeString withCompletion:^(id object) {
                    NSDictionary *questionDictionary = (NSDictionary *)object;
                    question = [PQCoreDataController questionWithQuestionId:questionId];
                    [PQSyncEngine overwriteQuestion:question withDictionary:questionDictionary];
                }];
            }
            if (question) {
                [questions addObject:question];
            }
        }
        for (question in survey.questions) {
            if (![questions containsObject:question]) {
                [PQCoreDataController deleteObject:question];
            }
        }
        survey.questions = questions;
        [PQCoreDataController save];
    }];
}

+ (void)removeFirebaseObserversFromSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!survey.author || !survey.surveyId) {
        return;
    }
    
    // $userId/surveys/$surveyId/createdAt
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyCreatedAt]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/editedAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/enabled
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/name
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/repeat
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/time
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questionIds
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
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

+ (void)addFirebaseObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!question.survey || !question.survey.author || !question.survey.author.userId || !question.survey.surveyId || !question.questionId) {
        return;
    }
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionCreatedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        question.createdAt = [PQSyncEngine convertDateString:dateString];
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *secureValue = (NSNumber *)value;
        question.secureValue = secureValue;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        question.text = text;
        [PQCoreDataController save];
    }];
    
#warning TO DO – See if this works when adding/removing choices
    // $userId/surveys/$surveyId/questions/$questionId/choices
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id child) {
        NSArray *choiceDictionaries = (NSArray *)child;
        [PQSyncEngine overwriteChoicesForQuestion:question withDictionaries:choiceDictionaries];
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *dictionary = (NSDictionary *)child;
        NSString *responseId = dictionary.allKeys.firstObject;
        NSDictionary *responseDictionary = dictionary[responseId];
        [PQSyncEngine saveResponseToLocalWithId:responseId question:question dictionary:responseDictionary];
        [PQCoreDataController save];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *dictionary = (NSDictionary *)child;
        NSString *responseId = dictionary.allKeys.firstObject;
        PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
        if (response) {
            [PQCoreDataController deleteObject:response];
            [PQCoreDataController save];
        }
    }];
}

+ (void)removeFirebaseObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!question.survey || !question.survey.author || !question.survey.author.userId || !question.survey.surveyId || !question.questionId) {
        return;
    }
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionCreatedAt]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    [PQFirebaseController removeChildAddedObserverAtPath:url.relativeString];
    [PQFirebaseController removeChildRemovedObserverAtPath:url.relativeString];
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

+ (void)addFirebaseObserversToChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSString *userId = choice.question.survey.author.userId;
    NSString *surveyId = choice.question.survey.surveyId;
    NSString *questionId = choice.question.questionId;
    NSString *indexString = [PQSyncEngine convertInteger:[choice.question.choices indexOfObject:choice]];
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        choice.text = text;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *textInputValue = (NSNumber *)value;
        choice.textInputValue = textInputValue;
        [PQCoreDataController save];
    }];
}

+ (void)removeFirebaseObserversFromChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSString *userId = choice.question.survey.author.userId;
    NSString *surveyId = choice.question.survey.surveyId;
    NSString *questionId = choice.question.questionId;
    NSString *indexString = [PQSyncEngine convertInteger:[choice.question.choices indexOfObject:choice]];
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
}

- (void)addObserversToResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseUserDidSave:) name:PQResponseUserDidSaveNotification object:response];
}

- (void)removeObserversFromResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQResponseUserDidSaveNotification object:response];
}

+ (void)addFirebaseObserversToResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
    NSString *userId = response.question.survey.author.userId;
    NSString *surveyId = response.question.survey.surveyId;
    NSString *questionId = response.question.questionId;
    NSString *responseId = response.responseId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseDate]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        NSDate *date = [PQSyncEngine convertDateString:dateString];
        response.date = date;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        response.text = text;
        [PQCoreDataController save];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *userId = (NSString *)value;
        PQUser *user = [PQSyncEngine userWithId:userId];
        response.user = user;
        [PQCoreDataController save];
    }];
}

+ (void)removeFirebaseObserversFromResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
    NSString *userId = response.question.survey.author.userId;
    NSString *surveyId = response.question.survey.surveyId;
    NSString *questionId = response.question.questionId;
    NSString *responseId = response.responseId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseDate]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseText]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)managedObjectDidAppear:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    
    [self addObserversToManagedObject:managedObject];
}

- (void)managedObjectWillBeDeallocated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    
    [self removeObserversFromManagedObject:managedObject];
}

- (void)currentUserDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQUser *currentUser = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    if (!currentUser) {
        return;
    }
    
#warning OK – TO DO – Add and remove Firebase observers for user
}

- (void)surveyDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    if ((!survey.inserted && !survey.isDeleted) || survey.changedKeys) {
        return;
    }
    
//    [PQSyncEngine addFirebaseObserversToSurvey:survey];
    
    [PQSyncEngine saveSurveyToRemote:survey withAuthorId:survey.author.userId];
}

- (void)surveyEditedAtDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/editedAt
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    NSDate *editedAt = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSString *convertedEditedAt = [PQSyncEngine convertDate:editedAt];
    [PQFirebaseController saveObject:convertedEditedAt toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyEnabledDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/enabled
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    NSNumber *enabledValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:enabledValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyNameDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/name
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    NSString *name = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:name toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyRepeatDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/repeat
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    NSNumber *repeatValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:repeatValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyTimeDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/time
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    NSDate *time = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSString *convertedTime = [PQSyncEngine convertDate:time];
    [PQFirebaseController saveObject:convertedTime toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyQuestionsDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    
    // $userId/surveys/$surveyId/questionIds
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    NSOrderedSet *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSMutableArray *order = [NSMutableArray arrayWithCapacity:questions.count];
    NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionaryWithCapacity:questions.count];
    PQQuestion *question;
    for (int i = 0; i < questions.count; i++) {
        question = questions[i];
        [order addObject:question.questionId];
        convertedQuestions[question.questionId] = [PQSyncEngine convertQuestion:question];
    }
    [PQFirebaseController saveObject:order toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
    
    // $userId/surveys/$surveyId/questions
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
    [PQFirebaseController saveObject:convertedQuestions toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)surveyAuthorDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQSurvey *survey = (PQSurvey *)notification.object;
    if (!survey.author) {
        return;
    }
    
    // $userId/surveys/$surveyId
    NSString *userId = survey.author.userId;
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
    NSDictionary *convertedSurvey = [PQSyncEngine convertSurvey:survey];
    [PQFirebaseController saveObject:convertedSurvey toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)questionDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = (PQQuestion *)notification.object;
    if ((!question.inserted && !question.isDeleted) || question.changedKeys) {
        return;
    }
    
//    [PQSyncEngine addFirebaseObserversToQuestion:question];
}

- (void)questionSecureDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = (PQQuestion *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    NSNumber *secureValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:secureValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)questionTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = (PQQuestion *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:text toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)questionChoicesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = (PQQuestion *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    NSOrderedSet *choices = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
    NSUInteger index;
    NSString *key;
    for (PQChoice *choice in choices) {
        index = [choice.question.choices indexOfObject:choice];
        key = [PQSyncEngine convertInteger:index];
        convertedChoices[key] = [PQSyncEngine convertChoice:choice];
    }
    [PQFirebaseController saveObject:convertedChoices toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)questionResponsesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = (PQQuestion *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    NSString *userId = question.survey.author.userId;
    NSString *surveyId = question.survey.surveyId;
    NSString *questionId = question.questionId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    NSSet *responses = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (PQResponse *response in responses) {
        convertedResponses[response.responseId] = [PQSyncEngine convertResponse:response];
    }
    [PQFirebaseController saveObject:convertedResponses toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)choiceDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQChoice *choice = (PQChoice *)notification.object;
    if ((!choice.inserted && !choice.isDeleted) || choice.changedKeys) {
        return;
    }
    
//    [PQSyncEngine addFirebaseObserversToChoice:choice];
}

- (void)choiceTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQChoice *choice = (PQChoice *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSString *userId = choice.question.survey.author.userId;
    NSString *surveyId = choice.question.survey.surveyId;
    NSString *questionId = choice.question.questionId;
    NSUInteger index = [choice.question.choices indexOfObject:choice];
    NSString *indexString = [PQSyncEngine convertInteger:index];
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:text toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)choiceTextInputDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQChoice *choice = (PQChoice *)notification.object;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    NSString *userId = choice.question.survey.author.userId;
    NSString *surveyId = choice.question.survey.surveyId;
    NSString *questionId = choice.question.questionId;
    NSUInteger index = [choice.question.choices indexOfObject:choice];
    NSString *indexString = [PQSyncEngine convertInteger:index];
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    NSNumber *textInputValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [PQFirebaseController saveObject:textInputValue toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

- (void)responseDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQResponse *response = (PQResponse *)notification.object;
    
//    [PQSyncEngine addFirebaseObserversToResponse:response];
}

- (void)responseUserDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQResponse *response = (PQResponse *)notification.object;
    if (!response.user) {
        return;
    }
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId
    NSString *userId = response.question.survey.author.userId;
    NSString *surveyId = response.question.survey.surveyId;
    NSString *questionId = response.question.questionId;
    NSString *responseId = response.responseId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId]];
    NSDictionary *convertedResponse = [PQSyncEngine convertResponse:response];
    [PQFirebaseController saveObject:convertedResponse toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
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
    
    NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionaryWithCapacity:survey.questions.count];
    NSMutableArray *order = [NSMutableArray arrayWithCapacity:survey.questions.count];
    PQQuestion *question;
    for (int i = 0; i < survey.questions.count; i++) {
        question = survey.questions[i];
        convertedQuestions[question.questionId] = [PQSyncEngine convertQuestion:question];
        [order addObject:question.questionId];
    }
    dictionary[PQFirebasePathQuestions] = convertedQuestions;
    dictionary[PQFirebasePathSurveyOrder] = order;
    
    return dictionary;
}

+ (NSDictionary *)convertQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathQuestionCreatedAt] = [PQSyncEngine convertDate:question.createdAt];
    dictionary[PQFirebasePathQuestionSecure] = question.secureValue;
    dictionary[PQFirebasePathQuestionText] = question.text;
    
    NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
    NSUInteger index;
    NSString *indexString;
    for (PQChoice *choice in question.choices) {
        index = [choice.question.choices indexOfObject:choice];
        indexString = [PQSyncEngine convertInteger:index];
        convertedChoices[indexString] = [PQSyncEngine convertChoice:choice];
    }
    dictionary[PQFirebasePathChoices] = convertedChoices;
    
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (PQResponse *response in question.responses) {
        convertedResponses[response.responseId] = [PQSyncEngine convertResponse:response];
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

+ (NSString *)convertInteger:(NSUInteger)integer {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    return [NSString stringWithFormat:@"%lu", integer];
}

+ (NSString *)convertDate:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    if (!date) {
        return nil;
    }
    
    NSString *uuid = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    return [uuid stringByReplacingOccurrencesOfString:@"." withString:@"-"];
}

+ (NSDate *)convertDateString:(NSString *)dateString {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    return [NSDate dateWithTimeIntervalSince1970:[dateString stringByReplacingOccurrencesOfString:@"-" withString:@"."].floatValue];
}

#pragma mark - // PRIVATE METHODS (SYNC) //

+ (void)saveSurveyToRemote:(PQSurvey *)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    // $userId/surveys/$surveyId
    NSString *surveyId = survey.surveyId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId]];
    NSDictionary *convertedSurvey = [PQSyncEngine convertSurvey:survey];
    [PQFirebaseController saveObject:convertedSurvey toPath:url.relativeString withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

+ (void)synchronizeSurveyWithId:(NSString *)surveyId authorId:(NSString *)authorId dictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if (!survey) {
        [PQSyncEngine saveSurveyToLocalWithId:surveyId authorId:authorId dictionary:dictionary];
        return;
    }
    
    NSDate *remoteEditDate = [PQSyncEngine convertDateString:dictionary[PQFirebasePathSurveyEditedAt]];
    NSDate *localEditDate = survey.editedAt;
    NSComparisonResult comparison = [localEditDate compare:remoteEditDate];
    if (comparison == NSOrderedAscending) {
        [PQSyncEngine overwriteSurvey:survey withDictionary:dictionary];
    }
    else if (comparison == NSOrderedDescending) {
        [PQSyncEngine saveSurveyToRemote:survey withAuthorId:authorId];
    }
}

+ (void)saveSurveyToLocalWithId:(NSString *)surveyId authorId:(NSString *)authorId dictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController surveyWithSurveyId:surveyId];
    PQUser *author = [PQSyncEngine userWithId:authorId];
    survey.author = author;
    [PQSyncEngine overwriteSurvey:survey withDictionary:dictionary];
}

+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    survey.createdAt = [PQSyncEngine convertDateString:dictionary[PQFirebasePathSurveyCreatedAt]];
    survey.enabledValue = (NSNumber *)dictionary[PQFirebasePathSurveyEnabled];
    survey.name = dictionary[PQFirebasePathSurveyName];
    survey.repeatValue = (NSNumber *)dictionary[PQFirebasePathSurveyRepeat];
    survey.time = [PQSyncEngine convertDateString:dictionary[PQFirebasePathSurveyTime]];
    
    NSArray *questionIds = dictionary[PQFirebasePathSurveyOrder];
    if (questionIds && questionIds.count) {
        NSDictionary *questionDictionaries = dictionary[PQFirebasePathQuestions];
        NSDictionary *questionDictionary;
        PQQuestion *question;
        NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:questionIds.count];
        for (NSString *questionId in questionIds) {
            questionDictionary = questionDictionaries[questionId];
            question = [PQCoreDataController getQuestionWithId:questionId];
            if (!question) {
                question = [PQCoreDataController questionWithText:nil choices:nil];
                question.questionId = questionId;
            }
            [PQSyncEngine overwriteQuestion:question withDictionary:questionDictionary];
            [questions addObject:question];
        }
        for (question in survey.questions) {
            if (![questions containsObject:question]) {
                [PQCoreDataController deleteObject:question];
            }
        }
        survey.questions = questions;
    }
    
    survey.editedAt = [PQSyncEngine convertDateString:dictionary[PQFirebasePathSurveyEditedAt]];
}

+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    question.createdAt = [PQSyncEngine convertDateString:dictionary[PQFirebasePathQuestionCreatedAt]];
    question.secureValue = (NSNumber *)dictionary[PQFirebasePathQuestionSecure];
    question.text = dictionary[PQFirebasePathQuestionText];
    
    NSArray *choiceDictionaries = dictionary[PQFirebasePathChoices];
    [PQSyncEngine overwriteChoicesForQuestion:question withDictionaries:choiceDictionaries];
    
    NSDictionary *responseDictionaries = dictionary[PQFirebasePathResponses];
    NSDictionary *responseDictionary;
    NSSet *foundResponses;
    for (NSString *responseId in responseDictionaries.allKeys) {
        responseDictionary = responseDictionaries[responseId];
        foundResponses = [question.responses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(responseId)), responseId]];
        if (!foundResponses.count) {
            [PQSyncEngine saveResponseToLocalWithId:responseId question:question dictionary:responseDictionary];
        }
    }
}

+ (void)overwriteChoicesForQuestion:(PQQuestion *)question withDictionaries:(NSArray <NSDictionary *> *)choiceDictionaries {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithCapacity:choiceDictionaries.count];
    NSDictionary *choiceDictionary;
    PQChoice *choice;
    for (int i = 0; i < choiceDictionaries.count; i++) {
        choiceDictionary = choiceDictionaries[i];
        NSString *text = choiceDictionary[PQFirebasePathChoiceText];
        
        if (i < question.choices.count) {
            choice = question.choices[i];
            choice.text = text;
        }
        else {
            choice = [PQCoreDataController choiceWithText:text];
        }
        choice.textInputValue = (NSNumber *)choiceDictionary[PQFirebasePathChoiceTextInput];
        
        [choices addObject:choice];
    }
    for (choice in question.choices) {
        if (![choices containsObject:choice]) {
            [PQCoreDataController deleteObject:choice];
        }
    }
    question.choices = choices;
}

+ (void)saveResponseToLocalWithId:(NSString *)responseId question:(PQQuestion *)question dictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *text = dictionary[PQFirebasePathResponseText];
    NSString *userId = dictionary[PQFirebasePathResponseUser];
    PQUser *user = [PQSyncEngine userWithId:userId];
    NSDate *responseDate = [PQSyncEngine convertDateString:dictionary[PQFirebasePathResponseDate]];
    PQResponse *response = [PQCoreDataController responseWithText:text user:user date:responseDate];
    [question addResponse:response];
}

#pragma mark - // PRIVATE METHODS (OTHER) //

+ (PQUser *)userWithId:(NSString *)userId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQUser *user = [PQCoreDataController getUserWithId:userId];
    if (!user) {
        user = [PQCoreDataController userWithUserId:userId];
    }
    return user;
}

@end
