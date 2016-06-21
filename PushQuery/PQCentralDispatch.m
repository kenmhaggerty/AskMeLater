//
//  PQCentralDispatch.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQCentralDispatch+Delegates.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQLoginManager.h"
#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQCentralDispatchUpdatesDidBegin = @"kNotificationPQCentralDispatch_UpdatesDidBegin";
NSString * const PQCentralDispatchUpdatesProgressDidChange = @"kNotificationPQCentralDispatch_UpdatesProgressDidChange";
NSString * const PQCentralDispatchUpdatesDidFinish = @"kNotificationPQCentralDispatch_UpdatesDidFinish";

@interface PQCentralDispatch ()
@property (nonatomic, strong) id <PQLoginDelegate> loginDelegate;
@property (nonatomic) BOOL isUpdating;

// GENERAL //

+ (instancetype)sharedDispatch;

// CONVENIENCE //

+ (id <PQLoginDelegate>)loginDelegate;
+ (Class <PQAccountDelegate>)accountDelegate;

+ (BOOL)isUpdating;
+ (void)setIsUpdating:(BOOL)isUpdating;

// SETUP //

+ (void)migrateCoreDataWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

// OBSERVERS //

- (void)addObserversToCoreData;
- (void)removeObserversFromCoreData;

// RESPONDERS //

- (void)coreDataMigrationProgressDidChange:(NSNotification *)notification;

@end

@implementation PQCentralDispatch

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

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

+ (BOOL)requiresUpdates {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    return [PQCoreDataController needsMigration];
}

+ (void)startUpdates {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if ([PQCentralDispatch isUpdating]) {
        return;
    }
    
    [PQCentralDispatch setIsUpdating:YES];
    
    [NSNotificationCenter postNotificationToMainThread:PQCentralDispatchUpdatesDidBegin object:nil userInfo:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [PQCentralDispatch migrateCoreDataWithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [PQCentralDispatch setIsUpdating:NO];
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:error forKey:NOTIFICATION_OBJECT_KEY];
                [NSNotificationCenter postNotificationToMainThread:PQCentralDispatchUpdatesDidFinish object:nil userInfo:userInfo];
                
            });
        }];
    });
}

#pragma mark - // PUBLIC METHODS (Accounts) //

+ (id <PQUser>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    Class accountDelegate = [PQCentralDispatch accountDelegate];
    if (!accountDelegate) {
        return nil;
    }
    
    return [accountDelegate currentUser];
}

+ (void)requestLoginWithCompletion:(void(^)(id <PQUser> user))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    id <PQLoginDelegate> loginDelegate = [PQCentralDispatch loginDelegate];
    if (loginDelegate) {
        [loginDelegate requestLoginWithCompletion:completionBlock];
    }
}

+ (void)requestLogoutWithCompletion:(void (^)(BOOL))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    id <PQLoginDelegate> loginDelegate = [PQCentralDispatch loginDelegate];
    if (loginDelegate) {
        [loginDelegate requestLogoutWithCompletion:completionBlock];
    }
}

#pragma mark - // CATEGORY METHODS (Delegates) //

+ (void)setLoginDelegate:(id <PQLoginDelegate>)loginDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [PQCentralDispatch sharedDispatch].loginDelegate = loginDelegate;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super setup];
    
    self.isUpdating = NO;
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedDispatch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    static PQCentralDispatch *_sharedDispatch = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDispatch = [[PQCentralDispatch alloc] init];
    });
    return _sharedDispatch;
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id <PQLoginDelegate>)loginDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [PQCentralDispatch sharedDispatch].loginDelegate;
}

+ (Class <PQAccountDelegate>)accountDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [PQLoginManager class];
}

+ (BOOL)isUpdating {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    return [PQCentralDispatch sharedDispatch].isUpdating;
}

+ (void)setIsUpdating:(BOOL)isUpdating {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    [PQCentralDispatch sharedDispatch].isUpdating = isUpdating;
}

#pragma mark - // PRIVATE METHODS (Setup) //

+ (void)migrateCoreDataWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    PQCentralDispatch *sharedDispatch = [PQCentralDispatch sharedDispatch];
    
    [sharedDispatch addObserversToCoreData];
    
    NSError *error;
    BOOL success = [PQCoreDataController migrate:&error];
    
    [sharedDispatch removeObserversFromCoreData];
    
    completionBlock(success, error);
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCoreData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA, AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataMigrationProgressDidChange:) name:PQCentralDispatchUpdatesProgressDidChange object:nil];
}

- (void)removeObserversFromCoreData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA, AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQCentralDispatchUpdatesProgressDidChange object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)coreDataMigrationProgressDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA, AKD_NOTIFICATION_CENTER] message:nil];
    
    [NSNotificationCenter postNotificationToMainThread:PQCentralDispatchUpdatesProgressDidChange object:nil userInfo:notification.userInfo];
}

@end
