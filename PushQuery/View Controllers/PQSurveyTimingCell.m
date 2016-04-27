//
//  PQSurveyTimingCell.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurveyTimingCell.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSurveyTimingCell ()
@property (nonatomic, strong) IBOutlet UISwitch *repeatSwitch;

// ACTIONS //

- (IBAction)switchDidSwitch:(UISwitch *)sender;

@end

@implementation PQSurveyTimingCell

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

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
    
    return NSStringFromClass([PQSurveyTimingCell class]);
}

- (void)setRepeatSwitch:(BOOL)on animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if (on == self.repeatSwitch.on) {
        return;
    }
    
    [self.repeatSwitch setOn:on animated:animated];
    [self switchDidSwitch:self.repeatSwitch];
}

- (BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.repeatSwitch.on;
}

- (void)setEnabledSwitch:(BOOL)on animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    if (on == self.enabledSwitch.on) {
        return;
    }
    
    [self.enabledSwitch setOn:on animated:animated];
    [self switchDidSwitch:self.enabledSwitch];
}

- (BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.enabledSwitch.on;
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super setup];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.timePicker.minimumDate = [NSDate date];
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)datePickerDidChange:(UIDatePicker *)datePicker {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(timingCellTimeDidChange:)]) {
        [self.delegate timingCellTimeDidChange:self];
    }
}

- (IBAction)switchDidSwitch:(UISwitch *)sender {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if (!self.delegate) {
        return;
    }
    
    if ([sender isEqual:self.repeatSwitch]) {
        [self.delegate timingCellRepeatDidChange:self];
    }
    else if ([sender isEqual:self.enabledSwitch]) {
        [self.delegate timingCellEnabledDidChange:self];
    }
}

@end
