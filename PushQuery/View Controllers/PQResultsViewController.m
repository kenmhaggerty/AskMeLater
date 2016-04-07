//
//  PQResultsViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResultsViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQQuestionUIProtocol.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResultsViewController ()

// OBSERVERS //

- (void)addObserversToSurveyUI:(id <PQSurveyUI>)surveyUI;
- (void)removeObserversFromSurveyUI:(id <PQSurveyUI>)surveyUI;

// RESPONDERS //

- (void)didSelectQuestion:(NSNotification *)notification;

@end

@implementation PQResultsViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:survey isEqualToObject:_survey]) {
        return;
    }
    
    _survey = survey;
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(PQSurveyUI)]) {
            ((id <PQSurveyUI>)childViewController).survey = survey;
        }
    }];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(PQSurveyUI)]) {
            id <PQSurveyUI> surveyUIController = (id <PQSurveyUI>)childViewController;
            [self removeObserversFromSurveyUI:surveyUIController];
        }
    }];
}

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(PQSurveyUI)]) {
            id <PQSurveyUI> surveyUIController = (id <PQSurveyUI>)childViewController;
            surveyUIController.survey = self.survey;
            [self addObserversToSurveyUI:surveyUIController];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = self.navigationItem.title;
    self.tabBarController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
    self.tabBarController.navigationItem.hidesBackButton = YES;
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (PQQuestionUI) //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurveyUI:(id<PQSurveyUI>)surveyUI {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectQuestion:) name:PQSurveyUIDidSelectQuestion object:surveyUI];
}

- (void)removeObserversFromSurveyUI:(id<PQSurveyUI>)surveyUI {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyUIDidSelectQuestion object:surveyUI];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)didSelectQuestion:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    id <PQQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(PQQuestionUI)]) {
            ((id <PQQuestionUI>)childViewController).question = question;
        }
    }];
}

@end
