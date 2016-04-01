//
//  ViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "ViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AMLPrivateInfo.h"

#import "AMLLoginManager.h"
#import "AMLDataManager.h"
#import "AMLCoreDataController.h" // temp
#import "AMLDataManager.h"

#pragma mark - // DEFINITIONS (Private) //

@interface ViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UILabel *connection;
@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UILabel *email;
@property (nonatomic, strong) IBOutlet UIButton *connect;
@property (nonatomic, strong) id <AMLUser_Editable> user;

// ACTIONS //

- (IBAction)signIn:(UIButton *)sender;
- (IBAction)info:(id)sender;
- (IBAction)test:(id)sender;
- (IBAction)connect:(id)sender;

// GENERAL //

- (void)isConnected:(BOOL)isConnected;

// OBSERVERS //

- (void)addObserversToDataManager;
- (void)removeObserversFromDataManager;

// RESPONDERS //

- (void)firebaseConnectionDidChange:(NSNotification *)notification;

@end

@implementation ViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize user = _user;

- (void)setUser:(id <AMLUser_Editable>)user {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    _user = user;
    
    self.username.text = user.username;
    self.email.text = user.email;
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITextFieldDelgate) //

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    [textField resignFirstResponder];
    if (![AKGenerics object:textField isEqualToObject:self.username]) {
        return NO;
    }
    
    self.user.username = textField.text;
    [AMLCoreDataController save];
    return NO;
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    [self addObserversToDataManager];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self removeObserversFromDataManager];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)signIn:(UIButton *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    if (self.user) {
        self.user = nil;
        [AMLLoginManager logout];
        [sender setTitle:@"Sign In" forState:UIControlStateNormal];
    }
    else {
        [AMLLoginManager loginWithEmail:FirebaseAPITestEmail password:FirebaseAPITestPassword success:^(id <AMLUser_Editable> currentUser) {
            self.user = currentUser;
            [sender setTitle:@"Sign Out" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            self.email.text = error.localizedDescription;
        }];
    }
}

- (IBAction)info:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    //
}

- (IBAction)test:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    [AMLDataManager test];
}

- (IBAction)connect:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
//    [AMLDataManager isConnectedToFirebase:^(BOOL connected) {
//        if (connected) {
//            [AMLDataManager disconnectFromFirebase];
//        }
//        else {
//            [AMLDataManager connectToFirebase];
//        }
//    }];
    
    if ([AMLDataManager isConnectedToFirebase]) {
        [AMLDataManager disconnectFromFirebase];
    }
    else {
        [AMLDataManager connectToFirebase];
    }
}

#pragma mark - // PRIVATE METHODS (General) //

- (void)isConnected:(BOOL)isConnected {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    self.connection.text = (isConnected ? @"YES" : @"NO");
    [self.connect setTitle:(isConnected ? @"Disconnect" : @"Connect") forState:UIControlStateNormal];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToDataManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firebaseConnectionDidChange:) name:AMLFirebaseIsConnectedDidChangeNotification object:nil];
}

- (void)removeObserversFromDataManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLFirebaseIsConnectedDidChangeNotification object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)firebaseConnectionDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    BOOL isConnected = ((NSNumber *)notification.userInfo[NOTIFICATION_OBJECT_KEY]).boolValue;
    [self isConnected:isConnected];
}

@end
