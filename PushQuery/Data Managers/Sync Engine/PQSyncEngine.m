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

#import "PQFirebaseSyncEngine.h"
#import "PQNotificationsSyncEngine.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSyncEngine () <FirebaseSyncDelegate>

// GENERAL //

+ (instancetype)sharedEngine;

// OBSERVERS //

- (void)addObserversToCoreData;
- (void)removeObserversFromCoreData;

// RESPONDERS //

- (void)managedObjectDidAppear:(NSNotification *)notification;

// SYNC //

+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteSurvey:(PQSurvey *)survey withQuestions:(NSOrderedSet *)questionDictionaries;
+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteQuestion:(PQQuestion *)question withChoices:(NSOrderedSet *)choiceDictionaries;
+ (void)saveResponse:(NSDictionary *)responseDictionary toQuestion:(PQQuestion *)question;
+ (void)overwriteChoice:(PQChoice *)choice withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteResponse:(PQResponse *)response withDictionary:(NSDictionary *)dictionary;

+ (void)saveSurveyToLocalWithDictionary:(NSDictionary *)dictionary;
+ (void)saveSurveyToRemote:(PQSurvey *)survey;

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
        return;
    }
    
    [PQFirebaseSyncEngine setupWithDelegate:[self class]];
    [PQNotificationsSyncEngine setup];
}

+ (void)fetchSurveysWithCompletion:(void(^)(BOOL success))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    PQUser *currentUser = (PQUser *)[PQLoginManager currentUser];
    if (!currentUser) {
        completionBlock(NO);
        return;
    }
    
    NSMutableArray *surveyIds = [NSMutableArray array];
    [PQFirebaseSyncEngine fetchSurveysFromFirebaseWithAuthorId:currentUser.userId synchronization:^(NSDictionary *dictionary) {
        
        NSString *surveyId = dictionary[NSStringFromSelector(@selector(surveyId))];
        [surveyIds addObject:surveyId];
        
        PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
        if (survey) {
            NSDate *editedAt = dictionary[NSStringFromSelector(@selector(editedAt))];
            NSComparisonResult comparisonResult = [survey.editedAt compare:editedAt];
            if (comparisonResult == NSOrderedAscending) {
                [PQSyncEngine overwriteSurvey:survey withDictionary:dictionary];
            }
            else if (comparisonResult == NSOrderedDescending) {
                [PQSyncEngine saveSurveyToRemote:survey];
            }
        }
        else {
            [PQSyncEngine saveSurveyToLocalWithDictionary:dictionary];
        }
    } completion:^(BOOL success) {
        if (success) {
            for (PQSurvey *survey in currentUser.surveys) {
                if (![surveyIds containsObject:survey.surveyId]) {
                    [PQCoreDataController deleteObject:survey];
                }
            }
            [PQCoreDataController save];
        }
        completionBlock(success);
    }];
}

+ (void)didRespondToQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQNotificationsSyncEngine didRespondToQuestion:question];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (FirebaseSyncDelegate) //

+ (void)saveCreatedAt:(NSDate *)createdAt toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.createdAt = createdAt;
    [PQCoreDataController save];
}

+ (void)saveEditedAt:(NSDate *)editedAt toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.editedAt = editedAt;
    [PQCoreDataController save];
}

+ (void)saveEnabled:(BOOL)enabled toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.enabled = enabled;
    [PQCoreDataController save];
}

+ (void)saveName:(NSString *)name toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.name = name;
    [PQCoreDataController save];
}

+ (void)saveRepeat:(BOOL)repeat toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.repeat = repeat;
    [PQCoreDataController save];
}

+ (void)saveTime:(NSDate *)time toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.time = time;
    [PQCoreDataController save];
}

+ (void)saveQuestions:(NSOrderedSet *)questionDictionaries toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    [PQSyncEngine overwriteSurvey:survey withQuestions:questionDictionaries];
    [PQCoreDataController save];
}

+ (void)insertQuestion:(NSDictionary *)questionDictionary withId:(NSString *)questionId atIndex:(NSUInteger)index forLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController questionWithQuestionId:questionId surveyId:surveyId];
    [PQSyncEngine overwriteQuestion:question withDictionary:questionDictionary];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    [survey insertQuestion:question atIndex:index];
    
    [PQCoreDataController save];
}

+ (void)saveOrder:(NSOrderedSet *)questionIds forLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithOrderedSet:survey.questions];
    [questions sortUsingComparator:^NSComparisonResult(PQQuestion *question1, PQQuestion *question2) {
        NSNumber *index1 = [NSNumber numberWithInteger:[questionIds indexOfObject:question1.questionId]];
        NSNumber *index2 = [NSNumber numberWithInteger:[questionIds indexOfObject:question2.questionId]];
        return [index1 compare:index2];
    }];
    survey.questions = [NSOrderedSet orderedSetWithOrderedSet:questions];
    [PQCoreDataController save];
}

+ (void)deleteSurveyFromLocalWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    [PQCoreDataController deleteObject:survey];
    [PQCoreDataController save];
}

+ (void)saveCreatedAt:(NSDate *)createdAt toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    question.createdAt = createdAt;
    [PQCoreDataController save];
}

+ (void)saveSecure:(BOOL)secure toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    question.secure = secure;
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    question.text = text;
    [PQCoreDataController save];
}

+ (void)saveChoices:(NSOrderedSet *)choiceDictionaries toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    [PQSyncEngine overwriteQuestion:question withChoices:choiceDictionaries];
    [PQCoreDataController save];
}

+ (void)insertChoice:(NSDictionary *)choiceDictionary atIndex:(NSUInteger)index forLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQChoice *choice = [PQCoreDataController choiceWithText:nil];
    [PQSyncEngine overwriteChoice:choice withDictionary:choiceDictionary];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    [question insertChoice:choice atIndex:index];
    
    [PQCoreDataController save];
}

+ (void)saveResponse:(NSDictionary *)responseDictionary toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    [PQSyncEngine saveResponse:responseDictionary toQuestion:question];
    [PQCoreDataController save];
}

+ (void)deleteQuestionFromLocalWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    [PQCoreDataController deleteObject:question];
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    choice.text = text;
    [PQCoreDataController save];
}

+ (void)saveTextInput:(BOOL)textInput toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    choice.textInput = textInput;
    [PQCoreDataController save];
}

+ (void)deleteChoiceFromLocalWithIndex:(NSUInteger)index questionId:questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    [PQCoreDataController deleteObject:choice];
    [PQCoreDataController save];
}

+ (void)saveDate:(NSDate *)date toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    response.date = date;
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    response.text = text;
    [PQCoreDataController save];
}

+ (void)saveUserId:(NSString *)userId toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    response.userId = userId;
    [PQCoreDataController save];
}

+ (void)deleteResponseFromLocalWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    [PQCoreDataController deleteObject:response];
    [PQCoreDataController save];
}

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

#pragma mark - // PRIVATE METHODS (Obesrvers) //

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

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)managedObjectDidAppear:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    
    if ([managedObject isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)managedObject;
        [PQFirebaseSyncEngine addFirebaseObserversToSurvey:survey];
    }
    else if ([managedObject isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)managedObject;
        [PQFirebaseSyncEngine addFirebaseObserversToQuestion:question];
    }
    else if ([managedObject isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)managedObject;
        [PQFirebaseSyncEngine addFirebaseObserversToChoice:choice];
    }
    else if ([managedObject isKindOfClass:[PQResponse class]]) {
        PQResponse *response = (PQResponse *)managedObject;
        [PQFirebaseSyncEngine addFirebaseObserversToResponse:response];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectWillBeDeallocated:) name:PQManagedObjectWillBeDeallocatedNotification object:managedObject];
}

- (void)managedObjectWillBeDeallocated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    
    if ([managedObject isKindOfClass:[PQSurvey class]]) {
        PQSurvey *survey = (PQSurvey *)managedObject;
        [PQFirebaseSyncEngine removeFirebaseObserversFromSurvey:survey];
    }
    else if ([managedObject isKindOfClass:[PQQuestion class]]) {
        PQQuestion *question = (PQQuestion *)managedObject;
        [PQFirebaseSyncEngine removeFirebaseObserversFromQuestion:question];
    }
    else if ([managedObject isKindOfClass:[PQChoice class]]) {
        PQChoice *choice = (PQChoice *)managedObject;
        [PQFirebaseSyncEngine removeFirebaseObserversFromChoice:choice];
    }
    else if ([managedObject isKindOfClass:[PQResponse class]]) {
        PQResponse *response = (PQResponse *)managedObject;
        [PQFirebaseSyncEngine removeFirebaseObserversFromResponse:response];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQManagedObjectWillBeDeallocatedNotification object:managedObject];
}

#pragma mark - // PRIVATE METHODS (Sync) //

+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    survey.createdAt = dictionary[NSStringFromSelector(@selector(createdAt))];
    survey.enabledValue = dictionary[NSStringFromSelector(@selector(enabledValue))];
    survey.name = dictionary[NSStringFromSelector(@selector(name))];
    survey.repeatValue = dictionary[NSStringFromSelector(@selector(repeatValue))];
    survey.time = dictionary[NSStringFromSelector(@selector(time))];
    
    NSOrderedSet *questionDictionaries = dictionary[NSStringFromSelector(@selector(questions))];
    [PQSyncEngine overwriteSurvey:survey withQuestions:questionDictionaries];
    
    survey.editedAt = dictionary[NSStringFromSelector(@selector(editedAt))];
}

+ (void)overwriteSurvey:(PQSurvey *)survey withQuestions:(NSOrderedSet *)questionDictionaries {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:questionDictionaries.count];
    NSDictionary *questionDictionary;
    NSString *questionId;
    NSMutableSet *questionIds = [NSMutableSet set];
    for (int i = 0; i < questionDictionaries.count; i++) {
        
        questionDictionary = questionDictionaries[i];
        questionId = questionDictionary[NSStringFromSelector(@selector(questionId))];
        [questionIds addObject:questionId];
        
        PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
        if (!question) {
            question = [PQCoreDataController questionWithQuestionId:questionId surveyId:survey.surveyId];
        }
        
        [PQSyncEngine overwriteQuestion:question withDictionary:questionDictionary];
        
        [questions addObject:question];
    }
    for (PQQuestion *question in survey.questions) {
        if (![questionIds containsObject:question.questionId]) {
            [PQCoreDataController deleteObject:question];
        }
    }
    survey.questions = [NSOrderedSet orderedSetWithOrderedSet:questions];
}

+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    question.createdAt = dictionary[NSStringFromSelector(@selector(createdAt))];
    question.secureValue = dictionary[NSStringFromSelector(@selector(secureValue))];
    question.text = dictionary[NSStringFromSelector(@selector(text))];
    
    NSOrderedSet *choiceDictionaries = dictionary[NSStringFromSelector(@selector(choices))];
    [PQSyncEngine overwriteQuestion:question withChoices:choiceDictionaries];
    
    NSSet *responseDictionaries = dictionary[NSStringFromSelector(@selector(responses))];
    for (NSDictionary *responseDictionary in responseDictionaries) {
        [PQSyncEngine saveResponse:responseDictionary toQuestion:question];
    }
}

+ (void)overwriteQuestion:(PQQuestion *)question withChoices:(NSOrderedSet *)choiceDictionaries {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithCapacity:choiceDictionaries.count];
    NSDictionary *choiceDictionary;
    PQChoice *choice;
    for (int i = 0; i < MAX(choiceDictionaries.count, question.choices.count); i++) {
        
        if (i < choiceDictionaries.count) {
            choiceDictionary = choiceDictionaries[i];
            
            if (i < question.choices.count) {
                choice = question.choices[i];
            }
            else {
                choice = [PQCoreDataController choiceWithText:nil];
            }
            
            [PQSyncEngine overwriteChoice:choice withDictionary:choiceDictionary];
            
            [choices addObject:choice];
        }
        else {
            choice = question.choices[i];
            [PQCoreDataController deleteObject:choice];
        }
    }
    question.choices = [NSOrderedSet orderedSetWithOrderedSet:choices];
}

+ (void)overwriteChoice:(PQChoice *)choice withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    choice.text = dictionary[NSStringFromSelector(@selector(text))];
    choice.textInputValue = dictionary[NSStringFromSelector(@selector(textInputValue))];
}

+ (void)overwriteResponse:(PQResponse *)response withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    response.date = dictionary[NSStringFromSelector(@selector(date))];
    response.text = dictionary[NSStringFromSelector(@selector(text))];
    response.userId = dictionary[NSStringFromSelector(@selector(userId))];
}

+ (void)saveResponse:(NSDictionary *)responseDictionary toQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *responseId = responseDictionary[NSStringFromSelector(@selector(responseId))];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if (!response) {
        response = [PQCoreDataController responseWithResponseId:responseId questionId:question.questionId];
    }
    [PQSyncEngine overwriteResponse:response withDictionary:responseDictionary];
}

+ (void)saveSurveyToLocalWithDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = dictionary[NSStringFromSelector(@selector(surveyId))];
    NSString *authorId = dictionary[NSStringFromSelector(@selector(authorId))];
    
    PQSurvey *survey = [PQCoreDataController surveyWithSurveyId:surveyId authorId:authorId];
    [PQSyncEngine overwriteSurvey:survey withDictionary:dictionary];
    
    [PQCoreDataController save];
}

+ (void)saveSurveyToRemote:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQFirebaseSyncEngine saveSurveyToFirebase:survey withAuthorId:survey.authorId];
}

@end
