//
//  AMLGraphViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLGraphViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "JBLineChartView.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLGraphViewController () <JBLineChartViewDataSource, JBLineChartViewDelegate>
@property (nonatomic, strong) IBOutlet JBLineChartView *chartView;
@end

@implementation AMLGraphViewController

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self.chartView.dataSource = self;
    self.chartView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
    
    [self.chartView reloadDataAnimated:animated];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (JBLineChartViewDataSource) //

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.survey.questions.count;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    id <AMLQuestion> question = [self.survey.questions objectAtIndex:lineIndex];
    
    return question.responses.count;
}

#pragma mark - // DELEGATED METHODS (JBLineChartViewDelegate) //

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
//    id <AMLQuestion> question = [self.survey.questions objectAtIndex:lineIndex];
    
    return horizontalIndex;
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
