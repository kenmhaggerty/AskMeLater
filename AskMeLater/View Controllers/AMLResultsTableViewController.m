//
//  AMLResultsTableViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLResultsTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "AMLQuestionUIProtocol.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLResultsTableViewController ()

// OBSERVERS //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey;
- (void)removeObserversFromSurvey:(id <AMLSurvey>)survey;
- (void)addObserversToQuestion:(id <AMLQuestion>)question;
- (void)removeObserversFromQuestion:(id <AMLQuestion>)question;

// RESPONDERS //

- (void)surveyQuestionsDidChange:(NSNotification *)notification;
- (void)surveyQuestionWasAdded:(NSNotification *)notification;
- (void)surveyQuestionWasReordered:(NSNotification *)notification;
- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification;
- (void)surveyWillBeDeleted:(NSNotification *)notification;
- (void)questionWasUpdated:(NSNotification *)notification;

@end

@implementation AMLResultsTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id<AMLSurvey>)survey {
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
    
    return (self.survey ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.survey.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    UITableViewCell *cell = [AKGenerics cellWithReuseIdentifier:@"cell" class:[UITableViewCell class] style:UITableViewCellStyleValue1 tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    id <AMLQuestion> question = [self.survey.questions objectAtIndex:indexPath.row];
    cell.textLabel.text = question.text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", question.responses.count, [AKGenerics pluralizationForCount:question.responses.count singular:@"response" plural:@"responses"]];
    return cell;
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

#pragma mark - // OVERWRITTEN METHODS //

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    if ([segue.destinationViewController conformsToProtocol:@protocol(AMLQuestionUI)]) {
        id <AMLQuestion> question = [self.survey.questions objectAtIndex:[self.tableView indexPathForCell:sender].row];
        ((id <AMLQuestionUI>)segue.destinationViewController).question = question;
        [AKGenerics postNotificationName:AMLSurveyUIDidSelectQuestion object:self userInfo:@{NOTIFICATION_OBJECT_KEY : question}];
    }
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:AMLSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasAdded:) name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasReordered:) name:AMLSurveyQuestionWasReorderedNotification object:survey];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWillBeRemoved:) name:AMLSurveyQuestionWillBeRemoved object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionAtIndexWasRemoved:) name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyWillBeDeleted:) name:AMLSurveyWillBeDeletedNotification object:survey];
    
}

- (void)removeObserversFromSurvey:(id<AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasReorderedNotification object:survey];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWillBeRemoved object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyWillBeDeletedNotification object:survey];
}

- (void)addObserversToQuestion:(id<AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWasUpdated:) name:AMLQuestionResponsesCountDidChangeNotification object:question];
}

- (void)removeObserversFromQuestion:(id<AMLQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLQuestionResponsesCountDidChangeNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyQuestionsDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self.tableView reloadData];
}

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

//- (void)surveyQuestionWillBeRemoved:(NSNotification *)notification {
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
//    
//    id <AMLQuestion> question = notification.object;
//    [self removeObserversFromQuestion:question];
//}

- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.object;
    [self removeObserversFromQuestion:question];
    
    NSNumber *index = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    self.survey = nil;
    [self.tableView reloadData];
}

- (void)questionWasUpdated:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <AMLQuestion> question = notification.object;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
