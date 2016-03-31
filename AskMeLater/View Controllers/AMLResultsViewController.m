//
//  AMLResultsViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLResultsViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLQuestionUIProtocol.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLResultsViewController ()

// OBSERVERS //

- (void)addObserversToSurveyUI:(id <AMLSurveyUI>)surveyUI;
- (void)removeObserversFromSurveyUI:(id <AMLSurveyUI>)surveyUI;

// RESPONDERS //

- (void)didSelectQuestion:(NSNotification *)notification;

@end

@implementation AMLResultsViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:survey isEqualToObject:_survey]) {
        return;
    }
    
    _survey = survey;
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(AMLSurveyUI)]) {
            ((id <AMLSurveyUI>)childViewController).survey = survey;
        }
    }];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(AMLSurveyUI)]) {
            id <AMLSurveyUI> surveyUIController = (id <AMLSurveyUI>)childViewController;
            [self removeObserversFromSurveyUI:surveyUIController];
        }
    }];
}

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(AMLSurveyUI)]) {
            id <AMLSurveyUI> surveyUIController = (id <AMLSurveyUI>)childViewController;
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
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (AMLQuestionUI) //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurveyUI:(id<AMLSurveyUI>)surveyUI {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectQuestion:) name:AMLSurveyUIDidSelectQuestion object:surveyUI];
}

- (void)removeObserversFromSurveyUI:(id<AMLSurveyUI>)surveyUI {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyUIDidSelectQuestion object:surveyUI];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)didSelectQuestion:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    id <AMLQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(AMLQuestionUI)]) {
            ((id <AMLQuestionUI>)childViewController).question = question;
        }
    }];
}

@end
