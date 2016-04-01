//
//  AMLLoginManager.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLLoginManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLFirebaseController+Auth.h"
#import "AMLCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const AMLLoginManagerCurrentUserDidChangeNotification = @"kNotificationAMLLoginManager_CurrentUserDidChange";
NSString * const AMLLoginManagerEmailDidChangeNotification = @"kNotificationAMLLoginManager_EmailDidChange";

@interface AMLLoginManager ()
@property (nonatomic, strong) id <AMLUser_PRIVATE> currentUser;

// GENERAL //

+ (instancetype)sharedManager;
+ (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser;

// OBSERVERS //

- (void)addObserversToFirebase;
- (void)removeObserversFromFirebase;
- (void)addObserversToUser:(id <AMLUser>)user;
- (void)removeObserversFromUser:(id <AMLUser>)user;

// RESPONDERS //

- (void)firebaseEmailDidChange:(NSNotification *)notification;
- (void)currentUserEmailDidChange:(NSNotification *)notification;

// OTHER //

+ (id <AMLUser_Editable>)setCurrentUserUsingAuthData:(NSDictionary *)authData;
+ (void)updateUser:(id <AMLUser_Editable>)user withDictionary:(NSDictionary *)dictionary;

@end

@implementation AMLLoginManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    if ([AKGenerics object:currentUser isEqualToObject:_currentUser]) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentUser) {
        [userInfo setObject:currentUser forKey:NOTIFICATION_OBJECT_KEY];
    }
    
    if (_currentUser) {
        [self removeObserversFromUser:_currentUser];
    }
    
    _currentUser = currentUser;
    
    if (currentUser) {
        [self addObserversToUser:currentUser];
    }
    
    [AKGenerics postNotificationName:AMLLoginManagerCurrentUserDidChangeNotification object:nil userInfo:userInfo];
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

+ (id <AMLUser_Editable>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    NSDictionary *authData = [AMLFirebaseController authData];
    return [AMLLoginManager setCurrentUserUsingAuthData:authData];
}

+ (void)signUpWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController signUpWithEmail:email password:password success:^(NSDictionary *result) {
        
        [AMLLoginManager loginWithEmail:email password:password success:successBlock failure:failureBlock];
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id <AMLUser_Editable>))successBlock failure:(void (^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController loginUserWithEmail:email password:password success:^(NSDictionary *userInfo) {
        id <AMLUser_Editable> currentUser = [AMLLoginManager setCurrentUserUsingAuthData:userInfo];
        successBlock(currentUser);
        
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)updateEmail:(NSString *)email password:(NSString *)password withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    id <AMLUser_Editable> currentUser = (id <AMLUser_Editable>)[AMLLoginManager currentUser];
    NSString *currentEmail = currentUser.email;
    
    [AMLFirebaseController changeEmailForUserWithEmail:currentEmail password:password toNewEmail:email withCompletionBlock:^(NSError *error) {
        if (error) {
            failureBlock(error);
        }
        else {
            successBlock();
        }
    }];
}

+ (void)updatePassword:(NSString *)oldPassword toPassword:(NSString *)newPassword withSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *))failureBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    id <AMLUser_Editable> currentUser = (id <AMLUser_Editable>)[AMLLoginManager currentUser];
    NSString *email = currentUser.email;
    
    [AMLFirebaseController changePasswordForUserWithEmail:email fromOld:oldPassword toNew:newPassword withCompletionBlock:^(NSError *error) {
        if (error) {
            failureBlock(error);
        }
        else {
            successBlock();
        }
    }];
}

+ (void)logout {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLFirebaseController logout];
    [AMLLoginManager setCurrentUser:nil];
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
    
    static AMLLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[AMLLoginManager alloc] init];
    });
    return _sharedManager;
}

+ (void)setCurrentUser:(id <AMLUser_PRIVATE>)currentUser {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [AMLLoginManager sharedManager].currentUser = currentUser;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firebaseEmailDidChange:) name:AMLFirebaseEmailDidChangeNotification object:nil];
}

- (void)removeObserversFromFirebase {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLFirebaseEmailDidChangeNotification object:nil];
}

- (void)addObserversToUser:(id <AMLUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserEmailDidChange:) name:AMLUserEmailDidChangeNotification object:user];
}

- (void)removeObserversFromUser:(id <AMLUser>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLUserEmailDidChangeNotification object:user];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)firebaseEmailDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    NSString *email = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [AMLLoginManager currentUser].email = email;
}

- (void)currentUserEmailDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [AKGenerics postNotificationName:AMLLoginManagerEmailDidChangeNotification object:nil userInfo:notification.userInfo];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (id <AMLUser_Editable>)setCurrentUserUsingAuthData:(NSDictionary *)authData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if (!authData) {
        [AMLLoginManager setCurrentUser:nil];
        return nil;
    }
    
    NSString *userId = authData[FirebaseAuthKeyUID];
    
    id <AMLUser_PRIVATE> currentUser = [AMLLoginManager sharedManager].currentUser;
    if (currentUser && [currentUser.userId isEqualToString:userId]) {
        return currentUser;
    }
    
    currentUser = [AMLCoreDataController userWithUserId:userId];
    if (!currentUser) {
        NSString *email = authData[FirebaseAuthKeyEmail];
        currentUser = [AMLCoreDataController userWithUserId:userId email:email];
    }
    [AMLLoginManager updateUser:currentUser withDictionary:authData];
    [AMLCoreDataController save];
    [AMLLoginManager setCurrentUser:currentUser];
    return currentUser;
}

+ (void)updateUser:(id <AMLUser_Editable>)user withDictionary:(NSDictionary *)dictionary {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    NSString *email = dictionary[FirebaseAuthKeyEmail];
//    NSString *username;
    NSString *profileImageURL = dictionary[FirebaseAuthKeyProfileImageURL];
    
    user.email = email;
//    user.username = username;
    if (profileImageURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImageURL]];
            user.avatar = [UIImage imageWithData:imageData];
        });
    }
}

@end
