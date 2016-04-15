//
//  PQRootViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQRootViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQLoginUIProtocol.h"
#import "UIAlertController+Info.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const SEGUE_LOGIN = @"segueLogin";

@interface PQRootViewController ()
@property (nonatomic, strong) UIAlertController *alertConfirmLogout;
@end

@implementation PQRootViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize alertConfirmLogout = _alertConfirmLogout;

- (UIAlertController *)alertConfirmLogout {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertConfirmLogout) {
        return _alertConfirmLogout;
    }
    
    _alertConfirmLogout = [UIAlertController alertControllerWithTitle:nil message:@"Signing out will disable all of your currently enabled surveys." preferredStyle:UIAlertControllerStyleActionSheet];
    [_alertConfirmLogout addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        void (^completionBlock)(BOOL success) = _alertConfirmLogout.info[NOTIFICATION_OBJECT_KEY];
        if (completionBlock) {
            completionBlock(NO);
        }
    }]];
    [_alertConfirmLogout addAction:[UIAlertAction actionWithTitle:@"Disable Surveys & Sign Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        void (^completionBlock)(BOOL success) = _alertConfirmLogout.info[NOTIFICATION_OBJECT_KEY];
        if (completionBlock) {
            completionBlock(YES);
        }
    }]];
    return _alertConfirmLogout;
}

#pragma mark - // INITS AND LOADS //

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

#pragma mark - // DELEGATED METHODS (PQLoginDelegate) //

- (void)requestLoginWithCompletion:(void (^)(id <PQUser>))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS, AKD_UI] message:nil];
    
    [self performSegueWithIdentifier:SEGUE_LOGIN sender:completionBlock];
}

- (void)requestLogoutWithCompletion:(void (^)(BOOL success))completionBlock {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_ACCOUNTS, AKD_UI] message:nil];
    
    self.alertConfirmLogout.info = [NSDictionary dictionaryWithNullableObject:completionBlock forKey:NOTIFICATION_OBJECT_KEY];
    [self presentViewController:self.alertConfirmLogout animated:YES completion:nil];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    [PQCentralDispatch setLoginDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    if ([segue.identifier isEqualToString:SEGUE_LOGIN]) {
        id <PQLoginUI> loginViewController = (id <PQLoginUI>)segue.destinationViewController;
        loginViewController.completionBlock = sender;
    }
}

#pragma mark - // PRIVATE METHODS //

@end
