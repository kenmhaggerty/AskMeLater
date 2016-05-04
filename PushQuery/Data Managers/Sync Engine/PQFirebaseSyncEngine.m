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

#import "PQFirebaseController.h"
#import "PQLoginManager.h"

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
NSString * const PQFirebasePathSurveyOrder = @"questionIds";

NSString * const PQFirebasePathQuestionCreatedAt = @"createdAt";
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

- (void)questionSecureDidSave:(NSNotification *)notification;
- (void)questionTextDidSave:(NSNotification *)notification;
- (void)questionChoicesDidSave:(NSNotification *)notification;
- (void)questionResponsesDidSave:(NSNotification *)notification;

- (void)choiceTextDidSave:(NSNotification *)notification;
- (void)choiceTextInputDidSave:(NSNotification *)notification;

- (void)responseUserIdDidSave:(NSNotification *)notification;

// SURVEYS //

+ (void)setEditedAt:(NSDate *)editedAt forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setEnabled:(BOOL)enabled forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setName:(NSString *)name forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setRepeat:(BOOL)repeat forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setTime:(NSDate *)time forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId;
+ (void)setQuestions:(NSOrderedSet *)questions forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId;

// QUESTIONS //

+ (void)setSecure:(BOOL)secure forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setText:(NSString *)text forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setChoices:(NSOrderedSet *)choices forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setResponses:(NSSet *)responses forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId;

// CHOICES //

+ (void)setText:(NSString *)text forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;
+ (void)setTextInput:(BOOL)textInput forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;

// RESPONSES //

+ (void)setUserId:(NSString *)userId forResponseOnFirebase:(id <PQResponse>)response withQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId;

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

+ (void)saveObjectToFirebase:(id)object withPath:(NSString *)path;

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
    
    [PQFirebaseController setup];
    
    PQFirebaseSyncEngine *sharedEngine = [PQFirebaseSyncEngine sharedEngine];
    if (!sharedEngine) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not instantiate %@", NSStringFromSelector(@selector(sharedEngine))]];
        return;
    }
    
    sharedEngine.delegate = delegate;
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)fetchSurveysFromFirebaseWithAuthorId:(NSString *)authorId synchronization:(void (^)(NSDictionary *surveyDictionary))synchronizationBlock completion:(void (^)(BOOL))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    // $userId/surveys/
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys]];
    [PQFirebaseController getObjectsAtPath:url.relativeString withQueries:nil andCompletion:^(id result) {
        if ([result isKindOfClass:[NSNull class]]) {
            completionBlock(NO);
            return;
        }
        
        NSDictionary *surveyDictionaries = (NSDictionary *)result;
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

+ (void)saveSurveyToFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId]];
    id convertedSurvey = [PQFirebaseSyncEngine convertObjectForFirebase:survey withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedSurvey withPath:url.relativeString];
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
    
    if (!user.userId) {
        return;
    }
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *surveyDictionary = (NSDictionary *)child;
        NSString *surveyId = surveyDictionary.allKeys.firstObject;
        surveyDictionary = surveyDictionary[surveyId];
        NSDictionary *convertedDictionary = [PQFirebaseSyncEngine convertFirebaseDictionary:surveyDictionary forSurveyWithId:surveyId authorId:userId withKey:userId];
        [[PQFirebaseSyncEngine delegate] saveSurveyToLocalWithDictionary:convertedDictionary];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *dictionary = (NSDictionary *)child;
        NSString *surveyId = dictionary.allKeys.firstObject;
        [[PQFirebaseSyncEngine delegate] deleteSurveyFromLocalWithId:surveyId];
    }];
}

+ (void)removeFirebaseObserversFromUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    // $userId/surveys/
    NSString *userId = user.userId;
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys]];
    [PQFirebaseController removeChildAddedObserverAtPath:url.relativeString];
    [PQFirebaseController removeChildRemovedObserverAtPath:url.relativeString];
}

- (void)addObserversToSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyDidSave:) name:PQSurveyDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEditedAtDidSave:) name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidSave:) name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidSave:) name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyRepeatDidSave:) name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyTimeDidSave:) name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidSave:) name:PQSurveyQuestionsDidSaveNotification object:survey];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/createdAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyCreatedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *createdAtString = (NSString *)value;
        NSDate *createdAt = [PQFirebaseSyncEngine convertDateString:createdAtString];
        [[PQFirebaseSyncEngine delegate] saveCreatedAt:createdAt toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/editedAt
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *editedAtString = (NSString *)value;
        NSDate *editedAt = [PQFirebaseSyncEngine convertDateString:editedAtString];
        [[PQFirebaseSyncEngine delegate] saveEditedAt:editedAt toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/enabled
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *enabledValue = (NSNumber *)value;
        BOOL enabled = enabledValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveEnabled:enabled toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/name
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *name = (NSString *)value;
        name = [name decryptUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveName:name toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/repeat
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *repeatValue = (NSNumber *)value;
        BOOL repeat = repeatValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveRepeat:repeat toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/time
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *timeString = (NSString *)value;
        NSDate *time = [PQFirebaseSyncEngine convertDateString:timeString];
        [[PQFirebaseSyncEngine delegate] saveTime:time toLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/order
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSArray *questionIds = (NSArray *)value;
        [[PQFirebaseSyncEngine delegate] saveOrder:[NSOrderedSet orderedSetWithArray:questionIds] forLocalSurveyWithId:surveyId];
    }];
    
    // $userId/surveys/$surveyId/questions
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSDictionary *questionDictionaries = (NSDictionary *)value;
        
        // $userId/surveys/$surveyId/order
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
        [PQFirebaseController getObjectAtPath:url.relativeString withCompletion:^(id object) {
            NSArray *questionIds = (NSArray *)object;
            NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:questionIds.count];
            NSString *questionId;
            NSDictionary *questionDictionary, *question;
            for (int i = 0; i < questionIds.count; i++) {
                questionId = questionIds[i];
                questionDictionary = questionDictionaries[questionId];
                question = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:userId withKey:key];
                [questions addObject:question];
            }
            [[PQFirebaseSyncEngine delegate] saveQuestions:questions toLocalSurveyWithId:surveyId];
        }];
    }];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *questionDictionary = (NSDictionary *)child;
        NSString *questionId = questionDictionary.allKeys.firstObject;
        questionDictionary = questionDictionary[questionId];
        
        // $userId/surveys/$surveyId/order
        NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyOrder]];
        [PQFirebaseController getObjectAtPath:url.relativeString withCompletion:^(id object) {
            NSArray *questionIds = (NSArray *)object;
            NSUInteger index = [questionIds indexOfObject:questionId];
            NSDictionary *question = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:userId withKey:key];
            [[PQFirebaseSyncEngine delegate] insertQuestion:question withId:questionId atIndex:index forLocalSurveyWithId:surveyId];
        }];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *questionDictionary = (NSDictionary *)child;
        NSString *questionId = questionDictionary.allKeys.firstObject;
        [[PQFirebaseSyncEngine delegate] deleteQuestionFromLocalWithId:questionId];
    }];
}

- (void)removeObserversFromSurvey:(id <PQSurvey_Firebase>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = survey.authorId;
    NSString *surveyId = survey.surveyId;
    
    // $userId/surveys/$surveyId/createdAt
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
    [PQFirebaseController removeChildAddedObserverAtPath:url.relativeString];
    [PQFirebaseController removeChildRemovedObserverAtPath:url.relativeString];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEditedAtDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyNameDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyRepeatDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyTimeDidSaveNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidSaveNotification object:survey];
}

- (void)addObserversToQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionSecureDidSave:) name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidSave:) name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionChoicesDidSave:) name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidSave:) name:PQQuestionResponsesDidSaveNotification object:question];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionCreatedAt]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *createdAtString = (NSString *)value;
        NSDate *createdAt = [PQFirebaseSyncEngine convertDateString:createdAtString];
        [[PQFirebaseSyncEngine delegate] saveCreatedAt:createdAt toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *secureValue = (NSNumber *)value;
        BOOL secure = secureValue.boolValue;
        [[PQFirebaseSyncEngine delegate] saveSecure:secure toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        text = [text decryptUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalQuestionWithId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSArray *choiceDictionaries = (NSArray *)value;
        NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithCapacity:choiceDictionaries.count];
        NSDictionary *choiceDictionary, *choice;
        for (int i = 0; i < choiceDictionaries.count; i++) {
            choiceDictionary = choiceDictionaries[i];
            choice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:userId withKey:key];
            [choices addObject:question];
        }
        [[PQFirebaseSyncEngine delegate] saveChoices:choices toLocalQuestionWithId:surveyId];
    }];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *choiceDictionary = (NSDictionary *)child;
        NSString *indexString = choiceDictionary.allKeys.firstObject;
        NSUInteger index = indexString.integerValue;
        choiceDictionary = choiceDictionary[indexString];
        NSDictionary *choice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:userId withKey:key];
        [[PQFirebaseSyncEngine delegate] insertChoice:choice atIndex:index forLocalQuestionWithId:questionId];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *choiceDictionary = (NSDictionary *)child;
        NSString *indexString = choiceDictionary.allKeys.firstObject;
        NSUInteger index = indexString.integerValue;
        [[PQFirebaseSyncEngine delegate] deleteChoiceFromLocalWithIndex:index questionId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    [PQFirebaseController observeChildAddedAtPath:url.relativeString withBlock:^(id child) {
        NSDictionary *responseDictionary = (NSDictionary *)child;
        NSString *responseId = responseDictionary.allKeys.firstObject;
        responseDictionary = responseDictionary[responseId];
        NSDictionary *response = [PQFirebaseSyncEngine convertFirebaseDictionary:responseDictionary forResponseWithId:responseId questionId:questionId surveyId:surveyId authorId:userId withKey:key];
        [[PQFirebaseSyncEngine delegate] saveResponse:response toLocalQuestionWithId:questionId];
    }];
    [PQFirebaseController observeChildRemovedFromPath:url.relativeString withBlock:^(id child) {
        NSDictionary *responseDictionary = (NSDictionary *)child;
        NSString *responseId = responseDictionary.allKeys.firstObject;
        [[PQFirebaseSyncEngine delegate] deleteResponseFromLocalWithId:responseId];
    }];
}

- (void)removeObserversFromQuestion:(id <PQQuestion_Firebase>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = question.authorId;
    NSString *surveyId = question.surveyId;
    NSString *questionId = question.questionId;
    
    // $userId/surveys/$surveyId/questions/$questionId/createdAt
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionSecureDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionChoicesDidSaveNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesDidSaveNotification object:question];
}

- (void)addObserversToChoice:(id <PQChoice_Firebase>)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextDidSave:) name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceTextInputDidSave:) name:PQChoiceTextInputDidSaveNotification object:choice];
    
    NSString *userId = choice.authorId;
    NSString *surveyId = choice.surveyId;
    NSString *questionId = choice.questionId;
    NSUInteger index = choice.indexValue.integerValue;
    NSString *indexString = [NSString stringWithFormat:@"%i", index];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        text = [text decryptUsingKey:userId];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalChoiceWithIndex:index questionId:questionId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSNumber *textInputValue = (NSNumber *)value;
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
    NSString *indexString = [NSString stringWithFormat:@"%i", index];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    [PQFirebaseController removeValueChangedObserverAtPath:url.relativeString];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextDidSaveNotification object:choice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceTextInputDidSaveNotification object:choice];
}

- (void)addObserversToResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    NSString *key = userId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
    NSURL *url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseDate]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *dateString = (NSString *)value;
        NSDate *date = [PQFirebaseSyncEngine convertDateString:dateString];
        [[PQFirebaseSyncEngine delegate] saveDate:date toLocalResponseWithId:responseId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/text
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseText]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *text = (NSString *)value;
        text = [text decryptUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveText:text toLocalResponseWithId:responseId];
    }];
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    url = [NSURL fileURLWithPathComponents:@[userId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    [PQFirebaseController observeValueChangedAtPath:url.relativeString withBlock:^(id value) {
        NSString *userId = (NSString *)value;
        userId = [userId decryptUsingKey:key];
        [[PQFirebaseSyncEngine delegate] saveUserId:userId toLocalResponseWithId:responseId];
    }];
}

- (void)removeObserversFromResponse:(id <PQResponse_Firebase>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *userId = response.authorId;
    NSString *surveyId = response.surveyId;
    NSString *questionId = response.questionId;
    NSString *responseId = response.responseId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/date
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    
    [PQFirebaseSyncEngine saveSurveyToFirebase:(survey.isDeleted ? survey : nil) withAuthorId:survey.authorId];
}

- (void)surveyEditedAtDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSDate *editedAt = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setEditedAt:editedAt forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyEnabledDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSNumber *enabledValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setEnabled:enabledValue.boolValue forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyNameDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSString *name = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setName:name forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyRepeatDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSNumber *repeatValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setRepeat:repeatValue.boolValue forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyTimeDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSDate *time = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setTime:time forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)surveyQuestionsDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQSurvey_Firebase> survey = (id <PQSurvey_Firebase>)notification.object;
    NSOrderedSet *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!%K", NSStringFromSelector(@selector(isDeleted))];
    NSOrderedSet *filteredQuestions = [questions filteredOrderedSetUsingPredicate:predicate];
    
    [PQFirebaseSyncEngine setQuestions:filteredQuestions forSurveyOnFirebase:survey withAuthorId:survey.authorId];
}

- (void)questionSecureDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    NSNumber *secureValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setSecure:secureValue.boolValue forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setText:text forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionChoicesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    NSOrderedSet *choices = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!%K", NSStringFromSelector(@selector(isDeleted))];
    NSOrderedSet *filteredChoices = [choices filteredOrderedSetUsingPredicate:predicate];
    
    [PQFirebaseSyncEngine setChoices:filteredChoices forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)questionResponsesDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion_Firebase> question = (id <PQQuestion_Firebase>)notification.object;
    NSSet *responses = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!%K", NSStringFromSelector(@selector(isDeleted))];
    NSSet *filteredResponses = [responses filteredSetUsingPredicate:predicate];
    
    [PQFirebaseSyncEngine setResponses:filteredResponses forQuestionOnFirebase:question withSurveyId:question.surveyId authorId:question.authorId];
}

- (void)choiceTextDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    NSString *text = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setText:text forChoiceOnFirebase:choice withIndex:choice.indexValue.integerValue questionId:choice.questionId surveyId:choice.surveyId authorId:choice.authorId];
}

- (void)choiceTextInputDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQChoice_Firebase> choice = (id <PQChoice_Firebase>)notification.object;
    NSNumber *textInputValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setTextInput:textInputValue.boolValue forChoiceOnFirebase:choice withIndex:choice.indexValue.integerValue questionId:choice.questionId surveyId:choice.surveyId authorId:choice.authorId];
}

- (void)responseUserIdDidSave:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse_Firebase> response = (id <PQResponse_Firebase>)notification.object;
    NSString *userId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQFirebaseSyncEngine setUserId:userId forResponseOnFirebase:response withQuestionId:response.questionId surveyId:response.surveyId authorId:response.authorId];
}

#pragma mark - // PRIVATE METHODS (Surveys) //

+ (void)setEditedAt:(NSDate *)editedAt forSurveyOnFirebase:(id <PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/editedAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEditedAt]];
    id convertedEditedAt = [PQFirebaseSyncEngine convertObjectForFirebase:editedAt withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedEditedAt withPath:url.relativeString];
}

+ (void)setEnabled:(BOOL)enabled forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/enabled
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyEnabled]];
    id convertedEnabled = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:enabled] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedEnabled withPath:url.relativeString];
}

+ (void)setName:(NSString *)name forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/name
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyName]];
    id convertedName = [PQFirebaseSyncEngine convertObjectForFirebase:name withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedName withPath:url.relativeString];
}

+ (void)setRepeat:(BOOL)repeat forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/repeat
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyRepeat]];
    id convertedRepeat = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:repeat] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedRepeat withPath:url.relativeString];
}

+ (void)setTime:(NSDate *)time forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/editedAt
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathSurveyTime]];
    id convertedTime = [PQFirebaseSyncEngine convertObjectForFirebase:time withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedTime withPath:url.relativeString];
}

+ (void)setQuestions:(NSOrderedSet *)questions forSurveyOnFirebase:(id<PQSurvey>)survey withAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *surveyId = survey.surveyId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions]];
    id convertedQuestions = [PQFirebaseSyncEngine convertObjectForFirebase:questions withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedQuestions withPath:url.relativeString];
}

#pragma mark - // PRIVATE METHODS (Questions) //

+ (void)setSecure:(BOOL)secure forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/secure
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionSecure]];
    id convertedSecure = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:secure] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedSecure withPath:url.relativeString];
}

+ (void)setText:(NSString *)text forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathQuestionText]];
    id convertedText = [PQFirebaseSyncEngine convertObjectForFirebase:text withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedText withPath:url.relativeString];
}

+ (void)setChoices:(NSOrderedSet *)choices forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices]];
    id convertedChoices = [PQFirebaseSyncEngine convertObjectForFirebase:choices withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedChoices withPath:url.relativeString];
}

+ (void)setResponses:(NSSet *)responses forQuestionOnFirebase:(id <PQQuestion>)question withSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *questionId = question.questionId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses]];
    id convertedResponses = [PQFirebaseSyncEngine convertObjectForFirebase:responses withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedResponses withPath:url.relativeString];
}

#pragma mark - // PRIVATE METHODS (Choices) //

+ (void)setText:(NSString *)text forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *indexString = [NSString stringWithFormat:@"%i", index];
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/text
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceText]];
    id convertedText = [PQFirebaseSyncEngine convertObjectForFirebase:text withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedText withPath:url.relativeString];
}

+ (void)setTextInput:(BOOL)textInput forChoiceOnFirebase:(id <PQChoice>)choice withIndex:(NSUInteger)index questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *indexString = [NSString stringWithFormat:@"%i", index];
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/choices/$index/textInput
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathChoices, indexString, PQFirebasePathChoiceTextInput]];
    id convertedTextInput = [PQFirebaseSyncEngine convertObjectForFirebase:[NSNumber numberWithBool:textInput] withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedTextInput withPath:url.relativeString];
}

#pragma mark - // PRIVATE METHODS (Responses) //

+ (void)setUserId:(NSString *)userId forResponseOnFirebase:(id <PQResponse>)response withQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *responseId = response.responseId;
    NSString *key = authorId;
    
    // $userId/surveys/$surveyId/questions/$questionId/responses/$responseId/user
    NSURL *url = [NSURL fileURLWithPathComponents:@[authorId, PQFirebasePathSurveys, surveyId, PQFirebasePathQuestions, questionId, PQFirebasePathResponses, responseId, PQFirebasePathResponseUser]];
    id convertedUserId = [PQFirebaseSyncEngine convertObjectForFirebase:userId withEncryptionKey:key];
    [PQFirebaseSyncEngine saveObjectToFirebase:convertedUserId withPath:url.relativeString];
}

#pragma mark - // PRIVATE METHODS (Converters) //

+ (id)convertObjectForFirebase:(id)object withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)object;
        NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:array.count];
        id convertedObject;
        for (int i = 0; i < array.count; i++) {
            convertedObject = [PQFirebaseSyncEngine convertObjectForFirebase:array[i] withEncryptionKey:key];
            [convertedArray addObject:convertedObject];
        }
        
        if ([object isKindOfClass:[NSMutableArray class]]) {
            return convertedArray;
        }
        
        return [NSArray arrayWithArray:convertedArray];
    }
    
    if ([object isKindOfClass:[NSSet class]]) {
        NSSet *set = (NSSet *)object;
        NSMutableSet *convertedSet = [NSMutableSet setWithCapacity:set.count];
        id convertedObject;
        for (id object in set) {
            convertedObject = [PQFirebaseSyncEngine convertObjectForFirebase:object withEncryptionKey:key];
            [convertedSet addObject:convertedObject];
        }
        
        if ([object isKindOfClass:[NSMutableSet class]]) {
            return convertedSet;
        }
        
        return [NSSet setWithSet:convertedSet];
    }
    
    if ([object isKindOfClass:[NSOrderedSet class]]) {
        NSOrderedSet *orderedSet = (NSOrderedSet *)object;
        NSMutableOrderedSet *convertedOrderedSet = [NSMutableOrderedSet orderedSetWithCapacity:orderedSet.count];
        id convertedObject;
        for (int i = 0; i < orderedSet.count; i++) {
            convertedObject = [PQFirebaseSyncEngine convertObjectForFirebase:orderedSet[i] withEncryptionKey:key];
            [convertedOrderedSet addObject:convertedObject];
        }
        
        if ([object isKindOfClass:[NSMutableOrderedSet class]]) {
            return convertedOrderedSet;
        }
        
        return [NSOrderedSet orderedSetWithOrderedSet:convertedOrderedSet];
    }
    
    if ([object conformsToProtocol:@protocol(PQSurvey)]) {
        return [PQFirebaseSyncEngine convertSurveyForFirebase:object withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQQuestion)]) {
        return [PQFirebaseSyncEngine convertQuestionForFirebase:object withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQChoice)]) {
        return [PQFirebaseSyncEngine convertChoiceForFirebase:object withEncryptionKey:key];
    }
    
    if ([object conformsToProtocol:@protocol(PQResponse)]) {
        return [PQFirebaseSyncEngine convertResponseForFirebase:object withEncryptionKey:key];
    }
    
    if ([object isKindOfClass:[NSDate class]]) {
        return [PQFirebaseSyncEngine convertDateForFirebase:object];
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return [object encryptWithKey:key];
    }
    
    return object;
}

+ (id)convertSurveyForFirebase:(id <PQSurvey>)survey withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSNumber *enabled = [NSNumber numberWithBool:survey.enabled];
    NSNumber *repeat = [NSNumber numberWithBool:survey.repeat];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
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
    dictionary[PQFirebasePathQuestions] = convertedQuestions;
    dictionary[PQFirebasePathSurveyOrder] = order;
    
    return dictionary;
}

+ (id)convertQuestionForFirebase:(id <PQQuestion>)question withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSNumber *secure = [NSNumber numberWithBool:question.secure];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathQuestionCreatedAt] = [PQFirebaseSyncEngine convertObjectForFirebase:question.createdAt withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionSecure] = [PQFirebaseSyncEngine convertObjectForFirebase:secure withEncryptionKey:key];
    dictionary[PQFirebasePathQuestionText] = [PQFirebaseSyncEngine convertObjectForFirebase:question.text withEncryptionKey:key];
    
    NSMutableDictionary *convertedChoices = [NSMutableDictionary dictionary];
    NSUInteger index;
    NSString *indexString;
    for (id <PQChoice> choice in question.choices) {
        index = [question.choices indexOfObject:choice];
        indexString = [NSString stringWithFormat:@"%i", index];
        convertedChoices[indexString] = [PQFirebaseSyncEngine convertObjectForFirebase:choice withEncryptionKey:key];
    }
    dictionary[PQFirebasePathChoices] = convertedChoices;
    
    NSMutableDictionary *convertedResponses = [NSMutableDictionary dictionary];
    for (id <PQResponse> response in question.responses) {
        convertedResponses[response.responseId] = [PQFirebaseSyncEngine convertObjectForFirebase:response withEncryptionKey:key];
    }
    dictionary[PQFirebasePathResponses] = convertedResponses;
    
    return dictionary;
}

+ (id)convertChoiceForFirebase:(id <PQChoice>)choice withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSNumber *textInput = [NSNumber numberWithBool:choice.textInput];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathChoiceText] = [PQFirebaseSyncEngine convertObjectForFirebase:choice.text withEncryptionKey:key];
    dictionary[PQFirebasePathChoiceTextInput] = [PQFirebaseSyncEngine convertObjectForFirebase:textInput withEncryptionKey:key];
    return dictionary;
}

+ (id)convertResponseForFirebase:(id <PQResponse>)response withEncryptionKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[PQFirebasePathResponseDate] = [PQFirebaseSyncEngine convertObjectForFirebase:response.date withEncryptionKey:key];
    dictionary[PQFirebasePathResponseText] = [PQFirebaseSyncEngine convertObjectForFirebase:response.text withEncryptionKey:key];
    dictionary[PQFirebasePathResponseUser] = [PQFirebaseSyncEngine convertObjectForFirebase:response.userId withEncryptionKey:key];
    return dictionary;
}

+ (id)convertDateForFirebase:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    if (!date) {
        return nil;
    }
    
    NSString *uuid = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    return [uuid stringByReplacingOccurrencesOfString:@"." withString:@"-"];
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)surveyDictionary forSurveyWithId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
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
    convertedDictionary[NSStringFromSelector(@selector(name))] = [name decryptUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(repeat))] = surveyDictionary[PQFirebasePathSurveyRepeat];
    convertedDictionary[NSStringFromSelector(@selector(time))] = [PQFirebaseSyncEngine convertDateString:time];
    
    NSDictionary *questionDictionaries = surveyDictionary[PQFirebasePathQuestions];
    NSMutableOrderedSet *convertedQuestions = [NSMutableOrderedSet orderedSetWithCapacity:questionDictionaries.count];
    NSDictionary *questionDictionary;
    NSDictionary *convertedQuestion;
    for (NSString *questionId in questionDictionaries.allKeys) {
        questionDictionary = questionDictionaries[questionId];
        convertedQuestion = [PQFirebaseSyncEngine convertFirebaseDictionary:questionDictionary forQuestionWithId:questionId surveyId:surveyId authorId:authorId withKey:key];
        [convertedQuestions addObject:convertedQuestion];
    }
    convertedDictionary[NSStringFromSelector(@selector(questions))] = [NSOrderedSet orderedSetWithOrderedSet:convertedQuestions];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)questionDictionary forQuestionWithId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *createdAt = questionDictionary[PQFirebasePathQuestionCreatedAt];
    NSString *text = questionDictionary[PQFirebasePathQuestionText];
    
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(createdAt))] = [PQFirebaseSyncEngine convertDateString:createdAt];
    convertedDictionary[NSStringFromSelector(@selector(secure))] = questionDictionary[PQFirebasePathQuestionSecure];
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptUsingKey:key];
    
    NSArray *choiceDictionaries = questionDictionary[PQFirebasePathChoices];
    NSMutableOrderedSet *convertedChoices = [NSMutableOrderedSet orderedSetWithCapacity:choiceDictionaries.count];
    NSDictionary *choiceDictionary;
    NSDictionary *convertedChoice;
    for (int i = 0; i < choiceDictionaries.count; i++) {
        choiceDictionary = choiceDictionaries[i];
        convertedChoice = [PQFirebaseSyncEngine convertFirebaseDictionary:choiceDictionary forChoiceWithQuestionId:questionId surveyId:surveyId authorId:authorId withKey:key];
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
        [convertedResponses addObject:convertedResponse];
    }
    convertedDictionary[NSStringFromSelector(@selector(responses))] = [NSSet setWithSet:convertedResponses];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)choiceDictionary forChoiceWithQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *text = choiceDictionary[PQFirebasePathChoiceText];
    
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(textInput))] = choiceDictionary[PQFirebasePathChoiceTextInput];
    
    return convertedDictionary;
}

+ (NSDictionary *)convertFirebaseDictionary:(NSDictionary *)responseDictionary forResponseWithId:(NSString *)responseId questionId:(NSString *)questionId surveyId:(NSString *)surveyId authorId:(NSString *)authorId withKey:(NSString *)key {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    
    NSString *date = responseDictionary[PQFirebasePathResponseDate];
    NSString *text = responseDictionary[PQFirebasePathResponseText];
    NSString *userId = responseDictionary[PQFirebasePathResponseUser];
    
    convertedDictionary[NSStringFromSelector(@selector(responseId))] = responseId;
    convertedDictionary[NSStringFromSelector(@selector(questionId))] = questionId;
    convertedDictionary[NSStringFromSelector(@selector(surveyId))] = surveyId;
    convertedDictionary[NSStringFromSelector(@selector(authorId))] = authorId;
    convertedDictionary[NSStringFromSelector(@selector(date))] = [PQFirebaseSyncEngine convertDateString:date];
    convertedDictionary[NSStringFromSelector(@selector(text))] = [text decryptUsingKey:key];
    convertedDictionary[NSStringFromSelector(@selector(userId))] = [userId decryptUsingKey:key];
    
    return convertedDictionary;
}

+ (NSDate *)convertDateString:(NSString *)dateString {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    return [NSDate dateWithTimeIntervalSince1970:[dateString stringByReplacingOccurrencesOfString:@"-" withString:@"."].floatValue];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (void)saveObjectToFirebase:(id)object withPath:(NSString *)path {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQFirebaseController saveObject:object toPath:path withCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
    }];
}

@end
