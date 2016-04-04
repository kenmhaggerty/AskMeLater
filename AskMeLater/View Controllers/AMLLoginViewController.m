//
//  AMLLoginViewController.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/21/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLLoginViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "UIViewController+Keyboard.h"

#import "AMLPrivateInfo.h"
#import "AMLLoginManager.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const SignIn = @"Sign in";
NSString * const CreateAccount = @"Create account";

NSTimeInterval const AnimationSpeed = 0.18f;

@interface AMLLoginViewController () <UITextFieldDelegate, UIKeyboardDelegate>
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UITextField *textFieldEmail;
@property (nonatomic, strong) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, strong) IBOutlet UITextField *textFieldConfirmPassword;
@property (nonatomic, strong) IBOutlet UIButton *passwordResetButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintShowButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintConfirmPassword;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintPasswordReset;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintBottom;
@property (nonatomic, strong) UIAlertController *alertPasswordReset;
@property (nonatomic, strong) UIAlertController *alertError;
@property (nonatomic, readonly) BOOL isCreatingAccount;

// ACTIONS //

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender;
- (IBAction)passwordReset:(id)sender;
- (IBAction)submit:(UIButton *)sender;

// OBSERVERS //

- (void)addObserversToLoginManager;
- (void)removeObserversFromLoginManager;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;

// DATA //

- (void)signIn;
- (void)createAccount;
- (void)resetPassword;

// OTHER //

- (void)showButton:(BOOL)show;
- (void)showPasswordConfirmation:(BOOL)show animated:(BOOL)animated;
- (void)showPasswordReset:(BOOL)show animated:(BOOL)animated;

@end

@implementation AMLLoginViewController

#pragma mark - // SETTERS AND GETTERS //

- (UIAlertController *)alertPasswordReset {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertPasswordReset) {
        return _alertPasswordReset;
    }
    
    _alertPasswordReset = [UIAlertController alertControllerWithTitle:@"Password Reset Requested" message:@"Please check your email and follow the instructions to reset your password." preferredStyle:UIAlertControllerStyleAlert actionText:nil dismissalText:nil completion:nil];
    return _alertPasswordReset;
}

- (UIAlertController *)alertError {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertError) {
        return _alertError;
    }
    
    _alertError = [UIAlertController alertControllerWithTitle:@"Couldn't Sign In" message:@"We couldn't sign you in. Please try again and contact us if you continue to encounter problems." preferredStyle:UIAlertControllerStyleAlert actionText:nil dismissalText:@"Dismiss" completion:nil];
    return _alertError;
}

- (void)setIsCreatingAccount:(BOOL)isCreatingAccount animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    _isCreatingAccount = isCreatingAccount;
    
    [self showPasswordConfirmation:isCreatingAccount animated:animated];
    [self showPasswordReset:!isCreatingAccount animated:animated];
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

- (void)didReceiveMemoryWarning {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super didReceiveMemoryWarning];
    
    self.alertPasswordReset = nil;
    self.alertError = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    [self.segmentedControl setTitle:SignIn forSegmentAtIndex:0];
    [self.segmentedControl setTitle:CreateAccount forSegmentAtIndex:1];
    self.passwordResetButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
    
    [self showPasswordConfirmation:NO animated:NO];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITextFieldDelegate) //

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    if ([string stringByTrimmingCharactersInSet:[[NSCharacterSet newlineCharacterSet] invertedSet]].length) {
        if ([textField isEqual:self.textFieldEmail]) {
            [self.textFieldPassword becomeFirstResponder];
        }
        else if ([textField isEqual:self.textFieldPassword] && self.isCreatingAccount) {
            [self.textFieldConfirmPassword becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
            if (self.isCreatingAccount) {
                [self createAccount];
            }
            else  {
                [self signIn];
            }
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if ([textField isEqual:self.textFieldEmail]) {
        NSString *email = self.textFieldEmail.text;
        self.passwordResetButton.enabled = [AMLPrivateInfo validEmail:email];
    }
}

#pragma mark - // DELEGATED METHODS (UIKeyboardDelegate) //

- (void)keyboardWillDisappearWithAnimationDuration:(NSTimeInterval)animationDuration {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.constraintBottom.constant = 0.0f;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardFrameWillChangeWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.constraintBottom.constant = frame.size.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    [self addObserversToLoginManager];
    [self addObserversToKeyboard];
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self removeObserversFromKeyboard];
    [self removeObserversFromLoginManager];
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    [self setIsCreatingAccount:!self.isCreatingAccount animated:YES];
    [self showPasswordReset:!self.isCreatingAccount animated:YES];
}

- (IBAction)passwordReset:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    [self resetPassword];
}

- (IBAction)submit:(UIButton *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    [self.view.firstResponder resignFirstResponder];
    
    if (self.isCreatingAccount) {
        [self createAccount];
    }
    else {
        [self signIn];
    }
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToLoginManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange:) name:AMLLoginManagerCurrentUserDidChangeNotification object:nil];
}

- (void)removeObserversFromLoginManager {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMLLoginManagerCurrentUserDidChangeNotification object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    if (notification.userInfo[NOTIFICATION_OBJECT_KEY]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - // PRIVATE METHODS (Data) //

- (void)signIn {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    [AMLLoginManager loginWithEmail:self.textFieldEmail.text password:self.textFieldPassword.text success:^(id <AMLUser_Editable> user) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        self.alertError.message = error.localizedDescription;
        [self presentViewController:self.alertError animated:YES completion:nil];
    }];
}

- (void)createAccount {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    if (![self.textFieldPassword.text isEqualToString:self.textFieldConfirmPassword.text]) {
        self.alertError.message = @"Passwords do not match.";
        [self presentViewController:self.alertError animated:YES completion:nil];
        return;
    }
    
    [AMLLoginManager signUpWithEmail:self.textFieldEmail.text password:self.textFieldPassword.text success:^(id <AMLUser_Editable> user) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        self.alertError.message = error.localizedDescription;
        [self presentViewController:self.alertError animated:YES completion:nil];
    }];
}

- (void)resetPassword {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    NSString *email = self.textFieldEmail.text;
    
    [AMLLoginManager resetPasswordForEmail:email success:^{
        self.alertPasswordReset.message = [NSString stringWithFormat:@"Please check your email at %@ and follow the instructions to reset your password.", email];
        [self presentViewController:self.alertPasswordReset animated:YES completion:nil];
    } failure:^(NSError *error) {
        self.alertError.message = error.localizedDescription;
        [self presentViewController:self.alertError animated:YES completion:nil];
    }];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)enableButton:(BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.submitButton.backgroundColor = (enabled ? [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f] : [UIColor grayColor]);
    self.submitButton.enabled = enabled;
}

- (void)showButton:(BOOL)show {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.constraintShowButton.active = show;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.18f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showPasswordConfirmation:(BOOL)show animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.textFieldPassword.returnKeyType = show ? UIReturnKeyNext : UIReturnKeyGo;
    self.textFieldConfirmPassword.userInteractionEnabled = show;
    [self.submitButton setTitle:(show ? CreateAccount : SignIn) forState:UIControlStateNormal];
    [self.submitButton setTitle:(show ? CreateAccount : SignIn) forState:UIControlStateHighlighted];
    [self.submitButton setTitle:(show ? CreateAccount : SignIn) forState:UIControlStateSelected];
    self.constraintConfirmPassword.active = show;
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:(animated ? AnimationSpeed : 0.0f) animations:^{
        [self.view layoutIfNeeded];
        self.textFieldConfirmPassword.alpha = show ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        if (self.textFieldPassword.isFirstResponder) {
            [UIView setAnimationsEnabled:NO];
            [self.textFieldPassword resignFirstResponder];
            [self.textFieldPassword becomeFirstResponder];
            [UIView setAnimationsEnabled:YES];
        }
        if (!show) {
            self.textFieldConfirmPassword.text = nil;
        }
    }];
}

- (void)showPasswordReset:(BOOL)show animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.constraintPasswordReset.active = show;
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:(animated ? AnimationSpeed : 0.0f) animations:^{
        [self.view layoutIfNeeded];
        self.passwordResetButton.alpha = show ? 1.0f : 0.0f;
    } completion:nil];
}

@end
