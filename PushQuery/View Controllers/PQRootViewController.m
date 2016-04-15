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

#pragma mark - // DEFINITIONS (Private) //

NSString * const SEGUE_LOGIN = @"segueLogin";

@interface PQRootViewController ()
@end

@implementation PQRootViewController

#pragma mark - // SETTERS AND GETTERS //

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
