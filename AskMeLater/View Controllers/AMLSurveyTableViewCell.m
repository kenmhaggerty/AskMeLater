//
//  AMLSurveyTableViewCell.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurveyTableViewCell.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

NSTimeInterval const AMLSurveyTableViewCellAnimationDuration = 0.15f;

@interface AMLSurveyTableViewCell () <UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraightMinimumHeight;

// ACTIONS //

- (IBAction)delete:(id)sender;

// OTHER //

- (void)didChangeHeight;

@end

@implementation AMLSurveyTableViewCell

#pragma mark - // SETTERS AND GETTERS //

- (void)setMinimumHeight:(CGFloat)minimumHeight {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if (minimumHeight == self.constraightMinimumHeight.constant) {
        return;
    }
    
    self.constraightMinimumHeight.constant = minimumHeight;
    [self didChangeHeight];
}

- (CGFloat)minimumHeight {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.constraightMinimumHeight.constant;
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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

#pragma mark - // PUBLIC METHODS //

+ (NSString *)reuseIdentifier {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return NSStringFromClass([AMLSurveyTableViewCell class]);
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (UITextViewDelegate) //

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    self.deleteButton.enabled = NO;
    [UIView animateWithDuration:AMLSurveyTableViewCellAnimationDuration animations:^{
        self.deleteButton.alpha = 0.0f;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidBeginEditing:)]) {
        [self.delegate cellDidBeginEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator tags:@[AKD_UI] message:nil];
    
    if ([text stringByTrimmingCharactersInSet:[[NSCharacterSet newlineCharacterSet] invertedSet]].length) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellWillChangeText:)]) {
        [self.delegate cellWillChangeText:self];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidChangeText:)]) {
        [self.delegate cellDidChangeText:self];
    }
    [self didChangeHeight];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    [UIView animateWithDuration:AMLSurveyTableViewCellAnimationDuration animations:^{
        self.deleteButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.deleteButton.enabled = YES;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidEndEditing:)]) {
        [self.delegate cellDidEndEditing:self];
    }
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textView.delegate = self;
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)delete:(id)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (self.delegate) {
        [self.delegate cellShouldBeDeleted:self];
    }
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)didChangeHeight {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI] message:nil];
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
    if (self.delegate) {
        [self.delegate cellDidChangeHeight:self];
    }
}

@end
