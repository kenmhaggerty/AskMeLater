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

#import "PNChart.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLGraphViewController () <PNChartDelegate>
@property (nonatomic, strong) IBOutlet PNPieChart *chartView;
- (void)reloadChart;
@end

@implementation AMLGraphViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setQuestion:(id<AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:question isEqualToObject:_question]) {
        return;
    }
    
    _question = question;
    
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

#pragma mark - // PRIVATE METHODS //

- (void)reloadChart {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *responses = [NSMutableDictionary dictionary];
        NSNumber *count;
        for (id <AMLResponse> response in self.question.responses) {
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
