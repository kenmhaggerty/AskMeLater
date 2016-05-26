//
//  PQResultsTableViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResultsTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQQuestionUIProtocol.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - // DEFINITIONS (Private) //

@interface PQResultsTableViewController ()

// OBSERVERS //

- (void)addObserversToSurvey:(id <PQSurvey>)survey;
- (void)removeObserversFromSurvey:(id <PQSurvey>)survey;
- (void)addObserversToQuestion:(id <PQQuestion>)question;
- (void)removeObserversFromQuestion:(id <PQQuestion>)question;

// RESPONDERS //

- (void)surveyQuestionsDidChange:(NSNotification *)notification;
- (void)surveyQuestionsWereAdded:(NSNotification *)notification;
- (void)surveyQuestionsWereReordered:(NSNotification *)notification;
- (void)surveyQuestionsWereRemoved:(NSNotification *)notification;
- (void)surveyWillBeDeleted:(NSNotification *)notification;
- (void)questionWasUpdated:(NSNotification *)notification;

@end

@implementation PQResultsTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id<PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if ([AKGenerics object:survey isEqualToObject:_survey]) {
        return;
    }
    
    if (_survey) {
        for (id <PQQuestion> question in _survey.questions) {
            [self removeObserversFromQuestion:question];
        }
        [self removeObserversFromSurvey:_survey];
    }
    
    _survey = survey;
    
    if (survey) {
        [self addObserversToSurvey:survey];
        for (id <PQQuestion> question in survey.questions) {
            [self addObserversToQuestion:question];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - // INITS AND LOADS //

- (void)viewDidLoad {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, navigationBar.frame.size.width, 1.0f/UIScreen.mainScreen.scale)];
    topBorder.backgroundColor = self.tableView.separatorColor;
    [navigationBar addSubview:topBorder];
    [navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:navigationBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    [navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:navigationBar attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:navigationBar attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    [self.tableView setShowsVerticalScrollIndicator:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 0.0f, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 0.0f, self.tableView.scrollIndicatorInsets.right);
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return (self.survey ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.survey.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    UITableViewCell *cell = [UITableViewCell cellWithReuseIdentifier:@"questionCell" style:UITableViewCellStyleValue1 tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    id <PQQuestion> question = [self.survey.questions objectAtIndex:indexPath.row];
    cell.textLabel.text = question.text ?: @"(blank)";
    cell.textLabel.textColor = question.text ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)question.responses.count, [AKGenerics pluralizationForCount:question.responses.count singular:@"response" plural:@"responses"]];
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.925f alpha:1.0f];
    cell.selectedBackgroundView = backgroundView;
    return cell;
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UITableViewAutomaticDimension;
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    if ([segue.destinationViewController conformsToProtocol:@protocol(PQQuestionUI)]) {
        id <PQQuestion> question = [self.survey.questions objectAtIndex:[self.tableView indexPathForCell:sender].row];
        ((id <PQQuestionUI>)segue.destinationViewController).question = question;
        [AKGenerics postNotificationName:PQSurveyUIDidSelectQuestion object:self userInfo:@{NOTIFICATION_OBJECT_KEY : question}];
    }
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsWereAdded:) name:PQSurveyQuestionsWereAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsWereReordered:) name:PQSurveyQuestionsWereReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsWereRemoved:) name:PQSurveyQuestionsWereRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyWillBeDeleted:) name:PQSurveyWillBeDeletedNotification object:survey];
    
}

- (void)removeObserversFromSurvey:(id<PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsWereAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsWereReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsWereRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyWillBeDeletedNotification object:survey];
}

- (void)addObserversToQuestion:(id<PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWasUpdated:) name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWasUpdated:) name:PQQuestionResponsesCountDidChangeNotification object:question];
}

- (void)removeObserversFromQuestion:(id<PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesCountDidChangeNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyQuestionsDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self.tableView reloadData];
}

- (void)surveyQuestionsWereAdded:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSOrderedSet <id <PQQuestion>> *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSOrderedSet <id <PQQuestion>> *primitiveQuestions = notification.userInfo[NOTIFICATION_OLD_KEY];
    
    NSArray *indexPaths;
    [AKGenerics compareArray:primitiveQuestions.array toArray:questions.array andGenerateIndexPathsToInsert:&indexPaths withSection:0];
    
    id <PQQuestion> question;
    for (NSIndexPath *indexPath in indexPaths) {
        question = questions[indexPath.row];
        [self addObserversToQuestion:question];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyQuestionsWereReordered:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSOrderedSet <id <PQQuestion>> *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSOrderedSet <id <PQQuestion>> *primitiveQuestions = notification.userInfo[NOTIFICATION_OLD_KEY];
    
    NSArray *indexPaths, *newIndexPaths;
    [AKGenerics compareArray:primitiveQuestions.array toArray:questions.array andGenerateIndexPaths:&indexPaths toMoveToIndexPaths:&newIndexPaths withSection:0];
    
    [self.tableView moveRowsAtIndexPaths:indexPaths toIndexPaths:newIndexPaths];
}

- (void)surveyQuestionsWereRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSOrderedSet <id <PQQuestion>> *questions = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSOrderedSet <id <PQQuestion>> *primitiveQuestions = notification.userInfo[NOTIFICATION_OLD_KEY];
    
    NSArray *indexPaths;
    [AKGenerics compareArray:primitiveQuestions.array toArray:questions.array andGenerateIndexPathsToDelete:&indexPaths withSection:0];
    
    id <PQQuestion> question;
    for (NSIndexPath *indexPath in indexPaths) {
        question = primitiveQuestions[indexPath.row];
        [self removeObserversFromQuestion:question];
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    self.survey = nil;
    [self.tableView reloadData];
}

- (void)questionWasUpdated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQQuestion> question = notification.object;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
