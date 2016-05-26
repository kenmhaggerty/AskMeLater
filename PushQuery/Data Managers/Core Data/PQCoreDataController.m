//
//  PQCoreDataController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQCoreDataController+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import <CoreData/CoreData.h>

#pragma mark - // DEFINITIONS (Private) //

@interface PQCoreDataController ()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// GENERAL //

+ (instancetype)sharedController;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSURL *)applicationDocumentsDirectory;

// OTHER //
+ (NSManagedObject *)fetchObjectWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;
+ (NSArray <NSManagedObject *> *)fetchObjectsWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;

+ (NSString *)uuidWithValidator:(BOOL(^)(NSString *uuid))validationBlock;
+ (NSString *)surveyId;
+ (NSString *)questionId;
+ (NSString *)responseId;

@end

@implementation PQCoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:appName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[PQCoreDataController applicationDocumentsDirectory] URLByAppendingPathComponent:@"PushQuery.sqlite"];
    NSError *error;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - // PUBLIC METHODS (Initializers) //

+ (PQUser *)userWithUserId:(NSString *)userId email:(NSString *)email {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQUser *user;
    [managedObjectContext performBlockAndWait:^{
        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQUser class]) inManagedObjectContext:managedObjectContext];
        user.createdAt = [NSDate date];
        user.userId = userId;
        user.email = email;
    }];
    
    return user;
}

+ (PQSurvey *)surveyWithName:(NSString *)name authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQSurvey *survey;
    [managedObjectContext performBlockAndWait:^{
        survey = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQSurvey class]) inManagedObjectContext:managedObjectContext];
        survey.surveyId = [PQCoreDataController surveyId];
        survey.createdAt = [NSDate date];
        survey.editedAt = survey.createdAt;
        survey.name = name;
        survey.authorId = authorId;
    }];
    
    return survey;
}

+ (PQQuestion *)questionWithText:(NSString *)text choices:(NSOrderedSet <PQChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQQuestion *question;
    [managedObjectContext performBlockAndWait:^{
        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:managedObjectContext];
        question.questionId = [PQCoreDataController questionId];
        question.createdAt = [NSDate date];
        question.text = text;
        question.choices = choices;
    }];
    
    return question;
}

+ (PQChoice *)choiceWithText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQChoice *choice;
    [managedObjectContext performBlockAndWait:^{
        choice = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQChoice class]) inManagedObjectContext:managedObjectContext];
        choice.text = text;
    }];
    
    return choice;
}

+ (PQResponse *)responseWithText:(NSString *)text userId:(NSString *)userId date:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQResponse *response;
    [managedObjectContext performBlockAndWait:^{
        response = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQResponse class]) inManagedObjectContext:managedObjectContext];
        response.responseId = [PQCoreDataController responseId];
        response.text = text;
        response.userId = userId;
        response.date = date;
    }];
    
    return response;
}

#pragma mark - // PUBLIC METHODS (Getters) //

+ (PQUser *)getUserWithId:(NSString *)userId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(userId)), userId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt)) ascending:YES];
    
    return (PQUser *)[PQCoreDataController fetchObjectWithClass:[PQUser class] predicate:predicate sortDescriptors:@[sortDescriptor]];
}

+ (PQSurvey *)getSurveyWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(surveyId)), surveyId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt)) ascending:YES];
    
    return (PQSurvey *)[PQCoreDataController fetchObjectWithClass:[PQSurvey class] predicate:predicate sortDescriptors:@[sortDescriptor]];
}

+ (NSSet *)getSurveysWithAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(authorId)), authorId];
    
    return [NSSet setWithArray:[PQCoreDataController fetchObjectsWithClass:[PQSurvey class] predicate:predicate sortDescriptors:nil]];
}

+ (PQQuestion *)getQuestionWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(questionId)), questionId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt)) ascending:YES];
    
    return (PQQuestion *)[PQCoreDataController fetchObjectWithClass:[PQQuestion class] predicate:predicate sortDescriptors:@[sortDescriptor]];
}

+ (PQResponse *)getResponseWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(responseId)), responseId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(date)) ascending:YES];
    
    return (PQResponse *)[PQCoreDataController fetchObjectWithClass:[PQResponse class] predicate:predicate sortDescriptors:@[sortDescriptor]];
}

+ (NSSet *)getResponsesWithUserId:(NSString *)userId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(userId)), userId];
    
    return [NSSet setWithArray:[PQCoreDataController fetchObjectsWithClass:[PQResponse class] predicate:predicate sortDescriptors:nil]];
}

#pragma mark - // PUBLIC METHODS (Deletors) //

+ (void)deleteObject:(NSManagedObject *)object {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext deleteObject:object];
    }];
}

#pragma mark - // CATEGORY METHODS (PRIVATE) //

+ (PQUser *)userWithUserId:(NSString *)userId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQUser *user;
    [managedObjectContext performBlockAndWait:^{
        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQUser class]) inManagedObjectContext:managedObjectContext];
        user.userId = userId;
    }];
    
    return user;
}

+ (PQSurvey *)surveyWithSurveyId:(NSString *)surveyId authorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQSurvey *survey;
    [managedObjectContext performBlockAndWait:^{
        survey = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQSurvey class]) inManagedObjectContext:managedObjectContext];
        survey.surveyId = surveyId;
        survey.authorId = authorId;
    }];
    
    return survey;
}

+ (PQQuestion *)questionWithQuestionId:(NSString *)questionId surveyId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQQuestion *question;
    [managedObjectContext performBlockAndWait:^{
        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:managedObjectContext];
        question.questionId = questionId;
        question.surveyId = surveyId;
    }];
    
    return question;
}

+ (PQResponse *)responseWithResponseId:(NSString *)responseId questionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQResponse *response;
    [managedObjectContext performBlockAndWait:^{
        response = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQResponse class]) inManagedObjectContext:managedObjectContext];
        response.responseId = responseId;
        response.questionId = questionId;
    }];
    
    return response;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedController {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    static PQCoreDataController *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[PQCoreDataController alloc] init];
    });
    return _sharedController;
}

+ (NSManagedObjectContext *)managedObjectContext {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [PQCoreDataController sharedController].managedObjectContext;
}

+ (NSURL *)applicationDocumentsDirectory {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.flatiron-school.learn.ios.PushQuery" in the application's documents directory.
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSManagedObject *)fetchObjectWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSArray *foundObjects = [PQCoreDataController fetchObjectsWithClass:class predicate:predicate sortDescriptors:sortDescriptors];
    
    if (foundObjects.count > 1)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu objects with class %@ and given %@; returning first object", (unsigned long)foundObjects.count, NSStringFromClass(class), stringFromVariable(predicate)]];
    }
    return [foundObjects firstObject];
}

+ (NSArray <NSManagedObject *> *)fetchObjectsWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block NSArray *foundObjects;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:managedObjectContext];
        request.predicate = predicate;
        request.sortDescriptors = sortDescriptors;
        foundObjects = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!foundObjects)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(foundResponses)]];
        return nil;
    }
    
    return foundObjects;
}

+ (NSString *)uuidWithValidator:(BOOL(^)(NSString *uuid))validationBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    NSString *uuid;
    do {
        uuid = [NSUUID UUID].UUIDString;
    } while (!validationBlock(uuid));
    return uuid;
}

+ (NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    return [PQCoreDataController uuidWithValidator:^BOOL(NSString *uuid) {
        return [PQCoreDataController getSurveyWithId:uuid] ? NO : YES;
    }];
}

+ (NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    return [PQCoreDataController uuidWithValidator:^BOOL(NSString *uuid) {
        return [PQCoreDataController getQuestionWithId:uuid] ? NO : YES;
    }];
}

+ (NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_DATA] message:nil];
    
    return [PQCoreDataController uuidWithValidator:^BOOL(NSString *uuid) {
        return [PQCoreDataController getResponseWithId:uuid] ? NO : YES;
    }];
}

@end
