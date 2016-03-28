//
//  AMLDataManager.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/5/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLDataManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLLoginManager.h"
#import "AMLCoreDataController.h"
#import "AMLFirebaseController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLDataManager ()

// CONVERTERS //

+ (AMLUser *)convertUser:(id <AMLUser>)user;
+ (AMLSurvey *)convertSurvey:(id <AMLSurvey>)survey;
+ (AMLQuestion *)convertQuestion:(id <AMLQuestion>)question;

// OTHER //

+ (NSOrderedSet <AMLChoice *> *)choices;

@end

@implementation AMLDataManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:nil];
    
    [AMLFirebaseController setup];
}

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    [AMLCoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Surveys) //

+ (id <AMLSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *name = nil;
    AMLUser *author = [AMLDataManager convertUser:[AMLLoginManager currentUser]];
    id <AMLSurvey_Editable> survey = [AMLCoreDataController surveyWithName:name author:author];
    [AMLCoreDataController save];
    return survey;
}

+ (NSSet <id <AMLSurvey>> *)surveysAuthoredByUser:(id <AMLUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    AMLUser *author = [AMLDataManager convertUser:user];
    return (NSSet <id <AMLSurvey>> *)[AMLCoreDataController surveysWithAuthor:author];
}

+ (void)deleteSurvey:(id <AMLSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [AMLCoreDataController deleteObject:[AMLDataManager convertSurvey:survey]];
}

#pragma mark - // PUBLIC METHODS (Questions) //

+ (id <AMLQuestion_Editable>)questionForSurvey:(id <AMLSurvey_Editable>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *text = nil;
    NSOrderedSet <AMLChoice *> *choices = [AMLDataManager choices];
    id <AMLQuestion_Editable> question = [AMLCoreDataController questionWithText:text choices:choices];
    [survey addQuestion:question];
    [AMLCoreDataController save];
    return question;
}

+ (void)deleteQuestion:(id <AMLQuestion_Editable>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_DATA] message:nil];
    
    [AMLCoreDataController deleteObject:[AMLDataManager convertQuestion:question]];
    [AMLCoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Debugging) //

+ (void)test {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    AMLFirebaseQuery *query = [AMLFirebaseQuery queryWithKey:@"hidden" relation:AMLKeyIsEqualTo value:@NO];
    [AMLFirebaseController getObjectsAtPath:@"users" withQueries:@[query] andCompletion:^(id result) {
        //
    }];
}

#pragma mark - // CATEGORY METHODS (Firebase) //

+ (BOOL)isConnectedToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:nil message:nil];
    
    return [AMLFirebaseController isConnected];
}

+ (void)connectToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [AMLFirebaseController connect];
}

+ (void)disconnectFromFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [AMLFirebaseController disconnect];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Converters) //

+ (AMLUser *)convertUser:(id <AMLUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([user isKindOfClass:[AMLUser class]]) {
        return (AMLUser *)user;
    }
    
    return nil;
}

+ (AMLSurvey *)convertSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([survey isKindOfClass:[AMLSurvey class]]) {
        return (AMLSurvey *)survey;
    }
    
    return nil;
}

+ (AMLQuestion *)convertQuestion:(id <AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if ([question isKindOfClass:[AMLQuestion class]]) {
        return (AMLQuestion *)question;
    }
    
    return nil;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSOrderedSet <AMLChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    AMLChoice *primaryChoice = [AMLCoreDataController choiceWithText:@"👍"];
    AMLChoice *secondaryChoice = [AMLCoreDataController choiceWithText:@"👎"];
    return [NSOrderedSet orderedSetWithArray:@[primaryChoice, secondaryChoice]];
}

@end
