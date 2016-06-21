//
//  PQLoadingViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQLoadingViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQCentralDispatch.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const SEGUE_COMPLETE = @"segueComplete";
NSTimeInterval const SEGUE_DELAY = 1.5f;

@interface PQLoadingViewController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@end

@interface PQLoadingViewController ()

// OBSERVERS //

- (void)addObserversToCentralDispatch;
- (void)removeObserversFromCentralDispatch;

// RESPONDERS //

- (void)centralDispatchUpdatesProgressDidChange:(NSNotification *)notification;
- (void)centralDispatchUpdatesDidFinish:(NSNotification *)notification;

@end

@implementation PQLoadingViewController

#pragma mark - // SETTERS AND GETTERS //

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

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    self.iconView.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.progressView.hidden = YES;
    self.descriptionLabel.text = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    if ([PQCentralDispatch requiresUpdates]) {
        self.settingsBarButtonItem.enabled = NO;
        [self.activityIndicator startAnimating];
        self.descriptionLabel.text = @"Updating...";
        
        [PQCentralDispatch startUpdates];
    }
    else {
        [self performSegueWithIdentifier:SEGUE_COMPLETE sender:self];
    }
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    [self addObserversToCentralDispatch];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self removeObserversFromCentralDispatch];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCentralDispatch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralDispatchUpdatesProgressDidChange:) name:PQCentralDispatchUpdatesProgressDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralDispatchUpdatesDidFinish:) name:PQCentralDispatchUpdatesDidFinish object:nil];
}

- (void)removeObserversFromCentralDispatch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQCentralDispatchUpdatesProgressDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQCentralDispatchUpdatesDidFinish object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)centralDispatchUpdatesProgressDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSNumber *progressValue = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    float progress = progressValue ? progressValue.floatValue : 0.0f;
    BOOL animated = (progress > 0);
    
    self.progressView.hidden = animated;
    [self.progressView setProgress:progress animated:animated];
}

- (void)centralDispatchUpdatesDidFinish:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSError *error = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.progressView.hidden = YES;
    self.descriptionLabel.text = nil;
    [self.activityIndicator stopAnimating];
    
    if (error) {
        [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    }
    
    self.descriptionLabel.text = error ? @"Update Failed\n\nIf you continue to encounter this error, please email us at pushquerysupport@gmail.com." : @"Update Complete";
    self.iconView.image = error ? [UIImage imageNamed:@"x"] : [UIImage imageNamed:@"checkmark"];
    self.iconView.hidden = NO;
    
    if (error) {
        
        NSString *title = [NSString stringWithFormat:@"Error %li", (long)error.code];
        NSString *message = error.localizedDescription;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert actions:nil preferredAction:nil dismissalText:nil completion:nil];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SEGUE_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:SEGUE_COMPLETE sender:self];
    });
}

@end
