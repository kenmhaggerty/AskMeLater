//
//  PQSyncEngine+Firebase.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQFirebaseSyncEngine.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "FirebaseController.h"
#import "PQLoginManager.h"
#import "PQPrivateInfo.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQFirebasePathObjectDeleted = @"deleted";

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
NSString * const PQFirebasePathSurveyOrder = @"questionIds";

NSString * const PQFirebasePathQuestionCreatedAt = @"createdAt";
NSString * const PQFirebasePathQuestionEditedAt = @"editedAt";
NSString * const PQFirebasePathQuestionSecure = @"secure";
NSString * const PQFirebasePathQuestionText = @"text";

NSString * const PQFirebasePathChoiceText = @"text";
NSString * const PQFirebasePathChoiceTextInput = @"textInput";

NSString * const PQFirebasePathResponseDate = @"date";
NSString * const PQFirebasePathResponseText = @"text";
NSString * const PQFirebasePathResponseUser = @"user";

@interface PQFirebaseSyncEngine ()
@property (nonatomic) Class <FirebaseSyncDelegate> delegate;

// GENERAL //

+ (instancetype)sharedEngine;

// OBSERVERS //

- (void)addObserversToLoginManager;
- (void)removeObserversFromLoginManager;

+ (void)addFirebaseObserversToUser:(id <PQUser>)user;
+ (void)removeFirebaseObserversFromUser:(id <PQUser>)user;

- (void)addObserversToSurvey:(id <PQSurvey_Firebase>)survey;
- (void)removeObserversFromSurvey:(id <PQSurvey_Firebase>)survey;

- (void)addObserversToQuestion:(id <PQQuestion_Firebase>)question;
- (void)removeObserversFromQuestion:(id <PQQuestion_Firebase>)question;

- (void)addObserversToChoice:(id <PQChoice_Firebase>)choice;
- (void)removeObserversFromChoice:(id <PQChoice_Firebase>)choice;

- (void)addObserversToResponse:(id <PQResponse_Firebase>)response;
- (void)removeObserversFromResponse:(id <PQResponse_Firebase>)response;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;

- (void)surveyFirebasePathWillChange:(NSNotification *)notification;
- (void)surveyFirebasePathDidChange:(NSNotification *)notification;

- (void)questionFirebasePathWillChange:(NSNotification *)notification;
- (void)questionFirebasePathDidChange:(NSNotification *)notification;

- (void)choiceFirebasePathWillChange:(NSNotification *)notification;
- (void)choiceFirebasePathDidChange:(NSNotification *)notification;

- (void)responseFirebasePathWillChange:(NSNotification *)notification;
- (void)responseFirebasePathDidChange:(NSNotification *)notification;

- (void)surveyDidSave:(NSNotification *)notification;
- (void)surveyEditedAtDidSave:(NSNotification *)notification;
- (void)surveyEnabledDidSave:(NSNotification *)notification;
- (void)surveyNameDidSave:(NSNotification *)notification;
- (void)surveyRepeatDidSave:(NSNotification *)notification;
- (void)surveyTimeDidSave:(NSNotification *)notification;
- (void)surveyQuestionsDidSave:(NSNotification *)notification;
- (void)surveyQuestionsOrderDidSave:(NSNotification *)notification;

- (void)questionDidSave:(NSNotification *)notification;
- (void)questionSecureDidSave:(NSNotification *)notification;
- (void)questionTextDidSave:(NSNotification *)notification;
- (void)questionChoicesDidSave:(NSNotification *)notification;
- (void)questionResponsesDidSave:(NSNotification *)notification;

- (void)choiceDidSave:(NSNotification *)notification;
- (void)choiceTextDidSave:(NSNotification *)notification;
- (void)choiceTextInputDidSave:(NSNotification *)notification;

- (void)responseDidSave:(NSNotification *)notification;
- (void)responseUserIdDidSave:(NSNotification *)notification;

// SURVEYS //

+ (void)setEditedAt:(NSDate *)editedAt forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setEnabled:(BOOL)enabled forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setName:(NSString *)name forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setRepeat:(BOOL)repeat forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setTime:(NSDate *)time forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setQuestions:(NSOrderedSet *)questions forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setOrder:(NSArray *)questionIds forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)deleteSurveyFromFirebase:(id <PQSurvey_Firebase>)survey;

// QUESTIONS //

+ (void)setSecure:(BOOL)secure forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setText:(NSString *)text forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setChoices:(NSOrderedSet *)choices forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setResponses:(NSSet *)responses forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)deleteQuestionFromFirebase:(id <PQQuestion_Firebase>)question;

// CHOICES //

+ (void)setText:(NSString *)text forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setTextInput:(BOOL)textInput forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)deleteChoiceFromFirebase:(id <PQChoice_Firebase>)choice;

// RESPONSES //

+ (void)setUserId:(NSString *)userId forResponseOnFirebase:(id <PQResponse>)response withQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)deleteResponseFromFirebase:(id <PQResponse_Firebase>)response;

// CONVERTERS //

+ (id)convertObjectForFirebase:(id)object withEncryptionKey:(NSString *)key;
+ (id)convertSurveyForFirebase:(id <PQSurvey>)survey withEncryptionKey:(NSString *)key;
+ (id)convertQuestionForFirebase:(id <PQQuestion>)question withEncryptionKey:(NSString *)key;
+ (id)convertChoiceForFirebase:(id <PQChoice>)choice withEncryptionKey:(NSString *)key;
+ (id)convertResponseForFirebase:(id <PQResponse>)response withEncryptionKey:(NSString *)key;
+ (id)convertDateForFirebase:(NSDate *)date;

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)surveyDictionary forSurveyWithId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key;
+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)questionDictionary forQuestionWithId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key;
+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)choiceDictionary forChoiceWithQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key;
+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)responseDictionary forResponseWithId:(NSString *)responseId questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key;

+ (NSDate *)convertDateString:(NSString *)dateString;

// OTHER //

+ (BOOL)establishConnection:(BOOL)connection;
+ (void)saveObject:(id)object toFirebaseAtPath:(NSURL *)url;
+ (void)deleteObjectAtPath:(NSURL *)url;

@end

@implementation PQFirebaseSyncEngine

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

+ (void)setupWithDelegate:(Class <FirebaseSyncDelegate>)delegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [FirebaseController setup];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    if (!sharedEngine) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_REMOTE_DATA] message:[NSString stringWithFormat:@"Could not instantiate %@", NSStringFromSelector(@selector(sharedEngine))]];
        return;
    }
    
    sharedEngine.delegate = delegate;
}

#pragma mark - // PUBLIC METHODS (Exists) //

+ (void)firebaseObjectExistsForSurvey:(id <PQSurvey_Firebase>)survey withCompletion:(void(^)(BOOL exists))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    
    // $userId/surveys/$surveyId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
    [FirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(NSDictionary *result) {
        NSDictionary *surveyDictionary = result[surveyId];
        BOOL exists = ![surveyDictionary isKindOfClass:[NSNull class]];
        completionBlock(exists);
    }];
}

+ (void)firebaseObjectExistsForQuestion:(id <PQQuestion_Firebase>)question withCompletion:(void(^)(BOOL exists))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    
    // $userId/surveys/$surveyId/questions/$questionId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId]];
    [FirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(NSDictionary *result) {
        NSDictionary *questionDictionary = result[questionId];
        BOOL exists = ![questionDictionary isKindOfClass:[NSNull class]];
        completionBlock(exists);
    }];
}

+ (void)firebaseObjectExistsForChoice:(id <PQChoice_Firebase>)choice withCompletion:(void(^)(BOOL exists))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSUInteger index = choice.indexValue.integerValue;
    NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString]];
    [FirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(NSDictionary *result) {
        NSDictionary *choiceDictionary = result[indexString];
        BOOL exists = ![choiceDictionary isKindOfClass:[NSNull class]];
        completionBlock(exists);
    }];
}

+ (void)firebaseObjectExistsForResponse:(id <PQResponse_Firebase>)response withCompletion:(void(^)(BOOL exists))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId]];
    [FirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(NSDictionary *result) {
        NSDictionary *responseDictionary = result[surveyId];
        BOOL exists = ![responseDictionary isKindOfClass:[NSNull class]];
        completionBlock(exists);
    }];
}

#pragma mark - // PUBLIC METHODS (Fetch) //

+ (void)fetchSurveysFromFirebaseWithAuthorId:(NSString *)authorId synchronization:(void (^)(NSDictionary *surveyDictionary))synchronizationBlock completion:(void (^)(BOOL fetched))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_REMOTE_DATA] message:nil];
    
    // $userId/surveys/
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys]];
    [FirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(NSDictionary *result) {
        NSDictionary *surveyDictionaries = result[PQFirebasePathSurveys];
        if ([surveyDictionaries isKindOfClass:[NSNull class]]) {
            completionBlock(NO);
            return;
        }
        
        NSArray *surveyIds = surveyDictionaries.allKeys;
        NSDictionary *surveyDictionary, *convertedDictionary;
        for (NSString *surveyId in surveyIds) {
            surveyDictionary = surveyDictionaries[surveyId];
            convertedDictionary = [PQFirebaseSyncEngine convertFirebaseDictionary:surveyDictionary forSurveyWithId:surveyId authorId:authorId withKey:authorId];
            synchronizationBlock(convertedDictionary);
        }
        completionBlock(YES);
    }];
}

#pragma mark - // PUBLIC METHODS (Save) //

+ (void)saveSurveyToFirebase:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
    id convertedSurvey = [PQFirebaseSyncEngine convertObjectForFirebase:survey withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedSurvey toFirebaseAtPath:url];
    survey.isUploaded = YES;
}

+ (void)saveQuestionToFirebase:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId]];
    id convertedQuestion = [PQFirebaseSyncEngine convertObjectForFirebase:question withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedQuestion toFirebaseAtPath:url];
    question.isUploaded = YES;
}

+ (void)saveChoiceToFirebase:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSNumber *indexValue = choice.indexValue;
    NSString *index = [NSString stringWithFormat:@"%li", (long)indexValue.integerValue];
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, index]];
    id convertedChoice = [PQFirebaseSyncEngine convertObjectForFirebase:choice withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedChoice toFirebaseAtPath:url];
    choice.isUploaded = YES;
}

+ (void)saveResponseToFirebase:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId]];
    id convertedResponse = [PQFirebaseSyncEngine convertObjectForFirebase:response withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedResponse toFirebaseAtPath:url];
    response.isUploaded = YES;
}

#pragma mark - // PUBLIC METHODS (Observers) //

+ (void)addFirebaseObserversToSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(surveyFirebasePathWillChange:) name:PQSurveyAuthorIdWillChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(surveyFirebasePathWillChange:) name:PQSurveyIdWillChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(surveyFirebasePathDidChange:) name:PQSurveyAuthorIdDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(surveyFirebasePathDidChange:) name:PQSurveyIdDidChangeNotification object:survey];
    if (survey.authorId && survey.surveyId) {
        [sharedEngine addObserversToSurvey:survey];
    }
}

+ (void)removeFirebaseObserversFromSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQSurveyAuthorIdWillChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQSurveyIdWillChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQSurveyAuthorIdDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQSurveyIdDidChangeNotification object:survey];
    if (survey.authorId && survey.surveyId) {
        [sharedEngine removeObserversFromSurvey:survey];
    }
}

+ (void)addFirebaseObserversToQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathWillChange:) name:PQQuestionAuthorIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathWillChange:) name:PQQuestionSurveyIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathWillChange:) name:PQQuestionIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathDidChange:) name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathDidChange:) name:PQQuestionSurveyIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(questionFirebasePathDidChange:) name:PQQuestionIdDidChangeNotification object:question];
    if (question.authorId && question.surveyId && question.questionId) {
        [sharedEngine addObserversToQuestion:question];
    }
}

+ (void)removeFirebaseObserversFromQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionAuthorIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionSurveyIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionIdWillChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionAuthorIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionSurveyIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQQuestionIdDidChangeNotification object:question];
    if (question.authorId && question.surveyId && question.questionId) {
        [sharedEngine removeObserversFromQuestion:question];
    }
}

+ (void)addFirebaseObserversToChoice:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathWillChange:) name:PQChoiceAuthorIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathWillChange:) name:PQChoiceSurveyIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathWillChange:) name:PQChoiceQuestionIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathWillChange:) name:PQChoiceIndexWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathDidChange:) name:PQChoiceAuthorIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathDidChange:) name:PQChoiceSurveyIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathDidChange:) name:PQChoiceQuestionIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(choiceFirebasePathDidChange:) name:PQChoiceIndexDidChangeNotification object:choice];
    if (choice.authorId && choice.surveyId && choice.questionId && choice.indexValue) {
        [sharedEngine addObserversToChoice:choice];
    }
}

+ (void)removeFirebaseObserversFromChoice:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceAuthorIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceSurveyIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceQuestionIdWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceIndexWillChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceAuthorIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceSurveyIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceQuestionIdDidChangeNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQChoiceIndexDidChangeNotification object:choice];
    if (choice.authorId && choice.surveyId && choice.questionId && choice.indexValue) {
        [sharedEngine removeObserversFromChoice:choice];
    }
}

+ (void)addFirebaseObserversToResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathWillChange:) name:PQResponseAuthorIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathWillChange:) name:PQResponseSurveyIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathWillChange:) name:PQResponseQuestionIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathWillChange:) name:PQResponseIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathDidChange:) name:PQResponseAuthorIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathDidChange:) name:PQResponseSurveyIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathDidChange:) name:PQResponseQuestionIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:sharedEngine selector:@selector(responseFirebasePathDidChange:) name:PQResponseIdDidChangeNotification object:response];
    if (response.authorId && response.surveyId && response.questionId && response.responseId) {
        [sharedEngine addObserversToResponse:response];
    }
}

+ (void)removeFirebaseObserversFromResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseAuthorIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseSurveyIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseQuestionIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseIdWillChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseAuthorIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseSurveyIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseQuestionIdDidChangeNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedEngine name:PQResponseIdDidChangeNotification object:response];
    if (response.authorId && response.surveyId && response.questionId && response.responseId) {
        [sharedEngine removeObserversFromResponse:response];
    }
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super setup];
    
    [self addObserversToLoginManager];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self removeObserversFromLoginManager];
    
    [self teardown];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedEngine {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static PQFirebaseSyncEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[PQFirebaseSyncEngine alloc] init];
    });
    return _sharedEngine;
}

+ (Class <FirebaseSyncDelegate>)delegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [PQFirebaseSyncEngine sharedEngine].delegate;
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

+ (void)addFirebaseObserversToUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
//    if (!user.userId) {
//        return;
//    }
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [FirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(NSDictionary *child) {
        NSString *surveyId = child.allKeys.firstObject;
        NSDictionary *surveyDictionary = child[surveyId];
        NSDictionary *convertedDictionary = [PQFirebaseSyncEngine convertFirebaseDictionary:surveyDictionary forSurveyWithId:surveyId authorId:userId withKey:userId];
        if (!convertedDictionary) {
            return;
        }
        
        [[PQFirebaseSyncEngine delegate] synchronizeSurveyWithDictionary:convertedDictionary];
    }];
//    [FirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *surveyId = child.allKeys.firstObject;
//        [[PQFirebaseSyncEngine delegate] deleteSurveyFromLocalWithId:surveyId];
//    }];
}

+ (void)removeFirebaseObserversFromUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [FirebaseController removeChildAddedObserverAtPath:url.relativeString];
    [FirebaseController removeChildRemovedObserverAtPath:url.relativeString];
}

- (void)addObserversToSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyWillSave:) name:PQSurveyWillSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyDidSave:) name:PQSurveyDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEditedAtDidSave:) name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidSave:) name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidSave:) name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyRepeatDidSave:) name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyTimeDidSave:) name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidSave:) name:PQSurveyQuestionsDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsOrderDidSave:) name:PQSurveyQuestionsOrderDidSaveNotification object:survey];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathObjectDeleted]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *deletedValue = value[PQFirebasePathObjectDeleted];
        if ([deletedValue isKindOfClass:[NSNull class]] || deletedValue.boolValue) {
            [[PQFirebaseSyncEngine delegate] deleteSurveyFromLocalWithId:surveyId];
        }
    }];
    
    // $userId/surveys/$surveyId/createdAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyCreatedAt]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *createdAtString = value[PQFirebasePathSurveyCreatedAt];
        NSDate *createdAt = [PQFirebaseSyncEngine convertDateString:createdAtString];
        [[PQFirebaseSyncEngine delegate] saveCreatedAt:createdAt toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/editedAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *editedAtString = value[PQFirebasePathSurveyEditedAt];
        NSDate *editedAt = [PQFirebaseSyncEngine convertDateString:editedAtString];
        [[PQFirebaseSyncEngine delegate] saveEditedAt:editedAt toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/enabled
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *enabledValue = value[PQFirebasePathSurveyEnabled];
        BOOL enabled = enabledValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveEnabled:enabled toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/name
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *name = value[PQFirebasePathSurveyName];
        name = [name decryptedStringUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveName:name toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/repeat
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *repeatValue = value[PQFirebasePathSurveyRepeat];
        BOOL repeat = repeatValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveRepeat:repeat toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/time
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *timeString = value[PQFirebasePathSurveyTime];
        NSDate *time = [PQFirebaseSyncEngine convertDateString:timeString];
        [[PQFirebaseSyncEngine delegate] saveTime:time toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/order
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSDictionary *questionIds = value[PQFirebasePathSurveyOrder];
        NSMutableOrderedSet *convertedQuestionIds = [NSMutableOrderedSet orderedSetWithCapacity:questionIds.count];
        NSNumber *index;
        NSString *questionId;
        for (int i = 0; i < questionIds.count; i++) {
            index = [NSNumber numberWithInteger:i];
            questionId = questionIds[index];
            [convertedQuestionIds addObject:questionId];
        }
        
        [[PQFirebaseSyncEngine delegate] saveOrder:[NSOrderedSet orderedSetWithOrderedSet:convertedQuestionIds] forLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/questions
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
//    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
//        NSDictionary *questionDictionaries = value[PQFirebasePathQuestions];
//        // $userId/surveys/$surveyId/order
//        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
//        [FirebaseController getObjectAtPath:url.relativeString withCompletion:^(NSDictionary *object) {
//            NSDictionary *questionIds = object[PQFirebasePathSurveyOrder];
//            NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:questionIds.count];
//            NSNumber *index;
//            NSString *questionId;
//            NSDictionary *questionDictionary, *question;
//            for (int i = 0; i < questionIds.count; i++) {
//                index = [NSNumber numberWithInteger:i];
//                questionId = questionIds[index];
//                questionDictionary = questionDictionaries[questionId];
//                question = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:userId withKey:key];
//                [questions addObject:question];
//            }
//            [[PQFirebaseSyncEngine delegate] saveQuestions:[NSOrderedSet orderedSetWithOrderedSet:questions] toLocalSurveyWithId:surveyId];
//        }];
//    }];
    [FirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(NSDictionary *child) {
        NSString *questionId = child.allKeys.firstObject;
        NSDictionary *questionDictionary = child[questionId];
        
        // $userId/surveys/$surveyId/order
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
        [FirebaseController getObjectAtPath:url.relativeString withCompletion:^(NSDictionary *object) {
            NSDictionary *questionIds = object[PQFirebasePathSurveyOrder];
            NSArray *indices = [questionIds allKeysForObject:questionId];
            NSNumber *index = indices.firstObject;
            NSDictionary *question = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:userId withKey:key];
            [[PQFirebaseSyncEngine delegate] insertQuestion:question withId:questionId atIndex:index.integerValue forLocalSurveyWithId:surveyId];
        }];
    }];
//    [FirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *questionId = child.allKeys.firstObject;
//        [[PQFirebaseSyncEngine delegate] deleteQuestionFromLocalWithId:questionId];
//    }];
}

- (void)removeObserversFromSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    
    // $userId/surveys/$surveyId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathObjectDeleted]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/createdAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyCreatedAt]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/editedAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/enabled
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/name
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/repeat
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/time
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questionIds
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    [FirebaseController removeChildAddedObserverAtPath:url.relativeString];
//    [FirebaseController removeChildRemovedObserverAtPath:url.relativeString];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyWillSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsOrderDidSaveNotification object:survey];
}

- (void)addObserversToQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWillSave:) name:PQQuestionWillSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionDidSave:) name:PQQuestionDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionSecureDidSave:) name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidSave:) name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidSave:) name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidSave:) name:PQQuestionChoicesOrderDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidSave:) name:PQQuestionResponsesDidSaveNotification object:question];
    
    NSString *authorId = question.authorId;
    NSString *userId = authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathObjectDeleted]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *deletedValue = value[PQFirebasePathObjectDeleted];
        if ([deletedValue isKindOfClass:[NSNull class]] || deletedValue.boolValue) {
            [[PQFirebaseSyncEngine delegate] deleteQuestionFromLocalWithId:questionId];
        }
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionCreatedAt]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *createdAtString = value[PQFirebasePathQuestionCreatedAt];
        NSDate *createdAt = [PQFirebaseSyncEngine convertDateString:createdAtString];
        [[PQFirebaseSyncEngine delegate] saveCreatedAt:createdAt toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *secureValue = value[PQFirebasePathQuestionSecure];
        BOOL secure = secureValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveSecure:secure toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *text = value[PQFirebasePathQuestionText];
        text = [text decryptedStringUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSDictionary *choiceDictionaries = value[PQFirebasePathChoices];
        
        NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSet];
        if (![choiceDictionaries isKindOfClass:[NSNull class]]) {
            NSDictionary *choiceDictionary, *choice;
            NSNumber *index;
            for (int i = 0; i < choiceDictionaries.count; i++) {
                index = [NSNumber numberWithInteger:i];
                choiceDictionary = choiceDictionaries[index];
                choice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:authorId withKey:key];
                if (choice) {
                    [choices addObject:choice];
                }
            }
        }
        
        [[PQFirebaseSyncEngine delegate] saveChoices:[NSOrderedSet orderedSetWithOrderedSet:choices] toLocalQuestionWithId:questionId];
    }];
//    [FirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *indexString = child.allKeys.firstObject;
//        NSUInteger index = indexString.integerValue;
//        NSDictionary *choiceDictionary = child[indexString];
//        NSDictionary *choice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:userId withKey:key];
//        [[PQFirebaseSyncEngine delegate] insertChoice:choice atIndex:index forLocalQuestionWithId:questionId];
//    }];
//    [FirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *indexString = child.allKeys.firstObject;
//        NSUInteger index = indexString.integerValue;
//        [[PQFirebaseSyncEngine delegate] deleteChoiceFromLocalWithIndex:index questionId:questionId];
//    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSDictionary *responseDictionaries = value[PQFirebasePathResponses];
        
        NSMutableSet *responses = [NSMutableSet set];
        if (![responseDictionaries isKindOfClass:[NSNull class]]) {
            NSDictionary *responseDictionary, *response;
            for (NSString *responseId in responseDictionaries.allKeys) {
                responseDictionary = responseDictionaries[responseId];
                response = [PQFirebaseSyncEngine convertFirebaseDictionary:responseDictionaries[responseId] forResponseWithId:responseId questionId:questionId surveyId:surveyId authorId:userId withKey:key];
                if (response) {
                    [responses addObject:response];
                }
            }
        }
        
        [[PQFirebaseSyncEngine delegate] saveResponses:[NSSet setWithSet:responses] toLocalQuestionWithId:questionId];
    }];
    
    
//    [FirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *responseId = child.allKeys.firstObject;
//        NSDictionary *responseDictionary = child[responseId];
//        NSDictionary *response = [PQFirebaseSyncEngine convertFirebaseDictionary:responseDictionary forResponseWithId:responseId questionId:questionId surveyId:surveyId authorId:userId withKey:key];
//        [[PQFirebaseSyncEngine delegate] saveResponse:response toLocalQuestionWithId:questionId];
//    }];
//    [FirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(NSDictionary *child) {
//        NSString *responseId = child.allKeys.firstObject;
//        [[PQFirebaseSyncEngine delegate] deleteResponseFromLocalWithId:responseId];
//    }];
}

- (void)removeObserversFromQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    
    // $userId/surveys/$surveyId/questions/$questionId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathObjectDeleted]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionCreatedAt]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
//    [FirebaseController removeChildAddedObserverAtPath:url.relativeString];
//    [FirebaseController removeChildRemovedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
//    [FirebaseController removeChildAddedObserverAtPath:url.relativeString];
//    [FirebaseController removeChildRemovedObserverAtPath:url.relativeString];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionWillSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesOrderDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesDidSaveNotification object:question];
}

- (void)addObserversToChoice:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceWillSave:) name:PQChoiceWillSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceDidSave:) name:PQChoiceDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextDidSave:) name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextInputDidSave:) name:PQChoiceTextInputDidSaveNotification object:choice];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSUInteger index = choice.indexValue.integerValue;
    NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathObjectDeleted]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *deletedValue = value[PQFirebasePathObjectDeleted];
        if ([deletedValue isKindOfClass:[NSNull class]] || deletedValue.boolValue) {
            [[PQFirebaseSyncEngine delegate] deleteChoiceFromLocalWithIndex:index questionId:questionId];
        }
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *text = value[PQFirebasePathChoiceText];
        text = [text decryptedStringUsingKey:userId];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalChoiceWithIndex:index questionId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *textInputValue = value[PQFirebasePathChoiceTextInput];
        BOOL textInput = textInputValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveTextInput:textInput toLocalChoiceWithIndex:index questionId:questionId];
    }];
}

- (void)removeObserversFromChoice:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSUInteger index = choice.indexValue.integerValue;
    NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathObjectDeleted]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceWillSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextInputDidSaveNotification object:choice];
}

- (void)addObserversToResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseDidSave:) name:PQResponseDidSaveNotification object:response];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathObjectDeleted]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSNumber *deletedValue = value[PQFirebasePathObjectDeleted];
        if ([deletedValue isKindOfClass:[NSNull class]] || deletedValue.boolValue) {
            [[PQFirebaseSyncEngine delegate] deleteResponseFromLocalWithId:responseId];
        }
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseDate]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *dateString = value[PQFirebasePathResponseDate];
        NSDate *date = [PQFirebaseSyncEngine convertDateString:dateString];
        [[PQFirebaseSyncEngine delegate] saveDate:date toLocalResponseWithId:responseId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseText]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *text = value[PQFirebasePathResponseText];
        text = [text decryptedStringUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalResponseWithId:responseId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    [FirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(NSDictionary *value) {
        NSString *userId = value[PQFirebasePathResponseUser];
        userId = [userId decryptedStringUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveUserId:userId toLocalResponseWithId:responseId];
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseWillSave:) name:PQResponseWillSaveNotification object:response];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseDidSave:) name:PQResponseDidSaveNotification object:response];
}

- (void)removeObserversFromResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/deleted
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathObjectDeleted]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseDate]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseText]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    [FirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQResponseWillSaveNotification object:response];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQResponseDidSaveNotification object:response];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQUser> currentUser = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    id <PQUser> previousUser = notification.userInfo[NOTIFICATION_OLD_KEY];
    
    if (previousUser) {
        [PQFirebaseSyncEngine removeFirebaseObserversFromUser:previousUser];
    }
    
    if (currentUser) {
        [PQFirebaseSyncEngine addFirebaseObserversToUser:currentUser];
    }
}

- (void)surveyFirebasePathWillChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.authorId && survey.surveyId) {
        [self removeObserversFromSurvey:survey];
    }
}

- (void)surveyFirebasePathDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.authorId && survey.surveyId) {
        [self addObserversToSurvey:survey];
    }
}

- (void)questionFirebasePathWillChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.authorId && question.surveyId && question.questionId) {
        [self removeObserversFromQuestion:question];
    }
}

- (void)questionFirebasePathDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.authorId && question.surveyId && question.questionId) {
        [self addObserversToQuestion:question];
    }
}

- (void)choiceFirebasePathWillChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    
    if (choice.authorId && choice.surveyId && choice.questionId && choice.indexValue) {
        [self removeObserversFromChoice:choice];
    }
}

- (void)choiceFirebasePathDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    
    if (choice.authorId && choice.surveyId && choice.questionId && choice.indexValue) {
        [self addObserversToChoice:choice];
    }
}

- (void)responseFirebasePathWillChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)notification.object;
    
    if (response.authorId && response.surveyId && response.questionId && response.responseId) {
        [self removeObserversFromResponse:response];
    }
}

- (void)responseFirebasePathDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)notification.object;
    
    if (response.authorId && response.surveyId && response.questionId && response.responseId) {
        [self addObserversToResponse:response];
    }
}

- (void)surveyDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    if (survey.wasDeleted) {
        if (!survey.parentIsDeleted) {
            [PQFirebaseSyncEngine deleteSurveyFromFirebase:survey];
        }
        return;
    }
    
    [PQFirebaseSyncEngine saveSurveyToFirebase:survey];
}

- (void)surveyEditedAtDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSDate *editedAt = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setEditedAt:editedAt forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyEnabledDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSNumber *enabledValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setEnabled:enabledValue.boolValue forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyNameDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSString *name = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setName:name forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyRepeatDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSNumber *repeatValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setRepeat:repeatValue.boolValue forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyTimeDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSDate *time = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setTime:time forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyQuestionsDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSOrderedSet <PQQuestion_Firebase> *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setQuestions:questions forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyQuestionsOrderDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    if (survey.isDownloaded) {
        return;
    }
    
    NSOrderedSet <id <PQQuestion_Firebase>> *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSMutableArray *questionIds = [NSMutableArray arrayWithCapacity:questions.count];
    id <PQQuestion_Firebase> question;
    NSString *questionId;
    for (int i = 0; i < questions.count; i++) {
        question = questions[i];
        questionId = question.questionId;
        [questionIds addObject:questionId];
    }
    [PQFirebaseSyncEngine setOrder:[NSArray arrayWithArray:questionIds] forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)questionDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.isDownloaded) {
        return;
    }
    
    if (question.wasDeleted) {
        if (!question.parentIsDeleted) {
            [PQFirebaseSyncEngine deleteQuestionFromFirebase:question];
        }
        return;
    }
    
//    [PQFirebaseSyncEngine saveQuestionToFirebase:question];
}

- (void)questionSecureDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.isDownloaded) {
        return;
    }
    
    NSNumber *secureValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setSecure:secureValue.boolValue forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.isDownloaded) {
        return;
    }
    
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setText:text forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionChoicesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.isDownloaded) {
        return;
    }
    
    NSOrderedSet <PQChoice_Firebase> *choices = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(wasDeleted)), @NO];
    NSOrderedSet *filteredChoices = [choices filteredOrderedSetUsingPredicate:predicate];
    
    [PQFirebaseSyncEngine setChoices:filteredChoices forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionResponsesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    
    if (question.isDownloaded) {
        return;
    }
    
    NSSet <PQResponse_Firebase> *responses = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(wasDeleted)), @NO];
    NSSet *filteredResponses = [responses filteredSetUsingPredicate:predicate];
    
    [PQFirebaseSyncEngine setResponses:filteredResponses forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)choiceDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    
    if (choice.isDownloaded) {
        return;
    }
    
    if (choice.wasDeleted) {
        if (!choice.parentIsDeleted) {
            [PQFirebaseSyncEngine deleteChoiceFromFirebase:choice];
        }
        return;
    }
    
//    [PQFirebaseSyncEngine saveChoiceToFirebase:choice];
}

- (void)choiceTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    
    if (choice.isDownloaded) {
        return;
    }
    
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setText:text forChoiceOnFirebase:choice withIndex:choice.indexValue.integerValue questionId:choice.questionId surveyId:choice.surveyId authorId:choice.authorId];
}

- (void)choiceTextInputDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    
    if (choice.isDownloaded) {
        return;
    }
    
    NSNumber *textInputValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setTextInput:textInputValue.boolValue forChoiceOnFirebase:choice withIndex:choice.indexValue.integerValue questionId:choice.questionId surveyId:choice.surveyId authorId:choice.authorId];
}

- (void)responseDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)notification.object;
    
    if (response.isDownloaded) {
        return;
    }
    
    if (response.wasDeleted) {
        if (!response.parentIsDeleted) {
            [PQFirebaseSyncEngine deleteResponseFromFirebase:response];
        }
        return;
    }
    
//    [PQFirebaseSyncEngine saveResponseToFirebase:response];
}

- (void)responseUserIdDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)notification.object;
    
    if (response.isDownloaded) {
        return;
    }
    
    NSString *userId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setUserId:userId forResponseOnFirebase:response withQuestionId:response.questionId surveyId:response.surveyId authorId:response.authorId];
}

#pragma mark - // PRIVATE METHODS (Surveys) //

+ (void)setEditedAt:(NSDate *)editedAt forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/editedAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    id convertedEditedAt = [PQFirebaseSyncEngine convertObjectForFirebase:editedAt withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedEditedAt toFirebaseAtPath:url];
}

+ (void)setEnabled:(BOOL)enabled forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/enabled
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    id convertedEnabled = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:enabled] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedEnabled toFirebaseAtPath:url];
}

+ (void)setName:(NSString *)name forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/name
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    id convertedName = [PQFirebaseSyncEngine convertObjectForFirebase:name withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedName toFirebaseAtPath:url];
}

+ (void)setRepeat:(BOOL)repeat forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/repeat
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    id convertedRepeat = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:repeat] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedRepeat toFirebaseAtPath:url];
}

+ (void)setTime:(NSDate *)time forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/editedAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    id convertedTime = [PQFirebaseSyncEngine convertObjectForFirebase:time withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedTime toFirebaseAtPath:url];
}

+ (void)setQuestions:(NSOrderedSet *)questions forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [FirebaseController getObjectAtPath:url.relativeString withCompletion:^(NSDictionary *object) {
        NSDictionary *existingQuestionIds = object[PQFirebasePathSurveyOrder];
        NSOrderedSet *matchingQuestions;
        NSURL *deletedURL;
        for (NSString *questionId in existingQuestionIds.allValues) {
            matchingQuestions = [questions filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(questionId)), questionId]];
            if (!matchingQuestions.count) {
                deletedURL = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathObjectDeleted]];
                [FirebaseController saveObject:@YES toPath:deletedURL.relativeString withCompletion:nil];
            }
        }
        
        id <PQQuestion> question;
        NSString *questionId;
        NSMutableArray *questionIds = [NSMutableArray array];
        id convertedQuestion;
        NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionary];
        for (int i = 0; i < questions.count; i++) {
            question = questions[i];
            questionId = question.questionId;
            [questionIds addObject:question.questionId];
            convertedQuestion = [PQFirebaseSyncEngine convertObjectForFirebase:question withEncryptionKey:key];
            convertedQuestions[questionId] = convertedQuestion;
        }
        
        // $userId/surveys/$surveyId/questions
        NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
        [PQFirebaseSyncEngine saveObject:convertedQuestions toFirebaseAtPath:url];
        [PQFirebaseSyncEngine setOrder:questionIds forSurveyOnFirebase:survey withAuthorId:authorId];
    }];
}

+ (void)setOrder:(NSArray *)questionIds forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    
    // $userId/surveys/$surveyId/order
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [PQFirebaseSyncEngine saveObject:questionIds toFirebaseAtPath:url];
}

+ (void)deleteSurveyFromFirebase:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    
    // $userId/surveys/$surveyId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId]];
    [PQFirebaseSyncEngine removeFirebaseObserversFromSurvey:survey];
    [PQFirebaseSyncEngine deleteObjectAtPath:url];
}

#pragma mark - // PRIVATE METHODS (Questions) //

+ (void)setSecure:(BOOL)secure forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    id convertedSecure = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:secure] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedSecure toFirebaseAtPath:url];
}

+ (void)setText:(NSString *)text forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    id convertedText = [PQFirebaseSyncEngine convertObjectForFirebase:text withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedText toFirebaseAtPath:url];
}

+ (void)setChoices:(NSOrderedSet *)choices forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    id <PQChoice> choice;
    NSString *index;
    id convertedChoice;
    NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
    for (int i = 0; i < choices.count; i++) {
        choice = choices[i];
        index = [NSString stringWithFormat:@"%i", i];
        convertedChoice = [PQFirebaseSyncEngine convertObjectForFirebase:choice withEncryptionKey:key];
        convertedChoices[index] = convertedChoice;
    }
    [PQFirebaseSyncEngine saveObject:convertedChoices toFirebaseAtPath:url];
}

+ (void)setResponses:(NSSet *)responses forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    NSString *responseId;
    id convertedResponse;
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (id <PQResponse> response in responses) {
        responseId = response.responseId;
        convertedResponse = [PQFirebaseSyncEngine convertObjectForFirebase:response withEncryptionKey:key];
        convertedResponses[responseId] = convertedResponse;
    }
    [PQFirebaseSyncEngine saveObject:convertedResponses toFirebaseAtPath:url];
}

+ (void)deleteQuestionFromFirebase:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    
    // $userId/surveys/$surveyId/questions/$questionId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId]];
    [PQFirebaseSyncEngine removeFirebaseObserversFromQuestion:question];
    [PQFirebaseSyncEngine deleteObjectAtPath:url];
}

#pragma mark - // PRIVATE METHODS (Choices) //

+ (void)setText:(NSString *)text forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    id convertedText = [PQFirebaseSyncEngine convertObjectForFirebase:text withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedText toFirebaseAtPath:url];
}

+ (void)setTextInput:(BOOL)textInput forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    id convertedTextInput = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:textInput] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedTextInput toFirebaseAtPath:url];
}

+ (void)deleteChoiceFromFirebase:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSNumber *indexValue = choice.indexValue;
    NSString *index = [NSString stringWithFormat:@"%li", (long)indexValue.integerValue];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, index]];
    [PQFirebaseSyncEngine removeFirebaseObserversFromChoice:choice];
    [PQFirebaseSyncEngine deleteObjectAtPath:url];
}

#pragma mark - // PRIVATE METHODS (Responses) //

+ (void)setUserId:(NSString *)userId forResponseOnFirebase:(id <PQResponse>)response withQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *responseId = response.responseId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    id convertedUserId = [PQFirebaseSyncEngine convertObjectForFirebase:userId withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObject:convertedUserId toFirebaseAtPath:url];
}

+ (void)deleteResponseFromFirebase:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId]];
    [PQFirebaseSyncEngine removeFirebaseObserversFromResponse:response];
    [PQFirebaseSyncEngine deleteObjectAtPath:url];
}

#pragma mark - // PRIVATE METHODS (Converters) //

+ (id)convertObjectForFirebase:(id)object withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    if ([object conformsToProtocol:@protocol(PQSurvey_Firebase)]) {
        id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)object;
        return [PQFirebaseSyncEngine convertSurveyForFirebase:survey withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQQuestion_Firebase)]) {
        id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)object;
        return [PQFirebaseSyncEngine convertQuestionForFirebase:question withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQChoice_Firebase)]) {
        id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)object;
        return [PQFirebaseSyncEngine convertChoiceForFirebase:choice withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQResponse_Firebase)]) {
        id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)object;
        return [PQFirebaseSyncEngine convertResponseForFirebase:response withEncryptionKey:key];
    }
    
    if ([object isKindOfClass:[NSDate class]]) {
        return [PQFirebaseSyncEngine convertDateForFirebase:object];
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return [object encryptedStringUsingKey:key];
    }
    
    return object;
}

+ (id)convertSurveyForFirebase:(id <PQSurvey>)survey withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSNumber *enabled = [NSNumber numberWithBool:survey.enabled];
    NSNumber *repeat = [NSNumber numberWithBool:survey.repeat];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathObjectDeleted] = [PQFirebaseSyncEngine convertObjectForFirebase:@NO withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyCreatedAt] = [PQFirebaseSyncEngine convertObjectForFirebase:survey.createdAt withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyEditedAt] = [PQFirebaseSyncEngine convertObjectForFirebase:survey.editedAt withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyEnabled] = [PQFirebaseSyncEngine convertObjectForFirebase:enabled withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyName] = [PQFirebaseSyncEngine convertObjectForFirebase:survey.name withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyRepeat] = [PQFirebaseSyncEngine convertObjectForFirebase:repeat withEncryptionKey:key];
    dictionary[PQFirebasePathSurveyTime] = [PQFirebaseSyncEngine convertObjectForFirebase:survey.time withEncryptionKey:key];
    
    NSMutableDictionary *convertedQuestions = [NSMutableDictionary dictionaryWithCapacity:survey.questions.count];
    NSMutableArray *order = [NSMutableArray arrayWithCapacity:survey.questions.count];
    id <PQQuestion> question;
    for (int i = 0; i < survey.questions.count; i++) {
        question = (id <PQQuestion>)survey.questions[i];
        convertedQuestions[question.questionId] = [PQFirebaseSyncEngine convertObjectForFirebase:question withEncryptionKey:key];
        [order addObject:question.questionId];
    }
    dictionary[PQFirebasePathQuestions] = convertedQuestions.count ? convertedQuestions : nil;
    dictionary[PQFirebasePathSurveyOrder] = order.count ? order : nil;
    
    return dictionary;
}

+ (id)convertQuestionForFirebase:(id <PQQuestion>)question withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSNumber *secure = [NSNumber numberWithBool:question.secure];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathObjectDeleted] = [PQFirebaseSyncEngine convertObjectForFirebase:@NO withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionCreatedAt] = [PQFirebaseSyncEngine convertObjectForFirebase:question.createdAt withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionEditedAt] = [PQFirebaseSyncEngine convertObjectForFirebase:question.editedAt withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionSecure] = [PQFirebaseSyncEngine convertObjectForFirebase:secure withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionText] = [PQFirebaseSyncEngine convertObjectForFirebase:question.text withEncryptionKey:key];
    
    NSMutableArray *convertedChoices = [NSMutableArray arrayWithCapacity:question.choices.count];
    id <PQChoice> choice;
    id convertedChoice;
    for (int i = 0; i < question.choices.count; i++) {
        choice = question.choices[i];
        convertedChoice = [PQFirebaseSyncEngine convertObjectForFirebase:choice withEncryptionKey:key];
        [convertedChoices addObject:convertedChoice];
    }
    dictionary[PQFirebasePathChoices] = convertedChoices.count ? convertedChoices : nil;
    
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (id <PQResponse> response in question.responses) {
        convertedResponses[response.responseId] = [PQFirebaseSyncEngine convertObjectForFirebase:response withEncryptionKey:key];
    }
    dictionary[PQFirebasePathResponses] = convertedResponses.count ? convertedResponses : nil;
    
    return dictionary;
}

+ (id)convertChoiceForFirebase:(id <PQChoice>)choice withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSNumber *textInput = [NSNumber numberWithBool:choice.textInput];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathObjectDeleted] = [PQFirebaseSyncEngine convertObjectForFirebase:@NO withEncryptionKey:key];
    dictionary[PQFirebasePathChoiceText] = [PQFirebaseSyncEngine convertObjectForFirebase:choice.text withEncryptionKey:key];
    dictionary[PQFirebasePathChoiceTextInput] = [PQFirebaseSyncEngine convertObjectForFirebase:textInput withEncryptionKey:key];
    return dictionary;
}

+ (id)convertResponseForFirebase:(id <PQResponse>)response withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathObjectDeleted] = [PQFirebaseSyncEngine convertObjectForFirebase:@NO withEncryptionKey:key];
    dictionary[PQFirebasePathResponseDate] = [PQFirebaseSyncEngine convertObjectForFirebase:response.date withEncryptionKey:key];
    dictionary[PQFirebasePathResponseText] = [PQFirebaseSyncEngine convertObjectForFirebase:response.text withEncryptionKey:key];
    dictionary[PQFirebasePathResponseUser] = [PQFirebaseSyncEngine convertObjectForFirebase:response.userId withEncryptionKey:key];
    return dictionary;
}

+ (id)convertDateForFirebase:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_REMOTE_DATA] message:nil];
    
    if (!date) {
        return nil;
    }
    
    NSString *uuid = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    return [uuid stringByReplacingOccurrencesOfString:@"." withString:@"-"];
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)surveyDictionary forSurveyWithId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
//    NSNumber *deletedValue = surveyDictionary[PQFirebasePathObjectDeleted];
//    BOOL deleted = deletedValue.boolValue;
//    if (deleted) {
//        return nil;
//    }
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *createdAt = surveyDictionary[PQFirebasePathSurveyCreatedAt];
    NSString *editedAt = surveyDictionary[PQFirebasePathSurveyEditedAt];
    NSString *name = surveyDictionary[PQFirebasePathSurveyName];
    NSString *time = surveyDictionary[PQFirebasePathSurveyTime];
    
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(createdAt))] = [PQFirebaseSyncEngine convertDateString:createdAt];
    convertedDictionary[NSStringFromSelector(@selector(editedAt))] = [PQFirebaseSyncEngine convertDateString:editedAt];
    convertedDictionary[NSStringFromSelector(@selector(enabled))] = surveyDictionary[PQFirebasePathSurveyEnabled];
    convertedDictionary[NSStringFromSelector(@selector(name))] = [name decryptedStringUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(repeat))] = surveyDictionary[PQFirebasePathSurveyRepeat];
    convertedDictionary[NSStringFromSelector(@selector(time))] = [PQFirebaseSyncEngine convertDateString:time];
    
    NSArray *questionIds = surveyDictionary[PQFirebasePathSurveyOrder];
    NSDictionary *questionDictionaries = surveyDictionary[PQFirebasePathQuestions];
    NSMutableOrderedSet *convertedQuestions = [NSMutableOrderedSet orderedSetWithCapacity:questionDictionaries.count];
    NSString *questionId;
    NSDictionary *questionDictionary, *convertedQuestion;
    for (int i = 0; i < questionIds.count; i++) {
        questionId = questionIds[i];
        questionDictionary = questionDictionaries[questionId];
        convertedQuestion = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:authorId withKey:key];
        if (!convertedQuestion) {
            continue;
        }
        
        [convertedQuestions addObject:convertedQuestion];
    }
    convertedDictionary[NSStringFromSelector(@selector(questions))] = [NSOrderedSet orderedSetWithOrderedSet:convertedQuestions];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)questionDictionary forQuestionWithId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
//    NSNumber *deletedValue = questionDictionary[PQFirebasePathObjectDeleted];
//    BOOL deleted = deletedValue.boolValue;
//    if (deleted) {
//        return nil;
//    }
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *createdAt = questionDictionary[PQFirebasePathQuestionCreatedAt];
    NSString *editedAt = questionDictionary[PQFirebasePathQuestionEditedAt];
    NSString *text = questionDictionary[PQFirebasePathQuestionText];
    
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(createdAt))] = [PQFirebaseSyncEngine convertDateString:createdAt];
    convertedDictionary[NSStringFromSelector(@selector(editedAt))] = [PQFirebaseSyncEngine convertDateString:editedAt];
    convertedDictionary[NSStringFromSelector(@selector(secure))] = questionDictionary[PQFirebasePathQuestionSecure];
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptedStringUsingKey:key];
    
    NSArray *choiceDictionaries = questionDictionary[PQFirebasePathChoices];
    NSMutableOrderedSet *convertedChoices = [NSMutableOrderedSet orderedSetWithCapacity:choiceDictionaries.count];
    NSDictionary *choiceDictionary;
    NSDictionary *convertedChoice;
    for (int i = 0; i < choiceDictionaries.count; i++) {
        choiceDictionary = choiceDictionaries[i];
        convertedChoice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:authorId withKey:key];
        if (!convertedChoice) {
            continue;
        }
        
        [convertedChoices addObject:convertedChoice];
    }
    convertedDictionary[NSStringFromSelector(@selector(choices))] = [NSOrderedSet orderedSetWithOrderedSet:convertedChoices];
    
    NSDictionary *responseDictionaries = questionDictionary[PQFirebasePathResponses];
    NSMutableSet *convertedResponses = [NSMutableSet setWithCapacity:responseDictionaries.count];
    NSDictionary *responseDictionary;
    NSDictionary *convertedResponse;
    for (NSString *responseId in responseDictionaries.allKeys) {
        responseDictionary = responseDictionaries[responseId];
        convertedResponse = [PQFirebaseSyncEngine convertFirebaseDictionary:responseDictionary forResponseWithId:responseId questionId:questionId surveyId:surveyId authorId:authorId withKey:key];
        if (!convertedResponse) {
            continue;
        }
        
        [convertedResponses addObject:convertedResponse];
    }
    convertedDictionary[NSStringFromSelector(@selector(responses))] = [NSSet setWithSet:convertedResponses];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)choiceDictionary forChoiceWithQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
//    if ([choiceDictionary isKindOfClass:[NSNull class]]) {
//        return nil;
//    }
    
//    NSNumber *deletedValue = choiceDictionary[PQFirebasePathObjectDeleted];
//    BOOL deleted = deletedValue.boolValue;
//    if (deleted) {
//        return nil;
//    }
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *text = choiceDictionary[PQFirebasePathChoiceText];
    
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptedStringUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(textInput))] = choiceDictionary[PQFirebasePathChoiceTextInput];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)responseDictionary forResponseWithId:(NSString *)responseId questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
//    NSNumber *deletedValue = responseDictionary[PQFirebasePathObjectDeleted];
//    BOOL deleted = deletedValue.boolValue;
//    if (deleted) {
//        return nil;
//    }
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *date = responseDictionary[PQFirebasePathResponseDate];
    NSString *text = responseDictionary[PQFirebasePathResponseText];
    NSString *userId = responseDictionary[PQFirebasePathResponseUser];
    
    convertedDictionary[NSStringFromSelector(@selector(responseId))] = responseId;
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(date))] = [PQFirebaseSyncEngine convertDateString:date];
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptedStringUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(userId))] = [userId decryptedStringUsingKey:key];
    
    return convertedDictionary;
}

+ (NSDate *)convertDateString:(NSString *)dateString {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (!dateString) {
        return nil;
    }
    
    NSString *convertedDateString = [dateString stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    NSDecimalNumber *decimalDate = [NSDecimalNumber decimalNumberWithString:convertedDateString];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:decimalDate.doubleValue];
    return date;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (BOOL)establishConnection:(BOOL)connection {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (!connection) {
        connection = YES;
        return NO;
    }
    
    return YES;
}

+ (void)saveObject:(id)object toFirebaseAtPath:(NSURL *)url {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_REMOTE_DATA] message:nil];
    
    [FirebaseController saveObject:object toPath:url.relativeString withCompletion:nil];
}

+ (void)deleteObjectAtPath:(NSURL *)url {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_REMOTE_DATA] message:nil];
    
    NSURL *deletedURL = [url URLByAppendingPathComponent:PQFirebasePathObjectDeleted];
    [FirebaseController saveObject:@YES toPath:deletedURL.relativeString withCompletion:^(BOOL success) {
        if (!success) {
            return;
        }
        
        [FirebaseController saveObject:nil toPath:url.relativeString withCompletion:nil];
    }];
}

@end
