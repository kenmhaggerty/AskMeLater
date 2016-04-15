//
//  PQResponsesTableViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResponsesTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQDataManager.h"

#import "PQTableViewCell.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResponsesTableViewController ()
@property (nonatomic, strong) NSMutableOrderedSet <id <PQResponse>> *responses;
@property (nonatomic, strong) NSComparisonResult (^sortComparator)(id <PQResponse> response1, id <PQResponse> response2);

// OBSERVERS //

- (void)addObserversToQuestion:(id <PQQuestion>)question;
- (void)removeObserversFromQuestion:(id <PQQuestion>)question;

// RESPONDERS //

- (void)questionTextDidChange:(NSNotification *)notification;
- (void)questionResponsesDidChange:(NSNotification *)notification;
- (void)questionResponseWasAdded:(NSNotification *)notification;
- (void)questionResponseWasRemoved:(NSNotification *)notification;
- (void)questionWillBeRemoved:(NSNotification *)notification;

// OTHER //

+ (NSString *)stringForDate:(NSDate *)date;

@end

@implementation PQResponsesTableViewController

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
    
    self.responses = [NSMutableOrderedSet orderedSetWithSet:(question ? question.responses : [NSSet set])];
    [self.responses sortUsingComparator:self.sortComparator];
    
    [self.tableView reloadData];
}

- (NSComparisonResult (^)(id <PQResponse> response1, id <PQResponse> response2))sortComparator {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_sortComparator) {
        return _sortComparator;
    }
    
    _sortComparator = ^NSComparisonResult(id <PQResponse> response1, id <PQResponse> response2) {
        return [response1.date compare:response2.date];
    };
    return _sortComparator;
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.responses.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.question.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    PQTableViewCell *cell = (PQTableViewCell *)[AKGenerics cellWithReuseIdentifier:@"responseCell" class:[PQTableViewCell class] style:UITableViewCellStyleValue1 tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    id <PQResponse> response = [self.responses objectAtIndex:indexPath.row];
    id <PQUser_PRIVATE> user = (id <PQUser_PRIVATE>)response.user;
    cell.textLabel.text = response.text;
    cell.detailTextLabel.text = [PQResponsesTableViewController stringForDate:response.date];
    cell.subtitleTextLabel.text = [NSString stringWithFormat:@"by %@", user ? (user.username ?: user.email) : @"anonymous"];
    cell.subtitleTextLabel.textColor = response.user ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id <PQResponse> response = [self.responses objectAtIndex:indexPath.row];
        [PQDataManager deleteResponse:response];
        [PQDataManager save];
    }
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidChange:) name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponsesDidChange:) name:PQQuestionResponsesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponseWasAdded:) name:PQQuestionResponseWasAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionResponseWasRemoved:) name:PQQuestionResponseWasRemovedNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWillBeRemoved:) name:PQQuestionWillBeRemovedNotification object:question];
}

- (void)removeObserversFromQuestion:(id <PQQuestion>)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponsesDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponseWasAddedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionResponseWasRemovedNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionWillBeRemovedNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionTextDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self.tableView reloadData];
}

- (void)questionResponsesDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSSet *responses = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSMutableOrderedSet *sortedResponses = [NSMutableOrderedSet orderedSetWithSet:responses];
    [sortedResponses sortUsingComparator:self.sortComparator];
    self.responses = sortedResponses;
    
    [self.tableView reloadData];
}

- (void)questionResponseWasAdded:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse> response = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSUInteger index = [self.responses indexOfObject:response inSortedRange:(NSRange){0, [self.responses count]} options:NSBinarySearchingInsertionIndex usingComparator:self.sortComparator];
    
    [self.responses insertObject:response atIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)questionResponseWasRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    id <PQResponse> response = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.responses indexOfObject:response] inSection:0];
    
    [self.responses removeObject:response];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)questionWillBeRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSString *)stringForDate:(NSDate *)date {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    return [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
}

@end
