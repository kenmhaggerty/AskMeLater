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
#import "PQFirebaseController.h"
#import "PQNotificationsManager.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQDataManager ()

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

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [PQFirebaseController setup];
    [PQNotificationsManager setup];
}

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Surveys) //

+ (id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *name = nil;
    PQUser *author = [PQDataManager convertUser:[PQLoginManager currentUser]];
    id <PQSurvey_Editable> survey = [PQCoreDataController surveyWithName:name author:author];
    [PQCoreDataController save];
    return survey;
}

+ (NSSet <id <PQSurvey>> *)surveysAuthoredByUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    PQUser *author = [PQDataManager convertUser:user];
    return (NSSet <id <PQSurvey>> *)[PQCoreDataController surveysWithAuthor:author];
}

+ (void)deleteSurvey:(id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController deleteObject:[PQDataManager convertSurvey:survey]];
}

#pragma mark - // PUBLIC METHODS (Questions) //

+ (id <PQQuestion>)questionWithId:(NSString *)uuid {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    return [PQCoreDataController questionWithId:uuid];
}

+ (id <PQQuestion_Editable>)questionForSurvey:(id <PQSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *text = nil;
    NSOrderedSet <PQChoice *> *choices = [PQDataManager choices];
    id <PQQuestion_Editable> question = [PQCoreDataController questionWithText:text choices:choices];
    [survey addQuestion:question];
    [PQCoreDataController save];
    return question;
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
    PQResponse *response = [PQCoreDataController responseWithText:text user:[PQDataManager convertUser:currentUser] date:[NSDate date]];
    [(id <PQQuestion_PRIVATE>)question addResponse:response];
    
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)[PQDataManager surveyForQuestion:question];
    if (![survey.questions.lastObject isEqual:question]) {
        id <PQQuestion_PRIVATE> nextQuestion = (id <PQQuestion_PRIVATE>)[survey.questions objectAtIndex:[survey.questions indexOfObject:question]+1];
        NSMutableArray <UIMutableUserNotificationAction *> *actions = [NSMutableArray arrayWithCapacity:nextQuestion.choices.count];
        for (id <PQChoice> choice in nextQuestion.choices) {
            [actions addObject:[PQNotificationsManager notificationActionWithTitle:choice.text textInput:NO destructive:NO authentication:NO]];
        }
        [PQNotificationsManager setNotificationWithTitle:survey.name body:nextQuestion.text actions:actions actionString:PQNotificationActionString uuid:nextQuestion.uuid fireDate:nil repeat:NO];
    }
    else if (!survey.repeat) {
        survey.enabled = NO;
    }
    [PQDataManager save];
}

+ (void)deleteResponse:(id <PQResponse>)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [PQCoreDataController deleteObject:[PQDataManager convertResponse:response]];
}

#pragma mark - // PUBLIC METHODS (Debugging) //

+ (void)test {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    PQFirebaseQuery *query = [PQFirebaseQuery queryWithKey:@"hidden" relation:PQKeyIsEqualTo value:@NO];
    [PQFirebaseController getObjectsAtPath:@"users" withQueries:@[query] andCompletion:^(id result) {
        //
    }];
}

#pragma mark - // CATEGORY METHODS (Firebase) //

+ (BOOL)isConnectedToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:nil message:nil];
    
    return [PQFirebaseController isConnected];
}

+ (void)connectToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [PQFirebaseController connect];
}

+ (void)disconnectFromFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [PQFirebaseController disconnect];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

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
