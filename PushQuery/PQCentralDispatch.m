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

#pragma mark - // DEFINITIONS (Private) //

@interface PQCentralDispatch ()
@property (nonatomic, strong) id <PQLoginDelegate> loginDelegate;
+ (instancetype)sharedDispatch;
+ (id <PQLoginDelegate>)loginDelegate;
+ (Class <PQAccountDelegate>)accountDelegate;
@end

@implementation PQCentralDispatch

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

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

#pragma mark - // CATEGORY METHODS (Delegates) //

+ (void)setLoginDelegate:(id <PQLoginDelegate>)loginDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [PQCentralDispatch sharedDispatch].loginDelegate = loginDelegate;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

+ (instancetype)sharedDispatch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    static PQCentralDispatch *_sharedDispatch = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDispatch = [[PQCentralDispatch alloc] init];
    });
    return _sharedDispatch;
}

+ (id <PQLoginDelegate>)loginDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [PQCentralDispatch sharedDispatch].loginDelegate;
}

+ (Class <PQAccountDelegate>)accountDelegate {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [PQLoginManager class];
}

@end
