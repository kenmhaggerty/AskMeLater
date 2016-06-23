//
//  PQLoginManager.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQLoginManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "FirebaseController+Auth.h"
#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const PQLoginManagerCurrentUserDidChangeNotification = @"kNotificationPQLoginManager_CurrentUserDidChange";
NSString * const PQLoginManagerEmailDidChangeNotification = @"kNotificationPQLoginManager_EmailDidChange";

@interface PQLoginManager ()
@property (nonatomic, strong) id <PQUser_PRIVATE> currentUser;

// GENERAL //

+ (instancetype)sharedManager;
+ (void)setCurrentUser:(id <PQUser_PRIVATE>)currentUser;

// OBSERVERS //

- (void)addObserversToFirebase;
- (void)removeObserversFromFirebase;
- (void)addObserversToUser:(id <PQUser>)user;
- (void)removeObserversFromUser:(id <PQUser>)user;

// RESPONDERS //

- (void)firebaseUserDidChange:(NSNotification *)notification;
- (void)firebaseEmailDidChange:(NSNotification *)notification;
- (void)currentUserEmailDidChange:(NSNotification *)notification;

// OTHER //

+ (void)setCurrentUserUsingInfo:(id <FIRUserInfo>)userInfo;
+ (void)updateUser:(id <PQUser_PRIVATE>)user withInfo:(id <FIRUserInfo>)userInfo;

@end

@implementation PQLoginManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(id <PQUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    if ([AKGenerics object:currentUser isEqualToObject:_currentUser]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithNullableObject:currentUser forKey:NOTIFICATION_OBJECT_KEY];
    [userInfo setNullableObject:_currentUser forKey:NOTIFICATION_OLD_KEY];
    
    if (_currentUser) {
        [self removeObserversFromUser:_currentUser];
    }
    
    _currentUser = currentUser;
    
    if (currentUser) {
        [self addObserversToUser:currentUser];
    }
    
    [NSNotificationCenter postNotificationToMainThread:PQLoginManagerCurrentUserDidChangeNotification object:nil userInfo:userInfo];
}

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
    
    if (![PQLoginManager sharedManager]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not initialize %@", NSStringFromClass([PQLoginManager class])]];
    }
    
    [PQLoginManager setCurrentUserUsingInfo:[FirebaseController userInfo]];
}

+ (id <PQUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    id <FIRUserInfo> userInfo = [FirebaseController userInfo];
    [PQLoginManager setCurrentUserUsingInfo:userInfo];
    return [PQLoginManager sharedManager].currentUser;
}

+ (void)signUpAndLogInWithEmail:(NSString *)email password:(NSString *)password failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController signUpAndLogInWithEmail:email password:password failure:failureBlock];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController signInWithEmail:email password:password failure:failureBlock];
}

+ (void)resetPasswordForEmail:(NSString *)email success:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController resetPasswordForUserWithEmail:email withCompletionBlock:^(NSError *error) {
        if (error) {
            failureBlock(error);
            return;
        }
        
        successBlock();
    }];
}

+ (void)updateEmailForCurrentUser:(NSString *)email withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController updateEmailForCurrentUser:email withCompletionBlock:^(NSError *error) {
        if (error) {
            failureBlock(error);
            return;
        }
        
        successBlock();
    }];
}

+ (void)updatePasswordForCurrentUser:(NSString *)password withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController updatePasswordForCurrentUser:password withCompletionBlock:^(NSError *error) {
        if (error) {
            failureBlock(error);
            return;
        }
        
        successBlock();
    }];
}

+ (void)logoutWithCompletion:(void (^)(NSError *error))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [FirebaseController signOutWithCompletion:completionBlock];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self addObserversToFirebase];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self removeObserversFromFirebase];
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)sharedManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    static PQLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PQLoginManager alloc] init];
    });
    return _sharedManager;
}

+ (void)setCurrentUser:(id <PQUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [PQLoginManager sharedManager].currentUser = currentUser;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [NSNotificationCenter addObserver:self selector:@selector(firebaseUserDidChange:) name:FirebaseUserDidChangeNotification object:nil];
    [NSNotificationCenter addObserver:self selector:@selector(firebaseEmailDidChange:) name:FirebaseEmailDidChangeNotification object:nil];
}

- (void)removeObserversFromFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [NSNotificationCenter removeObserver:self name:FirebaseUserDidChangeNotification object:nil];
    [NSNotificationCenter removeObserver:self name:FirebaseEmailDidChangeNotification object:nil];
}

- (void)addObserversToUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserEmailDidChange:) name:PQUserEmailDidChangeNotification object:user];
}

- (void)removeObserversFromUser:(id <PQUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQUserEmailDidChangeNotification object:user];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)firebaseUserDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    id <FIRUserInfo> userInfo = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQLoginManager setCurrentUserUsingInfo:userInfo];
}

- (void)firebaseEmailDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    NSString *email = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [PQLoginManager currentUser].email = email;
}

- (void)currentUserEmailDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [NSNotificationCenter postNotificationToMainThread:PQLoginManagerEmailDidChangeNotification object:nil userInfo:notification.userInfo];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (void)setCurrentUserUsingInfo:(id <FIRUserInfo>)userInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if (!userInfo) {
        [PQLoginManager setCurrentUser:nil];
        return;
    }
    
    NSString *userId = userInfo.uid;
    
    id <PQUser_PRIVATE> currentUser = [PQLoginManager sharedManager].currentUser;
    if (currentUser && [currentUser.userId isEqualToString:userId]) {
        return;
    }
    
    currentUser = [PQCoreDataController getUserWithId:userId];
    if (!currentUser) {
        NSString *email = userInfo.email;
        currentUser = [PQCoreDataController userWithUserId:userId email:email];
    }
    [PQLoginManager updateUser:currentUser withInfo:userInfo];
    [PQCoreDataController save];
    [PQLoginManager setCurrentUser:currentUser];
}

+ (void)updateUser:(id <PQUser_PRIVATE>)user withInfo:(id<FIRUserInfo>)userInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *email = userInfo.email;
//    NSString *username;
//    NSString *profileImageURL = dictionary[FirebaseAuthKeyProfileImageURL];
    
    user.email = email;
//    user.username = username;
//    if (profileImageURL) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImageURL]];
//            user.avatar = [UIImage imageWithData:imageData];
//        });
//    }
}

@end
