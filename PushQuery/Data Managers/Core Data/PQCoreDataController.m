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

NSString * const PQCoreDataMigrationProgressDidChangeNotification = @"kNotificationPQCoreDataController_MigrationProgressDidChange";
NSString * const PQCoreDataWillSaveNotification = @"kNotificationPQCoreDataController_WillSave";

NSString * const PQCoreDataSourceStoreFilename = @"PushQuery.sqlite";

@interface PQCoreDataController ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMigrationManager *migrationManager;

// GENERAL //

+ (instancetype)sharedController;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL *)sourceStoreURL;
+ (NSString *)sourceStoreType;

+ (BOOL)objectExistsWithClass:(Class)class predicate:(NSPredicate *)predicate;
+ (NSManagedObject *)fetchObjectWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;
+ (NSArray <NSManagedObject *> *)fetchObjectsWithClass:(Class)class predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;

// UUID //

+ (NSString *)uuidWithValidator:(BOOL(^)(NSString *uuid))validationBlock;
+ (NSString *)surveyId;
+ (NSString *)questionId;
+ (NSString *)responseId;

// MIGRATION //

+ (void)setMigrationManager:(NSMigrationManager *)migrationManager;
+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError **)error;
+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata;
+ (NSArray *)modelPaths;
+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName;
+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error;

@end

@implementation PQCoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize migrationManager = _migrationManager;

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
    NSURL *sourceStoreURL = [PQCoreDataController sourceStoreURL];
    NSError *error;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sourceStoreURL options:nil error:&error]) {
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

- (void)setMigrationManager:(NSMigrationManager *)migrationManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQCoreDataController *sharedController = [PQCoreDataController sharedController];
    
    if (_migrationManager) {
        [migrationManager removeObserver:sharedController forKeyPath:NSStringFromSelector(@selector(migrationProgress))];
    }
    
    _migrationManager = migrationManager;
    
    if (migrationManager) {
        [migrationManager addObserver:sharedController forKeyPath:NSStringFromSelector(@selector(migrationProgress)) options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (BOOL)needsMigration {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectModel *managedObjectModel = [PQCoreDataController managedObjectModel];
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[PQCoreDataController sourceStoreType] URL:[PQCoreDataController sourceStoreURL] error:nil];
    
    return ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
}

+ (BOOL)migrate:(NSError **)error {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    // Enable migrations to run even while user exits app
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    BOOL complete = [PQCoreDataController progressivelyMigrateURL:[PQCoreDataController sourceStoreURL] ofType:[PQCoreDataController sourceStoreType] toModel:[PQCoreDataController managedObjectModel] error:error];
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Migration %@", complete ? @"complete" : @"incomplete"]];
    
    // Mark it as invalid
    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
    
    return complete;
}

+ (void)save {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    if (managedObjectContext != nil) {
        
        [AKGenerics postNotificationName:PQCoreDataWillSaveNotification object:nil userInfo:nil];
        
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
        user.editedAt = user.createdAt;
        user.updatedAt = user.editedAt;
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
        survey.createdAt = [NSDate date];
        survey.editedAt = survey.createdAt;
        survey.updatedAt = survey.editedAt;
        survey.surveyId = [PQCoreDataController surveyId];
        survey.authorId = authorId;
        survey.name = name;
    }];
    
    return survey;
}

+ (PQQuestion *)questionWithText:(NSString *)text choices:(NSOrderedSet <PQChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block PQQuestion *question;
    [managedObjectContext performBlockAndWait:^{
        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:managedObjectContext];
        question.createdAt = [NSDate date];
        question.editedAt = question.createdAt;
        question.updatedAt = question.editedAt;
        question.questionId = [PQCoreDataController questionId];
        question.text = text;
        question.choices = choices;
        question.questionIndex = [PQCoreDataController questionIndexInManagedObjectContext:nil];
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
        choice.choiceIndex = [PQCoreDataController choiceIndexInManagedObjectContext:nil];
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

#pragma mark - // PUBLIC METHODS (Exists) //

+ (BOOL)surveyExistsWithId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(surveyId)), surveyId];
    
    return [PQCoreDataController objectExistsWithClass:[PQSurvey class] predicate:predicate];
}

+ (BOOL)questionExistsWithId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(questionId)), questionId];
    
    return [PQCoreDataController objectExistsWithClass:[PQQuestion class] predicate:predicate];
}

+ (BOOL)responseExistsWithId:(NSString *)responseId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_CORE_DATA] message:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(responseId)), responseId];
    
    return [PQCoreDataController objectExistsWithClass:[PQResponse class] predicate:predicate];
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

+ (PQUser *)userWithUserId:(NSString *)userId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQUser *user;
    [managedObjectContext performBlockAndWait:^{
        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQUser class]) inManagedObjectContext:managedObjectContext];
        user.userId = userId;
    }];
    
    return user;
}

+ (PQSurvey *)surveyWithSurveyId:(NSString *)surveyId authorId:(NSString *)authorId createdAt:(NSDate *)createdAt inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQSurvey *survey;
    [managedObjectContext performBlockAndWait:^{
        survey = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQSurvey class]) inManagedObjectContext:managedObjectContext];
        survey.createdAt = createdAt;
        survey.surveyId = surveyId;
        survey.authorId = authorId;
    }];
    
    return survey;
}

+ (PQQuestion *)questionWithQuestionId:(NSString *)questionId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQQuestion *question;
    [managedObjectContext performBlockAndWait:^{
        question = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestion class]) inManagedObjectContext:managedObjectContext];
        question.questionId = questionId;
        question.questionIndex = [PQCoreDataController questionIndexInManagedObjectContext:managedObjectContext];
    }];
    
    return question;
}

+ (PQChoice *)choiceInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQChoice *choice;
    [managedObjectContext performBlockAndWait:^{
        choice = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQChoice class]) inManagedObjectContext:managedObjectContext];
        choice.choiceIndex = [PQCoreDataController choiceIndexInManagedObjectContext:managedObjectContext];
    }];
    
    return choice;
}

+ (PQResponse *)responseWithResponseId:(NSString *)responseId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQResponse *response;
    [managedObjectContext performBlockAndWait:^{
        response = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQResponse class]) inManagedObjectContext:managedObjectContext];
        response.responseId = responseId;
    }];
    
    return response;
}

+ (PQQuestionIndex *)questionIndexInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQQuestionIndex *questionIndex;
    [managedObjectContext performBlockAndWait:^{
        questionIndex = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQQuestionIndex class]) inManagedObjectContext:managedObjectContext];
    }];
    
    return questionIndex;
}

+ (PQChoiceIndex *)choiceIndexInManagedObjectContext:(NSManagedObjectContext *)managedObjectContextOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = managedObjectContextOrNil ?: [PQCoreDataController managedObjectContext];
    __block PQChoiceIndex *choiceIndex;
    [managedObjectContext performBlockAndWait:^{
        choiceIndex = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PQChoiceIndex class]) inManagedObjectContext:managedObjectContext];
    }];
    
    return choiceIndex;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if ([AKGenerics object:object isEqualToObject:self.migrationManager]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(migrationProgress))]) {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ = %f", NSStringFromSelector(@selector(migrationProgress)), self.migrationManager.migrationProgress]];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:self.migrationManager.migrationProgress] forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQCoreDataMigrationProgressDidChangeNotification object:nil userInfo:userInfo];
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

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

+ (NSManagedObjectModel *)managedObjectModel {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [PQCoreDataController sharedController].managedObjectModel;
}

+ (NSURL *)applicationDocumentsDirectory {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.flatiron-school.learn.ios.PushQuery" in the application's documents directory.
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)sourceStoreURL {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [[PQCoreDataController applicationDocumentsDirectory] URLByAppendingPathComponent:PQCoreDataSourceStoreFilename];
}

+ (NSString *)sourceStoreType {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return NSSQLiteStoreType;
}

+ (BOOL)objectExistsWithClass:(Class)class predicate:(NSPredicate *)predicate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [PQCoreDataController managedObjectContext];
    __block NSUInteger count;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:managedObjectContext];
        request.predicate = predicate;
        count = [managedObjectContext countForFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    
    if (count > 1)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with given predicate", (unsigned long)count, NSStringFromClass(class)]];
    }
    return (count > 0);
}

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

#pragma mark - // PRIVATE METHODS (UUID) //

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

#pragma mark - // PRIVATE METHODS (Migration) //
// All migration code via Marcus Zarra and Objc.io //

+ (void)setMigrationManager:(NSMigrationManager *)migrationManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    [PQCoreDataController sharedController].migrationManager = migrationManager;
}

+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError **)error {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL error:error];
    
    if (!sourceMetadata) {
        return NO;
    }
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (NULL != error) {
            *error = nil;
        }
        return YES;
    }
    
    NSManagedObjectModel *sourceModel = [self sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel;
    NSMappingModel *mappingModel;
    NSString *modelName;
    if (![self getDestinationModel:&destinationModel mappingModel:&mappingModel modelName:&modelName forSourceModel:sourceModel error:error]) {
        return NO;
    }
    
//    NSArray *mappingModels = @[mappingModel];
//    if ([self.delegate respondsToSelector:@selector(migrationManager:mappingModelsForSourceModel:)]) {
//        NSArray *explicitMappingModels = [self.delegate migrationManager:self mappingModelsForSourceModel:sourceModel];
//        if (0 < explicitMappingModels.count) {
//            mappingModels = explicitMappingModels;
//        }
//    }
    
    // We have a mapping model, time to migrate
    NSURL *destinationStoreURL = [self destinationStoreURLWithSourceStoreURL:sourceStoreURL modelName:modelName];
    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
    
    [PQCoreDataController setMigrationManager:migrationManager];
    
    // Migrate
    BOOL success = [migrationManager migrateStoreFromURL:sourceStoreURL type:type options:nil withMappingModel:mappingModel toDestinationURL:destinationStoreURL destinationType:type destinationOptions:nil error:error];
    
    [PQCoreDataController setMigrationManager:nil];
    
    if (!success) {
        return NO;
    }
    
    // Migration was successful, move the files around to preserve the source in case things go bad
    if (![self backupSourceStoreAtURL:sourceStoreURL movingDestinationStoreAtURL:destinationStoreURL error:error]) {
        return NO;
    }
    
    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}

+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]] forStoreMetadata:sourceMetadata];
}

+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSArray *modelPaths = [self modelPaths];
    if (!modelPaths.count) {
        //Throw an error if there are no models
        if (NULL != error) {
            *error = [NSError errorWithDomain:@"PushQuery" code:8001 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No %@ found", stringFromVariable(modelPaths)]}];
        }
        return NO;
    }
    
    //See if we can find a matching destination model
    NSManagedObjectModel *model;
    NSMappingModel *mapping;
    NSString *modelPath;
    for (modelPath in modelPaths) {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]] forSourceModel:sourceModel destinationModel:model];
        //If we found a mapping model then proceed
        if (mapping) {
            break;
        }
    }
    //We have tested every model, if nil here we failed
    if (!mapping) {
        if (NULL != error) {
            *error = [NSError errorWithDomain:@"PushQuery" code:8001 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ is nil", stringFromVariable(mapping)]}];
        }
        return NO;
    }
    
    *destinationModel = model;
    *mappingModel = mapping;
    *modelName = modelPath.lastPathComponent.stringByDeletingPathExtension;
    return YES;
}

+ (NSArray *)modelPaths {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    for (NSString *momdPath in momdArray) {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    return modelPaths;
}

+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    // We have a mapping model, time to migrate
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:sourceStoreURL.path toPath:backupPath error:error]) {
        //Failed to copy the file
        return NO;
    }
    
    //Move the destination to the source path
    if (![fileManager moveItemAtPath:destinationStoreURL.path toPath:sourceStoreURL.path error:error]) {
        //Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath toPath:sourceStoreURL.path error:nil];
        return NO;
    }
    
    return YES;
}

@end
