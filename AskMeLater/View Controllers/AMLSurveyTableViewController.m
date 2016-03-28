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

#import "AMLSurveyTableViewCell.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const AddCellReuseIdentifier = @"addCell";

@interface AMLSurveyTableViewController () <AMLSurveyTableViewCellDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIAlertController *alertRenameSurvey;
@property (nonatomic, strong) UIAlertController *alertEditChoice;

// ACTIONS //

- (void)titleWasTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)edit:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)addQuestion:(id)sender;

// OBSERVERS //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey;
- (void)removeObserversFromSurvey:(id <AMLSurvey>)survey;

// RESPONDERS //

- (void)surveyNameDidChange:(NSNotification *)notification;
- (void)surveyQuestionsDidChange:(NSNotification *)notification;
- (void)surveyQuestionWasAdded:(NSNotification *)notification;
- (void)surveyQuestionWasReordered:(NSNotification *)notification;
- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification;
- (void)surveyWillBeDeleted:(NSNotification *)notification;

@end

@implementation AMLSurveyTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:survey isEqualToObject:_survey]) {
        return;
    }
    
    if (_survey) {
        [self removeObserversFromSurvey:_survey];
    }
    
    _survey = survey;
    
    if (survey) {
        [self addObserversToSurvey:survey];
    }
    
    self.title = survey.name;
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
        id <AMLSurvey_Editable> survey = (id <AMLSurvey_Editable>)self.survey;
        survey.name = title.length ? title : nil;
        survey.editedAt = [NSDate date];
        [AMLDataManager save];
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
            id <AMLChoice_Editable> choice = (id <AMLChoice_Editable>)_alertEditChoice.info[NOTIFICATION_OBJECT_KEY];
            choice.text = (text.length ? text : nil);
        }];
        [self.tableView setEditing:NO animated:YES];
        [CATransaction commit];
    }]];
    
    return _alertEditChoice;
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

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
    
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.tabBarController.tabBar.frame.size.height, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, self.tabBarController.tabBar.frame.size.height, self.tableView.scrollIndicatorInsets.right);
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    self.title = self.survey.name;
    self.tabBarController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (self.tableView.editing) {
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (section) {
        return 1;
    }
    
    return (self.survey ? self.survey.questions.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (indexPath.section) {
        UITableViewCell *cell;
        cell = [AKGenerics cellWithReuseIdentifier:AddCellReuseIdentifier class:[UITableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        return cell;
    }
    
    AMLSurveyTableViewCell *cell = (AMLSurveyTableViewCell *)[AKGenerics cellWithReuseIdentifier:[AMLSurveyTableViewCell reuseIdentifier] class:[AMLSurveyTableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
    id <AMLQuestion> question = [self.survey.questions objectAtIndex:indexPath.row];
    cell.textView.text = question.text;
    cell.delegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    if (indexPath.section) {
        return NO;
    }
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if (tableView.editing) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    //
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    id <AMLSurvey_Editable> survey = (id <AMLSurvey_Editable>)self.survey;
    [survey moveQuestionAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    [AMLDataManager save];
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
    
    id <AMLQuestion_Editable> question = (id <AMLQuestion_Editable>)[self.survey.questions objectAtIndex:indexPath.row];
    
    id <AMLChoice_Editable> primaryChoice = (id <AMLChoice_Editable>)[question.choices objectAtIndex:0];
    UITableViewRowAction *primaryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(primaryChoice.text ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.alertEditChoice.textFields[0].text = primaryChoice.text;
        self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : primaryChoice};
        [self presentViewController:self.alertEditChoice animated:YES completion:nil];
    }];
    primaryAction.backgroundColor = self.view.tintColor;
    
    id <AMLChoice_Editable> secondaryChoice = (id <AMLChoice_Editable>)[question.choices objectAtIndex:1];
    UITableViewRowAction *secondaryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(secondaryChoice.text ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.alertEditChoice.textFields[0].text = secondaryChoice.text;
        self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : secondaryChoice};
        [self presentViewController:self.alertEditChoice animated:YES completion:nil];
    }];
    secondaryAction.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    
    return @[primaryAction, secondaryAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (indexPath.section) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self addQuestion:nil];
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[AMLSurveyTableViewCell class]]) {
        AMLSurveyTableViewCell *surveyTableViewCell = (AMLSurveyTableViewCell *)cell;
        [surveyTableViewCell.textView becomeFirstResponder];
    }
}

#pragma mark - // DELEGATED METHODS (AMLSurveyTableViewCellDelegate) //

- (void)cellDidChangeHeight:(UITableViewCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    [self.tableView refresh];
}

- (void)cellShouldBeDeleted:(UITableViewCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (!indexPath) {
        return;
    }
    
    id <AMLSurvey_Editable> survey = (id <AMLSurvey_Editable>)self.survey;
    id <AMLQuestion_Editable> question = (id <AMLQuestion_Editable>)[survey.questions objectAtIndex:indexPath.row];
    [AMLDataManager deleteQuestion:question];
}

- (void)cellDidChangeText:(AMLSurveyTableViewCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (!indexPath) {
        return;
    }
    
    id <AMLQuestion_Editable> question = (id <AMLQuestion_Editable>)[self.survey.questions objectAtIndex:indexPath.row];
    question.text = sender.textView.text;
    [AMLDataManager save];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    
    [self.navigationItem addObserver:self forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem)) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self.navigationItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem)) context:NULL];
    
    [super teardown];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if ([object isEqual:self.navigationItem]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
            self.tabBarController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        }
    }
}

- (void)setTitle:(NSString *)title {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [super setTitle:title];
    
    self.tabBarItem.title = @"Survey";
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:17.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleWasTapped:)]];
    
    label.text = title ?: AMLSurveyNamePlaceholder;
    label.textColor = title ? [UIColor blackColor] : [UIColor lightGrayColor];
    [label sizeToFit];
    
    self.tabBarController.navigationItem.titleView = label;
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (void)titleWasTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    self.alertRenameSurvey.textFields[0].text = self.survey.name;
    [self presentViewController:self.alertRenameSurvey animated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
    }
    [self.tableView setEditing:YES animated:YES];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    self.tabBarController.navigationItem.rightBarButtonItem = self.doneButton;
}

- (IBAction)doneEditing:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    [self.tableView setEditing:NO animated:YES];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    self.tabBarController.navigationItem.rightBarButtonItem = self.editButton;
}

- (IBAction)addQuestion:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    id <AMLQuestion_Editable> question = [AMLDataManager questionForSurvey:(id <AMLSurvey_Editable>)self.survey];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidChange:) name:AMLSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:AMLSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasAdded:) name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasReordered:) name:AMLSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionAtIndexWasRemoved:) name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
}

- (void)removeObserversFromSurvey:(id <AMLSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLSurveyQuestionAtIndexWasRemovedNotification object:survey];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyNameDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    self.title = self.survey.name;
}

- (void)surveyQuestionsDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    [self.tableView reloadData];
}

- (void)surveyQuestionWasAdded:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    id <AMLQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyQuestionWasReordered:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    id <AMLQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:0];
    NSNumber *oldIndex = notification.userInfo[NOTIFICATION_SECONDARY_KEY];
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:oldIndex.integerValue inSection:0];
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:indexPath];
}

- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    NSNumber *index = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
