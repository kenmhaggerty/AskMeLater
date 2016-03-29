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

@interface AMLResultsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *graphView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

// OBSERVERS //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey;
- (void)removeObserversFromSurvey:(id <AMLSurvey>)survey;
- (void)addObserversToQuestion:(id <AMLQuestion>)question;
- (void)removeObserversFromQuestion:(id <AMLQuestion>)question;

// RESPONDERS //

- (void)surveyQuestionWasAdded:(NSNotification *)notification;
- (void)surveyQuestionWasReordered:(NSNotification *)notification;
- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification;

- (void)questionWasUpdated:(NSNotification *)notification;

@end

@implementation AMLResultsViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:survey isEqualToObject:_survey]) {
        return;
    }
    
    if (_survey) {
        for (id <AMLQuestion> question in _survey.questions) {
            [self removeObserversFromQuestion:question];
        }
        [self removeObserversFromSurvey:_survey];
    }
    
    _survey = survey;
    
    if (survey) {
        [self addObserversToSurvey:survey];
        for (id <AMLQuestion> question in survey.questions) {
            [self addObserversToQuestion:question];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.graphView.frame.size.height, self.tableView.contentInset.left, self.tabBarController.tabBar.frame.size.height, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.graphView.frame.size.height, self.tableView.scrollIndicatorInsets.left, self.tabBarController.tabBar.frame.size.height, self.tableView.scrollIndicatorInsets.right);
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = self.navigationItem.title;
    self.tabBarController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
}

- (void)viewDidAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
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
    
    return self.survey.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    UITableViewCell *cell = [AKGenerics cellWithReuseIdentifier:@"cell" class:[UITableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    id <AMLQuestion> question = [self.survey.questions objectAtIndex:indexPath.row];
    cell.textLabel.text = question.text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", question.responses.count, [AKGenerics pluralizationForCount:question.responses.count singular:@"response" plural:@"responses"]];
    return cell;
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

#pragma mark - // OVERWRITTEN METHODS //

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    for (id <AMLQuestion> question in self.survey.questions) {
        [self removeObserversFromQuestion:question];
    }
    [self removeObserversFromSurvey:self.survey];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasAdded:) name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasReordered:) name:AMLSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWillBeRemoved:) name:AMLSurveyQuestionWillBeRemoved object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionAtIndexWasRemoved:) name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
}

- (void)removeObserversFromSurvey:(id<AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWillBeRemoved object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
}

- (void)addObserversToQuestion:(id<AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWasUpdated:) name:AMLQuestionResponsesCountDidChange object:question];
}

- (void)removeObserversFromQuestion:(id<AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLQuestionResponsesCountDidChange object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyQuestionWasAdded:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    [self addObserversToQuestion:question];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyQuestionWasReordered:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    NSNumber *oldIndex = notification.userInfo[NOTIFICATION_SECONDARY_KEY];
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:oldIndex.integerValue inSection:0];
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:indexPath];
}

- (void)surveyQuestionWillBeRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.object;
    [self removeObserversFromQuestion:question];
}

- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSNumber *index = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)questionWasUpdated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.object;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
