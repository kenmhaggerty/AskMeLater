//
//  AMLSurveyTableViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurveyTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "UITableView+Extras.h"
#import "UIAlertController+Info.h"

#import "AMLDataManager.h"
#import "AMLMockQuestion.h" // temp

#import "AMLSurveyTableViewCell.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const UnnamedSurveyTitle = @"(unnamed survey)";

NSString * const AddCellReuseIdentifier = @"addCell";

@interface AMLSurveyTableViewController () <AMLSurveyTableViewCellDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray <AMLMockQuestion *> *questions;
@property (nonatomic, strong) UIAlertController *alertRenameSurvey;
@property (nonatomic, strong) UIAlertController *alertEditChoice;

// ACTIONS //

- (void)titleWasTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)edit:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)addQuestion:(id)sender;

@end

@implementation AMLSurveyTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setQuestions:(NSMutableArray <AMLMockQuestion *> *)questions {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:questions isEqualToObject:_questions]) {
        return;
    }
    
    _questions = questions;
    
    [self.tableView reloadData];
}

- (UIAlertController *)alertRenameSurvey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertRenameSurvey) {
        return _alertRenameSurvey;
    }
    
    _alertRenameSurvey = [UIAlertController alertControllerWithTitle:@"Rename Survey:" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [_alertRenameSurvey addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"survey title";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [_alertRenameSurvey addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [_alertRenameSurvey addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *title = _alertRenameSurvey.textFields[0].text;
        self.survey.name = title.length ? title : nil;
    }]];
    
    return _alertRenameSurvey;
}

- (UIAlertController *)alertEditChoice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertEditChoice) {
        return _alertEditChoice;
    }
    
    _alertEditChoice = [UIAlertController alertControllerWithTitle:@"Edit Choice" message:@"Enter your desired choice below. Choices should be kept short in order to be displayed properly:" preferredStyle:UIAlertControllerStyleAlert];
    [_alertEditChoice addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"choice";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [_alertEditChoice addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [_alertEditChoice addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            NSString *text = _alertEditChoice.textFields[0].text;
            AMLMockQuestion *question = (AMLMockQuestion *)_alertEditChoice.info[NOTIFICATION_OBJECT_KEY];
            [question performSelector:[_alertEditChoice.info[NOTIFICATION_SECONDARY_KEY] pointerValue] withObject:(text.length ? text : nil)];
        }];
        [self.tableView setEditing:NO animated:YES];
        [CATransaction commit];
    }]];
    
    return _alertEditChoice;
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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = self.navigationItem.title;
    self.tabBarController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
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
    
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    
    AMLSurveyTableViewCell *cell = (AMLSurveyTableViewCell *)[AKGenerics cellWithReuseIdentifier:[AMLSurveyTableViewCell reuseIdentifier] class:[AMLSurveyTableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    cell.delegate = self;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    // reorder
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UITableViewAutomaticDimension;
}

- (NSArray <UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (indexPath.section) {
        return nil;
    }
    
    AMLMockQuestion *question = self.questions[indexPath.row];
    UITableViewRowAction *leftAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(question.leftChoice ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.alertEditChoice.textFields[0].text = question.leftChoice;
        self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : question, NOTIFICATION_SECONDARY_KEY : [NSValue valueWithPointer:@selector(setLeftChoice:)]};
        [self presentViewController:self.alertEditChoice animated:YES completion:nil];
    }];
    leftAction.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    UITableViewRowAction *rightAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(question.rightChoice ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.alertEditChoice.textFields[0].text = question.rightChoice;
        self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : question, NOTIFICATION_SECONDARY_KEY : [NSValue valueWithPointer:@selector(setRightChoice:)]};
        [self presentViewController:self.alertEditChoice animated:YES completion:nil];
    }];
    rightAction.backgroundColor = self.view.tintColor;
    return @[rightAction, leftAction];
}

#pragma mark - // DELEGATED METHODS (AMLSurveyTableViewCellDelegate) //

- (void)cellDidChangeHeight:(UITableViewCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    [self.tableView refresh];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    _questions = [NSMutableArray array];
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (void)titleWasTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    self.alertRenameSurvey.textFields[0].text = self.survey.name;
    [self presentViewController:self.alertRenameSurvey animated:YES completion:nil];
}


- (IBAction)addQuestion:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
//    id <AMLQuestion> question = [AMLDataManager questionForSurvey:self.survey];
    AMLMockQuestion *question = [[AMLMockQuestion alloc] init];
    [self.questions addObject:question];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.questions.count-1 inSection:0];
    [CATransaction begin];
    [self.tableView beginUpdates];
    [CATransaction setCompletionBlock:^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [CATransaction commit];
}

@end
