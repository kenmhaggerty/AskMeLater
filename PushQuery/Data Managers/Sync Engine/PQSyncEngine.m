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

- (void)addObserversToLoginManager;
- (void)removeObserversFromLoginManager;
- (void)addObserversToCoreData;
- (void)removeObserversFromCoreData;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;
- (void)managedObjectDidAppear:(NSNotification *)notification;
- (void)managedObjectWillDisappear:(NSNotification *)notification;

// SYNC //

+ (void)synchronizeSurveyWithDictionary:(NSDictionary *)dictionary;
+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteSurvey:(PQSurvey *)survey withQuestions:(NSOrderedSet *)questionDictionaries;
+ (void)saveSurveyToRemote:(PQSurvey *)survey;

+ (void)synchronizeQuestionWithDictionary:(NSDictionary *)dictionary;
+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary;
+ (void)overwriteQuestion:(PQQuestion *)question withChoices:(NSOrderedSet *)choiceDictionaries;
+ (void)saveQuestionToRemote:(PQQuestion *)question;

+ (void)overwriteChoice:(PQChoice *)choice withDictionary:(NSDictionary *)dictionary;

+ (void)overwriteResponse:(PQResponse *)response withDictionary:(NSDictionary *)dictionary;
+ (void)saveResponse:(NSDictionary *)responseDictionary toQuestion:(PQQuestion *)question;

// OTHER //

+ (void)managedObjectShouldBeDeleted:(NSManagedObject *)managedObject withCompletion:(void(^)(BOOL delete))completionBlock;

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

+ (void)fetchSurveysWithCompletion:(void(^)(BOOL fetched))completionBlock {
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
        
        [PQSyncEngine synchronizeSurveyWithDictionary:dictionary];
        
    } completion:^(BOOL fetched){
        for (PQSurvey *survey in currentUser.surveys) {
            if (![surveyIds containsObject:survey.surveyId]) {
                if (survey.isDownloaded) {
                    [PQCoreDataController deleteObject:survey];
                }
                else {
                    [PQSyncEngine saveSurveyToRemote:survey];
                }
            }
        }
        [PQCoreDataController save];
        completionBlock(fetched);
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
    if ([AKGenerics object:createdAt isEqualToObject:survey.createdAt]) { // || survey.isSaving
        return;
    }
    
    
    survey.isDownloaded = YES;
    survey.createdAt = createdAt;
    [PQCoreDataController save];
}

+ (void)saveEditedAt:(NSDate *)editedAt toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if ([AKGenerics object:editedAt isEqualToObject:survey.editedAt]) { // || survey.isSaving
        return;
    }
    
    survey.isDownloaded = YES;
    survey.editedAt = editedAt;
    [PQCoreDataController save];
}

+ (void)saveEnabled:(BOOL)enabled toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if (enabled == survey.enabled) { // || survey.isSaving
        return;
    }
    
    survey.isDownloaded = YES;
    survey.enabled = enabled;
    [PQCoreDataController save];
}

+ (void)saveName:(NSString *)name toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if ([AKGenerics object:name isEqualToObject:survey.name]) { // || survey.isSaving
        return;
    }
    
    survey.isDownloaded = YES;
    survey.name = name;
    [PQCoreDataController save];
}

+ (void)saveRepeat:(BOOL)repeat toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if (repeat == survey.repeat) { // || survey.isSaving
        return;
    }
    
    survey.isDownloaded = YES;
    survey.repeat = repeat;
    [PQCoreDataController save];
}

+ (void)saveTime:(NSDate *)time toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    if ([AKGenerics object:time isEqualToObject:survey.time]) { // || survey.isSaving
        return;
    }
    
    survey.isDownloaded = YES;
    survey.time = time;
    [PQCoreDataController save];
}

+ (void)saveQuestions:(NSOrderedSet *)questionDictionaries toLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
//    if (survey.isSaving) {
//        return;
//    }
    
    survey.isDownloaded = YES;
    [PQSyncEngine overwriteSurvey:survey withQuestions:questionDictionaries];
    [PQCoreDataController save];
}

+ (void)insertQuestion:(NSDictionary *)questionDictionary withId:(NSString *)questionId atIndex:(NSUInteger)index forLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if (question) {
        return;
    }
    
    question = (PQQuestion *)[PQCoreDataController questionWithQuestionId:questionId];
    question.isDownloaded = YES;
    [PQSyncEngine overwriteQuestion:question withDictionary:questionDictionary];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
    survey.isDownloaded = YES;
    [survey insertQuestion:question atIndex:index];
    
    [PQCoreDataController save];
}

+ (void)saveOrder:(NSOrderedSet *)questionIds forLocalSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQSurvey *survey = [PQCoreDataController getSurveyWithId:surveyId];
//    if (survey.isSaving) {
//        return;
//    }
    
    survey.isDownloaded = YES;
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
    if (!survey) {
        return;
    }
    
    survey.isDownloaded = YES;
    [PQCoreDataController deleteObject:survey];
    [PQCoreDataController save];
}

+ (void)synchronizeQuestionWithDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *questionId = dictionary[NSStringFromSelector(@selector(questionId))];
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    
    if (question) {
        NSDate *editedAt = dictionary[NSStringFromSelector(@selector(editedAt))];
        NSComparisonResult comparisonResult = [question.editedAt compare:editedAt];
        if (comparisonResult == NSOrderedAscending) {
            [PQSyncEngine overwriteQuestion:question withDictionary:dictionary];
        }
        else if (comparisonResult == NSOrderedDescending) {
            [PQSyncEngine saveQuestionToRemote:question];
        }
    }
    else {
        question = (PQQuestion *)[PQCoreDataController questionWithQuestionId:questionId];
        question.isDownloaded = YES;
        [PQSyncEngine overwriteQuestion:question withDictionary:dictionary];
    }
    question.lastSyncDate = [NSDate date];
    [PQCoreDataController save];
}

+ (void)saveCreatedAt:(NSDate *)createdAt toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if ([AKGenerics object:createdAt isEqualToObject:question.createdAt]) { // || question.isSaving
        return;
    }
    
    question.isDownloaded = YES;
    question.createdAt = createdAt;
    [PQCoreDataController save];
}

+ (void)saveSecure:(BOOL)secure toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if (secure == question.secure) { // || question.isSaving
        return;
    }
    
    question.isDownloaded = YES;
    question.secure = secure;
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if ([AKGenerics object:text isEqualToObject:question.text]) { // || question.isSaving
        return;
    }
    
    question.isDownloaded = YES;
    question.text = text;
    [PQCoreDataController save];
}

+ (void)saveChoices:(NSOrderedSet *)choiceDictionaries toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if (!question) {
        return;
    }
//    if (question.isSaving) {
//        return;
//    }
    
    question.isDownloaded = YES;
    [PQSyncEngine overwriteQuestion:question withChoices:choiceDictionaries];
    [PQCoreDataController save];
}

//+ (void)insertChoice:(NSDictionary *)choiceDictionary atIndex:(NSUInteger)index forLocalQuestionWithId:(NSString *)questionId {
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
//    
//    PQChoice *choice = [PQCoreDataController choiceWithText:nil];
//    [PQSyncEngine overwriteChoice:choice withDictionary:choiceDictionary];
//    
//    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
//    [question insertChoice:choice atIndex:index];
//    
//    [PQCoreDataController save];
//}

+ (void)saveResponse:(NSDictionary *)responseDictionary toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
//    if (question.isSaving) {
//        return;
//    }
    
    question.isDownloaded = YES;
    [PQSyncEngine saveResponse:responseDictionary toQuestion:question];
    [PQCoreDataController save];
}

+ (void)saveResponses:(NSSet *)responseDictionaries toLocalQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    //    if (question.isSaving) {
    //        return;
    //    }
    
    question.isDownloaded = YES;
    for (NSDictionary *responseDictionary in responseDictionaries) {
        [PQSyncEngine saveResponse:responseDictionary toQuestion:question];
    }
    [PQCoreDataController save];
}

+ (void)deleteQuestionFromLocalWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    if (!question) {
        return;
    }
    
    question.isDownloaded = YES;
    [PQCoreDataController deleteObject:question];
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    if ([AKGenerics object:text isEqualToObject:choice.text]) { // || choice.isSaving
        return;
    }
    
    choice.isDownloaded = YES;
    choice.text = text;
    [PQCoreDataController save];
}

+ (void)saveTextInput:(BOOL)textInput toLocalChoiceWithIndex:(NSUInteger)index questionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    if (textInput == choice.textInput) { // || choice.isSaving
        return;
    }
    
    choice.isDownloaded = YES;
    choice.textInput = textInput;
    [PQCoreDataController save];
}

+ (void)deleteChoiceFromLocalWithIndex:(NSUInteger)index questionId:questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
    PQChoice *choice = question.choices[index];
    if (!choice) {
        return;
    }
    
    choice.isDownloaded = YES;
    [PQCoreDataController deleteObject:choice];
    [PQCoreDataController save];
}

+ (void)saveDate:(NSDate *)date toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if ([AKGenerics object:date isEqualToObject:response.date]) { // || response.isSaving
        return;
    }
    
    response.isDownloaded = YES;
    response.date = date;
    [PQCoreDataController save];
}

+ (void)saveText:(NSString *)text toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if ([AKGenerics object:text isEqualToObject:response.text]) { // || response.isSaving
        return;
    }
    
    response.isDownloaded = YES;
    response.text = text;
    [PQCoreDataController save];
}

+ (void)saveUserId:(NSString *)userId toLocalResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if ([AKGenerics object:userId isEqualToObject:response.userId]) { // || response.isSaving
        return;
    }
    
    response.isDownloaded = YES;
    response.userId = userId;
    [PQCoreDataController save];
}

+ (void)deleteResponseFromLocalWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if (!response) {
        return;
    }
    
    response.isDownloaded = YES;
    [PQCoreDataController deleteObject:response];
    [PQCoreDataController save];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super setup];
    
    [self addObserversToLoginManager];
    [self addObserversToCoreData];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self removeObserversFromLoginManager];
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

- (void)currentUserDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQUser *currentUser = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    PQUser *priorUser = notification.userInfo[NOTIFICATION_OLD_KEY];
    
    if (!priorUser) {
        NSSet *surveys = [PQCoreDataController getSurveysWithAuthorId:nil];
        for (PQSurvey *survey in surveys) {
            survey.authorId = currentUser.userId;
            [PQCoreDataController save];
        }
        NSSet *responses = [PQCoreDataController getResponsesWithUserId:nil];
        for (PQResponse *response in responses) {
            response.userId = currentUser.userId;
            [PQCoreDataController save];
        }
        return;
    }
    
    for (PQSurvey *survey in priorUser.surveys) {
        for (PQQuestion *question in survey.questionObjects) {
            for (PQChoice *choice in question.choiceObjects) {
                [PQFirebaseSyncEngine removeFirebaseObserversFromChoice:choice];
            }
            for (PQResponse *response in question.responses) {
                [PQFirebaseSyncEngine removeFirebaseObserversFromResponse:response];
            }
            [PQFirebaseSyncEngine removeFirebaseObserversFromQuestion:question];
        }
        [PQFirebaseSyncEngine removeFirebaseObserversFromSurvey:survey];
    }
}

- (void)managedObjectDidAppear:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    
    [PQSyncEngine managedObjectShouldBeDeleted:managedObject withCompletion:^(BOOL delete) {
        if (delete) {
            [PQCoreDataController deleteObject:managedObject];
            return;
        }
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectWillDisappear:) name:PQManagedObjectWillBeDeallocatedNotification object:managedObject];
    }];
}

- (void)managedObjectWillDisappear:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSManagedObject *managedObject = notification.object;
    if (managedObject.fault) {
        return;
    }
    
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

+ (void)synchronizeSurveyWithDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = dictionary[NSStringFromSelector(@selector(surveyId))];
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
        NSString *authorId = dictionary[NSStringFromSelector(@selector(authorId))];
        NSDate *createdAt= dictionary[NSStringFromSelector(@selector(createdAt))];
        survey = (PQSurvey *)[PQCoreDataController surveyWithSurveyId:surveyId authorId:authorId createdAt:createdAt];
        survey.isDownloaded = YES;
        [PQSyncEngine overwriteSurvey:survey withDictionary:dictionary];
    }
    survey.lastSyncDate = [NSDate date];
    [PQCoreDataController save];
}

+ (void)overwriteSurvey:(PQSurvey *)survey withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSDate *createdAt = dictionary[NSStringFromSelector(@selector(createdAt))];
    NSNumber *enabledValue = dictionary[NSStringFromSelector(@selector(enabled))];
    NSString *name = dictionary[NSStringFromSelector(@selector(name))];
    NSNumber *repeatValue = dictionary[NSStringFromSelector(@selector(repeat))];
    NSDate *time = dictionary[NSStringFromSelector(@selector(time))];
    NSOrderedSet *questionDictionaries = dictionary[NSStringFromSelector(@selector(questions))];
    NSDate *editedAt = dictionary[NSStringFromSelector(@selector(editedAt))];
    
    survey.createdAt = createdAt;
    survey.editedAt = editedAt;
    survey.name = name;
    survey.time = time;
    survey.repeat = repeatValue.boolValue;
    
    [PQSyncEngine overwriteSurvey:survey withQuestions:questionDictionaries];
    
    survey.enabled = enabledValue.boolValue;
    survey.updatedAt = [NSDate date];
}

+ (void)overwriteSurvey:(PQSurvey *)survey withQuestions:(NSOrderedSet *)questionDictionaries {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:(questionDictionaries ? questionDictionaries.count : 0)];
    NSDictionary *questionDictionary;
    NSString *questionId;
    NSMutableSet *questionIds = [NSMutableSet set];
    for (int i = 0; i < questionDictionaries.count; i++) {
        
        questionDictionary = questionDictionaries[i];
        questionId = questionDictionary[NSStringFromSelector(@selector(questionId))];
        [questionIds addObject:questionId];
        
        PQQuestion *question = [PQCoreDataController getQuestionWithId:questionId];
        if (!question) {
            question = (PQQuestion *)[PQCoreDataController questionWithQuestionId:questionId];
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

+ (void)saveSurveyToRemote:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQFirebaseSyncEngine saveSurveyToFirebase:survey];
}

+ (void)overwriteQuestion:(PQQuestion *)question withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSDate *createdAt = dictionary[NSStringFromSelector(@selector(createdAt))];
    NSDate *editedAt = dictionary[NSStringFromSelector(@selector(editedAt))];
    NSNumber *secureValue = dictionary[NSStringFromSelector(@selector(secure))];
    NSString *text = dictionary[NSStringFromSelector(@selector(text))];
    NSOrderedSet *choiceDictionaries = dictionary[NSStringFromSelector(@selector(choices))];
    NSSet *responseDictionaries = dictionary[NSStringFromSelector(@selector(responses))];
    
    question.createdAt = createdAt;
    question.editedAt = editedAt;
    question.secure = secureValue.boolValue;
    question.text = text;
    
    [PQSyncEngine overwriteQuestion:question withChoices:choiceDictionaries];
    
    for (NSDictionary *responseDictionary in responseDictionaries) {
        [PQSyncEngine saveResponse:responseDictionary toQuestion:question];
    }
    
    question.updatedAt = [NSDate date];
}

+ (void)overwriteQuestion:(PQQuestion *)question withChoices:(NSOrderedSet *)choiceDictionaries {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithCapacity:(choiceDictionaries ? choiceDictionaries.count : 0)];
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

+ (void)saveQuestionToRemote:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQFirebaseSyncEngine saveQuestionToFirebase:question];
}

+ (void)overwriteChoice:(PQChoice *)choice withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *text = dictionary[NSStringFromSelector(@selector(text))];
    NSNumber *textInputValue = dictionary[NSStringFromSelector(@selector(textInput))];
    
    choice.text = text;
    choice.textInputValue = textInputValue;
}

+ (void)overwriteResponse:(PQResponse *)response withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSDate *date = dictionary[NSStringFromSelector(@selector(date))];
    NSString *text = dictionary[NSStringFromSelector(@selector(text))];
    NSString *userId = dictionary[NSStringFromSelector(@selector(userId))];
    
    response.date = date;
    response.text = text;
    response.userId = userId;
}

+ (void)saveResponse:(NSDictionary *)responseDictionary toQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *responseId = responseDictionary[NSStringFromSelector(@selector(responseId))];
    
    PQResponse *response = [PQCoreDataController getResponseWithId:responseId];
    if (!response) {
        response = (PQResponse *)[PQCoreDataController responseWithResponseId:responseId];
    }
    [PQSyncEngine overwriteResponse:response withDictionary:responseDictionary];
    [question addResponsesObject:response];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (void)managedObjectShouldBeDeleted:(NSManagedObject *)managedObject withCompletion:(void(^)(BOOL delete))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_DATA] message:nil];
    
    if ([managedObject isKindOfClass:[PQSyncedObject class]]) {
        PQSyncedObject *syncedObject = (PQSyncedObject *)managedObject;
        if (!syncedObject.isUploaded) {
            completionBlock(NO);
            return;
        }
        
        if ([managedObject isKindOfClass:[PQSurvey class]]) {
            PQSurvey *survey = (PQSurvey *)managedObject;
            [PQFirebaseSyncEngine firebaseObjectExistsForSurvey:survey withCompletion:^(BOOL exists) {
                completionBlock(!exists);
            }];
            return;
        }
        
        if ([managedObject isKindOfClass:[PQQuestion class]]) {
            PQQuestion *question = (PQQuestion *)managedObject;
            [PQFirebaseSyncEngine firebaseObjectExistsForQuestion:question withCompletion:^(BOOL exists) {
                completionBlock(!exists);
            }];
            return;
        }
        
        if ([managedObject isKindOfClass:[PQChoice class]]) {
            PQChoice *choice = (PQChoice *)managedObject;
            [PQFirebaseSyncEngine firebaseObjectExistsForChoice:choice withCompletion:^(BOOL exists) {
                completionBlock(!exists);
            }];
            return;
        }
        
        if ([managedObject isKindOfClass:[PQResponse class]]) {
            PQResponse *response = (PQResponse *)managedObject;
            [PQFirebaseSyncEngine firebaseObjectExistsForResponse:response withCompletion:^(BOOL exists) {
                completionBlock(!exists);
            }];
            return;
        }
    }
    
    completionBlock(NO);
}

@end
