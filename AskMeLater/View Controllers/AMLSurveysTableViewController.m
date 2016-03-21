//
//  AMLSurveysTableViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurveysTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLMockSurvey.h" // temp

#import "AMLSurveyUIProtocol.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const REUSE_IDENTIFIER = @"surveyCell";
NSString * const SEGUE_SURVEY = @"segueSurvey";

@interface AMLSurveysTableViewController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) NSMutableArray <AMLMockSurvey *> *surveys;

// ACTIONS //

- (IBAction)newSurvey:(id)sender;

// OTHER //

+ (NSString *)stringForDate:(NSDate *)date;

@end

@implementation AMLSurveysTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurveys:(NSMutableArray <AMLMockSurvey *> *)surveys {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:surveys isEqualToObject:_surveys]) {
        return;
    }
    
    _surveys = surveys;
    
    [self.tableView reloadData];
}

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self  = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.surveys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    UITableViewCell *cell = [AKGenerics cellWithReuseIdentifier:REUSE_IDENTIFIER class:[UITableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    AMLMockSurvey *survey = self.surveys[indexPath.row];
    cell.textLabel.text = survey.name;
    cell.detailTextLabel.text = [AMLSurveysTableViewController stringForDate:survey.createdAt];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.surveys removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    id survey = self.surveys[indexPath.row];
    [self performSegueWithIdentifier:SEGUE_SURVEY sender:survey];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    _surveys = [NSMutableArray array];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    UIViewController *destinationViewController = segue.destinationViewController;
    BOOL success = NO;
    do {
        if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
            destinationViewController = ((UINavigationController *)destinationViewController).topViewController;
        }
        else if ([destinationViewController isKindOfClass:[UITabBarController class]]) {
            destinationViewController = ((UITabBarController *)destinationViewController).viewControllers[0];
        }
        else {
            success = YES;
        }
    } while (!success);
    
    if ([destinationViewController conformsToProtocol:@protocol(AMLSurveyUI)]) {
        UIViewController <AMLSurveyUI> *surveyViewController = (UIViewController <AMLSurveyUI> *)destinationViewController;
        if ([sender isKindOfClass:[AMLMockSurvey class]]) {
            surveyViewController.survey = (AMLMockSurvey *)sender;
        }
    }
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)newSurvey:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
//    id <AMLSurvey> survey = [AMLDataManager survey];
    AMLMockSurvey *survey = [[AMLMockSurvey alloc] init];
    [self.surveys insertObject:survey atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [CATransaction begin];
    [self.tableView beginUpdates];
    [CATransaction setCompletionBlock:^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [CATransaction commit];
//    [self performSegueWithIdentifier:SEGUE_SURVEY sender:survey];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSString *)stringForDate:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    return [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
}

@end
