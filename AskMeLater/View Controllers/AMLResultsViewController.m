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

#pragma mark - // DEFINITIONS (Private) //

@interface AMLResultsViewController ()
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

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

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    [self performBlockOnChildViewControllers:^(UIViewController *childViewController) {
        if ([childViewController conformsToProtocol:@protocol(AMLSurveyUI)]) {
            ((id <AMLSurveyUI>)childViewController).survey = self.survey;
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

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
