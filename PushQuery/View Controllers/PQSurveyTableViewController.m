//
//  PQSurveyTableViewController.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurveyTableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "UIViewController+Keyboard.h"
#import "UITableView+Extras.h"
#import "UIAlertController+Info.h"

#import "PQDataManager.h"

#import "PQSurveyTableViewCell.h"
#import "PQSurveyTimingCell.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const UnnamedSurveyString = @"tap to name survey";

NSString * const AddCellReuseIdentifier = @"addCell";
NSUInteger const QuestionsTableViewSection = 0;
NSUInteger const AddTableViewSection = 1;
NSUInteger const TimingTableViewSection = 2;

@interface PQSurveyTableViewController () <PQSurveyTableViewCellDelegate, PQSurveyTimingCellDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIAlertController *alertRenameSurvey;
@property (nonatomic, strong) UIAlertController *alertEditChoice;
@property (nonatomic) BOOL surveyCanBeEnabled;

// ACTIONS //

- (void)titleWasTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)edit:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)addQuestion:(id)sender;

// OBSERVERS //

- (void)addObserversToSurvey:(id <PQSurvey>)survey;
- (void)removeObserversFromSurvey:(id <PQSurvey>)survey;

// RESPONDERS //

- (void)surveyNameDidChange:(NSNotification *)notification;
- (void)surveyTimeDidChange:(NSNotification *)notification;
- (void)surveyRepeatDidChange:(NSNotification *)notification;
- (void)surveyEnabledDidChange:(NSNotification *)notification;
- (void)surveyQuestionsDidChange:(NSNotification *)notification;
- (void)surveyQuestionWasAdded:(NSNotification *)notification;
- (void)surveyQuestionWasReordered:(NSNotification *)notification;
- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification;
- (void)surveyQuestionsCountDidChange:(NSNotification *)notification;
- (void)surveyWillBeDeleted:(NSNotification *)notification;

// OTHER //

- (void)surveyCanBeEnabled:(BOOL)enable;

@end

@implementation PQSurveyTableViewController

#pragma mark - // SETTERS AND GETTERS //

- (void)setSurvey:(id <PQSurvey>)survey {
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
    
    _alertRenameSurvey = [UIAlertController alertControllerWithTitle:@"Rename Survey:" message:nil preferredStyle:UIAlertControllerStyleAlert actions:@[@"Rename"] preferredAction:@"Rename" dismissalText:@"Cancel" completion:^(UIAlertAction *action) {
        NSString *title = _alertRenameSurvey.textFields[0].text;
        id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
        survey.name = title.length ? title : nil;
        survey.editedAt = [NSDate date];
        [PQDataManager save];
    }];
    [_alertRenameSurvey addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"survey title";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    return _alertRenameSurvey;
}

- (UIAlertController *)alertEditChoice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertEditChoice) {
        return _alertEditChoice;
    }
    
    _alertEditChoice = [UIAlertController alertControllerWithTitle:@"Edit Choice" message:@"Enter your desired choice below. Choices should be kept short in order to be displayed properly:" preferredStyle:UIAlertControllerStyleAlert actions:@[@"Update"] preferredAction:@"Update" dismissalText:@"Cancel" completion:^(UIAlertAction *action) {
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            NSString *text = _alertEditChoice.textFields[0].text;
            id <PQChoice_Editable> choice = (id <PQChoice_Editable>)_alertEditChoice.info[NOTIFICATION_OBJECT_KEY];
            choice.text = (text.length ? text : nil);
            [PQDataManager save];
        }];
        [self.tableView setEditing:NO animated:YES];
        [CATransaction commit];
    }];
    [_alertEditChoice addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"choice";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    return _alertEditChoice;
}

- (void)setSurveyCanBeEnabled:(BOOL)surveyCanBeEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    _surveyCanBeEnabled = surveyCanBeEnabled;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection];
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.enabledLabel.textColor = surveyCanBeEnabled ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.enabledSwitch.userInteractionEnabled = surveyCanBeEnabled;
    if (!surveyCanBeEnabled) {
        [PQDataManager cancelSurvey:self.survey];
    }
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
    
    self.surveyCanBeEnabled = (self.survey && self.survey.questions.count);
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    self.title = self.survey.name;
    self.tabBarController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
    self.tabBarController.navigationItem.hidesBackButton = NO;
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (section == QuestionsTableViewSection) {
        return (self.survey ? self.survey.questions.count : 0);
    }
    
    return (self.tableView.editing ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (indexPath.section == QuestionsTableViewSection) {
        PQSurveyTableViewCell *cell = (PQSurveyTableViewCell *)[AKGenerics cellWithReuseIdentifier:[PQSurveyTableViewCell reuseIdentifier] class:[PQSurveyTableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
        id <PQQuestion> question = [self.survey.questions objectAtIndex:indexPath.row];
        cell.textView.text = question.text;
        cell.delegate = self;
        return cell;
    }
    
    if (indexPath.section == AddTableViewSection) {
        UITableViewCell *cell = [AKGenerics cellWithReuseIdentifier:AddCellReuseIdentifier class:[UITableViewCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        return cell;
    }
    
    if (indexPath.section == TimingTableViewSection) {
        PQSurveyTimingCell *cell = (PQSurveyTimingCell *)[AKGenerics cellWithReuseIdentifier:[PQSurveyTimingCell reuseIdentifier] class:[PQSurveyTimingCell class] style:UITableViewCellStyleDefault tableView:tableView atIndexPath:indexPath fromStoryboard:YES];
        cell.delegate = self;
        if (self.survey.time) {
            cell.timePicker.date = self.survey.time;
        }
        cell.timePicker.userInteractionEnabled = !self.survey.enabled;
        cell.timePicker.alpha = self.survey.enabled ? 0.5f : 1.0f;
        [cell setRepeatSwitch:self.survey.repeat animated:NO];
        cell.enabledLabel.textColor = self.surveyCanBeEnabled ? [UIColor blackColor] : [UIColor lightGrayColor];
        cell.enabledSwitch.userInteractionEnabled = self.surveyCanBeEnabled;
        [cell setEnabledSwitch:self.survey.enabled animated:NO];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        return cell;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    if (indexPath.section == QuestionsTableViewSection) {
        return YES;
    }
    
    return NO;
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
    
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
    [survey moveQuestionAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    [PQDataManager save];
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (section == TimingTableViewSection) {
        return 1.0f/UIScreen.mainScreen.scale;
    }
    
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (section == TimingTableViewSection) {
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 1.0f/UIScreen.mainScreen.scale)];
        border.backgroundColor = tableView.separatorColor;
        return border;
    }
    
    return nil;
}

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
    
    if (indexPath.section == QuestionsTableViewSection) {
        id <PQQuestion_Editable> question = (id <PQQuestion_Editable>)[self.survey.questions objectAtIndex:indexPath.row];
        
        id <PQChoice_Editable> primaryChoice = (id <PQChoice_Editable>)[question.choices objectAtIndex:0];
        UITableViewRowAction *primaryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(primaryChoice.text ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            self.alertEditChoice.textFields[0].text = primaryChoice.text;
            self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : primaryChoice};
            [self presentViewController:self.alertEditChoice animated:YES completion:nil];
        }];
        primaryAction.backgroundColor = [UIColor iOSBlue];
        
        id <PQChoice_Editable> secondaryChoice = (id <PQChoice_Editable>)[question.choices objectAtIndex:1];
        UITableViewRowAction *secondaryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:(secondaryChoice.text ?: @"(blank)") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            self.alertEditChoice.textFields[0].text = secondaryChoice.text;
            self.alertEditChoice.info = @{NOTIFICATION_OBJECT_KEY : secondaryChoice};
            [self presentViewController:self.alertEditChoice animated:YES completion:nil];
        }];
        secondaryAction.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        return @[primaryAction, secondaryAction];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (indexPath.section == QuestionsTableViewSection) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[PQSurveyTableViewCell class]]) {
            PQSurveyTableViewCell *surveyTableViewCell = (PQSurveyTableViewCell *)cell;
            [surveyTableViewCell.textView becomeFirstResponder];
        }
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:AddCellReuseIdentifier]) {
        [self addQuestion:nil];
        return;
    }
}

#pragma mark - // DELEGATED METHODS (PQSurveyTableViewCellDelegate) //

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
    
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
    id <PQQuestion_Editable> question = (id <PQQuestion_Editable>)[survey.questions objectAtIndex:indexPath.row];
    
    UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet actions:nil preferredAction:nil dismissalText:@"Cancel" completion:nil];
    [confirmationAlert addAction:[UIAlertAction actionWithTitle:@"Delete Question" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [PQDataManager deleteQuestion:question];
    }]];
    
    [self presentViewController:confirmationAlert animated:YES completion:nil];
}

- (void)cellDidBeginEditing:(PQSurveyTableViewCell *)sender  {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection]];
    [cell setUserInteractionEnabled:NO];
}

- (void)cellDidEndEditing:(PQSurveyTableViewCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (!indexPath) {
        return;
    }
    
    id <PQQuestion_Editable> question = (id <PQQuestion_Editable>)[self.survey.questions objectAtIndex:indexPath.row];
    NSString *text = sender.textView.text;
    question.text = (text && text.length) ? text : nil;
    [PQDataManager save];
    
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection]];
    [cell setUserInteractionEnabled:YES];
}

#pragma mark - // DELEGATED METHODS (UISurveyTimingCellDelegate) //

- (void)timingCellTimeDidChange:(PQSurveyTimingCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    NSDate *time = sender.timePicker.date;
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
    survey.time = time;
    [PQDataManager save];
}

- (void)timingCellRepeatDidChange:(PQSurveyTimingCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    BOOL repeat = sender.repeat;
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
    survey.repeat = repeat;
    [PQDataManager save];
}

- (void)timingCellEnabledDidChange:(PQSurveyTimingCell *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    BOOL enabled = sender.enabled;
    id <PQSurvey_Editable> survey = (id <PQSurvey_Editable>)self.survey;
    survey.time = sender.timePicker.date;
    survey.enabled = enabled;
    [PQDataManager save];
    
    sender.timePicker.userInteractionEnabled = !enabled;
    sender.timePicker.alpha = enabled ? 0.5f : 1.0f;
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    
    [self.navigationItem addObserver:self forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem)) options:NSKeyValueObservingOptionNew context:NULL];
    
    [self addObserversToKeyboard];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self removeObserversFromKeyboard];
    
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
    
    label.text = title ?: UnnamedSurveyString;
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
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [self tableView:self.tableView numberOfRowsInSection:AddTableViewSection]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:AddTableViewSection]];
    }
    for (int i = 0; i < [self tableView:self.tableView numberOfRowsInSection:TimingTableViewSection]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:TimingTableViewSection]];
    }
    
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
    }
    [self.tableView setEditing:YES animated:YES];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tabBarController.navigationItem.rightBarButtonItem = self.doneButton;
}

- (IBAction)doneEditing:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    [self.tableView setEditing:NO animated:YES];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [self tableView:self.tableView numberOfRowsInSection:AddTableViewSection]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:AddTableViewSection]];
    }
    for (int i = 0; i < [self tableView:self.tableView numberOfRowsInSection:TimingTableViewSection]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:TimingTableViewSection]];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tabBarController.navigationItem.rightBarButtonItem = self.editButton;
}

- (IBAction)addQuestion:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    id <PQQuestion_Editable> question = [PQDataManager questionForSurvey:(id <PQSurvey_Editable>)self.survey];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:AddTableViewSection];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:QuestionsTableViewSection];
    PQSurveyTableViewCell *cell = (PQSurveyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textView becomeFirstResponder];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyNameDidChange:) name:PQSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyTimeDidChange:) name:PQSurveyTimeDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyRepeatDidChange:) name:PQSurveyRepeatDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyEnabledDidChange:) name:PQSurveyEnabledDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsDidChange:) name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasAdded:) name:PQSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionWasReordered:) name:PQSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionAtIndexWasRemoved:) name:PQSurveyQuestionAtIndexWasRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyQuestionsCountDidChange:) name:PQSurveyQuestionsCountDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyWillBeDeleted:) name:PQSurveyWillBeDeletedNotification object:survey];
}

- (void)removeObserversFromSurvey:(id <PQSurvey>)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyNameDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyTimeDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyRepeatDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyEnabledDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionWasAddedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionWasReorderedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionAtIndexWasRemovedNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyQuestionsCountDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyWillBeDeletedNotification object:survey];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyNameDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    self.title = self.survey.name;
}

- (void)surveyTimeDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    NSDate *time = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    if (!time) {
        return;
    }
    
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection]];
    [cell.timePicker setDate:time animated:YES];
}

- (void)surveyRepeatDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    BOOL repeat = ((NSNumber *)notification.userInfo[NOTIFICATION_OBJECT_KEY]).boolValue;
    
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection]];
    [cell setRepeatSwitch:repeat animated:YES];
}

- (void)surveyEnabledDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    BOOL enabled = ((NSNumber *)notification.userInfo[NOTIFICATION_OBJECT_KEY]).boolValue;
    
    PQSurveyTimingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TimingTableViewSection]];
    [cell setEnabledSwitch:enabled animated:YES];
}

- (void)surveyQuestionsDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    [self.tableView reloadData];
}

- (void)surveyQuestionWasAdded:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    id <PQQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:QuestionsTableViewSection];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyQuestionWasReordered:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    id <PQQuestion> question = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.survey.questions indexOfObject:question] inSection:QuestionsTableViewSection];
    NSNumber *oldIndex = notification.userInfo[NOTIFICATION_SECONDARY_KEY];
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:oldIndex.integerValue inSection:QuestionsTableViewSection];
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:indexPath];
}

- (void)surveyQuestionAtIndexWasRemoved:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    NSNumber *index = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:QuestionsTableViewSection];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)surveyQuestionsCountDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_UI] message:nil];
    
    BOOL enable = self.survey.questions.count;
    
    self.surveyCanBeEnabled = enable;
}

- (void)surveyWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_DATA, AKD_UI] message:nil];
    
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

@end
