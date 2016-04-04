//
//  AMLSurveyTimingCell.h
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

@class AMLSurveyTimingCell;

@protocol AMLSurveyTimingCellDelegate <NSObject>
@optional
- (void)timingCellTimeDidChange:(AMLSurveyTimingCell *)sender;
- (void)timingCellRepeatDidChange:(AMLSurveyTimingCell *)sender;
- (void)timingCellEnabledDidChange:(AMLSurveyTimingCell *)sender;
@end

#pragma mark - // DEFINITIONS (Public) //

@interface AMLSurveyTimingCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, strong) id <AMLSurveyTimingCellDelegate> delegate;
+ (NSString *)reuseIdentifier;
- (void)setRepeatSwitch:(BOOL)on animated:(BOOL)animated;
- (BOOL)repeat;
- (void)setEnabledSwitch:(BOOL)on animated:(BOOL)animated;
- (BOOL)enabled;
@end
