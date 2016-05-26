//
//  PQDataManager.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQDataManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQLoginManager.h"
#import "PQCoreDataController.h"
#import "PQSyncEngine.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQDataManagerIsSyncingDidChangeNotification = @"kNotificationPQDataManager_IsSyncingDidChange";

@interface PQDataManager ()
@property (nonatomic) BOOL isSyncing;

// GENERAL //

+ (instancetype)sharedManager;

// CONVERTERS //

+ (PQUser *)convertUser:(id <PQUser>)user;
+ (PQSurvey *)convertSurvey:(id <PQSurvey>)survey;
+ (PQQuestion *)convertQuestion:(id <PQQuestion>)question;
+ (PQResponse *)convertResponse:(id <PQResponse>)response;
+ (id <PQSurvey>)surveyForQuestion:(id <PQQuestion>)question;

// OTHER //

+ (NSOrderedSet <PQChoice *> *)choices;

@end

@implementation PQDataManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setIsSyncing:(BOOL)isSyncing {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    if (isSyncing == _isSyncing) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isSyncing] forKey:NOTIFICATION_OBJECT_KEY];
    
    _isSyncing = isSyncing;
    
    [AKGenerics postNotificationName:PQDataManagerIsSyncingDidChangeNotification object:nil userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    if (![PQDataManager sharedManager]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not initialize %@", NSStringFromClass([PQDataManager class])]];
    }
    
    [PQSyncEngine setup];
    [PQLoginManager setup];
}

+ (BOOL)isSyncing {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    return [PQDataManager sharedManager].isSyncing;
}

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Surveys) //

+ (id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *name = nil;
    id <PQUser_PRIVATE> author = (id <PQUser_PRIVATE>)[PQLoginManager currentUser];
    id <PQSurvey_Editable> survey = [PQCoreDataController surveyWithName:name authorId:author.userId];
    [PQCoreDataController save];
    return survey;
}

+ (NSSet *)getSurveysAuthoredByUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    id <PQUser_PRIVATE> author = (id <PQUser_PRIVATE>)user;
    return [PQCoreDataController getSurveysWithAuthorId:author.userId];
}

+ (void)fetchSurveysWithCompletion:(void(^)(BOOL fetched))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    [PQDataManager sharedManager].isSyncing = YES;
    [PQSyncEngine fetchSurveysWithCompletion:^(BOOL fetched){
        [PQDataManager sharedManager].isSyncing = NO;
        completionBlock(fetched);
    }];
}

+ (void)deleteSurvey:(id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController deleteObject:[PQDataManager convertSurvey:survey]];
}

#pragma mark - // PUBLIC METHODS (Questions) //

+ (id <PQQuestion_Editable>)questionForSurvey:(id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *text = nil;
    NSOrderedSet <PQChoice *> *choices = [PQDataManager choices];
    id <PQQuestion_Editable> question = [PQCoreDataController questionWithText:text choices:choices];
    [survey addQuestion:question];
    return question;
}

+ (id <PQQuestion>)getQuestionWithId:(NSString *)uuid {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    return [PQCoreDataController getQuestionWithId:uuid];
}

+ (void)deleteQuestion:(id <PQQuestion_Editable>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController deleteObject:[PQDataManager convertQuestion:question]];
    [PQCoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Responses) //

+ (void)addResponse:(NSString *)text forQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    id <PQUser> currentUser = [PQLoginManager currentUser];
    PQResponse *response = [PQCoreDataController responseWithText:text userId:currentUser.userId date:[NSDate date]];
    [(id <PQQuestion_PRIVATE>)question addResponse:response];
    
    [PQSyncEngine didRespondToQuestion:question];
    [PQDataManager save];
}

+ (void)deleteResponse:(id <PQResponse>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController deleteObject:[PQDataManager convertResponse:response]];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [super setup];
    
    self.isSyncing = NO;
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static PQDataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PQDataManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - // PRIVATE METHODS (Converters) //

+ (PQUser *)convertUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([user isKindOfClass:[PQUser class]]) {
        return (PQUser *)user;
    }
    
    return nil;
}

+ (PQSurvey *)convertSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([survey isKindOfClass:[PQSurvey class]]) {
        return (PQSurvey *)survey;
    }
    
    return nil;
}

+ (PQQuestion *)convertQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([question isKindOfClass:[PQQuestion class]]) {
        return (PQQuestion *)question;
    }
    
    return nil;
}

+ (PQResponse *)convertResponse:(id <PQResponse>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([response isKindOfClass:[PQResponse class]]) {
        return (PQResponse *)response;
    }
    
    return nil;
}

+ (id <PQSurvey>)surveyForQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    return [PQDataManager convertQuestion:question].survey;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSOrderedSet <PQChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    PQChoice *primaryChoice = [PQCoreDataController choiceWithText:@"👍"];
    PQChoice *secondaryChoice = [PQCoreDataController choiceWithText:@"👎"];
    return [NSOrderedSet orderedSetWithArray:@[primaryChoice, secondaryChoice]];
}

@end
