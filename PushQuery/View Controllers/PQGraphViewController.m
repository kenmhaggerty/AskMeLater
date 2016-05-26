//
//  PQGraphViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQGraphViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PNChart.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQGraphViewController () <PNChartDelegate>
@property (nonatomic, strong) IBOutlet PNPieChart *chartView;

// OBSERVERS //

- (void)addObserversToQuestion:(id <PQQuestion>)question;
- (void)removeObserversFromQuestion:(id <PQQuestion>)question;

// RESPONDERS //

- (void)questionResponsesDidChange:(NSNotification *)notification;

// OTHER //

- (void)reloadChart;

@end

@implementation PQGraphViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setQuestion:(id<PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:question isEqualToObject:_question]) {
        return;
    }
    
    if (_question) {
        [self removeObserversFromQuestion:_question];
    }
    
    _question = question;
    
    if (question) {
        [self addObserversToQuestion:question];
    }
    
    [self reloadChart];
}

#pragma mark - // INITS AND LOADS //

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self.chartView.delegate = self;
    self.chartView.descriptionTextColor = [UIColor whiteColor];
    self.chartView.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidChange:) name:PQQuestionResponsesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidChange:) name:PQQuestionResponsesWereAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidChange:) name:PQQuestionResponsesWereRemovedNotification object:question];
}

- (void)removeObserversFromQuestion:(id<PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesWereAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesWereRemovedNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionResponsesDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_UI] message:nil];
    
    [self reloadChart];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)reloadChart {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *responses = [NSMutableDictionary dictionary];
        NSNumber *count;
        for (id <PQResponse> response in self.question.responses) {
            count = responses[response.text];
            responses[response.text] = (count ? [NSNumber numberWithInteger:count.integerValue+1] : @1);
        }
        NSMutableArray *chartData = [NSMutableArray arrayWithCapacity:responses.count];
        CGFloat hue, saturation, brightness, alpha;
        [[UIColor iOSBlue] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        float i = 1.0f;
        for (NSString *key in responses.allKeys) {
            [chartData addObject:[PNPieChartDataItem dataItemWithValue:((NSNumber *)responses[key]).integerValue color:[UIColor colorWithHue:hue saturation:saturation*(i++/responses.count) brightness:brightness alpha:alpha] description:key]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chartView updateChartData:chartData];
            [self.chartView strokeChart];
        });
    });
}

@end
